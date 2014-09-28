//
//  DeviceInfoController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <sys/sysctl.h>
#import "AMUtils.h"
#import "HardcodedDeviceData.h"
#import "DeviceInfoController.h"

@interface DeviceInfoController()
@property (nonatomic, strong) DeviceInfo    *deviceInfo;

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

- (NSString*)getScreenResolution;
- (CGFloat)getScreenSize;
- (BOOL)isRetina;
- (NSUInteger)getPPI;
- (NSString*)getAspectRatio;
@end

@implementation DeviceInfoController
@synthesize deviceInfo;

#pragma mark - override

- (id)init
{
    if (self = [super init])
    {
        self.deviceInfo = [[DeviceInfo alloc] init];
    }
    return self;
}

#pragma mark - public

- (DeviceInfo*)getDeviceInfo
{
    self.deviceInfo.deviceName = [self getDeviceName];
    self.deviceInfo.hostName = [self getHostName];
    self.deviceInfo.osName = @"iOS";
    self.deviceInfo.osType = [self getOSType];
    self.deviceInfo.osVersion = [self getOSVersion];
    self.deviceInfo.osBuild = [self getOSBuild];
    self.deviceInfo.osRevision = [self getOSRevision];
    self.deviceInfo.kernelInfo = [self getKernelInfo];
    self.deviceInfo.maxVNodes = [self getMaxVNodes];
    self.deviceInfo.maxProcesses = [self getMaxProcesses];
    self.deviceInfo.maxFiles = [self getMaxFiles];
    self.deviceInfo.tickFrequency = [self getTickFrequency];
    self.deviceInfo.numberOfGroups = [self getNumberOfGroups];
    self.deviceInfo.bootTime = [self getBootTime];
    self.deviceInfo.safeBoot = [self getSafeBoot];
    self.deviceInfo.screenResolution = [self getScreenResolution];
    self.deviceInfo.screenSize = [self getScreenSize];
    self.deviceInfo.retina = [self isRetina];
    self.deviceInfo.retinaHD = [self isRetinaHD];
    self.deviceInfo.ppi = [self getPPI];
    self.deviceInfo.aspectRatio = [self getAspectRatio];
    
    return self.deviceInfo;
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

- (NSString*)getScreenResolution
{
    CGRect dimension = [UIScreen mainScreen].bounds;                    // Dimensions are flipped over.
    CGFloat scale = [UIScreen mainScreen].scale;
    NSString *resolution = [NSString stringWithFormat:@"%0.0fx%0.0f", dimension.size.height * scale, dimension.size.width * scale];
    return resolution;
}

- (CGFloat)getScreenSize
{
    HardcodedDeviceData *hardcode = [HardcodedDeviceData sharedDeviceData];
    return [hardcode getScreenSize];
}

- (BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0 || [UIScreen mainScreen].scale == 3.0));
}

- (BOOL)isRetinaHD
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            [UIScreen mainScreen].scale == 3.0);
}

- (NSUInteger)getPPI
{
    HardcodedDeviceData *hardcode = [HardcodedDeviceData sharedDeviceData];
    return [hardcode getPPI];
}

- (NSString*)getAspectRatio
{
    HardcodedDeviceData *hardcode = [HardcodedDeviceData sharedDeviceData];
    return [hardcode getAspectRatio];
}

@end
