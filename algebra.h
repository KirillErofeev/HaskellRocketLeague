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
    Vec3(const T0& v){
        x = v.x;
        y = v.y;
        z = v.z;
    }

    template<class T0>
    void operator=(const T0& v){
        x = v.x;
        y = v.y;
        z = v.z;
    }

    template<class T0>
    Vec3 operator-(const T0& v) const{
        return Vec3(x-v.x, y-v.y, z-v.z);
    }

    template<class T0>
    Vec3& operator-=(const T0& v) {
        x -= v.x;
        y -= v.y;
        z -= v.z;
        return *this;
    }

    template<class T0>
    Vec3& operator+=(const T0& v) {
        x += v.x;
        y += v.y;
        z += v.z;
        return *this;
    }

    template<class T0>
    Vec3 operator+(const T0& v) const{
        return Vec3(x+v.x, y+v.y, z+v.z);
    }

    template<class T0>
    double operator*(T0& v) const{
        return x*v.x + y*v.y + z*v.z;
    }

    Vec3 operator/(double v) const{
        return Vec3(x/v, y/v, z/v);
    }

    Vec3 operator*(double v) const{
        return Vec3(x*v, y*v, z*v);
    }

    template<class L>
    double distanceTo(L s) const{
        return std::sqrt((x-s.x)*(x-s.x) +
                    (y-s.y)*(y-s.y) +
                    (z-s.z)*(z-s.z));
    }

    double norm() const{
        return std::sqrt(x*x + y*y + z*z);
    }

    Vec3 maximize() const{
        return Vec3(x * 1000,
                    y * 1000,
                    z * 1000);
    }

    Vec3 normalize() const{
        return *this / this->norm();
    }

    Vec3 clamp(T max) const{
        double n = norm();
        if (n > max)
            return *this / n * max;
        return *this;

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

template<class T>
Vec touch_normal(const T& t){
    return Vec(t.touch_normal_x,
               t.touch_normal_y,
               t.touch_normal_z);
}

bool isICloserToBall(const Robot& robot, const Game& game);

struct Prediction{
    Vec position;   
    Vec velocity;   
    double radius;
    Prediction() : position(Vec()), velocity(Vec()), radius(0){}
};

template<class T, class D>
struct CollideInformation{
    D distance;
    Vec3<T> normal;

    CollideInformation(D d, Vec3<T> n) : distance(d), normal(n){};

    bool operator>(CollideInformation<T,D> c) const{
        return distance > c.distance;
    }

    bool operator<(CollideInformation<T,D> c) const{
        return distance < c.distance;
    }

    bool operator<=(CollideInformation<T,D> c) const{
        return distance <= c.distance;
    }

    bool operator>=(CollideInformation<T,D> c) const{
        return distance >= c.distance;
    }
};

typedef CollideInformation<double, double> CI;
struct Algebra{
    const Robot&  me;
    const Rules&  rules;
    const Game&   game;
          Action& action;

    const double TICK_DT = 0.01;

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

    Vec toBallVector();
    Vec toBallGroundVector();

    Vec chooseVel(Vec curVel, Vec vel, int ticks);
    Vec predictCurVelByVel(const Vec& curVelocity, const Vec& velocity, int ticks);
    Vec predictPosByVel(const Vec& position, const Vec& velocity, int ticks);
    void predict(
            std::vector<Prediction>& predictions, 
            double dt, double time,
            const Vec& velocity
            );
    void predictBall(
            std::vector<Prediction>& ballPredictions, 
            double dt, double time
            );
    int currentIndex();


    template <class T>
    CI CIToPlane(const T& p, const Vec& planeP, const Vec& normalP){
        return CI((p-planeP)*normalP, normalP);
    }

    template <class T>
    CI CIToInnerSphere(const T& p, const Vec& center, double radius){
        return CI(radius - (p - center).norm(), (center - p).normalize());
    }

    template <class T>
    CI CIToOuterSphere(const T& p, const Vec& center, double radius){
        return CI((p - center).norm() - radius , (p - center).normalize());
    }
    
    template <class T>
    CI CIToArenaQ(const T& p){
        CI c = CIToPlane(p, Vec(), Vec(0,1,0));
        c = std::min(c, CIToPlane(p, Vec(0,rules.arena.height,0) , Vec(0,-1,0)));
        c = std::min(c, CIToPlane(p, Vec(rules.arena.width/2,0,0), Vec(-1,0,0)));
        //Z
        Vec t = p; t.z=0;
        t -= Vec(rules.arena.goal_width/2 - rules.arena.goal_top_radius, 
                 rules.arena.goal_height  - rules.arena.goal_top_radius, 0);
        if (p.x >= rules.arena.goal_width/2 + rules.arena.goal_side_radius ||
            p.y >= rules.arena.goal_height  + rules.arena.goal_side_radius ||
            (t.x > 0 && t.y > 0 && t.norm() >= 
             rules.arena.goal_top_radius + rules.arena.goal_side_radius)){
            c = std::min(c, CIToPlane(p, Vec(0,0,rules.arena.depth/2), Vec(0,0,-1)));
        }
        //Corner
        if (p.x > rules.arena.width/2 - rules.arena.corner_radius && 
            p.z > rules.arena.depth/2 - rules.arena.corner_radius){
            Vec center = Vec(rules.arena.width/2 - rules.arena.corner_radius,
                             p.y,
                             rules.arena.depth/2 - rules.arena.corner_radius); 
            CI tc = CIToInnerSphere(p, center, rules.arena.corner_radius);
            c = std::min(c, tc);
        }
        ////Goal outer corner
        if (p.z < rules.arena.depth/2 + rules.arena.goal_side_radius){
            if (p.x < rules.arena.goal_width/2 + rules.arena.goal_side_radius){
                Vec center = Vec(rules.arena.goal_width/2 + rules.arena.goal_side_radius,
                                p.y,
                                rules.arena.depth/2 + rules.arena.goal_side_radius); 
                CI tc = CIToOuterSphere(p, center, rules.arena.goal_side_radius);
                c = std::min(c, tc);                
            }
            if (p.y < rules.arena.goal_height + rules.arena.goal_side_radius){
                Vec center = Vec(p.x,
                                rules.arena.goal_height + rules.arena.goal_side_radius,
                                rules.arena.depth/2 + rules.arena.goal_side_radius); 
                CI tc = CIToOuterSphere(p, center, rules.arena.goal_side_radius);
                c = std::min(c, tc);                
            }
            Vec goalCenter(rules.arena.goal_width/2 - rules.arena.goal_top_radius,
                              rules.arena.goal_height - rules.arena.goal_top_radius,
                              0);
            Vec v = p - goalCenter;
            v.z = 0;
            if (v.x > 0 && v.y > 0){
                Vec goalCenter0 = 
                        goalCenter + 
                        (v.normalize() * 
                        (rules.arena.goal_top_radius + rules.arena.goal_side_radius));
                CI tc = CIToOuterSphere(p,
                            Vec(goalCenter0.x, goalCenter0.y, 
                                rules.arena.depth/2 + rules.arena.goal_side_radius), 
                                rules.arena.goal_side_radius);
                c = std::min(c, tc);
            }
        }
        //Bottom corners (without side Z goal)
        if (p.y < rules.arena.bottom_radius){
            if (p.x > rules.arena.width/2 - rules.arena.bottom_radius){
                Vec center = Vec(rules.arena.width/2 - rules.arena.bottom_radius,
                                rules.arena.bottom_radius,
                                p.z); 
                CI tc = CIToInnerSphere(p, center, rules.arena.bottom_radius);
                c = std::min(c, tc);
            }
            if (p.z >  rules.arena.depth/2      - rules.arena.bottom_radius &&//check iT!
                p.x >= rules.arena.goal_width/2 + rules.arena.goal_side_radius){
                Vec center = Vec(p.x,
                                rules.arena.bottom_radius,
                                rules.arena.depth/2 - rules.arena.bottom_radius); 
                CI tc = CIToInnerSphere(p, center, rules.arena.bottom_radius);
                c = std::min(c, tc);
            }
            
        }
        //Goal outer corner
        Vec o(rules.arena.goal_width/2 + rules.arena.goal_side_radius,
              0,
              rules.arena.depth/2 + rules.arena.goal_side_radius);
        Vec v = p - o;
        if (v.x < 0 && v.z < 0 &&
            v.norm() < rules.arena.goal_side_radius + rules.arena.bottom_radius){
            Vec o1 = o + v.normalize() * (rules.arena.goal_side_radius + rules.arena.bottom_radius);
            Vec center = Vec(o1.x,
                             rules.arena.bottom_radius,
                             o1.z);
            CI tc = CIToInnerSphere(p, center, rules.arena.bottom_radius);
        
        }
        return c;
    
    }
     
    template <class T>
    CI CIToArena(const T& p){
        bool isXNegative = location(p).x < 0;    
        bool isZNegative = location(p).z < 0;    
    
        Vec p0 = location(p);
        p0.x = std::fabs(location(p).x);
        p0.z = std::fabs(location(p).z);
    
        CI c = CIToArenaQ(p0);
    
        if (isXNegative)
            c.normal.x = -c.normal.x;
        if (isZNegative)
            c.normal.z = -c.normal.z;
    
        return c;
    }
    
Prediction collideArena(const Ball& b);
Prediction& move(Prediction& p, const Ball& b, double dt);
Prediction& collideArena(Prediction& p, const Ball& b);
};



#endif
