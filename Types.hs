{-#language MultiParamTypeClasses #-}
{-#language FlexibleInstances #-}

module Types where 

import Foreign.Marshal (newArray)
import Foreign.Ptr (Ptr(..))
import Data.Semigroup (Semigroup, (<>))
import Data.Monoid (Sum, All, getAny, All(..))
import Debug.Trace (trace, traceShow)
import Data.Foldable (toList)

import Constants

class DoubleLike a where
    toDouble :: a -> Double

instance DoubleLike Bool where
    toDouble True  = 1.0
    toDouble _     = 0.0

instance DoubleLike Double where
    toDouble = id

class Normed v n where
    norm :: v n -> n

instance Floating a => Normed Vec3 a where
    norm v = sqrt $ foldr1 (+) $ (**2) <$> v

class MeasurableSpace v m where
    distance :: v m -> v m -> m

instance Floating a => MeasurableSpace Vec3 a where
    distance v1 v0 = norm $ v0 - v1

data Vec3 a = Vec3 {x :: a, y :: a, z :: a} 
    deriving (Eq, Ord)

instance Show a => Show (Vec3 a) where
    show (Vec3 x y z) = show x ++ " " ++ show y ++ " " ++ show z

type Vec = Vec3 Double

infix 6 *|
s *| v = (*s) <$> v

dot v0 v1 = sum $ v0 * v1
normalize v = (1/norm v) *| v

xzPrj v = v * (Vec3 1 0 1)
xyPrj v = v * (Vec3 1 1 0)

instance Functor Vec3 where
    fmap f (Vec3 x y z) = Vec3 (f x) (f y) (f z)

instance Applicative Vec3 where
    pure a = Vec3 a a a
    Vec3 fx fy fz <*> Vec3 x y z = Vec3 (fx x) (fy y) (fz z)

instance Num a => Num (Vec3 a) where
    v0 + v1 = (fmap (+) v0) <*> v1
    v0 * v1 = (fmap (*) v0) <*> v1
    fromInteger x = fromInteger <$> Vec3 x x x
    negate v      =  (*(-1)) <$> v
    signum v      = signum   <$> v
    abs    v      = abs      <$> v

instance Semigroup a => Semigroup (Vec3 a) where
    v0 <> v1 = (((<>) <$>) v0) <*> v1

instance Monoid a => Monoid (Vec3 a) where
    mempty  = Vec3 mempty mempty mempty
    mappend v0 v1 = ((mappend <$>) v0) <*> v1

zero :: Num a => Vec3 a
x1 :: Num a => Vec3 a
y1 :: Num a => Vec3 a
z1 :: Num a => Vec3 a

zero = Vec3 0 0 0
x1   = Vec3 1 0 0
y1   = Vec3 0 1 0
z1   = Vec3 0 0 1

instance Foldable Vec3 where
    foldMap f (Vec3 x y z) = mempty <> f x <> f y <> f z 
        where (<>) = mappend

data Action a = Action {actVelocity :: Vec3 a, jS :: a} 
    deriving (Show, Eq)

instance Foldable Action where
    foldr f m (Action v jump) = foldr f (jump `f` m) v


data Collide = Collide {colDist :: Double, colNormal :: Vec3 Double}
                    deriving (Show)

data Move a = Move {myAction :: Action a, mateAction :: Action a} 
    deriving (Show, Eq)

data Answer a = Answer {getMove :: Move a, getStored :: [a]}

instance ForeignType (Answer Double) where
    toForeignType (Answer m s) = toForeignType $ toList m ++ toList s

instance Foldable Move where
    foldr f ini (Move a0 a1) = foldr f (foldr f ini a1) a0

instance ForeignType (Move Double) where
    toForeignType (Move a0 a1) = toForeignType $ toList a0 ++ toList a1

class Finite a where
    isNumber :: a -> Bool

instance Finite Double where
    isNumber x = not $ isNaN x || isInfinite x

instance Finite Ball where
    isNumber (Ball l v) = isNumber l && isNumber v

instance Finite a => Finite (Vec3 a) where
    isNumber v = getAll $ foldMap (All . isNumber) v 

instance Eq Collide where
    Collide d0 _ == Collide d1 _ = d0 == d1

instance Ord Collide where
    Collide d0 _ <= Collide d1 _ = d0 <= d1

class ForeignType a where
    toForeignType :: a -> IO (Ptr Double)

instance ForeignType (Action Double) where
    toForeignType (Action (Vec3 x y z) js) = newArray [x, y, z, js]
    
instance ForeignType [Double] where
    toForeignType = newArray

instance (Foldable a, Foldable b) => ForeignType (a Double,b Double) where
    toForeignType (a,b) = toForeignType $ foldr (:) [] a ++ foldr (:) [] b

--instance (Foldable a, Foldable b) => ForeignType (a Double,b Double) where
--    toForeignType (a,b) = toForeignType $ foldr (:) [] a ++ foldr (:) [] b


data Game = Game {ball :: Ball, currentTick :: Int, score :: Score}

setBall (Game b ct score) ball = Game ball ct score
setBall' (Game b ct score) ball | isNumber ball = Game ball ct score
                               | otherwise = trace (show ball) undefined

data Score   = Score {myScore :: Int, enemyScore :: Int}

data Player         = Player {bot0 :: Bot, bot1 :: Bot}
newtype EnemyPlayer = EnemyPlayer Player
newtype IPlayer     = IPlayer Player
getMe   (IPlayer (Player me _  )) = me
getMate (IPlayer (Player _ mate)) = mate

data Bot     = Bot { botId :: Int,      botLoc :: Vec3 Double, botVel :: Vec3 Double, botRad :: Double, botTouch :: Touch, botRadiusChangeSpeed :: Double}

data Touch  = Touch {isTouch :: Bool,    touchNormal :: Vec3 Double}
data Ball    = Ball {ballLoc :: Vec3 Double, ballVel :: Vec3 Double} 
    deriving (Eq)

instance Show Ball where
    show (Ball l v) = "B: loc:" ++ show l ++ " vel:" ++ show v

mapBall f (Ball l v) = Ball (f <$> l) (f <$> v)


class Entity a where
    arenaE :: a -> Double
    mass   :: a -> Double

instance Entity Ball where
    arenaE b = 0.7 
    mass   b = 1.0

instance Entity Bot where
    arenaE b = 0.0 
    mass   b = 2.0

class MoveAble a where
    velocity :: a -> Vec3 Double

instance MoveAble Bot where
    velocity (Bot _ _ v _ _ _) = v

instance MoveAble Ball where
    velocity (Ball _ v) = v

instance MoveAble (Action Double) where
    velocity = actVelocity

instance MoveAble IPlayer where
    velocity = velocity . getMe

class MoveAble a => Character a where
    radius   :: a -> Double
    location :: a -> Vec3 Double

instance Character Bot where
    radius   (Bot _ _ _ r _ _) = r
    location (Bot _ l _ _ _ _) = l

instance Character Ball where
    radius   (Ball _ _) = ballRadius
    location (Ball l _) = l

instance Character IPlayer where
    radius   = radius   . getMe
    location = location . getMe

class Character a => PredictableCharacter a where
    setVelocity :: a -> Vec3 Double -> a
    setLocation :: a -> Vec3 Double -> a
    setRadius   :: a -> Double -> a
    setRadiusChangeSpeed :: a -> Double -> a
    radiusChangeSpeed :: a -> Double 

instance PredictableCharacter Bot where
    setVelocity (Bot a b v c d rcs) v' = Bot a b v' c d rcs
    setLocation (Bot a l v c d rcs) l' = Bot a l' v c d rcs
    setRadius   (Bot a l v r d rcs) r' = Bot a l v r' d rcs
    setRadiusChangeSpeed (Bot a l v r d rcs) rcs' =
        Bot a l v r d rcs'
    radiusChangeSpeed (Bot _ _ _ _ _ rcs) = rcs

instance PredictableCharacter Ball where
    setVelocity (Ball l v) v' = Ball l  v'
    setLocation (Ball l v) l' = Ball l' v
    setRadius   (Ball l v) r' = Ball l  v
    setRadiusChangeSpeed = const
    radiusChangeSpeed b  = 0.0

traceShow'  x = uncurry traceShow $ (\a->(a,a)) x
checkNumberTrace x | not . isNumber $ x = traceShow' x 
                   | otherwise          = x
