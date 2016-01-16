//
//  AMDevice.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>
#import "DeviceInfo.h"
#import "CPUInfo.h"
#import "GPUInfo.h"
#import "RAMInfo.h"
#import "NetworkInfo.h"
#import "StorageInfo.h"
#import "BatteryInfo.h"

#define kDefaultDataHistorySize     300

#define kCpuLoadUpdateFrequency     2
#define kRamUsageUpdateFrequency    1
#define kNetworkUpdateFrequency     1

@interface AMDevice : NSObject
@property (nonatomic, strong, readonly) DeviceInfo     *deviceInfo;
@property (nonatomic, strong, readonly) CPUInfo        *cpuInfo;
@property (nonatomic, strong, readonly) GPUInfo        *gpuInfo;
@property (nonatomic, copy, readonly)   NSArray        *processes;
@property (nonatomic, strong, readonly) RAMInfo        *ramInfo;
@property (nonatomic, strong, readonly) NetworkInfo    *networkInfo;
@property (nonatomic, strong, readonly) StorageInfo    *storageInfo;
@property (nonatomic, strong, readonly) BatteryInfo    *batteryInfo;

- (void)refreshStorageInfo;
@end
