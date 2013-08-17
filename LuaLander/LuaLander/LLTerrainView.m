//
//  LLTerrainView.m
//  LuaLander
//
//  Created by Hisai Toru on 2013/08/15.
//  Copyright (c) 2013年 Kronecker's Delta Studio. All rights reserved.
//

#import "LLTerrainView.h"

@implementation LLTerrainView
@synthesize drawRectFunc;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDrawRect:(LuaObjectReference*)func
{
    drawRectFunc = func;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    lua_State *L = drawRectFunc.L;
    int ref = drawRectFunc.ref;
    
    lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
    luabridge_push_object(L, [NSValue valueWithCGRect:rect]);
    if (lua_pcall(L, 1, 0, 0)) {
        NSLog(@"Lua Error: %s", lua_tostring(L, -1));
    }
}


@end
