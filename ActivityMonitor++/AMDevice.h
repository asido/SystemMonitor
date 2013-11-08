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
@property (readonly) DeviceInfo     *deviceInfo;
@property (readonly) CPUInfo        *cpuInfo;
@property (readonly) GPUInfo        *gpuInfo;
@property (readonly) NSArray        *processes;
@property (readonly) RAMInfo        *ramInfo;
@property (readonly) NetworkInfo    *networkInfo;
@property (readonly) StorageInfo    *storageInfo;
@property (readonly) BatteryInfo    *batteryInfo;

- (void)refreshProcesses;
- (void)refreshStorageInfo;
@end
