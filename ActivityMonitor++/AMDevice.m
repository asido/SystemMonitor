//
//  AMDevice.m
//  ActivityMonitor++
//
//  Created by st on 08/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMUtils.h"
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
        
        _deviceInfo = [[[DeviceInfoController alloc] init] getDeviceInfo];
        _cpuInfo = [[[CPUInfoController alloc] init] getCpuInfo];
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
