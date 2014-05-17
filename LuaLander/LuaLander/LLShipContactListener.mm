//
//  LLShipContactListener.cpp
//  LuaLander
//
//  Created by Hisai Toru on 2013/08/20.
//  Copyright (c) 2013年 Kronecker's Delta Studio. All rights reserved.
//

#include "LLShipContactListener.h"
#include "LuaBridge.h"
#include "lua.hpp"

// defined in SWIG interface
void process_impulses(lua_State *L, b2Contact* contact, const b2ContactImpulse *imp, int table_ref);

LLShipContactListener::LLShipContactListener(int ref)
: table_ref_(ref)
{
}

void LLShipContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
    lua_State *L = [[LuaBridge instance] L];
    process_impulses(L, contact, impulse, table_ref_);
}
