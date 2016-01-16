//
//  AMDevice.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AMUtils.h"
#import "AppDelegate.h"
#import "HardcodedDeviceData.h"
#import "DeviceInfoController.h"
#import "CPUInfoController.h"
#import "DeviceInfo.h"
#import "CPUInfo.h"
#import "GPUInfo.h"
#import "AMDevice.h"

@interface AMDevice()
// Overriden
@property (nonatomic, strong) DeviceInfo     *deviceInfo;
@property (nonatomic, strong) CPUInfo        *cpuInfo;
@property (nonatomic, strong) GPUInfo        *gpuInfo;
@property (nonatomic, copy)   NSArray        *processes;
@property (nonatomic, strong) RAMInfo        *ramInfo;
@property (nonatomic, strong) NetworkInfo    *networkInfo;
@property (nonatomic, strong) StorageInfo    *storageInfo;
@property (nonatomic, strong) BatteryInfo    *batteryInfo;
@end

@implementation AMDevice
@synthesize deviceInfo;
@synthesize cpuInfo;
@synthesize gpuInfo;
@synthesize processes;
@synthesize ramInfo;
@synthesize networkInfo;
@synthesize storageInfo;
@synthesize batteryInfo;

- (id)init
{
    if (self = [super init])
    {
        // Warning: since we rely a lot on hardcoded data, hw.machine must be retrieved
        // before everything else!
        NSString *hwMachine = [AMUtils getSysCtlChrWithSpecifier:"hw.machine"];
        HardcodedDeviceData *hardcodeData = [HardcodedDeviceData sharedDeviceData];
        [hardcodeData setHwMachine:hwMachine];
        
        AppDelegate *app = [AppDelegate sharedDelegate];
        deviceInfo = [app.deviceInfoCtrl getDeviceInfo];
        cpuInfo = [app.cpuInfoCtrl getCPUInfo];
        gpuInfo = [app.gpuInfoCtrl getGPUInfo];
        ramInfo = [app.ramInfoCtrl getRAMInfo];
        networkInfo = [app.networkInfoCtrl getNetworkInfo];
        storageInfo = [app.storageInfoCtrl getStorageInfo];
        batteryInfo = [app.batteryInfoCtrl getBatteryInfo];
    }
    return self;
}

- (DeviceInfo*)getDeviceInfo
{
    return deviceInfo;
}

- (CPUInfo*)getCpuInfo
{
    return cpuInfo;
}

- (NSArray*)getProcesses
{
    return processes;
}

#pragma mark - public

- (void)refreshStorageInfo
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    storageInfo = [app.storageInfoCtrl getStorageInfo];
}

@end
