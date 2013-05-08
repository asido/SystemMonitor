//
//  HardcodedData.m
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "HardcodedDeviceData.h"

typedef enum {
    iPhone_1G=0,
    iPhone_3G,
    iPhone_3GS,
    iPhone_4,
    iPhone_4_Verizon,
    iPhone_4S,
    iPhone_5_GSM,
    iPhone_5_CDMA,
    iPod_Touch_1G,
    iPod_Touch_2G,
    iPod_Touch_3G,
    iPod_Touch_4G,
    iPod_Touch_5,
    iPad_1,
    iPad_2_WiFi,
    iPad_2_GSM,
    iPad_2_CDMA,
    iPad_3_WiFi,
    iPad_3_GSM,
    iPad_3_CDMA,
    iPad_4_WiFi,
    iPad_4_GSM,
    iPad_4_CDMA,
    iPad_Mini_WiFi,
    iPad_Mini_GSM,
    iPad_Mini_CDMA,
    iUnknown
} iDevice_t;

@interface HardcodedDeviceData()
@property (assign) iDevice_t iDevice;

- (iDevice_t)hwMachineToIdevice:(NSString*)hwMachine;
@end

@implementation HardcodedDeviceData
@synthesize iDevice;

static const NSString *iDeviceNameTable[] = {
    [iPhone_1G]         = @"iPhone 1G",
    [iPhone_3G]         = @"iPhone 3G",
    [iPhone_3GS]        = @"iPhone 3GS",
    [iPhone_4]          = @"iPhone 4",
    [iPhone_4_Verizon]  = @"Verizon iPhone 4",
    [iPhone_4S]         = @"iPhone 4S",
    [iPhone_5_GSM]      = @"iPhone 5 (GSM)",
    [iPhone_5_CDMA]     = @"iPhone 5 (CDMA)",
    [iPod_Touch_1G]     = @"iPod Touch 1G",
    [iPod_Touch_2G]     = @"iPod Touch 2G",
    [iPod_Touch_3G]     = @"iPod Touch 3G",
    [iPod_Touch_4G]     = @"iPod Touch 4G",
    [iPod_Touch_5]      = @"iPod Touch 5",
    [iPad_1]            = @"iPad 1",
    [iPad_2_CDMA]       = @"iPad 2 (GSM)",
    [iPad_2_GSM]        = @"iPad 2 (CDMA)",
    [iPad_2_WiFi]       = @"iPad 2 (WiFi)",
    [iPad_3_WiFi]       = @"iPad 3 (WiFi)",
    [iPad_3_GSM]        = @"iPad 3 (GSM)",
    [iPad_3_CDMA]       = @"iPad 3 (CDMA)",
    [iPad_4_WiFi]       = @"iPad 4 (WiFi)",
    [iPad_4_GSM]        = @"iPad 4 (GSM)",
    [iPad_4_CDMA]       = @"iPad 4 (CDMA)",
    [iPad_Mini_WiFi]    = @"iPad Mini (WiFi)",
    [iPad_Mini_GSM]     = @"iPad Mini (GSM)",
    [iPad_Mini_CDMA]    = @"iPad Mini (CDMA)",
    [iUnknown]          = @"Unknown"
};

static const NSUInteger CPUFrequencyTable[] = {
    [iPhone_1G]         = 412,
    [iPhone_3G]         = 620,
    [iPhone_3GS]        = 600,
    [iPhone_4]          = 800,
    [iPhone_4_Verizon]  = 800,
    [iPhone_4S]         = 800,
    [iPhone_5_GSM]      = 1300,
    [iPhone_5_CDMA]     = 1300,
    [iPod_Touch_1G]     = 400,
    [iPod_Touch_2G]     = 533,
    [iPod_Touch_3G]     = 600,
    [iPod_Touch_4G]     = 800,
    [iPod_Touch_5]      = 1000,
    [iPad_1]            = 1000,
    [iPad_2_CDMA]       = 1000,
    [iPad_2_GSM]        = 1000,
    [iPad_2_WiFi]       = 1000,
    [iPad_3_WiFi]       = 1000,
    [iPad_3_GSM]        = 1000,
    [iPad_3_CDMA]       = 1000,
    [iPad_4_WiFi]       = 1400,
    [iPad_4_GSM]        = 1400,
    [iPad_4_CDMA]       = 1400,
    [iPad_Mini_WiFi]    = 1000,
    [iPad_Mini_GSM]     = 1000,
    [iPad_Mini_CDMA]    = 1000,
    [iUnknown]          = 0
};

static const NSString *CPUNameTable[] = {
    [iPhone_1G]         = @"ARM 1176JZ",
    [iPhone_3G]         = @"ARM 1176JZ",
    [iPhone_3GS]        = @"ARM Cortex-A8",
    [iPhone_4]          = @"Apple A4",
    [iPhone_4_Verizon]  = @"Apple A4",
    [iPhone_4S]         = @"Apple A5",
    [iPhone_5_GSM]      = @"Apple A6",
    [iPhone_5_CDMA]     = @"Apple A6",
    [iPod_Touch_1G]     = @"ARM 1176JZ",
    [iPod_Touch_2G]     = @"ARM 1176JZ",
    [iPod_Touch_3G]     = @"ARM Cortex-A8",
    [iPod_Touch_4G]     = @"ARM Cortex-A8",
    [iPod_Touch_5]      = @"Apple A5",
    [iPad_1]            = @"ARM Cortex-A8",
    [iPad_2_CDMA]       = @"ARM Cortex-A9",
    [iPad_2_GSM]        = @"ARM Cortex-A9",
    [iPad_2_WiFi]       = @"ARM Cortex-A9",
    [iPad_3_WiFi]       = @"ARM Cortex-A9",
    [iPad_3_GSM]        = @"ARM Cortex-A9",
    [iPad_3_CDMA]       = @"ARM Cortex-A9",
    [iPad_4_WiFi]       = @"Apple Swift",
    [iPad_4_GSM]        = @"Apple Swift",
    [iPad_4_CDMA]       = @"Apple Swift",
    [iPad_Mini_WiFi]    = @"ARM Cortex-A9",
    [iPad_Mini_GSM]     = @"ARM Cortex-A9",
    [iPad_Mini_CDMA]    = @"ARM Cortex-A9",
    [iUnknown]          = @"Unknown"
};

static const NSString *GPUNameTable[] = {
    [iPhone_1G]         = @"PowerVR MBX Lite 3D",
    [iPhone_3G]         = @"PowerVR MBX Lite 3D",
    [iPhone_3GS]        = @"PowerVR SGX535",
    [iPhone_4]          = @"PowerVR SGX535",
    [iPhone_4_Verizon]  = @"PowerVR SGX535",
    [iPhone_4S]         = @"PowerVR SGX543MP2",
    [iPhone_5_GSM]      = @"PowerVR SGX543MP3",
    [iPhone_5_CDMA]     = @"PowerVR SGX543MP3",
    [iPod_Touch_1G]     = @"PowerVR MBX Lite",
    [iPod_Touch_2G]     = @"PowerVR MBX Lite",
    [iPod_Touch_3G]     = @"PowerVR SGX535",
    [iPod_Touch_4G]     = @"PowerVR SGX535",
    [iPod_Touch_5]      = @"PowerVR SGX543MP2",
    [iPad_1]            = @"ARM Cortex-A8",
    [iPad_2_CDMA]       = @"ARM Cortex-A9",
    [iPad_2_GSM]        = @"ARM Cortex-A9",
    [iPad_2_WiFi]       = @"ARM Cortex-A9",
    [iPad_3_WiFi]       = @"ARM Cortex-A9",
    [iPad_3_GSM]        = @"ARM Cortex-A9",
    [iPad_3_CDMA]       = @"ARM Cortex-A9",
    [iPad_4_WiFi]       = @"Apple Swift",
    [iPad_4_GSM]        = @"Apple Swift",
    [iPad_4_CDMA]       = @"Apple Swift",
    [iPad_Mini_WiFi]    = @"ARM Cortex-A9",
    [iPad_Mini_GSM]     = @"ARM Cortex-A9",
    [iPad_Mini_CDMA]    = @"ARM Cortex-A9",
    [iUnknown]          = @"Unknown"
};
   
#pragma mark - public

+ (HardcodedDeviceData*)sharedDeviceData
{
    static HardcodedDeviceData *instance;
    if (!instance)
    {
        instance = [[HardcodedDeviceData alloc] init];
    }
    return instance;
}

- (void)setHwMachine:(NSString*)hwMachine
{
    self.iDevice = [self hwMachineToIdevice:hwMachine];
}

- (const NSString*)getiDeviceName
{
    return iDeviceNameTable[self.iDevice];
}

- (const NSString*)getCPUName
{
    return CPUNameTable[self.iDevice];
}

- (NSUInteger)getCPUFrequency
{
    return CPUFrequencyTable[self.iDevice];
}

- (const NSString*)getGPUName
{
    return GPUNameTable[self.iDevice];
}

#pragma mark - private

- (iDevice_t)hwMachineToIdevice:(NSString*)hwMachine
{
    if ([hwMachine isEqualToString:@"iPhone1,1"])    return iPhone_1G;
    if ([hwMachine isEqualToString:@"iPhone1,2"])    return iPhone_3G;
    if ([hwMachine isEqualToString:@"iPhone2,1"])    return iPhone_3GS;
    if ([hwMachine isEqualToString:@"iPhone3,1"])    return iPhone_4;
    if ([hwMachine isEqualToString:@"iPhone3,3"])    return iPhone_4_Verizon;
    if ([hwMachine isEqualToString:@"iPhone4,1"])    return iPhone_4S;
    if ([hwMachine isEqualToString:@"iPhone5,1"])    return iPhone_5_GSM;
    if ([hwMachine isEqualToString:@"iPhone5,2"])    return iPhone_5_CDMA;
    if ([hwMachine isEqualToString:@"iPod1,1"])      return iPod_Touch_1G;
    if ([hwMachine isEqualToString:@"iPod2,1"])      return iPod_Touch_2G;
    if ([hwMachine isEqualToString:@"iPod3,1"])      return iPod_Touch_3G;
    if ([hwMachine isEqualToString:@"iPod4,1"])      return iPod_Touch_4G;
    if ([hwMachine isEqualToString:@"iPod5,1"])      return iPod_Touch_5;
    if ([hwMachine isEqualToString:@"iPad1,1"])      return iPad_1;
    if ([hwMachine isEqualToString:@"iPad2,1"])      return iPad_2_WiFi;
    if ([hwMachine isEqualToString:@"iPad2,2"])      return iPad_2_GSM;
    if ([hwMachine isEqualToString:@"iPad2,3"])      return iPad_2_CDMA;
    if ([hwMachine isEqualToString:@"iPad2,4"])      return iPad_2_CDMA;
    if ([hwMachine isEqualToString:@"iPad2,5"])      return iPad_Mini_WiFi;
    if ([hwMachine isEqualToString:@"iPad2,6"])      return iPad_Mini_GSM;
    if ([hwMachine isEqualToString:@"iPad2,7"])      return iPad_Mini_CDMA;
    if ([hwMachine isEqualToString:@"iPad3,1"])      return iPad_3_WiFi;
    if ([hwMachine isEqualToString:@"iPad3,2"])      return iPad_3_GSM;
    if ([hwMachine isEqualToString:@"iPad3,3"])      return iPad_3_CDMA;
    if ([hwMachine isEqualToString:@"iPad3,4"])      return iPad_4_WiFi;
    if ([hwMachine isEqualToString:@"iPad3,5"])      return iPad_4_GSM;
    if ([hwMachine isEqualToString:@"iPad3,6"])      return iPad_4_CDMA;
    return iUnknown;
}

@end
