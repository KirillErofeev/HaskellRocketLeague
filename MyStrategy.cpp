#include <ctime>
#include <iostream>

#include "consts.h"
#include "algebra.h"

#include "MyStrategy.h"

#include "HaskellRL_stub.h"

using namespace model;

MyStrategy::MyStrategy() {}

std::string MyStrategy::custom_rendering() {
    return "";
}


void MyStrategy::act(const Robot& me, const Rules& rules, const Game& game, Action& action) {
    Player iAm;
    Player enemy;
    for(const auto& p: game.players){
        if (p.me)
            iAm = p;
        if (!p.me)
            enemy = p;
    }

    Robot mate;
    Robot eRobot;
    Robot eRobot0;
    bool isESet = false;
    for(const auto& r: game.robots){
        if (r.is_teammate)
            mate = r;
        if (enemy.id == r.player_id && !isESet){
            eRobot = r;
            isESet = true;
        }
        if (enemy.id == r.player_id && isESet)
            eRobot0 = r;
    }

    double* out = static_cast<double*>(
            haskellAct(
                me.id, me.is_teammate, me.x, me.y, me.z,
                me.velocity_x, me.velocity_y, me.velocity_z, me.radius,
                me.touch, me.touch_normal_x, me.touch_normal_y, me.touch_normal_z,
                mate.id, mate.is_teammate, mate.x, mate.y, mate.z,
                mate.velocity_x, mate.velocity_y, mate.velocity_z, mate.radius,
                mate.touch, mate.touch_normal_x, mate.touch_normal_y, mate.touch_normal_z,
                eRobot.id, eRobot.is_teammate, eRobot.x, eRobot.y, eRobot.z,
                eRobot.velocity_x, eRobot.velocity_y, eRobot.velocity_z, eRobot.radius,
                eRobot.touch, eRobot.touch_normal_x, eRobot.touch_normal_y, eRobot.touch_normal_z,
                eRobot0.id, eRobot0.is_teammate, eRobot0.x, eRobot0.y, eRobot0.z,
                eRobot0.velocity_x, eRobot0.velocity_y, eRobot0.velocity_z, eRobot0.radius,
                eRobot0.touch, eRobot0.touch_normal_x, eRobot0.touch_normal_y, eRobot0.touch_normal_z,
                game.ball.x, game.ball.y, game.ball.z,
                game.ball.velocity_x, game.ball.velocity_y, game.ball.velocity_z, game.ball.radius,
                game.current_tick, iAm.score, enemy.score
                ));

    action.target_velocity_x = out[0];
    action.target_velocity_y = out[1];
    action.target_velocity_z = out[2];
    action.jump_speed        = out[3];

    std::cout << " x" << out[0]
              << " y" << out[1]
              << " z" << out[2]
              << " j" << out[3]
              << std::endl;
    std::clock_t b = std::clock();

    Algebra a(me, rules, game, action);

    if (game.current_tick == 1 && isIdAssigned == false){
        predictions = std::vector<Prediction>(TICKS_PER_SECOND*450/a.TICK_DT);
        fId = me.id;
        sId = a.mate().id;
        isIdAssigned = true;
        std::cout << "a" << std::endl;
    }

    if (me.id != fId){
        a.goToBall();
        if (a.distanceToBall(me) < 3.5)
            a.jump();
    }

    if (me.id == fId){
        a.goToBall();
        if (a.distanceToBall(me) < 3.5)
            a.jump();

        if (a.game.current_tick % TICKS_PER_SECOND == 1)
            a.predictBall(predictions, 1, 1.0);

        if (game.current_tick > 1){
            Vec deltaV = predictions[a.currentIndex()].velocity - velocity(a.game.ball);
            if (deltaV.norm() > 1e-7 ){
                std::cout << velocity(a.game.ball) << std::endl;
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

