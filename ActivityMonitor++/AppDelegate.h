//
//  AppDelegate.h
//  ActivityMonitor++
//
//  Created by st on 06/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMDevice.h"
#import "DeviceInfoController.h"
#import "CPUInfoController.h"
#import "GPUInfoController.h"
#import "ProcessInfoController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow  *window;

@property (strong, nonatomic) AMDevice             *iDevice;
@property (strong, nonatomic) CPUInfoController    *cpuInfoCtrl;
@property (strong, nonatomic) DeviceInfoController *deviceInfoCtrl;
@property (strong, nonatomic) GPUInfoController    *gpuInfoCtrl;
@property (strong, nonatomic) ProcessInfoController *processInfoCtrl;

+ (AppDelegate*)sharedDelegate;
@end
