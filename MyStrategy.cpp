#include <ctime>
#include <iostream>

#include "consts.h"
#include "algebra.h"

#include "MyStrategy.h"

#include "HaskellRL_stub.h"

using namespace model;

MyStrategy::MyStrategy() {
    isStrategyComputed = false;
}

std::string MyStrategy::custom_rendering() { return "";}


void MyStrategy::act(const Robot& me, const Rules& rules, const Game& game, Action& action) {

    if (game.current_tick == 0 && !isStrategyComputed){
        stored = std::vector<double>(100);
        std::cout << "INI" << std::endl;
    }

    if (!isStrategyComputed){
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

        //std::cout << game.current_tick << ": " 
        //          << game.ball.x << " " 
        //          << game.ball.y << " " 
        //          << game.ball.z << " "
        //          << std::endl; 


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
                    game.current_tick, iAm.score, enemy.score, stored.data()
                    ));

        //std::cout << out[0] << " " <<
        //             out[1] << " " <<
        //             out[2] << " " <<
        //             out[3] << " " <<
        //             out[4] << " " <<
        //             out[5] << " " <<
        //             out[6] << " " <<
        //             out[7] << " " << std::endl;

        std::cout << stored[4] - game.ball.x << " " <<
                     stored[5] - game.ball.y << " " <<
                     stored[6] - game.ball.z << " " << std::endl;

        action.target_velocity_x = out[0];
        action.target_velocity_y = out[1];
        action.target_velocity_z = out[2];
        action.jump_speed        = out[3];

        stored[0] = out[4];
        stored[1] = out[5];
        stored[2] = out[6];
        stored[3] = out[7];

        stored[4] = out[8];
        stored[5] = out[9];
        stored[6] = out[10];
        

        isStrategyComputed = true;

    }
    else{
        action.target_velocity_x = stored[0];
        action.target_velocity_y = stored[1];
        action.target_velocity_z = stored[2];
        action.jump_speed        = stored[3];
        isStrategyComputed = false;
    }


}

