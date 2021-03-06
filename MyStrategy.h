#if defined(_MSC_VER) && (_MSC_VER >= 1200)
#pragma once
#endif

#ifndef _MY_STRATEGY_H_
#define _MY_STRATEGY_H_

#include <ctime>
#include <vector>

#include "Strategy.h"

class MyStrategy : public Strategy {
public:
    MyStrategy();
    ~MyStrategy();

    void act(const model::Robot& me, const model::Rules& rules, const model::Game& game, model::Action& action) override;

    std::string custom_rendering() override;

    std::string debug;
    std::clock_t allTime;

    std::vector<double> stored;
    std::vector<double> stored0;
    bool isStrategyComputed;
};

#endif
