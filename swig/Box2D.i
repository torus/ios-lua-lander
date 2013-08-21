%module b2

%{
#include <iostream>
#include <vector>
#include <Box2D/Box2D.h>
#include "LLShipContactListener.h"

// workaround
void b2WheelJoint::GetDefinition(b2WheelJointDef*) const {}

void process_impulses(lua_State *L, const b2ContactImpulse *imp, int table_ref)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, table_ref);
    lua_pushstring(L, "got_impulses");
    lua_gettable(L, -2);
    if (!lua_isfunction(L, -1)) {
        std::cerr << "got_impulses function not found" << std::endl;
        lua_pop(L, 1);
        return;
    }
    lua_insert(L, -2);
    /* SWIG_NewPointerObj(L,imp,SWIGTYPE_p_b2ContactImpulse,1); */
    lua_newtable(L);
    for (int i = 0; i < imp->count; i ++) {
        /* std::cout << i << " " << imp->normalImpulses[i] << std::endl; */
        lua_pushinteger(L, i + 1);
        lua_pushnumber(L, imp->normalImpulses[i]);
        lua_settable(L, -3);
    }
    if (lua_pcall(L, 2, 0, 0)) {
        std::cerr << "Lua Error: " << lua_tostring(L, -1) << std::endl;
    }
}

int create_contact_listener(lua_State *L)
{
  int SWIG_arg = 0;

  SWIG_check_num_args("create_contact_listener",1,1);
  {

  int ref = luaL_ref(L, LUA_REGISTRYINDEX);

  b2ContactListener *lis = new LLShipContactListener(ref);

  SWIG_NewPointerObj(L,lis,SWIGTYPE_p_b2ContactListener,1); SWIG_arg++; 

  return SWIG_arg;
  }
fail:
  lua_error(L);
  return SWIG_arg;    
}

%}

%native(create_contact_listener) int create_contact_listener(lua_State *L);

%include "../LuaLander/LuaLander/LLShipContactListener.h"

%typemap(in, numinputs=1, checkfn="lua_istable") (const b2Vec2* vertices, int32 vertexCount) (std::vector<b2Vec2> arr) {
    int n=0;
    while(1){
        lua_rawgeti(L,$argnum,n+1);
        if (lua_isnil(L,-1))break;
        ++n;

        b2Vec2 *ptr;
        if (!SWIG_IsOK(SWIG_ConvertPtr(L,-1,(void**)&ptr,SWIGTYPE_p_b2Vec2,0))){
            SWIG_fail_ptr("$symname",1,SWIGTYPE_p_b2Vec2);
        }
        arr.push_back(*ptr);

        lua_pop(L,1);
    }
    lua_pop(L,1);

    $1 = &arr.front();
    $2 = arr.size();
    // hehehehe
}

%include <Box2D/Common/b2Settings.h>
%include <Box2D/Common/b2Draw.h>
%include <Box2D/Common/b2Timer.h>

%include <Box2D/Common/b2Math.h>

%include <Box2D/Collision/Shapes/b2CircleShape.h>
%include <Box2D/Collision/Shapes/b2EdgeShape.h>
%include <Box2D/Collision/Shapes/b2ChainShape.h>
%include <Box2D/Collision/Shapes/b2PolygonShape.h>

%include <Box2D/Collision/b2BroadPhase.h>
%include <Box2D/Collision/b2Distance.h>
%include <Box2D/Collision/b2DynamicTree.h>
%include <Box2D/Collision/b2TimeOfImpact.h>

%include <Box2D/Dynamics/b2Body.h>
%include <Box2D/Dynamics/b2Fixture.h>
%include <Box2D/Dynamics/b2WorldCallbacks.h>
%include <Box2D/Dynamics/b2TimeStep.h>
%include <Box2D/Dynamics/b2World.h>

%include <Box2D/Dynamics/Contacts/b2Contact.h>

%include <Box2D/Dynamics/Joints/b2DistanceJoint.h>
%include <Box2D/Dynamics/Joints/b2FrictionJoint.h>
%include <Box2D/Dynamics/Joints/b2GearJoint.h>
%include <Box2D/Dynamics/Joints/b2WheelJoint.h>
%include <Box2D/Dynamics/Joints/b2MouseJoint.h>
%include <Box2D/Dynamics/Joints/b2PrismaticJoint.h>
%include <Box2D/Dynamics/Joints/b2PulleyJoint.h>
%include <Box2D/Dynamics/Joints/b2RevoluteJoint.h>
%include <Box2D/Dynamics/Joints/b2RopeJoint.h>
%include <Box2D/Dynamics/Joints/b2WeldJoint.h>

%native(convertB2BodyPtr) int native_convertB2BodyPtr(lua_State *L);

%{
int native_convertB2BodyPtr(lua_State *L)
{
  int SWIG_arg = 0;
  const void *ptr = lua_topointer(L, -1);

  SWIG_check_num_args("convertB2BodyPtr",1,1)

  SWIG_NewPointerObj(L,(b2Body*)ptr,SWIGTYPE_p_b2Body,0); SWIG_arg++; 

  return SWIG_arg;

fail:
  lua_error(L);
  return SWIG_arg;
}

%}
///////////////////////////////////////////////////////////
