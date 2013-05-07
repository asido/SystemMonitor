//
//  CPUInfoController.m
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <sys/sysctl.h>
#import <mach/mach_host.h>
#import "AMLog.h"
#import "CPUInfoController.h"

@interface CPUInfoController()
- (NSString*)cpuTypeToString:(cpu_type_t)cpuType;
- (NSString*)cpuSubtypeToString:(cpu_subtype_t)cpuSubtype;
- (host_basic_info_data_t*)getHostInfo:(host_basic_info_data_t*)hostInfo;
- (NSString*)getMachineModel;
- (NSString*)getEndianess;
- (NSUInteger)getActiveCPUCount;
@end

@implementation CPUInfoController

#pragma mark - public

- (CPUInfo*)getCpuInfo
{
    CPUInfo *cpuInfo = [[CPUInfo alloc] init];
    
    
    host_basic_info_data_t hostInfo;
    [self getHostInfo:&hostInfo];
    
    cpuInfo.activeCPUCount = [self getActiveCPUCount];
    cpuInfo.physicalCPUCount = hostInfo.physical_cpu;
    cpuInfo.physicalCPUMaxCount = hostInfo.physical_cpu_max;
    cpuInfo.logicalCPUCount = hostInfo.logical_cpu;
    cpuInfo.logicalCPUMaxCount = hostInfo.logical_cpu_max;
    cpuInfo.cpuType = [self cpuTypeToString:hostInfo.cpu_type];
    cpuInfo.cpuSubtype = [self cpuSubtypeToString:hostInfo.cpu_subtype];

    cpuInfo.cpuModel = [self getMachineModel];
    cpuInfo.endianess = [self getEndianess];
    
    return cpuInfo;
}

#pragma mark - private

- (NSString*)cpuTypeToString:(cpu_type_t)cpuType
{
    switch (cpuType) {
        case CPU_TYPE_ANY:      return @"Unknown";          break;
        case CPU_TYPE_ARM:      return @"ARM";              break;
        case CPU_TYPE_HPPA:     return @"HP PA-RISC";       break;
        case CPU_TYPE_I386:     return @"Intel i386";       break;
        case CPU_TYPE_I860:     return @"Intel i860";       break;
        case CPU_TYPE_MC680x0:  return @"Motorola680x0";    break;
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

- (host_basic_info_data_t*)getHostInfo:(host_basic_info_data_t*)hostInfo
{
    mach_msg_type_number_t infoCount;
    
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)hostInfo, &infoCount);
    
    return hostInfo;
}

- (NSString*)getMachineModel
{
    int query[] = { CTL_HW, HW_MODEL };
    size_t strLen;
    
    if (sysctl(query, 2, NULL, &strLen, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctl CTL_HW.HW_MODEL length failed: %s",
              __PRETTY_FUNCTION__, strerror(errno));
    }
    
    char str[strLen];
    if (sysctl(query, 2, str, &strLen, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctl CTL_HW.HW_MODEL value failed: %s",
              __PRETTY_FUNCTION__, strerror(errno));
    }
    
    NSString *result = [NSString stringWithCString:str
                                          encoding:NSUTF8StringEncoding];
    return result;
}

- (NSString*)getEndianess
{
    int query[] = { CTL_HW, HW_BYTEORDER };
    size_t len;
    
    if (sysctl(query, 2, NULL, &len, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctl CTL_HW.HW_BYTEORDER length failed: %s",
              __PRETTY_FUNCTION__, strerror(errno));
    }
    assert(len <= sizeof(NSInteger));
    
    NSInteger val = 0;
    if (sysctl(query, 2, &val, &len, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctl CTL_HW.HW_BYTEORDER value failed: %s",
              __PRETTY_FUNCTION__, strerror(errno));
    }
    
    NSString *result = @"Unknown";
    if (val == 1234)
    {
        result = @"Little endian";
    }
    else if (val == 4321)
    {
        result = @"Big endian";
    }
    
    AMWarn(@"Test warning");
    
    return result;
}

- (NSUInteger)getActiveCPUCount
{
    size_t size;
    if (sysctlbyname("hw.activecpu", NULL, &size, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctlbyname hw.activecpu failed: %s",
              __PRETTY_FUNCTION__, strerror(errno));
    }
    assert(size <= sizeof(NSUInteger));
    
    uint32_t val = 0;
    sysctlbyname("hw.activecpu", &val, &size, NULL, 0);
    return val;
}

@end
