//
//  LLWebViewDelegate.h
//  LuaLander
//
//  Created by Hisai Toru on 2013/08/23.
//  Copyright (c) 2013年 Kronecker's Delta Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LuaBridge.h"

@interface LLWebViewDelegate : NSObject <UIWebViewDelegate>
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (LLWebViewDelegate *)initWithFunc:(LuaObjectReference *)f;
@property LuaObjectReference *func_ref;
@end
