#include <algorithm>
#include <iostream>

#include "Strategy.h"

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

void Algebra::goToBall(){
    setVelocity((location(game.ball) - location(me)).maximize());
}

void Algebra::jump(double speed){
    action.jump_speed = speed;
}

void Algebra::goDefCenter(){
    goTo(Vec(0, 0, -0.5*rules.arena.depth));
}

