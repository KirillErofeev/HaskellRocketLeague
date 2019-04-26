
t = t' <$> minGrid
t' a = (a, freeKickEstimate (1/6000) e (Ball l v) (executor {possAct = a}))
e = (EnemyPlayer (Player e0 e1))
l = zero
v = Vec3 100 0 13
e0 = zero
e1 = zero
bots = \x -> zero {botLoc = x}

   
