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

freeKickEstimate dt (EnemyPlayer (Player e0 e1)) ball bot = --trace (show "isKickPts: " ++ show isKickPts) $ 
   isScoredPts + isAutogoalPts + isKickPts + posPts + touchPunish + scoredPosition where
      posPts | diffZBall < 0 = diffZBall*100
             | otherwise = 0
      diffZBall = z (location ball) - z (location bot)
      isScoredPts | isScored ball  = 1e5 + saveDif ball
                  | otherwise      = 0
      isScored b = z (location b) > arenaDepth/2 + ballRadius
      
      isAutogoalPts | isAutogoal = -1e5
                    | otherwise  = 0
      isAutogoal = z (location ball) <= -arenaDepth/2 - ballRadius 

      saveDif b = negate $ foldr1 min $ distance (location b) . location <$> [e0, e1] 

      ballBotXZDist = distance (xzPrj $ location ball) (xzPrj $ location ball)
      ballBotYDist  = abs $ (y $ location ball) - (y $ location bot)
      isKick = ballBotXZDist < 3.1 && ballBotYDist < 2
      isKickPts | isKick && isPrbScored =  100  + prbSaveDif
                | isKick                = (0)
                | otherwise = -distCurveBall*10

      distCurveBall = (fst3 . head) $ dropWhile final $
         iterate iterator (distance ball bot, 0, ball)
      final (distCB, t, ball) = distCB > 3.3 && t < 3*dt
      iterator (distCB, t, ball) = (min distCB (distance (xzPrj ball') (xzPrj bot)), t+dt, ball')

      canBeScored = head $ dropWhile kickFinal $
         iterate kickIterator (0, ball)
      kickFinal (t, ball) = not (isScored ball) && t < 1
      kickIterator (t, ball) = (t+dt, ball')
      ball' = simpleFreeBallPredict ball dt

      isPrbScored = isScored $ snd canBeScored
      prbSaveDif  = saveDif  $ snd canBeScored

      touchPunish | isTouch . botTouch $ bot = 0
                  | otherwise                = -15
      
      scoredPosition
                     | tBall <= 0       = -100.0
                     | onScoredPosition = 30 - ((abs $ botToBallX*tBall - botX) - 13.5)
                     | otherwise        = negate ((abs $ botToBallX*tBall - botX) - 13.5)
      onScoredPosition = (abs $ botToBallX*tBall - botX) < 13.5
      tBall = (40-botZ)/botToBallZ
      Vec3 botX  _ botZ  = location bot
      Vec3 ballX _ ballZ = location ball
      (botToBallX, botToBallZ) = (ballX - botX, ballZ - botZ)


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
