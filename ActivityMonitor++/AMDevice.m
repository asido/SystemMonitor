//
//  AMDevice.m
//  ActivityMonitor++
//
//  Created by st on 08/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMUtils.h"
#import "AppDelegate.h"
#import "HardcodedDeviceData.h"
#import "DeviceInfoController.h"
#import "CPUInfoController.h"
#import "AMDevice.h"

@interface AMDevice()
@end

@implementation AMDevice
{
    DeviceInfo  *_deviceInfo;
    CPUInfo     *_cpuInfo;
    GPUInfo     *_gpuInfo;
}

- (id)init
{
    if ([super init])
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

@end
