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


--tbfkk' dt enemy executor ball =
--   deepEstimateIterator dt enemy 1001 minGrid 11 [(ball,executor)]

--testDET = deepEstimateIterator (1/60) zero 10 minGrid 3 <$>
--   (return <$> zip (repeat 0) (zip (repeat tball) (minGridBots bot))) 

testBfk = zip (minGrid bot) (tbfkk (1/600) e (Ball l v) bot minGrid')
t' a = (a, freeKickEstimate (1) e tball (bot {possAct = a}))
e = (EnemyPlayer (Player e0 e1))
l = z1*5 + x1*15 + y1*15
v = Vec3 100 (-10) 0
e0 = zero
e1 = zero
bot = zero {botLoc=x1*17}
tball = (Ball l v)
   
