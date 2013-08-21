//
//  LLShipContactListener.h
//  LuaLander
//
//  Created by Hisai Toru on 2013/08/20.
//  Copyright (c) 2013年 Kronecker's Delta Studio. All rights reserved.
//

#ifndef __LuaLander__LLShipContactListener__
#define __LuaLander__LLShipContactListener__

#include <iostream>
#include <Box2D/Box2D.h>

class LLShipContactListener : public b2ContactListener {
public:
    LLShipContactListener(int ref);
//    void BeginContact(b2Contact* contact);
//    void EndContact(b2Contact* contact);
//    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
private:
    LLShipContactListener();
    int table_ref_;
};

#endif /* defined(__LuaLander__LLShipContactListener__) */
