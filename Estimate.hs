{-#language FlexibleInstances #-}
{-#language NoMonomorphismRestriction #-}
module Estimate where

import Types
import Constants
import Foretold
import Debug.Trace

maxPoints = 1000

estimate :: Game -> IPlayer -> EnemyPlayer -> Double
estimate' game iAm enemy | z bl > arenaDepth/2 + ballRadius = maxPoints
                         | z bl < -arenaDepth/2 - ballRadius = -maxPoints
                         | z bl < 0 = z bl * totalPoints / arenaDepth + abs(x bl) * 3
                         | z bl > 0 = z bl * totalPoints / arenaDepth - abs(x bl) * 3
                         | otherwise = 0 where
                            bot0en = getEnemyBot0 enemy
                            bl = location (ball game)
                            meLoc = location (getMe iAm)
                            mateLoc = location (getMate iAm)
                            bot0Loc = location (bot0en)
                            -- bot1Loc = location (bot1 enemy)
                            -- fromdistance (Vec3 0 0 (-arenaDepth/2)) (bl)
                            totalPoints = 2000

estimate game iAm enemy = estimate' game iAm enemy + cor where
    cor = (80 - minBallDistance) + (80 - minDefDistance - minBallDistance)
    minBallDistance = 
        min (distance (location iAm) bl) (distance (location . getMate $ iAm) bl)
    bl  = location . ball $ game
    def = Vec3 0 0 (-40)
    minDefDistance = 0

freeKickEstimate dt (EnemyPlayer (Player e0 e1)) ball bot = --trace ("\n" ++ show (location bot)) $ 
   isScoredPts + isAutogoalPts + isKickPts where
      isScoredPts | isScored ball  = 1e3 + saveDif ball
                  | otherwise      = 0
      isScored b = z (location b) > arenaDepth/2 + ballRadius
      
      isAutogoalPts | isAutogoal = -1e3
                    | otherwise  = 0
      isAutogoal = z (location ball) <= -arenaDepth/2 - ballRadius 

      saveDif b = foldr1 min $ distance (location b) . location <$> [e0, e1] 

      isKick = z (velocity ball) > 20 
      isKickPts | isKick && isPrbScored = 100 + prbSaveDif
                | isKick                = -100
                | otherwise = - distCurveBall 

      distCurveBall = (fst3 . head) $ dropWhile final $
         iterate iterator (distance ball bot, 0, ball)
      final (distCB, t, ball) = distCB > t*27 && t < 1.3
      iterator (distCB, t, ball) = (min distCB (distance ball' bot), t+dt, ball')

      ball' = simpleFreeBallPredict ball dt

      canBeScored = head $ dropWhile kickFinal $
         iterate kickIterator (0, ball)
      kickFinal (t, ball) = not (isScored ball) && t < 2
      kickIterator (t, ball) = (t+dt, ball')

      isPrbScored = isScored $ snd canBeScored
      prbSaveDif  = saveDif  $ snd canBeScored


uncurry3 f (a,b,c) = f a b c
traceShowStatic f a = trace (show' a ++ " ESTIMATION: " ++ show (f a)) ()
test = traceShowStatic (uncurry3 estimate) <$> [(posToGame (Vec3 10 0 (-43)), zero, zero)
                         ,(posToGame (Vec3 (-30) 0 (-40)), zero, zero)
                         ,(posToGame (Vec3   0   0   (0)), zero, zero)
                         ,(posToGame (Vec3   0   0  (10)), zero, zero)
                         ,(posToGame (Vec3  30   0  (40)), zero, zero)
                          ]

ballToGame ball = Game ball 0 (Score 0 0)
posToBall l = Ball l zero
posToGame = ballToGame . posToBall
