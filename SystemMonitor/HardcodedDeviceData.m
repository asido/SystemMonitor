//
//  HardcodedDeviceData.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
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
    iPhone_5C,
    iPhone_5S,
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
    iPad_5,
    iPad_Mini_WiFi,
    iPad_Mini_GSM,
    iPad_Mini_CDMA,
    iPad_Mini_2,
    iUnknown
} iDevice_t;

@interface HardcodedDeviceData()
@property (nonatomic, assign) iDevice_t iDevice;

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
    [iPhone_5C]         = @"iPhone 5C",
    [iPhone_5S]         = @"iPhone 5S",
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
    [iPad_5]            = @"iPad Air",
    [iPad_Mini_WiFi]    = @"iPad Mini (WiFi)",
    [iPad_Mini_GSM]     = @"iPad Mini (GSM)",
    [iPad_Mini_CDMA]    = @"iPad Mini (CDMA)",
    [iPad_Mini_2]       = @"iPad Mini 2",
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
    [iPhone_5C]         = 1000,
    [iPhone_5S]         = 1300,
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
    [iPad_5]            = 1400,
    [iPad_Mini_WiFi]    = 1000,
    [iPad_Mini_GSM]     = 1000,
    [iPad_Mini_CDMA]    = 1000,
    [iPad_Mini_2]       = 1400,
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
    [iPhone_5C]         = @"Apple A6",
    [iPhone_5S]         = @"Apple A7",
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
    [iPad_5]            = @"Apple A7",
    [iPad_Mini_WiFi]    = @"ARM Cortex-A9",
    [iPad_Mini_GSM]     = @"ARM Cortex-A9",
    [iPad_Mini_CDMA]    = @"ARM Cortex-A9",
    [iPad_Mini_2]       = @"Apple A7",
    [iUnknown]          = @"Unknown"
};

static const NSString *RAMTypeTable[] = {
    [iPhone_1G]         = @"LPDDR DRAM",
    [iPhone_3G]         = @"LPDDR DRAM",
    [iPhone_3GS]        = @"LPDDR DRAM",
    [iPhone_4]          = @"LPDDR2 DRAM",
    [iPhone_4_Verizon]  = @"LPDDR2 DRAM",
    [iPhone_4S]         = @"LPDDR2 DRAM",
    [iPhone_5_GSM]      = @"LPDDR2 DRAM",
    [iPhone_5_CDMA]     = @"LPDDR2 DRAM",
    [iPhone_5C]         = @"LPDDR2 DRAM",
    [iPhone_5S]         = @"LPDDR3 DRAM",
    [iPod_Touch_1G]     = @"LPDDR DRAM",
    [iPod_Touch_2G]     = @"LPDDR DRAM",
    [iPod_Touch_3G]     = @"LPDDR DRAM",
    [iPod_Touch_4G]     = @"LPDDR2 DRAM",
    [iPod_Touch_5]      = @"LPDDR2 DRAM",
    [iPad_1]            = @"LPDDR DRAM",
    [iPad_2_CDMA]       = @"LPDDR2 DRAM",
    [iPad_2_GSM]        = @"LPDDR2 DRAM",
    [iPad_2_WiFi]       = @"LPDDR2 DRAM",
    [iPad_3_WiFi]       = @"LPDDR2 DRAM",
    [iPad_3_GSM]        = @"LPDDR2 DRAM",
    [iPad_3_CDMA]       = @"LPDDR2 DRAM",
    [iPad_4_WiFi]       = @"LPDDR2 DRAM",
    [iPad_4_GSM]        = @"LPDDR2 DRAM",
    [iPad_4_CDMA]       = @"LPDDR2 DRAM",
    [iPad_5]            = @"LPDDR3 DRAM",
    [iPad_Mini_WiFi]    = @"LPDDR2 DRAM",
    [iPad_Mini_GSM]     = @"LPDDR2 DRAM",
    [iPad_Mini_CDMA]    = @"LPDDR2 DRAM",
    [iPad_Mini_2]       = @"LPDDR3 DRAM",
    [iUnknown]          = @"Unknown"
};

static const NSUInteger BatteryCapacityTable[] = {
    [iPhone_1G]         = 1400,
    [iPhone_3G]         = 1150,
    [iPhone_3GS]        = 1219,
    [iPhone_4]          = 1420,
    [iPhone_4_Verizon]  = 1420,
    [iPhone_4S]         = 1430,
    [iPhone_5_GSM]      = 1440,
    [iPhone_5_CDMA]     = 1440,
    [iPhone_5C]         = 1507,
    [iPhone_5S]         = 1570,
    [iPod_Touch_1G]     = 789,
    [iPod_Touch_2G]     = 789,
    [iPod_Touch_3G]     = 930,
    [iPod_Touch_4G]     = 930,
    [iPod_Touch_5]      = 1030,
    [iPad_1]            = 6613,
    [iPad_2_CDMA]       = 6930,
    [iPad_2_GSM]        = 6930,
    [iPad_2_WiFi]       = 6930,
    [iPad_3_WiFi]       = 11560,
    [iPad_3_GSM]        = 11560,
    [iPad_3_CDMA]       = 11560,
    [iPad_4_WiFi]       = 11560,
    [iPad_4_GSM]        = 11560,
    [iPad_4_CDMA]       = 11560,
    [iPad_5]            = 8827,
    [iPad_Mini_WiFi]    = 4440,
    [iPad_Mini_GSM]     = 4440,
    [iPad_Mini_CDMA]    = 4440,
    [iPad_Mini_2]       = 4440,
    [iUnknown]          = 0
};

static const CGFloat BatteryVoltageTable[] = {
    [iPhone_1G]         = 3.7,
    [iPhone_3G]         = 3.7,
    [iPhone_3GS]        = 3.7,
    [iPhone_4]          = 3.7,
    [iPhone_4_Verizon]  = 3.7,
    [iPhone_4S]         = 3.7,
    [iPhone_5_GSM]      = 3.8,
    [iPhone_5_CDMA]     = 3.8,
    [iPhone_5C]         = 3.8,
    [iPhone_5S]         = 3.8,
    [iPod_Touch_1G]     = 3.7,
    [iPod_Touch_2G]     = 3.7,
    [iPod_Touch_3G]     = 3.7,
    [iPod_Touch_4G]     = 3.7,
    [iPod_Touch_5]      = 3.8,
    [iPad_1]            = 3.75,
    [iPad_2_CDMA]       = 3.8,
    [iPad_2_GSM]        = 3.8,
    [iPad_2_WiFi]       = 3.8,
    [iPad_3_WiFi]       = 3.7,
    [iPad_3_GSM]        = 3.7,
    [iPad_3_CDMA]       = 3.7,
    [iPad_4_WiFi]       = 3.7,
    [iPad_4_GSM]        = 3.7,
    [iPad_4_CDMA]       = 3.7,
    [iPad_5]            = 3.7,
    [iPad_Mini_WiFi]    = 3.72,
    [iPad_Mini_GSM]     = 3.72,
    [iPad_Mini_CDMA]    = 3.72,
    [iPad_Mini_2]       = 3.72,
    [iUnknown]          = 0
};

static const CGFloat ScreenSizeTable[] = {
    [iPhone_1G]         = 3.5,
    [iPhone_3G]         = 3.5,
    [iPhone_3GS]        = 3.5,
    [iPhone_4]          = 3.5,
    [iPhone_4_Verizon]  = 3.5,
    [iPhone_4S]         = 3.5,
    [iPhone_5_GSM]      = 4.0,
    [iPhone_5_CDMA]     = 4.0,
    [iPhone_5C]         = 4.0,
    [iPhone_5S]         = 4.0,
    [iPod_Touch_1G]     = 3.5,
    [iPod_Touch_2G]     = 3.5,
    [iPod_Touch_3G]     = 3.5,
    [iPod_Touch_4G]     = 3.5,
    [iPod_Touch_5]      = 4.0,
    [iPad_1]            = 9.7,
    [iPad_2_CDMA]       = 9.7,
    [iPad_2_GSM]        = 9.7,
    [iPad_2_WiFi]       = 9.7,
    [iPad_3_WiFi]       = 9.7,
    [iPad_3_GSM]        = 9.7,
    [iPad_3_CDMA]       = 9.7,
    [iPad_4_WiFi]       = 9.7,
    [iPad_4_GSM]        = 9.7,
    [iPad_4_CDMA]       = 9.7,
    [iPad_5]            = 9.7,
    [iPad_Mini_WiFi]    = 7.9,
    [iPad_Mini_GSM]     = 7.9,
    [iPad_Mini_CDMA]    = 7.9,
    [iPad_Mini_2]       = 7.9,
    [iUnknown]          = 0.0
};

static const NSUInteger ScreenPPITable[] = {
    [iPhone_1G]         = 163,
    [iPhone_3G]         = 163,
    [iPhone_3GS]        = 163,
    [iPhone_4]          = 326,
    [iPhone_4_Verizon]  = 326,
    [iPhone_4S]         = 326,
    [iPhone_5_GSM]      = 326,
    [iPhone_5_CDMA]     = 326,
    [iPhone_5C]         = 326,
    [iPhone_5S]         = 326,
    [iPod_Touch_1G]     = 163,
    [iPod_Touch_2G]     = 163,
    [iPod_Touch_3G]     = 163,
    [iPod_Touch_4G]     = 326,
    [iPod_Touch_5]      = 326,
    [iPad_1]            = 132,
    [iPad_2_CDMA]       = 132,
    [iPad_2_GSM]        = 132,
    [iPad_2_WiFi]       = 132,
    [iPad_3_WiFi]       = 264,
    [iPad_3_GSM]        = 264,
    [iPad_3_CDMA]       = 264,
    [iPad_4_WiFi]       = 264,
    [iPad_4_GSM]        = 264,
    [iPad_4_CDMA]       = 264,
    [iPad_5]            = 264,
    [iPad_Mini_WiFi]    = 163,
    [iPad_Mini_GSM]     = 163,
    [iPad_Mini_CDMA]    = 163,
    [iPad_Mini_2]       = 326,
    [iUnknown]          = 0.0
};

static const NSString *AspectRatioTable[] = {
    [iPhone_1G]         = @"3:2",
    [iPhone_3G]         = @"3:2",
    [iPhone_3GS]        = @"3:2",
    [iPhone_4]          = @"3:2",
    [iPhone_4_Verizon]  = @"3:2",
    [iPhone_4S]         = @"3:2",
    [iPhone_5_GSM]      = @"16:9",
    [iPhone_5_CDMA]     = @"16:9",
    [iPhone_5C]         = @"16:9",
    [iPhone_5S]         = @"16:9",
    [iPod_Touch_1G]     = @"3:2",
    [iPod_Touch_2G]     = @"3:2",
    [iPod_Touch_3G]     = @"3:2",
    [iPod_Touch_4G]     = @"3:2",
    [iPod_Touch_5]      = @"16:9",
    [iPad_1]            = @"4:3",
    [iPad_2_CDMA]       = @"4:3",
    [iPad_2_GSM]        = @"4:3",
    [iPad_2_WiFi]       = @"4:3",
    [iPad_3_WiFi]       = @"4:3",
    [iPad_3_GSM]        = @"4:3",
    [iPad_3_CDMA]       = @"4:3",
    [iPad_4_WiFi]       = @"4:3",
    [iPad_4_GSM]        = @"4:3",
    [iPad_4_CDMA]       = @"4:3",
    [iPad_5]            = @"4:3",
    [iPad_Mini_WiFi]    = @"4:3",
    [iPad_Mini_GSM]     = @"4:3",
    [iPad_Mini_CDMA]    = @"4:3",
    [iPad_Mini_2]       = @"4:3",
    [iUnknown]          = @"0:0"
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

- (const NSString*)getRAMType
{
    return RAMTypeTable[self.iDevice];
}

- (NSUInteger)getBatteryCapacity
{
    return BatteryCapacityTable[self.iDevice];
}

- (CGFloat)getBatteryVoltage
{
    return BatteryVoltageTable[self.iDevice];
}

- (CGFloat)getScreenSize
{
    return ScreenSizeTable[self.iDevice];
}

- (NSUInteger)getPPI
{
    return ScreenPPITable[self.iDevice];
}

- (NSString*)getAspectRatio
{
    return (NSString*) AspectRatioTable[self.iDevice];
}

#pragma mark - private

- (iDevice_t)hwMachineToIdevice:(NSString*)hwMachine
{
    if ([hwMachine isEqualToString:@"iPhone1,1"])   return iPhone_1G;
    if ([hwMachine isEqualToString:@"iPhone1,2"])   return iPhone_3G;
    if ([hwMachine isEqualToString:@"iPhone2,1"])   return iPhone_3GS;
    if ([hwMachine isEqualToString:@"iPhone3,1"])   return iPhone_4;
    if ([hwMachine isEqualToString:@"iPhone3,3"])   return iPhone_4_Verizon;
    if ([hwMachine isEqualToString:@"iPhone4,1"])   return iPhone_4S;
    if ([hwMachine isEqualToString:@"iPhone5,1"])   return iPhone_5_GSM;
    if ([hwMachine isEqualToString:@"iPhone5,2"])   return iPhone_5_CDMA;
    if ([hwMachine isEqualToString:@"iPhone5,3"])   return iPhone_5C;
    if ([hwMachine isEqualToString:@"iPhone5,4"])   return iPhone_5C;
    if ([hwMachine isEqualToString:@"iPhone6,1"])   return iPhone_5S;
    if ([hwMachine isEqualToString:@"iPhone6,2"])   return iPhone_5S;
    if ([hwMachine isEqualToString:@"iPod1,1"])     return iPod_Touch_1G;
    if ([hwMachine isEqualToString:@"iPod2,1"])     return iPod_Touch_2G;
    if ([hwMachine isEqualToString:@"iPod3,1"])     return iPod_Touch_3G;
    if ([hwMachine isEqualToString:@"iPod4,1"])     return iPod_Touch_4G;
    if ([hwMachine isEqualToString:@"iPod5,1"])     return iPod_Touch_5;
    if ([hwMachine isEqualToString:@"iPad1,1"])     return iPad_1;
    if ([hwMachine isEqualToString:@"iPad2,1"])     return iPad_2_WiFi;
    if ([hwMachine isEqualToString:@"iPad2,2"])     return iPad_2_GSM;
    if ([hwMachine isEqualToString:@"iPad2,3"])     return iPad_2_CDMA;
    if ([hwMachine isEqualToString:@"iPad2,4"])     return iPad_2_CDMA;
    if ([hwMachine isEqualToString:@"iPad2,5"])     return iPad_Mini_WiFi;
    if ([hwMachine isEqualToString:@"iPad2,6"])     return iPad_Mini_GSM;
    if ([hwMachine isEqualToString:@"iPad2,7"])     return iPad_Mini_CDMA;
    if ([hwMachine isEqualToString:@"iPad3,1"])     return iPad_3_WiFi;
    if ([hwMachine isEqualToString:@"iPad3,2"])     return iPad_3_GSM;
    if ([hwMachine isEqualToString:@"iPad3,3"])     return iPad_3_CDMA;
    if ([hwMachine isEqualToString:@"iPad3,4"])     return iPad_4_WiFi;
    if ([hwMachine isEqualToString:@"iPad3,5"])     return iPad_4_GSM;
    if ([hwMachine isEqualToString:@"iPad3,6"])     return iPad_4_CDMA;
    if ([hwMachine isEqualToString:@"iPad4,1"])     return iPad_5;
    if ([hwMachine isEqualToString:@"iPad4,2"])     return iPad_5;
    if ([hwMachine isEqualToString:@"iPad4,4"])     return iPad_Mini_2;
    if ([hwMachine isEqualToString:@"iPad4,5"])     return iPad_Mini_2;

    return iUnknown;
}

@end
