{-#language NoMonomorphismRestriction #-}
module Prime where

primeStream :: [Int]
primeStream = 2:3:5:7: filter filtPrimes [11..] where
--primeStream = undefined 
primeCond n i = mod n i /= 0
filtPrimes n = all (primeCond n) $ takeWhile (comp' n) primeStream 
filtPrimes' n = takeWhile (comp' n) primeStream 
comp' x y = sqrt (fromIntegral x) >= fromIntegral y

