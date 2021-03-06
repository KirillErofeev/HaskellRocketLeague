{-# language NoMonomorphismRestriction #-}
{-#language FlexibleContexts #-}
module Algebra where

import Types
import Foretold
import Prediction
import Constants
import Data.Foldable (toList)

import Debug.Trace (traceShow, trace)
--traceShow = flip const

--act' :: Game -> IPlayer -> EnemyPlayer -> Score -> IO Double -> Answer Double
--act' game iAm enemy score savedData = --trace ( "[" ++ show(location iAm)++"]")$ --trace ("PRED VEL " ++ show (myVel)) $ 
--    Answer (Move myAct zero) stored where
--        stored = (toList predLoc ++ toList predVel ++ toList myLoc)
--        myAct = ballChaseJAct game iAm
--        predLoc = predBallLoc p
--        predVel = predBallVel p
--        myLoc = predMyLoc p
--        myVel = predMyVel p
--        iAmAct = setMyAct myAct iAm
--        p = predict simplePredict (Prediction game iAmAct enemy) (1/60) (1/6000)
--        --predVel = velocity $ trace ("BALL AFTER:" ++ show (newBall)) newBall
--        game' = trace ("BALL BEFORE:" ++ show (ball game)) game
--        celebrate = zeroAct

--act'' :: Game -> IPlayer -> EnemyPlayer -> Score -> IO Double -> Answer Double
--act'' game iAm enemy score savedData 
--    | currentTick game `mod` ddd == 0 = trace ( "\n"++show (currentTick game) ++ ": [" ++ show(ball$game) ++"] " ++ "\n["++show (predLoc)++"]") $ answer 
--    | otherwise = answer where
--        answer  | norm (location predLoc) < 10000 = Answer (Move kickoff zero) stored
--        move    = getBestMove game iAm enemy (ballChaseAct game iAm)
--        kickoff = freeKick game (getMe iAm) goalCenter 10
--        predLoc = predict simpleFreeBallPredict (ball$game) (ddd/60) (1/6000)
--        stored  = [0,0,0, 0,0,0, 0,0,0, 0,0,0]
--        ddd = 100

dt = 1/300
act :: Game -> IPlayer -> EnemyPlayer -> Score -> IO Double -> Answer Double
act game@(Game ball ct _) iAm@(IPlayer (Player me mate)) 
  enemy@(EnemyPlayer (Player e0 e1)) score savedData = trace (show ct ++ ": ")$ 
  Answer move stored where 
    move | True = Move (bestFreeKick (dynDt ball me) enemy me ball) (bestFreeKick (dynDt ball me) enemy me ball)
         | otherwise = Move zero (zero) --Move (cor (bestFreeKick (dt) enemy me ball)) (cor (bestFreeKick (dt) enemy mate ball)) 
    stored  = [0,0,0, 0,0,0, 0,0,0, 0,0,0]
    (meAct, mateAct) | isMyKickoff = trace (show "KICKOFF: 111")$ (kickoffAct me, scoreAct mate)  
                     | otherwise   = trace (show "KICKOFF: 333")$ (scoreAct me, kickoffAct mate)  
    isMyKickoff = z (velocity meOpp) < 0
    meOpp | x (location e0) - x (location me) < 0.3 = e0
          | otherwise                               = e1
    kickoffAct :: Bot -> Action Double
    kickoffAct bot | norm (velocity ball) < 1 = hitBall ball bot
                   | otherwise = bumpDef bot
    bumpDef bot = bump bot (closest enemyGoalkeeper e0 e1)
    scoreAct :: Bot -> Action Double
    scoreAct bot | False && norm (velocity ball) < 1 = Action (Vec3 (x . velocity $ (goTo ball me)) 0 0) 0
                 | otherwise = bestFreeKick dt enemy bot ball
    cor = id
    ballBotXZDist bot = distance (xzPrj $ location ball) (xzPrj $ location bot)
    dynDt ball bot 
       | ballBotXZDist bot > 4.5 = 1/120
       | y (location ball) > 7   = 1/120
       | otherwise               = 1/120

bump me goal = Action v j where
   j | distance me goal < 1.3 = 30
     | otherwise = 0
   v = velocity $ goTo me goal

holdSymmetry me e0 = Action v j where
   j | isTouch (botTouch e0) = 0
     | otherwise             = 30
   v = velocity $ goTo me ( (location e0) {z=(-zl)})
   zl = z . location $ e0

isKickoff1 game@(Game ball _ _) iAm@(IPlayer (Player me mate)) (EnemyPlayer (Player e0 e1)) = startPosition && ballPosition where
   iAmC = closestBall ball me mate 
   eC   = closestBall ball e0 e1
   symmetry = dist && symm
   dist = distance ball iAmC - distance ball eC < 0.001
   symm = (-z (location iAmC)) - (z (location eC)) < 0.3 
   startPosition = sum dists < 0.001
   dists = (distance ball me -) <$> (distance ball <$> [mate, e0, e1])
   ballPosition = (abs . z $ location ball) + (abs . x $ location ball) < 0.001

closestBall b e0 e1 | distance b e0 < distance b e1 = e0
                         | otherwise                     = e1

closest g e0 e1 | distance g e0 < distance g e1 = e0
                | otherwise                     = e1


jumpAction = Action zero 30
--isIAmCloserToBall game iAm
--     | myDist < mateDist = False
--     | otherwise         = True
--        where
--           bl = location . ball $ game
--           myDist   = distance (location iAm) bl
--           mateDist = distance (location (getMate iAm)) bl

ballChaseAct game iAm = Action v 0 where
    v = 1000 *| (bl - location iAm)
    bl = location . ball $ game

ballChaseJAct game iAm = Action v j where
    v = 1000 *| (bl - location iAm)
    bl = location . ball $ game
    j | distance bl (location iAm) < 3.5 = 30
      | otherwise                        = 0

isIAmCloserToBall game iAm
    | (botId . getMe) iAm > (botId . getMate) iAm = True
    | not $ isNotAutogoal (getMate iAm) game      = True
    | distance (location (getMate iAm)) bl - distance (location iAm) bl < 0 = True
    | distance (location iAm) bl < 6 = True
    | otherwise                                   = False
        where
            bl = (location . ball $ game)

hitBall ball bot = Action v j where
   v = velocity $ goTo bot ball 
   j | distance ball bot < 4 = 30.0
     | otherwise             = 0.0

isNotAutogoal p game = z (bl - location p) >= (-1) where
    bl = (location . ball $ game)

condHitBall game iAm enemy = action where
    action | (botId . getMe) iAm > (botId . getMate) iAm = Action vOff 0
           | otherwise = Action vOff jumpOff
    bl = (location . ball $ game)
    predictBall :: Double -> Vec3 Double
    predictBall time = undefined
    distanceToBall = distance bl (location iAm)
    isNotAutogoal = z (bl - location iAm) >= (-1)

    vBc = velocity $ goTo iAm bl
    jc = jumpOff

    vDef  = velocity $ goTo iAm defPs
    defPs = (0.5*|(bl - Vec3 0 0 (-30))) + Vec3 0 0 (-30)

    vOff | distanceToBall > 10  = velocity $ goTo iAm (predictBall (1))
         | otherwise            = Vec3 0 0 0

    jumpDef | distanceToBall < 5 && z bl < 2 && isNotAutogoal = 0
            | distanceToBall < 4             && isNotAutogoal = 0
            | otherwise                                       = 0
    jumpOff | distanceToBall < 3.5 && z bl < 7 && isNotAutogoal = 100
            | otherwise                                         = 0

