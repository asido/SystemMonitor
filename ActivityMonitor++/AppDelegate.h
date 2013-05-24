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
#import "RAMInfoController.h"
#import "ProcessInfoController.h"
#import "NetworkInfoController.h"
#import "StorageInfoController.h"
#import "BatteryInfoController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow  *window;

@property (strong, nonatomic) AMDevice              *iDevice;
@property (strong, nonatomic) CPUInfoController     *cpuInfoCtrl;
@property (strong, nonatomic) DeviceInfoController  *deviceInfoCtrl;
@property (strong, nonatomic) GPUInfoController     *gpuInfoCtrl;
@property (strong, nonatomic) ProcessInfoController *processInfoCtrl;
@property (strong, nonatomic) RAMInfoController     *ramInfoCtrl;
@property (strong, nonatomic) NetworkInfoController *networkInfoCtrl;
@property (strong, nonatomic) StorageInfoController *storageInfoCtrl;
@property (strong, nonatomic) BatteryInfoController *batteryInfoCtrl;

+ (AppDelegate*)sharedDelegate;
@end
