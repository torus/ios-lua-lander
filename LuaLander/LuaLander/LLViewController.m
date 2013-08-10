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
    
    [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(onInterval:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onInterval:(NSTimer*)theTimer {
    CFTimeInterval elapsedTime = CACurrentMediaTime() - self->startTime;

    lua_State *L = [[LuaBridge instance] L];
    lua_getglobal(L, "update");
    lua_rawgeti(L, LUA_REGISTRYINDEX, self->gameState);
    lua_pushnumber(L, elapsedTime);

    if (lua_pcall(L, 2, 0, 0)) {
        fprintf(stderr, "Lua Error: %s", lua_tostring(L, -1));
    }
}

@end
