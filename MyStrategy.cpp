#include <iostream>

#include "consts.h"
#include "algebra.h"

#include "MyStrategy.h"

using namespace model;

MyStrategy::MyStrategy() { }

void ballchaseAct(const Robot& me, const Rules& rules, const Game& game, Action& action){
}

void MyStrategy::act(const Robot& me, const Rules& rules, const Game& game, Action& action) {
    Algebra a(me, rules, game, action);

    if (me.id%2 == 0){
        updateMaxBallV(me, game);
        if(game.current_tick % 500 < 200)
            a.goDefCenter();
        else
            a.goToBall();

        //a.goToBall();
        //if (a.isICloserToBall()){
        if (location(me).distanceTo(game.ball) <= 4.5)//3.3
            a.jump();
        updateMaxBallV(me, game);
        //}
    }
}

void MyStrategy::updateMaxBallV(const model::Robot& me, const Game& game){
    double v = velocity(game.ball).norm();
    if (v > 40)
        std::cout << v << std::endl;
    if (v > maxBallV){
        maxBallV = v;
    }
}

//void MyStrategy::updateMinBallDistance(const model::Robot& me, const Game& game){
//    double l = (location(me) - location(game.ball)).norm();
//    if (l < minBallDistance){
//        minBallDistance = l;
//        std::cout << l << std::endl;
//    }
//}

