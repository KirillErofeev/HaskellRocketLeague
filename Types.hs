module Types where 

import Foreign.Marshal (newArray)

class DoubleLike a where
    toDouble :: a -> Double

instance DoubleLike Bool where
    toDouble True  = 1.0
    toDouble _     = 0.0

instance DoubleLike Double where
    toDouble = id

data Vec3 a = Vec3 {x :: a, y :: a, z :: a}

data Action = Action {actVelocity :: Vec3 Double, jS :: Double}
toForeignType (Action (Vec3 x y z) js) = newArray [x, y, z, js]

data Game = Game {ball :: Ball, currenTick :: Int, score :: Score}

data Score   = Score {myScore :: Int, enemyScore :: Int}

data Player         = Player {bot0 :: Bot, bot1 :: Bot}
newtype EnemyPlayer = EnemyPlayer Player
newtype IPlayer     = IPlayer Player
getMe   (IPlayer (Player me _  )) = me
getMate (IPlayer (Player _ mate)) = mate

data Bot     = Bot {botId :: Int, botLoc :: Vec3 Double, botVel :: Vec3 Double, 
                    botRad :: Double, botTouch :: Touch}
data Touch = Touch {isTouch :: Bool, touchNormal :: Vec3 Double}
data Ball    = Ball {ballLoc :: Vec3 Double, ballVel :: Vec3 Double, balRadius :: Double}

class MoveAble a where
    velocity :: a -> Vec3 Double

instance MoveAble Bot where
    velocity (Bot _ _ v _ _) = v

instance MoveAble Ball where
    velocity (Ball _ v _) = v

class MoveAble a => Character a where
    radius   :: a -> Double
    location :: a -> Vec3 Double

instance Character Bot where
    radius   (Bot _ _ _ r _) = r
    location (Bot _ l _ _ _) = l

instance Character Ball where
    radius   (Ball _ _ r) = r
    location (Ball l _ _) = l
