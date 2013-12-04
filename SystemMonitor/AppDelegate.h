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
@property (nonatomic, strong) UIWindow  *window;

@property (nonatomic, strong) AMDevice              *iDevice;
@property (nonatomic, strong) CPUInfoController     *cpuInfoCtrl;
@property (nonatomic, strong) DeviceInfoController  *deviceInfoCtrl;
@property (nonatomic, strong) GPUInfoController     *gpuInfoCtrl;
@property (nonatomic, strong) ProcessInfoController *processInfoCtrl;
@property (nonatomic, strong) RAMInfoController     *ramInfoCtrl;
@property (nonatomic, strong) NetworkInfoController *networkInfoCtrl;
@property (nonatomic, strong) StorageInfoController *storageInfoCtrl;
@property (nonatomic, strong) BatteryInfoController *batteryInfoCtrl;

@property (nonatomic, strong) DeviceSpecificUI      *deviceSpecificUI;

+ (AppDelegate*)sharedDelegate;
@end
