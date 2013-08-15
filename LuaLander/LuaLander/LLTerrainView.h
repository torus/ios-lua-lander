//
//  LLTerrainView.h
//  LuaLander
//
//  Created by Hisai Toru on 2013/08/15.
//  Copyright (c) 2013年 Kronecker's Delta Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LuaBridge.h"

@interface LLTerrainView : UIView
- (void)setDrawRect:(LuaObjectReference*)func;

@property LuaObjectReference *drawRectFunc;
@end
