//
//  DeviceInfoController.m
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMUtils.h"
#import "HardcodedDeviceData.h"
#import "DeviceInfoController.h"

@interface DeviceInfoController()
- (const NSString*)getDeviceName;
@end

@implementation DeviceInfoController

#pragma mark - public

- (DeviceInfo*)getDeviceInfo
{
    DeviceInfo *deviceInfo = [[DeviceInfo alloc] init];
    
    deviceInfo.deviceName = [self getDeviceName];
    
    return deviceInfo;
}

#pragma mark - private

- (const NSString*)getDeviceName
{
    HardcodedDeviceData *hardcodeData = [HardcodedDeviceData sharedDeviceData];
    return [hardcodeData getiDeviceName];
}

@end
