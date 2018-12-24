#ifndef ALGEBRA_H
#define ALGEBRA_H

#include <iostream>
#include <cmath>

#include "Strategy.h"

using namespace model;

template<class T>
struct Vec3{
    T x;
    T y;
    T z;

    Vec3() : x(0), y(0), z(0){}
    Vec3(T x, T y, T z) : x(x), y(y), z(z){}

    template<class T0>
    Vec3 operator-(T0 v){
        return Vec3(x-v.x, y-v.y, z-v.z);
    }

    template<class L>
    double distanceTo(L s){
        return std::sqrt((x-s.x)*(x-s.x) +
                    (y-s.y)*(y-s.y) +
                    (z-s.z)*(z-s.z));
    }

    double norm(){
        return std::sqrt(x*x + y*y + z*z);
    }

    Vec3 maximize(){
        return Vec3(x *= 1000,
                    y *= 1000,
                    z *= 1000);
    }
};

typedef Vec3<double> Vec;

template<class T>
std::ostream& operator<<(std::ostream& out, Vec3<T> v){
    return out << "(" << v.x << "," << v.y << "," << v.z << ")";
}

template<class T>
Vec location(const T& t){
    return Vec(t.x,
               t.y,
               t.z);
}

template<class T>
Vec velocity(const T& t){
    return Vec(t.velocity_x,
               t.velocity_y,
               t.velocity_z);
}

bool isICloserToBall(const Robot& robot, const Game& game);

struct Algebra{
    const Robot&  me;
    const Rules&  rules;
    const Game&   game;
          Action& action;

    Algebra(const Robot& me, const Rules& rules, const Game& game, Action& action);

    bool isICloserToBall();

    const Robot& mate();

    void goTo(Vec);
    void goToBall();
    void goDefCenter();
    void setVelocity(Vec v);
    void jump(double speed = 1000);

    template<class S>
    double distanceToBall(const S& s){
        return location(game.ball).distanceTo(s);
    }
};
#endif
