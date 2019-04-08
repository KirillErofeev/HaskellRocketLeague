{-# language NoMonomorphismRestriction #-}
{-#language FlexibleContexts #-}
module Algebra where

import Types
import Foretold
import Constants

import Debug.Trace (traceShow, trace)
--traceShow = flip const

act :: Game -> IPlayer -> EnemyPlayer -> Score -> (Action Double,[Double])
act game iAm enemy score | isItGoal game = trace (show (currentTick game) ++ "GOAL") (r,[1,4,88])
                         | otherwise     = (r,[1,4,88]) where
    isItGoal (Game b _ _) = (>=39) . abs . z . location $ b
    r = condHitBall game iAm enemy
    celebrate = zeroAct
    --r = zeroAct
    --debugPrint = show (location ballNow) ++ " " ++ show l
    --ballNow = ball$game
    --Ball l b = predict game iAm enemy (1/60) (1/6000)

zeroAct = (zeroAction, [])
zeroAction = Action (Vec3 0 0 0) 0.0

--isIAmCloserToBall game iAm
--     | myDist < mateDist = False
--     | otherwise         = True
--        where
--           bl = location . ball $ game
--           myDist   = distance (location iAm) bl
--           mateDist = distance (location (getMate iAm)) bl

isIAmCloserToBall game iAm
    | (botId . getMe) iAm > (botId . getMate) iAm = True
    | not $ isNotAutogoal (getMate iAm) game      = True
    | distance (location (getMate iAm)) bl - distance (location iAm) bl < 0 = True
    | distance (location iAm) bl < 6 = True
    | otherwise                                   = False
        where
            bl = (location . ball $ game)

goTo iAm point = Action v 0 where
    v = 1e3 *| xzPrj (point - location iAm)

hitBall game iAm = condHitBall game iAm

isNotAutogoal p game = z (bl - location p) >= (-1) where
    bl = (location . ball $ game)

condHitBall game iAm enemy = action where
    action | (botId . getMe) iAm > (botId . getMate) iAm = Action vOff 0
           | otherwise = Action vOff jumpOff
    bl = (location . ball $ game)
    predictBall :: Double -> Vec3 Double
    predictBall time = (location $ predict game iAm enemy time (1/6000))
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

