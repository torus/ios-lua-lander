//
//  LLViewController.m
//  LuaLander
//
//  Created by Hisai Toru on 2013/08/06.
//  Copyright (c) 2013年 Kronecker's Delta Studio. All rights reserved.
//

#import "LLViewController.h"
#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"
#import "LuaBridge.h"

@interface LLViewController ()

@end

@implementation LLViewController
@synthesize motionManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self->startTime = CACurrentMediaTime();
    
    lua_State *L = [[LuaBridge instance] L];
    lua_getglobal(L, "create");
    lua_pushlightuserdata(L, (__bridge void *)(self));
    if (lua_pcall(L, 1, 1, 0)) {
        fprintf(stderr, "Lua Error: %s", lua_tostring(L, -1));
    }
    self->gameState = luaL_ref(L, LUA_REGISTRYINDEX);
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = 1.0 / 60.0;
    [motionManager startAccelerometerUpdates];

    [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(onInterval:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onInterval:(NSTimer*)theTimer {
    CFTimeInterval elapsedTime = CACurrentMediaTime() - self->startTime;
    CMAcceleration acc = motionManager.accelerometerData.acceleration;

    lua_State *L = [[LuaBridge instance] L];
    lua_getglobal(L, "update");
    lua_rawgeti(L, LUA_REGISTRYINDEX, self->gameState);
    lua_pushnumber(L, elapsedTime);
    lua_pushnumber(L, acc.x);
    lua_pushnumber(L, acc.y);
    lua_pushnumber(L, acc.z);

    if (lua_pcall(L, 5, 0, 0)) {
        fprintf(stderr, "Lua Error: %s", lua_tostring(L, -1));
    }
}

@end
