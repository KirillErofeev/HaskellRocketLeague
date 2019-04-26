module Test0 where

import Types
import Debug.Trace

t :: [[Int]]
t = do
   a <- [[1],[2]]
   b <- [3:a]
   return b

t' = [[1],[2]] >>= (\a -> 3:a >>= (\b -> [b]))

t'' = [[1],[2]] >>= (\a -> [3:a])


scoredPosition bot ball = trace (show tBall ++ "  " ++ show (show (abs $ botToBallX*tBall - botX))) $
 scoredPosition' bot ball where
   scoredPosition' bot ball 
                         | tBall <= 0       = -10.0
                         | tBall <= 0       = -10.0
                         | otherwise        = 0.0
   onScoredPosition = (abs $ botToBallX*tBall - botX) - 13.5
   tBall = (40-botZ)/botToBallZ
   Vec3 botX  _ botZ  = location bot
   Vec3 ballX _ ballZ = location ball
   (botToBallX, botToBallZ) = (ballX - botX, ballZ - botZ)

tsp = scoredPosition bot ball where
   bot  = zero {botLoc  = Vec3 (-40) 1 (-1)}
   ball = zero {ballLoc = Vec3 (40) 1 (0)}
