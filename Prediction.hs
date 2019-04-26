{-#LANGUAGE NoMonomorphismRestriction#-}
module Prediction where

import Types
import Foretold
import Estimate
import Data.Foldable (foldl')
import Constants
import Data.List
import Primes

import Debug.Trace (traceShow, trace)

simplePredict' game iAm enemy dt
    | isBug = trace (show ballNow ++ show dt) undefined
    | otherwise = ball' where
        ball'      = Ball l' v'
        Ball l v   = move dt ballNow
        Ball l' v' = collideWithArena (Ball l v)
        --debugPrint = show (location ballNow) ++ " " ++ show l
        ballNow = ball$game
        isBug = isNumber ballNow && not (isNumber ball')

{-# NOINLINE [1] iterate' #-}
iterate' :: (a -> a) -> a -> [a]
iterate' f x =
    let x' = f x
    in x' `seq` (x : iterate' f x')

predict :: Double -> Double -> (Double -> a -> a) -> a -> a
predict dt time simplePredict p = --traceShow (possAct . getMe $ iAm)
    snd . head . dropWhile ((<time) . fst) $
    iterate' predictIterate (0,p) where 
        predictIterate (t, prediction) = (t+dt, simplePredict dt prediction)

minVelGrid1d = [-1000.0,0,1000.0]
minJumpGrid = [0.0,30.0]
jumpGrid = [0.0,15.0,30.0]
gridZ grid act =  actSetZ act <$> grid
gridJ grid act =  actSetJ act <$> grid

minGrid :: Bot -> [Action Double]
minGrid bot | not $ (isTouch . botTouch) bot = [zero]
            | otherwise = do
    xa <- actFromX <$> minVelGrid1d
    za <- gridZ minVelGrid1d xa 
    gridJ minJumpGrid za

testGrid :: Ball -> Bot -> [Action Double]
testGrid q w = [Action (Vec3 0 0 (-1000)) 0, Action (Vec3 0 0 (-1000)) 30,
                Action (Vec3 0 0 (1000))  0, Action (Vec3 0 0 (1000) ) 30]

minGrid' :: Ball -> Bot -> [Action Double]
minGrid' ball bot | False && (not $ (isTouch . botTouch) bot) = [zero]
                  | otherwise = goTo bot ball : (goTo bot ball) {jS=30.0} : do
    xa <- actFromX <$> minVelGrid1d
    za <- gridZ minVelGrid1d xa 
    gridJ (jumpGrid' ball bot) za

jumpGrid' ball bot | distance ball bot < 70 && z (location bot) < z (location ball) = minJumpGrid
                   | otherwise             = [0.0]

gridBots grid ball bot = (\x -> bot {possAct=x}) <$> grid ball bot

minGridMove gb0 gb1 = Move <$> gb0 <*> gb1

estimatePrd (Prediction game i e) = estimate game i e

deepEstimate :: Game -> IPlayer -> EnemyPlayer -> Action Double -> Move Double -> (Double, Prediction)
deepEstimate game iAm enemy eAc move = stepForesight game iAm enemy eAc move

stepForesight game iAm enemy eAc move@(Move act0 act1) = (estimatePrd p, p) where
    p = predict (1/60) (3/60) simplePredict (Prediction game iAm' enemy') 
    iAm'   = moveToIAm move iAm
    enemy' = setEnemyAct eAc enemy 

deepEstimate' :: Game -> IPlayer -> EnemyPlayer -> Action Double -> Move Double -> (Double, Move Double)
deepEstimate' game iAm enemy eAc move = (fst $ deepEstimate game iAm enemy eAc move, move)

--getBestMove :: Game -> IPlayer -> EnemyPlayer -> Action Double -> Move Double
--getBestMove game iAm enemy enemyAct = snd $ foldl' maxF (-100000, zero) $ 
--    deepEstimate' game iAm enemy enemyAct <$> minGridMove (minGrid (getMe iAm)) (minGrid (getMate iAm)) where
--        maxF (est, a) (est', a') | est > est' = (est,a)
--                                 | otherwise  = (est',a')

goalExactness = 0
goalUL = Vec3 x y z where
    x = (goalWidth/2-ballRadius-goalExactness)
    y = (goalHeight-ballRadius-goalExactness)
    z = arenaWidth/2

goalUR = Vec3 x y z where
    x = (-goalWidth/2+ballRadius+goalExactness)
    y = (goalHeight-ballRadius-goalExactness)
    z = arenaWidth/2

goalCenter = Vec3 x y z where
    x = 0
    y = (goalHeight)
    z = arenaWidth/2

freeKick game executor goal time
    | isReadyForKick = (goTo executor (ball$game)) {jS=30.0}
    | otherwise      = goTo executor (ball$game)
        where
            isReadyForKick = distance (ball$game) executor < 11.9

bestFreeKick dt enemy executor ball = --trace ("BESTFREEKICK" ++ show bestPeak) $
   bfk where
      bfk = fst $ foldr1 max' estimatedActs
      estimatedActs = zip (grid ball executor) bests
      bests | length acts > 1 = (fst . head) <$> rawEstimated
            | otherwise = [0.0]
      rawEstimated = deepEstimateIterator dt enemy 25 (grid ball) 2 <$> acts
      acts  = actsForChoose dt grid ball executor
      max' a@(_,b) a'@(_,b') | b > b' = a
                             | True   = a'
      grid = minGrid' 

      peaks = (snd . head) <$> rawEstimated
      estimatedPeaks = zip (zip (grid ball executor) peaks) bests
      bestPeak = fst $ foldr1 max' estimatedPeaks

actsForChoose :: 
    Double -> (Ball -> Bot -> [Action Double]) -> 
    Ball -> Bot -> [[(Double, (Ball, Bot))]]
actsForChoose dt grid ball bot = ((:[]) <$> botBallPredict <$> zip (repeat 0.0) (zip (repeat ball) (gridBots grid ball bot))) where
      botBallPredict (e, x) = (e, predict dt dt simpleBotBallPredict x)

deepEstimateIterator :: Double -> EnemyPlayer -> Int -> 
   (Bot -> [Action Double]) -> Int -> [(Double, (Ball,Bot))] -> [(Double, (Ball,Bot))] 
deepEstimateIterator dt enemy maxTreeWidth grid maxTreeDepth ballsBots = --trace ("deepEstimateIterator: ") $
 deepEstimateIterator' where
  deepEstimateIterator' 
   | maxTreeDepth <= 0 = [bestBallsBots]
   | length (ballsBots) < maxTreeWidth = --trace ("INDEPTH" ++ show (maxTreeDepth-1)) $ 
      newEstimator (maxTreeDepth-1) inDepthBots 
   | otherwise                  = --trace (show (length ballsBots) ++ " REDUCE " ++ show (length reducedBots))  $ 
   newEstimator  maxTreeDepth reducedBots where
      newEstimator = deepEstimateIterator dt enemy maxTreeWidth grid
      inDepthBots = botBallPredict <$> (concatMap grid' ballsBots)
      grid' (e, (ball,bot)) = zip3' (repeat e) (repeat ball) (setPossAct bot <$> grid bot)
      botBallPredict (e, x) = (e, predict dt dt simpleBotBallPredict x)
      reducedBots = reduce ballsBots
      reduce bots = firstBots ++ lastBots'
      (firstBots, lastBots) = splitAt (maxTreeWidth `div` 10) sortedBallsBots
      lastBots' = takeList primes lastBots
      sortedBallsBots = (sortBy estOrds $ est <$> ballsBots)
      bestBallsBots :: (Double, (Ball, Bot))
      bestBallsBots  = foldl' estMax (-7000.0,und) $ (est <$> ballsBots)
      estOrds (e,_) (e',_) = compare e' e 

      estMax :: (Double, (Ball, Bot)) -> (Double, (Ball, Bot)) -> (Double, (Ball, Bot))
      estMax  p@(e,_) p'@(e',_) | e >= e' = p
                                | True    = p'
      est (e,x) = (uncurry (freeKickEstimate dt enemy) x, x)
      und = (zero,zero)

bestFreeKick' dt enemy executor ball = fst $ foldl' max' (undefined,-1111111.0) $ zip (minGrid' ball executor) q where
   max' a@(_,b) a'@(_,b') | b >= b'    = a
                          | otherwise = a'
   q :: [Double]
   q = tbfkk dt enemy ball executor minGrid'

tbfkk dt enemy ball executor grid =
   uncurry (freeKickEstimate dt enemy) .
   curry (simpleBotBallPredict dt) ball .
   (\x -> executor {possAct = x})    <$>
   grid ball executor
