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
@end

@implementation AMDevice
{
    DeviceInfo  *_deviceInfo;
    CPUInfo     *_cpuInfo;
    GPUInfo     *_gpuInfo;
    NSArray     *_processes;
    RAMInfo     *_ramInfo;
    NetworkInfo *_networkInfo;
    StorageInfo *_storageInfo;
    BatteryInfo *_batteryInfo;
}

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
        _deviceInfo = [app.deviceInfoCtrl getDeviceInfo];
        _cpuInfo = [app.cpuInfoCtrl getCPUInfo];
        _gpuInfo = [app.gpuInfoCtrl getGPUInfo];
        _processes = [app.processInfoCtrl getProcesses];
        _ramInfo = [app.ramInfoCtrl getRAMInfo];
        _networkInfo = [app.networkInfoCtrl getNetworkInfo];
        _storageInfo = [app.storageInfoCtrl getStorageInfo];
        _batteryInfo = [app.batteryInfoCtrl getBatteryInfo];
    }
    return self;
}

- (DeviceInfo*)getDeviceInfo
{
    return _deviceInfo;
}

- (CPUInfo*)getCpuInfo
{
    return _cpuInfo;
}

- (NSArray*)getProcesses
{
    return _processes;
}

#pragma mark - public

- (void)refreshProcesses
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    _processes = [app.processInfoCtrl getProcesses];
}

- (void)refreshStorageInfo
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    _storageInfo = [app.storageInfoCtrl getStorageInfo];
}

@end
