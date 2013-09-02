//
//  LLWebViewDelegate.m
//  LuaLander
//
//  Created by Hisai Toru on 2013/08/23.
//  Copyright (c) 2013年 Kronecker's Delta Studio. All rights reserved.
//

#import "LLWebViewDelegate.h"

@implementation LLWebViewDelegate
@synthesize func_ref;

- (LLWebViewDelegate *)initWithFunc:(LuaObjectReference *)f {
    self = [super init];
    func_ref = f;
    return self;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    lua_State *L = [func_ref L];
    lua_rawgeti(L, LUA_REGISTRYINDEX, [func_ref ref]);
    lua_pushstring(L, [[[request URL] absoluteString] UTF8String]);
    luabridge_push_object(L, webView);
    if (lua_pcall(L, 2, 1, 0)) {
        NSLog(@"Lua Error: %s", lua_tostring(L, -1));
    }
    int sw = lua_toboolean(L, -1);
    
    return sw;
}
@end
