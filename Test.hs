module Test where

data T a = T a [a] deriving (Show)

add (T b l) (T b' l') = (T b (b':l), T b' (b:l'))
--add _ _ = undefined

l = [T 0 [], T 1 [], T 2 [], T 3 []]
t = T 4 []
