#include <ctime>
#include <iostream>

#include "consts.h"
#include "algebra.h"

#include "MyStrategy.h"

using namespace model;

MyStrategy::MyStrategy() {
    std::clock_t b = std::clock();
    isIdAssigned = false;
    predictions = std::vector<Prediction>(TICKS_PER_SECOND*450/TICK_DT);
    ballPredictions = std::vector<Prediction>(TICKS_PER_SECOND*450/TICK_DT);
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
        fId = me.id;
        sId = a.mate().id;
        isIdAssigned = true;
    }

    if (me.id%2 == 0){
        if (game.current_tick == 1){
            //a.predict(predictions, 1, 3, velocity(me), a.toBallGroundVector().maximize());
        }else{
            //if (game.current_tick % TICK_DT == 0)
                //std::cout
                //    << predictions[game.current_tick / TICK_DT].fPosition - location(me) 
                //    << predictions[game.current_tick / TICK_DT].fPosition - location(me) 
                //    << predictions[game.current_tick / TICK_DT].fPosition - location(me) 
                //    << std::endl;
        }
        a.goToBall();
        if (game.current_tick % 33 == 0)
            std::cout << touch_normal(me) << std::endl;

        //updateMaxBallV(me, game);
        //if(game.current_tick % 500 < 200)
        //    a.goDefCenter();
        //else
        //    a.goToBall();

        //if (a.isICloserToBall()){
        //if (location(me).distanceTo(game.ball) <= 4.5)//3.3 
        //    a.jump();
        //updateMaxBallV(me, game);
    }

    std::clock_t e = std::clock();
    double t = double(e - b)/CLOCKS_PER_SEC;
    updateMaxActTime(t);
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

