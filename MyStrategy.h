#if defined(_MSC_VER) && (_MSC_VER >= 1200)
#pragma once
#endif

#ifndef _MY_STRATEGY_H_
#define _MY_STRATEGY_H_

#include "Strategy.h"

class MyStrategy : public Strategy {
public:
    MyStrategy();

    void act(const model::Robot& me, const model::Rules& rules, const model::Game& game, model::Action& action) override;


    double maxBallV=0;
    void updateMaxBallV(const model::Robot& me, const model::Game& game);
    //double minBallDistance=10000;
    //void updateMinBallDistance(const model::Robot& me, const model::Game& game);
};

#endif
