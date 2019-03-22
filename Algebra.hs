module Algebra where

import Types

import Debug.Trace (trace, traceShow)

act :: Game -> IPlayer -> EnemyPlayer -> Score -> Action
act game iAm enemy score = traceShow (location iAm) r where
    r = hitBall game iAm
    t = velocity r

isIAmCloserToBall game iAm 
     | myDist > mateDist = True
     | myDist < mateDist = False
     | otherwise         = True
        where
           myDist   = distance (location iAm) (location . ball $ game)
           mateDist = distance (location (getMate iAm)) (location . ball $ game)

goTo iAm point = Action v 0 where
    v    = 1e3 *| xzPrj (point - location iAm)

hitBall game iAm = condHitBall game iAm

condHitBall game iAm = Action v jump where
    bl = (location . ball $ game)
    distanceToPoint = distance bl (location iAm)
    isNotAutogoal = foldr (*) 1 ((Vec3 0 0 1) * (bl - location iAm)) >= 0
    v | isIAmCloserToBall game iAm = vIAmCloser
      | otherwise                  = velocity $ goTo iAm (Vec3 0 0 (-30))
    vIAmCloser | distanceToPoint > 6 = velocity $ goTo iAm bl
               | isNotAutogoal       = velocity $ goTo iAm bl
               | otherwise           = velocity $ goTo iAm (Vec3 15 0 (-40))

    jump | distanceToPoint < 5 && z bl < 2 = 100
         | distanceToPoint < 4             = 100
         | otherwise                       = 0

distance v1 v0 = norm (v0 - v1)

norm v = sqrt $ foldr (+) 0 $ (**2) <$> v

infix 9 *| 
s *| v = (*s) <$> v

xzPrj v = v * (Vec3 1 0 1)
