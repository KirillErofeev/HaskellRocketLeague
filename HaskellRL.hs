module HaskellRL where

import Foreign.Marshal (newArray)
import Foreign.Ptr (Ptr(..))

import Rules (rTICKS_PER_SECOND)

foreign export ccall haskellAct :: 
  --  me.Id  -> me.is_teammate -> me.x   -> me.y   -> me.z 
    Double -> Bool    -> Double -> Double -> Double ->
  --me.vel_x -> me.vel_y -> me.vel_z ->
    Double   -> Double   -> Double   -> 
  --me.radius -> me.touch -> me.tnX -> me.tnY -> me.tnZ
    Double    -> Bool     -> Double -> Double -> Double ->
  --  me.Id  -> me.is_teammate -> me.x   -> me.y   -> me.z 
    Double -> Bool    -> Double -> Double -> Double ->
  --me.vel_x -> me.vel_y -> me.vel_z ->
    Double   -> Double   -> Double   -> 
  --me.radius -> me.touch -> me.tnX -> me.tnY -> me.tnZ
    Double    -> Bool     -> Double -> Double -> Double ->
  --  me.Id  -> me.is_teammate -> me.x   -> me.y   -> me.z 
    Double -> Bool    -> Double -> Double -> Double ->
  --me.vel_x -> me.vel_y -> me.vel_z ->
    Double   -> Double   -> Double   -> 
  --me.radius -> me.touch -> me.tnX -> me.tnY -> me.tnZ
    Double    -> Bool     -> Double -> Double -> Double ->
  --  me.Id  -> me.is_teammate -> me.x   -> me.y   -> me.z 
    Double -> Bool    -> Double -> Double -> Double ->
  --me.vel_x -> me.vel_y -> me.vel_z ->
    Double   -> Double   -> Double   -> 
  --me.radius -> me.touch -> me.tnX -> me.tnY -> me.tnZ
    Double    -> Bool     -> Double -> Double -> Double ->
    IO (Ptr Double)

foreign export ccall helloFromHaskell :: Double

class DoubleLike a where
    toDouble :: a -> Double

instance DoubleLike Bool where
    toDouble True  = 1.0
    toDouble _     = 0.0

instance DoubleLike Double where
    toDouble = id

data Vec3 a = Vec3 {x :: a, y :: a, z :: a}
data Action = Action {velocity :: Vec3 Double, jS :: Double}

haskellAct 
    meId meIsMate 
    meX meY meZ meVelX meVelY meVelZ 
    meRadius meTouch meTnX meTnY meTnZ 
    mateId mateIsMate 
    mateX mateY mateZ mateVelX mateVelY mateVelZ 
    mateRadius mateTouch mateTnX mateTnY mateTnZ 
    eBotId eBotIsMate 
    eBotX eBotY eBotZ eBotVelX eBotVelY eBotVelZ 
    eBotRadius eBotTouch eBotTnX eBotTnY eBotTnZ 
    eBot0Id eBot0IsMate 
    eBot0X eBot0Y eBot0Z eBot0VelX eBot0VelY eBot0VelZ 
    eBot0Radius eBot0Touch eBot0TnX eBot0TnY eBot0TnZ 
        = newArray [rTICKS_PER_SECOND, meId, toDouble meIsMate, meX, meY, meZ]
helloFromHaskell = 1111.0
