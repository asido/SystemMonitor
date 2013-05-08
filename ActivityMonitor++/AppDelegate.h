//
//  AppDelegate.h
//  ActivityMonitor++
//
//  Created by st on 06/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMDevice.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (retain) AMDevice *iDevice;

+ (AppDelegate*)sharedDelegate;
@end
