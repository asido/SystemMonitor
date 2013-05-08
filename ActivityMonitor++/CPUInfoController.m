//
//  CPUInfoController.m
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <sys/sysctl.h>
#import <mach/machine.h>
#import "HardcodedDeviceData.h"
#import "AMLog.h"
#import "AMUtils.h"
#import "CPUInfoController.h"

@interface CPUInfoController()
- (NSString*)getCPUName;
- (NSUInteger)getActiveCPUCount;
- (NSUInteger)getPhysicalCPUCount;
- (NSUInteger)getPhysicalCPUMaxCount;
- (NSUInteger)getLogicalCPUCount;
- (NSUInteger)getLogicalCPUMaxCount;
- (NSUInteger)getCPUFrequency;
- (NSUInteger)getL1ICache;
- (NSUInteger)getL1DCache;
- (NSUInteger)getL2Cache;
- (NSUInteger)getL3Cache;
- (NSString*)getCPUType;
- (NSString*)getCPUSubtype;
- (NSString*)getEndianess;

- (NSString*)cpuTypeToString:(cpu_type_t)cpuType;
- (NSString*)cpuSubtypeToString:(cpu_subtype_t)cpuSubtype;
@end

@implementation CPUInfoController

#pragma mark - public

- (CPUInfo*)getCpuInfo
{
    CPUInfo *cpuInfo = [[CPUInfo alloc] init];
    
    cpuInfo.cpuName = [self getCPUName];
    cpuInfo.activeCPUCount = [self getActiveCPUCount];
    cpuInfo.physicalCPUCount = [self getPhysicalCPUCount];
    cpuInfo.physicalCPUMaxCount = [self getPhysicalCPUMaxCount];
    cpuInfo.logicalCPUCount = [self getLogicalCPUCount];
    cpuInfo.logicalCPUMaxCount = [self getLogicalCPUMaxCount];
    cpuInfo.cpuFrequency = [self getCPUFrequency];
    cpuInfo.l1DCache = [self getL1DCache];
    cpuInfo.l1ICache = [self getL1ICache];
    cpuInfo.l2Cache = [self getL2Cache];
    cpuInfo.l3Cache = [self getL3Cache];
    cpuInfo.cpuType = [self getCPUType];
    cpuInfo.cpuSubtype = [self getCPUSubtype];
    cpuInfo.endianess = [self getEndianess];
    
    return cpuInfo;
}

#pragma mark - private

- (NSString*)getCPUName
{
    HardcodedDeviceData *hardcodeData = [HardcodedDeviceData sharedDeviceData];
    return (NSString*)[hardcodeData getCPUName];
}

- (NSUInteger)getActiveCPUCount
{
    return (NSUInteger)[AMUtils getSysCtl64WithSpecifier:"hw.activecpu"];
}

- (NSUInteger)getPhysicalCPUCount
{
    return (NSUInteger)[AMUtils getSysCtl64WithSpecifier:"hw.physicalcpu"];
}

- (NSUInteger)getPhysicalCPUMaxCount
{
    return (NSUInteger)[AMUtils getSysCtl64WithSpecifier:"hw.physicalcpu_max"];
}

- (NSUInteger)getLogicalCPUCount
{
    return (NSUInteger)[AMUtils getSysCtl64WithSpecifier:"hw.logicalcpu"];
}

- (NSUInteger)getLogicalCPUMaxCount
{
    return (NSUInteger)[AMUtils getSysCtl64WithSpecifier:"hw.logicalcpu_max"];
}

- (NSUInteger)getCPUFrequency
{
    HardcodedDeviceData *hardcodeData = [HardcodedDeviceData sharedDeviceData];
    return [hardcodeData getCPUFrequency];
}

- (NSUInteger)getL1ICache
{
    NSUInteger val = (NSUInteger)[AMUtils getSysCtl64WithSpecifier:"hw.l1icachesize"];
    if (val == -1)
    {
        val = 0;
    }
    {
        val = B_TO_KB(val);
    }
    return val;
}

- (NSUInteger)getL1DCache
{
    NSUInteger val = (NSUInteger)[AMUtils getSysCtl64WithSpecifier:"hw.l1dcachesize"];
    if (val == -1)
    {
        val = 0;
    }
    {
        val = B_TO_KB(val);
    }
    return val;
}

- (NSUInteger)getL2Cache
{
    NSUInteger val = (NSUInteger)[AMUtils getSysCtl64WithSpecifier:"hw.l2cachesize"];
    if (val == -1)
    {
        val = 0;
    }
    else
    {
        val = B_TO_KB(val);
    }
    return val;
}

- (NSUInteger)getL3Cache
{
    NSUInteger val = (NSUInteger)[AMUtils getSysCtl64WithSpecifier:"hw.l3cachesize"];
    if (val == -1)
    {
        val = 0;
    }
    else
    {
        val = B_TO_KB(val);
    }
    return val;
}

- (NSString*)getCPUType
{
    cpu_type_t cpuType = (cpu_type_t)[AMUtils getSysCtl64WithSpecifier:"hw.cputype"];
    return [self cpuTypeToString:cpuType];
}

- (NSString*)getCPUSubtype
{
    cpu_subtype_t cpuSubtype = [AMUtils getSysCtl64WithSpecifier:"hw.cpusubtype"];
    return [self cpuSubtypeToString:cpuSubtype];
}

- (NSString*)getEndianess
{
    NSUInteger value = (NSUInteger)[AMUtils getSysCtl64WithSpecifier:"hw.byteorder"];
    
    if (value == 1234)
    {
        return @"Little endian";
    }
    else if (value == 4321)
    {
        return @"Big endian";
    }
    else
    {
        return @"-";
    }
}

- (NSString*)cpuTypeToString:(cpu_type_t)cpuType
{
    switch (cpuType) {
        case CPU_TYPE_ANY:      return @"Unknown";          break;
        case CPU_TYPE_ARM:      return @"ARM";              break;
        case CPU_TYPE_HPPA:     return @"HP PA-RISC";       break;
        case CPU_TYPE_I386:     return @"Intel i386";       break;
        case CPU_TYPE_I860:     return @"Intel i860";       break;
        case CPU_TYPE_MC680x0:  return @"Motorola 680x0";   break;
        case CPU_TYPE_MC88000:  return @"Motorola 88000";   break;
        case CPU_TYPE_MC98000:  return @"Motorola 98000";   break;
        case CPU_TYPE_POWERPC:  return @"Power PC";         break;
        case CPU_TYPE_POWERPC64:return @"Power PC64";       break;
        case CPU_TYPE_SPARC:    return @"SPARC";            break;
        default:                return @"Unknown";          break;
    }
}

- (NSString*)cpuSubtypeToString:(cpu_subtype_t)cpuSubtype
{
    switch (cpuSubtype) {
        case CPU_SUBTYPE_ARM_ALL:   return @"ARM";          break;
        case CPU_SUBTYPE_ARM_V4T:   return @"ARMv4T";       break;
        case CPU_SUBTYPE_ARM_V5TEJ: return @"ARMv5TEJ";     break;
        case CPU_SUBTYPE_ARM_V6:    return @"ARMv6";        break;
        case CPU_SUBTYPE_ARM_V7:    return @"ARMv7";        break;
        case CPU_SUBTYPE_ARM_V7F:   return @"ARMv7F";       break;
        case CPU_SUBTYPE_ARM_V7K:   return @"ARMv7K";       break;
        case CPU_SUBTYPE_ARM_V7S:   return @"ARMv7S";       break;
        default:                    return @"Unknown";      break;
    }
}

@end
