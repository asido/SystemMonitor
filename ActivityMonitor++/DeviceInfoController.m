//
//  DeviceInfoController.m
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <sys/sysctl.h>
#import "AMUtils.h"
#import "HardcodedDeviceData.h"
#import "DeviceInfoController.h"

@interface DeviceInfoController()
- (const NSString*)getDeviceName;
- (NSString*)getHostName;
- (NSString*)getOSType;
- (NSString*)getOSVersion;
- (NSString*)getOSBuild;
- (NSInteger)getOSRevision;
- (NSString*)getKernelInfo;
- (NSUInteger)getMaxVNodes;
- (NSUInteger)getMaxProcesses;
- (NSUInteger)getMaxFiles;
- (NSUInteger)getTickFrequency;
- (NSUInteger)getNumberOfGroups;
- (time_t)getBootTime;
- (BOOL)getSafeBoot;
@end

@implementation DeviceInfoController

#pragma mark - public

- (DeviceInfo*)getDeviceInfo
{
    DeviceInfo *deviceInfo = [[DeviceInfo alloc] init];
    
    deviceInfo.deviceName = [self getDeviceName];
    deviceInfo.hostName = [self getHostName];
    deviceInfo.osName = @"iOS";
    deviceInfo.osType = [self getOSType];
    deviceInfo.osVersion = [self getOSVersion];
    deviceInfo.osBuild = [self getOSBuild];
    deviceInfo.osRevision = [self getOSRevision];
    deviceInfo.kernelInfo = [self getKernelInfo];
    deviceInfo.maxVNodes = [self getMaxVNodes];
    deviceInfo.maxProcesses = [self getMaxProcesses];
    deviceInfo.maxFiles = [self getMaxFiles];
    deviceInfo.tickFrequency = [self getTickFrequency];
    deviceInfo.numberOfGroups = [self getNumberOfGroups];
    deviceInfo.bootTime = [self getBootTime];
    deviceInfo.safeBoot = [self getSafeBoot];
    
    return deviceInfo;
}

#pragma mark - private

- (const NSString*)getDeviceName
{
    HardcodedDeviceData *hardcodeData = [HardcodedDeviceData sharedDeviceData];
    return [hardcodeData getiDeviceName];
}

- (NSString*)getHostName
{
    return [AMUtils getSysCtlChrWithSpecifier:"kern.hostname"];
}

- (NSString*)getOSType
{
    return [AMUtils getSysCtlChrWithSpecifier:"kern.ostype"];
}

- (NSString*)getOSVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString*)getOSBuild
{
    return [AMUtils getSysCtlChrWithSpecifier:"kern.osversion"];
}

- (NSInteger)getOSRevision
{
    return [AMUtils getSysCtl64WithSpecifier:"kern.osrevision"];
}

- (NSString*)getKernelInfo
{
    return [AMUtils getSysCtlChrWithSpecifier:"kern.version"];
}

- (NSUInteger)getMaxVNodes
{
    return [AMUtils getSysCtl64WithSpecifier:"kern.maxvnodes"];
}

- (NSUInteger)getMaxProcesses
{
    return [AMUtils getSysCtl64WithSpecifier:"kern.maxproc"];
}

- (NSUInteger)getMaxFiles
{
    return [AMUtils getSysCtl64WithSpecifier:"kern.maxfiles"];
}

- (NSUInteger)getTickFrequency
{
    struct clockinfo clockInfo;
    
    [AMUtils getSysCtlPtrWithSpecifier:"kern.clockrate" pointer:&clockInfo size:sizeof(struct clockinfo)];
    return clockInfo.hz;
}

- (NSUInteger)getNumberOfGroups
{
    return [AMUtils getSysCtl64WithSpecifier:"kern.ngroups"];
}

- (time_t)getBootTime
{
    struct timeval bootTime;
    
    [AMUtils getSysCtlPtrWithSpecifier:"kern.boottime" pointer:&bootTime size:sizeof(struct timeval)];
    return bootTime.tv_sec;
}

- (BOOL)getSafeBoot
{
    return [AMUtils getSysCtl64WithSpecifier:"kern.safeboot"] > 0;
}

@end
