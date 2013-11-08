//
//  AppDelegate.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
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
#import "DeviceSpecificUI.h"

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

@property (strong, nonatomic) DeviceSpecificUI      *deviceSpecificUI;

+ (AppDelegate*)sharedDelegate;
@end
