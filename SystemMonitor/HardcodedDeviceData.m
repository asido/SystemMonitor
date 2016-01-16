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
    iPhone_6,
    iPhone_6_Plus,
    iPhone_6S,
    iPhone_6S_Plus,
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
    iPad_Air,
    iPad_Air_Cellular,
    iPad_Air_2,
    iPad_Air_2_Cellular,
    iPad_Pro,
    iPad_Mini_WiFi,
    iPad_Mini_GSM,
    iPad_Mini_CDMA,
    iPad_Mini_2,
    iPad_Mini_2_Cellular,
    iPad_Mini_3,
    iPad_Mini_3_Cellular,
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
    [iPhone_6]          = @"iPhone 6",
    [iPhone_6_Plus]     = @"iPhone 6 Plus",
    [iPhone_6S]         = @"iPhone 6S",
    [iPhone_6S_Plus]    = @"iPhone 6S Plus",
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
    [iPad_Air]          = @"iPad Air",
    [iPad_Air_Cellular] = @"iPad Air (Cellular)",
    [iPad_Air_2]        = @"iPad Air 2",
    [iPad_Air_2_Cellular] = @"iPad Air 2 (Cellular)",
    [iPad_Mini_WiFi]    = @"iPad Mini (WiFi)",
    [iPad_Mini_GSM]     = @"iPad Mini (GSM)",
    [iPad_Mini_CDMA]    = @"iPad Mini (CDMA)",
    [iPad_Mini_2]       = @"iPad Mini 2",
    [iPad_Mini_2_Cellular] = @"iPad Mini 2 (Cellular)",
    [iPad_Mini_3]       = @"iPad Mini 3",
    [iPad_Mini_3_Cellular] = @"iPad Mini 3 (Cellular)",
    [iPad_Pro]          = @"iPad Pro",
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
    [iPhone_6]          = 1400,
    [iPhone_6_Plus]     = 1400,
    [iPhone_6S]         = 1850,
    [iPhone_6S_Plus]    = 1850,
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
    [iPad_Air]          = 1400,
    [iPad_Air_Cellular] = 1400,
    [iPad_Air_2]        = 1500,
    [iPad_Air_2_Cellular] = 1500,
    [iPad_Pro]          = 2260,
    [iPad_Mini_WiFi]    = 1000,
    [iPad_Mini_GSM]     = 1000,
    [iPad_Mini_CDMA]    = 1000,
    [iPad_Mini_2]       = 1300,
    [iPad_Mini_2_Cellular] = 1300,
    [iPad_Mini_3]       = 1300,
    [iPad_Mini_3_Cellular] = 1300,
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
    [iPhone_6]          = @"Apple A8",
    [iPhone_6_Plus]     = @"Apple A8",
    [iPhone_6S]         = @"Apple A9",
    [iPhone_6S_Plus]    = @"Apple A9",
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
    [iPad_Air]          = @"Apple A7",
    [iPad_Air_Cellular] = @"Apple A7",
    [iPad_Air_2]        = @"Apple A8X",
    [iPad_Air_2_Cellular] = @"Apple A8X",
    [iPad_Pro]          = @"Apple A9X",
    [iPad_Mini_WiFi]    = @"ARM Cortex-A9",
    [iPad_Mini_GSM]     = @"ARM Cortex-A9",
    [iPad_Mini_CDMA]    = @"ARM Cortex-A9",
    [iPad_Mini_2]       = @"Apple A7",
    [iPad_Mini_2_Cellular] = @"Apple A7",
    [iPad_Mini_3]       = @"Apple A7",
    [iPad_Mini_3_Cellular] = @"Apple A7",
    [iUnknown]          = @"Unknown"
};

static const NSString *CoprocessorNameTable[] = {
    [iPhone_1G]         = @"N/A",
    [iPhone_3G]         = @"N/A",
    [iPhone_3GS]        = @"N/A",
    [iPhone_4]          = @"N/A",
    [iPhone_4_Verizon]  = @"N/A",
    [iPhone_4S]         = @"N/A",
    [iPhone_5_GSM]      = @"N/A",
    [iPhone_5_CDMA]     = @"N/A",
    [iPhone_5C]         = @"N/A",
    [iPhone_5S]         = @"Apple M7 motion",
    [iPhone_6]          = @"Apple M8 motion",
    [iPhone_6_Plus]     = @"Apple M8 motion",
    [iPhone_6S]          = @"Apple M9 motion",
    [iPhone_6S_Plus]     = @"Apple M9 motion",
    [iPod_Touch_1G]     = @"N/A",
    [iPod_Touch_2G]     = @"N/A",
    [iPod_Touch_3G]     = @"N/A",
    [iPod_Touch_4G]     = @"N/A",
    [iPod_Touch_5]      = @"N/A",
    [iPad_1]            = @"N/A",
    [iPad_2_CDMA]       = @"N/A",
    [iPad_2_GSM]        = @"N/A",
    [iPad_2_WiFi]       = @"N/A",
    [iPad_3_WiFi]       = @"N/A",
    [iPad_3_GSM]        = @"N/A",
    [iPad_3_CDMA]       = @"N/A",
    [iPad_4_WiFi]       = @"N/A",
    [iPad_4_GSM]        = @"N/A",
    [iPad_4_CDMA]       = @"N/A",
    [iPad_Air]          = @"Apple M7 motion",
    [iPad_Air_Cellular] = @"Apple M7 motion",
    [iPad_Air_2]        = @"Apple M8 motion",
    [iPad_Air_2_Cellular] = @"Apple M8 motion",
    [iPad_Pro]          = @"Apple M9 motion",
    [iPad_Mini_WiFi]    = @"N/A",
    [iPad_Mini_GSM]     = @"N/A",
    [iPad_Mini_CDMA]    = @"N/A",
    [iPad_Mini_2]       = @"Apple M7 motion",
    [iPad_Mini_2_Cellular] = @"Apple M7 motion",
    [iPad_Mini_3]       = @"Apple M7 motion",
    [iPad_Mini_3_Cellular] = @"Apple M7 motion",
    [iUnknown]          = @"Unknown"
};

static const NSString *GraphicCardNameTable[] = {
    [iPhone_1G]         = @"PowerVR MBX Lite",
    [iPhone_3G]         = @"PowerVR MBX Lite",
    [iPhone_3GS]        = @"PowerVR SGX535",
    [iPhone_4]          = @"PowerVR SGX535",
    [iPhone_4_Verizon]  = @"PowerVR SGX535",
    [iPhone_4S]         = @"PowerVR SGX543",
    [iPhone_5_GSM]      = @"PowerVR SGX543MP3",
    [iPhone_5_CDMA]     = @"PowerVR SGX543MP3",
    [iPhone_5C]         = @"PowerVR SGX543MP3",
    [iPhone_5S]         = @"PowerVR G6430",
    [iPhone_6]          = @"PowerVR GX6450",
    [iPhone_6_Plus]     = @"PowerVR GX6450",
    [iPhone_6S]          = @"PowerVR GT6700",
    [iPhone_6S_Plus]     = @"PowerVR GT6700",
    [iPod_Touch_1G]     = @"PowerVR MBX Lite",
    [iPod_Touch_2G]     = @"PowerVR MBX Lite",
    [iPod_Touch_3G]     = @"PowerVR MBX Lite",
    [iPod_Touch_4G]     = @"PowerVR MBX Lite",
    [iPod_Touch_5]      = @"PowerVR MBX Lite",
    [iPad_1]            = @"PowerVR SGX535",
    [iPad_2_CDMA]       = @"PowerVR SGX543MP2",
    [iPad_2_GSM]        = @"PowerVR SGX543MP2",
    [iPad_2_WiFi]       = @"PowerVR SGX543MP2",
    [iPad_3_WiFi]       = @"PowerVR SGX543MP4",
    [iPad_3_GSM]        = @"PowerVR SGX543MP4",
    [iPad_3_CDMA]       = @"PowerVR SGX543MP4",
    [iPad_4_WiFi]       = @"PowerVR SGX554MP4",
    [iPad_4_GSM]        = @"PowerVR SGX554MP4",
    [iPad_4_CDMA]       = @"PowerVR SGX554MP4",
    [iPad_Air]          = @"PowerVR G6430",
    [iPad_Air_Cellular] = @"PowerVR G6430",
    [iPad_Air_2]        = @"PowerVR GXA6850",
    [iPad_Air_2_Cellular] = @"PowerVR GXA6850",
    [iPad_Pro]          = @"PowerVR Series 7XT",
    [iPad_Mini_WiFi]    = @"PowerVR SGX543MP2",
    [iPad_Mini_GSM]     = @"PowerVR SGX543MP2",
    [iPad_Mini_CDMA]    = @"PowerVR SGX543MP2",
    [iPad_Mini_2]       = @"PowerVR G6430",
    [iPad_Mini_2_Cellular] = @"PowerVR G6430",
    [iPad_Mini_3]       = @"PowerVR G6430",
    [iPad_Mini_3_Cellular] = @"PowerVR G6430",
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
    [iPhone_6]          = @"LPDDR3 DRAM",
    [iPhone_6_Plus]     = @"LPDDR3 DRAM",
    [iPhone_6S]         = @"LPDDR4 DRAM",
    [iPhone_6S_Plus]    = @"LPDDR4 DRAM",
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
    [iPad_Air]          = @"LPDDR3 DRAM",
    [iPad_Air_Cellular] = @"LPDDR3 DRAM",
    [iPad_Air_2]        = @"LPDDR3 DRAM",
    [iPad_Air_2_Cellular] = @"LPDDR3 DRAM",
    [iPad_Pro]          = @"LPDDR4 DRAM",
    [iPad_Mini_WiFi]    = @"LPDDR2 DRAM",
    [iPad_Mini_GSM]     = @"LPDDR2 DRAM",
    [iPad_Mini_CDMA]    = @"LPDDR2 DRAM",
    [iPad_Mini_2]       = @"LPDDR3 DRAM",
    [iPad_Mini_2_Cellular] = @"LPDDR3 DRAM",
    [iPad_Mini_3]       = @"LPDDR3 DRAM",
    [iPad_Mini_3_Cellular] = @"LPDDR3 DRAM",
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
    [iPhone_6]          = 1810,
    [iPhone_6_Plus]     = 2915,
    [iPhone_6S]         = 1715,
    [iPhone_6S_Plus]    = 2750,
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
    [iPad_Air]          = 8827,
    [iPad_Air_Cellular] = 8827,
    [iPad_Air_2]        = 7340,
    [iPad_Air_2_Cellular] = 7340,
    [iPad_Pro]          = 10307,
    [iPad_Mini_WiFi]    = 4440,
    [iPad_Mini_GSM]     = 4440,
    [iPad_Mini_CDMA]    = 4440,
    [iPad_Mini_2]       = 6471,
    [iPad_Mini_2_Cellular] = 6471,
    [iPad_Mini_3]       = 6471,
    [iPad_Mini_3_Cellular] = 6471,
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
    [iPhone_6]          = 3.82,
    [iPhone_6_Plus]     = 3.82,
    [iPhone_6S]         = 3.82,
    [iPhone_6S_Plus]    = 3.8,
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
    [iPad_Air]          = 3.73,
    [iPad_Air_Cellular] = 3.73,
    [iPad_Air_2]        = 3.76,
    [iPad_Air_2_Cellular] = 3.76,
    [iPad_Pro]          = 3.77,
    [iPad_Mini_WiFi]    = 3.72,
    [iPad_Mini_GSM]     = 3.72,
    [iPad_Mini_CDMA]    = 3.72,
    [iPad_Mini_2]       = 3.75,
    [iPad_Mini_2_Cellular] = 3.75,
    [iPad_Mini_3]       = 3.75,
    [iPad_Mini_3_Cellular] = 3.75,
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
    [iPhone_6]          = 4.7,
    [iPhone_6_Plus]     = 5.5,
    [iPhone_6S]          = 4.7,
    [iPhone_6S_Plus]     = 5.5,
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
    [iPad_Air]          = 9.7,
    [iPad_Air_Cellular] = 9.7,
    [iPad_Air_2]        = 9.7,
    [iPad_Air_2_Cellular] = 9.7,
    [iPad_Pro]          = 12.9,
    [iPad_Mini_WiFi]    = 7.9,
    [iPad_Mini_GSM]     = 7.9,
    [iPad_Mini_CDMA]    = 7.9,
    [iPad_Mini_2]       = 7.9,
    [iPad_Mini_2_Cellular] = 7.9,
    [iPad_Mini_3]       = 7.9,
    [iPad_Mini_3_Cellular] = 7.9,
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
    [iPhone_6]          = 326,
    [iPhone_6_Plus]     = 401,
    [iPhone_6S]          = 326,
    [iPhone_6S_Plus]     = 401,
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
    [iPad_Air]          = 264,
    [iPad_Air_Cellular] = 264,
    [iPad_Air_2]        = 264,
    [iPad_Air_2_Cellular] = 264,
    [iPad_Pro]          = 264,
    [iPad_Mini_WiFi]    = 163,
    [iPad_Mini_GSM]     = 163,
    [iPad_Mini_CDMA]    = 163,
    [iPad_Mini_2]       = 326,
    [iPad_Mini_2_Cellular] = 326,
    [iPad_Mini_3]       = 326,
    [iPad_Mini_3_Cellular] = 326,
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
    [iPhone_6]          = @"16:9",
    [iPhone_6_Plus]     = @"16:9",
    [iPhone_6S]          = @"16:9",
    [iPhone_6S_Plus]     = @"16:9",
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
    [iPad_Air]          = @"4:3",
    [iPad_Air_Cellular] = @"4:3",
    [iPad_Air_2]        = @"4:3",
    [iPad_Air_2_Cellular] = @"4:3",
    [iPad_Pro]          = @"4:3",
    [iPad_Mini_WiFi]    = @"4:3",
    [iPad_Mini_GSM]     = @"4:3",
    [iPad_Mini_CDMA]    = @"4:3",
    [iPad_Mini_2]       = @"4:3",
    [iPad_Mini_2_Cellular] = @"4:3",
    [iPad_Mini_3]       = @"4:3",
    [iPad_Mini_3_Cellular] = @"4:3",
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

- (const NSString*)getCoprocessorName
{
    return CoprocessorNameTable[self.iDevice];
}

- (const NSString*)getGraphicCardName
{
    return GraphicCardNameTable[self.iDevice];
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
    if ([hwMachine isEqualToString:@"iPhone7,2"])   return iPhone_6;
    if ([hwMachine isEqualToString:@"iPhone7,1"])   return iPhone_6_Plus;
    if ([hwMachine isEqualToString:@"iPhone8,1"])   return iPhone_6S;
    if ([hwMachine isEqualToString:@"iPhone8,2"])   return iPhone_6S_Plus;
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
    if ([hwMachine isEqualToString:@"iPad4,1"])     return iPad_Air;
    if ([hwMachine isEqualToString:@"iPad4,2"])     return iPad_Air_Cellular;
    if ([hwMachine isEqualToString:@"iPad5,3"])     return iPad_Air_2;
    if ([hwMachine isEqualToString:@"iPad5,4"])     return iPad_Air_2_Cellular;
    if ([hwMachine isEqualToString:@"iPad6,8"])     return iPad_Pro;
    if ([hwMachine isEqualToString:@"iPad4,4"])     return iPad_Mini_2;
    if ([hwMachine isEqualToString:@"iPad4,5"])     return iPad_Mini_2_Cellular;
    if ([hwMachine isEqualToString:@"iPad4,7"])     return iPad_Mini_3;
    if ([hwMachine isEqualToString:@"iPad4,8"])     return iPad_Mini_3_Cellular;

    return iUnknown;
}

@end
