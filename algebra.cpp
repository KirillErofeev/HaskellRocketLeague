#include <algorithm>
#include <iostream>

#include "model/Ball.h"

#include "Strategy.h"

#include "consts.h"

#include "algebra.h"

using namespace model;

Algebra::Algebra(
        const Robot& me, const Rules& rules, const Game& game, Action& action)
    : me(me), rules(rules), game(game), action(action){}

const Robot& Algebra::mate(){
    for(const auto& r : game.robots){
        if(r.is_teammate && (r.id != me.id)){
            return r;
        }
    }
}


//CI CIToPlane(Vec p, Vec planeP, Vec normalP){
//    return CI
//}

//Is i'm closer to the ball than my mate
bool Algebra::isICloserToBall(){
    return distanceToBall(me) <= distanceToBall(mate());
}

void Algebra::setVelocity(Vec v){
    action.target_velocity_x = v.x;
    action.target_velocity_y = v.y;
    action.target_velocity_z = v.z;
}

void Algebra::goTo(Vec d){
    setVelocity((location(d) - location(me)).maximize());
}

Vec Algebra::toBallVector(){
    return location(game.ball) - location(me);
}

Vec Algebra::toBallGroundVector(){
    Vec v = location(game.ball) - location(me);
    v.y = 0;
    return v;
}

void Algebra::goToBall(){
    setVelocity(toBallGroundVector().maximize());
}

void Algebra::jump(double speed){
    action.jump_speed = speed;
}

void Algebra::goDefCenter(){
    goTo(Vec(0, 0, -0.5*rules.arena.depth));
}

//void Algebra::predictBall(std::vector<Prediction>& ballPredictions, int ticks){
//    Vec pos = location(game.ball);
//    Vec vel = velocity(game.ball);
//    
//    int ct = game.current_tick / TICK_DT + 1;
//    int ticksToCt = ct*TICK_DT - game.current_tick;
//    
//    //predictions[ct].fPosition = 
//}

//Prediction predict(const Ball& ball, int ticks){
//    Prediction p;
//    
//    //p.fPosition = 
//}

Vec Algebra::predictCurVelByVel(const Vec& curVelocity, const Vec& velocity, int ticks){
    //Vec n = (curVelocity - velocity).normalize();
    //velocity + (curVelocity - velocity) * () * ROBOT_ACCELERATION * ticks;
    //return velocity + (curVelocity - velocity) * ROBOT_ACCELERATION * ticks;
}

Vec Algebra::predictPosByVel(const Vec& position, const Vec& velocity, int ticks){
    
    return velocity*ticks/TICKS_PER_SECOND + position;
}

Vec Algebra::chooseVel(Vec curVel, Vec vel, int ticks){
    if(ticks < ROBOT_MAX_GROUND_SPEED/ROBOT_ACCELERATION*TICKS_PER_SECOND*2)
        return (curVel - vel)/2;
    return vel;

}

//void Algebra::predict(std::vector<Prediction>& predictions,
//                      double dt,//is TICK_DT
//                      double time,
//                      const Vec& curVelocity,
//                      const Vec& velocity)
//{
//    int ct = game.current_tick / TICK_DT + 1;
//    int ticksToCt = ct*TICK_DT - game.current_tick;
//
//    //predictions[ct].fVelocity = predictCurVelByVel(curVelocity, velocity, ticksToCt);
//    //predictions[ct].fPosition = 
//    //    predictPosByVel(location(me), chooseVel(curVelocity, velocity, ticksToCt), ticksToCt);
//
//    //for(int i = 1; i*dt*TICKS_PER_SECOND<=time; ++i){
//    //    predictions[ct].fVelocity = predictCurVelByVel(predictions[ct+(i-1)*dt].fVelocity, velocity, ticksToCt);
//    //    predictions[ct + i*dt].fPosition = 
//    //        predictPosByVel(
//    //                predictions[ct+(i-1)*dt].fPosition,
//    //                chooseVel(predictions[ct+(i-1)*dt].fVelocity, 
//    //                          predictions[ct+i*dt].fVelocity, dt*TICK_DT),
//    //                dt*TICK_DT);
//    //}
//    
//    
//    
//}
