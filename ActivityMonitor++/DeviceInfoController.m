//
//  DeviceInfoController.m
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <sys/sysctl.h>
#import "DeviceInfoController.h"

@interface DeviceInfoController()
- (NSString*)getMachineName;
@end

@implementation DeviceInfoController

#pragma mark - public

- (DeviceInfo*)getDeviceInfo
{
    DeviceInfo *deviceInfo = [[DeviceInfo alloc] init];
    
    deviceInfo.machineName = [self getMachineName];
    
    return deviceInfo;
}

#pragma mark - private

- (NSString*)getMachineName
{
    int query[] = { CTL_HW, HW_MACHINE };
    size_t strLen;
    
    if (sysctl(query, 2, NULL, &strLen, NULL, 0) == -1)
    {
        NSLog(@"%s: sysctl CTL_HW.HW_MACHINE length failed: %s",
              __PRETTY_FUNCTION__, strerror(errno));
    }
    
    char str[strLen];
    if (sysctl(query, 2, str, &strLen, NULL, 0) == -1)
    {
        NSLog(@"%s: sysctl CTL_HW.HW_MACHINE value failed: %s",
              __PRETTY_FUNCTION__, strerror(errno));
    }
    
    NSString *result = [NSString stringWithCString:str
                                          encoding:NSUTF8StringEncoding];
    return result;
}

@end
