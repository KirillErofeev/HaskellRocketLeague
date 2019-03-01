#include <ctime>
#include <iostream>

#include "consts.h"
#include "algebra.h"

#include "MyStrategy.h"

using namespace model;

MyStrategy::MyStrategy() {
    std::clock_t b = std::clock();
    std::clock_t e = std::clock();
    double t = double(e - b)/CLOCKS_PER_SEC;
    std::cout << t << "s." << std::endl;
}

std::string MyStrategy::custom_rendering() {
    return "";
}

void MyStrategy::act(const Robot& me, const Rules& rules, const Game& game, Action& action) {
    std::clock_t b = std::clock();

    Algebra a(me, rules, game, action);

    if (game.current_tick == 1 && isIdAssigned == false){
        predictions = std::vector<Prediction>(TICKS_PER_SECOND*450/a.TICK_DT);
        fId = me.id;
        sId = a.mate().id;
        isIdAssigned = true;
        std::cout << "a" << std::endl;
    }

    if (me.id == fId){
        a.goToBall();
        if (true)
            a.jump();

        if (a.game.current_tick % TICKS_PER_SECOND == 1)
            a.predictBall(predictions, 1, 1.0);

        if (game.current_tick > 1){
            Vec deltaV = predictions[a.currentIndex()].velocity - velocity(a.game.ball);
            if (deltaV.norm() > 1e-7 ){
                std::cout << "TICK " << a.game.current_tick << std::endl;
                std::cout << "Pred:" << predictions[a.currentIndex()].position << " " << predictions[a.currentIndex()].velocity << std::endl;
                std::cout << "Real: " << location(a.game.ball) << " " <<
                    velocity(a.game.ball) << std::endl;
            }
        }
    }
}

void ballchaseAct(const Robot& me, const Rules& rules, const Game& game, Action& action){

}

void MyStrategy::updateMaxActTime(double time){
    if (time > maxActTime){
        maxActTime = time;
        //std::cout << time << "s." << std::endl;
    }
}

void MyStrategy::updateMaxBallV(const model::Robot& me, const Game& game){
    double v = velocity(game.ball).norm();
    //if (v > 40)
    //    std::cout << v << std::endl;
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

