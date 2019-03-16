module Algebra where

import Types

act :: Game -> IPlayer -> EnemyPlayer -> Score -> Action
act game iAm enemy score = Action (Vec3 0 0 0) 0

