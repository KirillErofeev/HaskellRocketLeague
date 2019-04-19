{-#language NoMonomorphismRestriction #-}
module Test where

import Data.List 

import Types
import Estimate
import Foretold
import Prediction
import Primes

import Debug.Trace

data T a = T a [a] deriving (Show)

add (T b l) (T b' l') = (T b (b':l), T b' (b:l'))
ad (T b l) (T b' l') = T b' (b:l')
--add _ _ = undefined

ll = [T 0 [], T 1 [], T 2 [], T 3 []]
tt = T 4 []

collideBotToBall''' ball bots = --traceShow (location <$> bots)
    foldr foldF (ball,[]) bots where
        foldF b (ball',prs) = --traceShow (location <$> prs) 
            (ball'', ad (T (-1) []) b':prs) where
                (ball'',b') = --traceShow (location b) $
                    add ball' b


tbfkk dt enemy executor ball =
   uncurry (freeKickEstimate dt enemy) .
   curry (simpleBotBallPredict dt) ball .
   (\x -> executor {possAct = x})    <$>
   minGrid executor

--tbfkk' dt enemy executor ball =
--   deepEstimateIterator dt enemy 1001 minGrid 11 [(ball,executor)]

deepEstimateIterator :: Double -> EnemyPlayer -> Int -> 
   (Bot -> [Action Double]) -> Int -> [(Double, (Ball,Bot))] -> [(Double, (Ball,Bot))] 
deepEstimateIterator dt enemy maxTreeWidth grid maxTreeDepth ballsBots 
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
      sortedBallsBots = (sortBy estOrds $ estBallsBots ballsBots)
      bestBallsBots :: (Double, (Ball, Bot))
      bestBallsBots  = (foldl' estMax (-7000.0,und) $ estBallsBots ballsBots)
      estOrds (e,_) (e',_) = compare e e' 

      estMax :: (Double, (Ball, Bot)) -> (Double, (Ball, Bot)) -> (Double, (Ball, Bot))
      estMax  p@(e,_) p'@(e',_) | e >= e' = p
                                | True    = p'
      estBallsBots l = est <$> l
      est (e,x) = (uncurry (freeKickEstimate dt enemy) x, x)
      und = (zero,zero)

testDET = deepEstimateIterator (1/60) zero 10 minGrid 3 <$>
   (return <$> zip (repeat 0) (zip (repeat tball) (minGridBots bot))) 
testBfk = zip (minGrid bot) (tbfkk (1/600) e bot (Ball l v))
t' a = (a, freeKickEstimate (1) e tball (bot {possAct = a}))
e = (EnemyPlayer (Player e0 e1))
l = z1*5 + x1*15 + y1*15
v = Vec3 100 (-10) 0
e0 = zero
e1 = zero
bot = zero {botLoc=x1*17}
tball = (Ball l v)

showColumn = foldMap $ (++"\n") . show
   
