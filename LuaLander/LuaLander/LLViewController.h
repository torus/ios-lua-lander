//
//  LLViewController.h
//  LuaLander
//
//  Created by Hisai Toru on 2013/08/06.
//  Copyright (c) 2013年 Kronecker's Delta Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface LLViewController : UIViewController {
    int gameState;
    CFTimeInterval startTime;
}
@property CMMotionManager *motionManager;
@end
