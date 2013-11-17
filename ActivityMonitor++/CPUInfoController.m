//
//  CPUInfoController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <sys/sysctl.h>
#import <mach/mach_host.h>
#import <mach/machine.h>
#import <mach/task_info.h>
#import <mach/mach_types.h>
#import <mach/mach_init.h>
#import <mach/vm_map.h>
#import "HardcodedDeviceData.h"
#import "AMLogger.h"
#import "AMUtils.h"
#import "AMDevice.h"
#import "CPUInfo.h"
#import "CPULoad.h"
#import "CPULoadFilter.h"
#import "CPUInfoController.h"

@interface CPUInfoController()
@property (strong, nonatomic) CPUInfo       *cpuInfo;
@property (strong, nonatomic) CPULoadFilter *cpuLoadFilter;
@property (assign, nonatomic) NSUInteger    cpuLoadHistorySize;

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
- (NSString*)getCPUType;
- (NSString*)getCPUSubtype;
- (NSString*)getEndianess;

- (NSString*)cpuTypeToString:(cpu_type_t)cpuType;
- (NSString*)cpuSubtypeToString:(cpu_subtype_t)cpuSubtype;

- (void)pushCPUHistory:(NSArray*)cpuLoads;

@property (strong, nonatomic) NSTimer *cpuLoadUpdateTimer;
- (void)cpuLoadUpdateTimerCB:(NSNotification*)notification;
- (NSArray*)calculateCPUUsage;
@end

@implementation CPUInfoController
{
    processor_cpu_load_info_t priorCpuTicks;
    mach_port_t host;
    processor_set_name_port_t processorSet;
}

@synthesize delegate;
@synthesize cpuLoadHistory;

@synthesize cpuInfo;
@synthesize cpuLoadFilter;
@synthesize cpuLoadHistorySize;

@synthesize cpuLoadUpdateTimer;

#pragma mark - override

- (id)init
{
    if (self = [super init])
    {
        self.cpuLoadHistory = [[NSMutableArray alloc] init];
        self.cpuLoadFilter = [[CPULoadFilter alloc] init];
        
        self.cpuLoadHistorySize = kDefaultDataHistorySize;
        
        // Set up mach host and default processor set for later calls.
        host = mach_host_self();
        processor_set_default(host, &processorSet);
        
        // Build the storage for the prior ticks and store the first block of data.
        natural_t cpuCount;
        processor_cpu_load_info_t processorTickInfo;
        mach_msg_type_number_t processorMsgCount;
        kern_return_t kStatus = host_processor_info(host, PROCESSOR_CPU_LOAD_INFO, &cpuCount,
                                                    (processor_info_array_t*)&processorTickInfo, &processorMsgCount);
        if (kStatus == KERN_SUCCESS)
        {
            priorCpuTicks = malloc(cpuCount * sizeof(*priorCpuTicks));
            for (natural_t i = 0; i < cpuCount; ++i)
            {
                for (NSUInteger j = 0; j < CPU_STATE_MAX; ++j)
                {
                    priorCpuTicks[i].cpu_ticks[j] = processorTickInfo[i].cpu_ticks[j];
                }
            }
            vm_deallocate(mach_task_self(), (vm_address_t)processorTickInfo, (vm_size_t)(processorMsgCount * sizeof(*processorTickInfo)));
        }
        else
        {
            AMLogWarn(@"failure retreiving host_processor_info. kStatus == %d", kStatus);
        }
        
    }
    return self;
}

- (void)dealloc
{
    free(priorCpuTicks);
}

#pragma mark - public

- (CPUInfo*)getCPUInfo
{
    if (!self.cpuInfo)
    {
        self.cpuInfo = [[CPUInfo alloc] init];
        
        self.cpuInfo.cpuName = [self getCPUName];
        self.cpuInfo.activeCPUCount = [self getActiveCPUCount];
        self.cpuInfo.physicalCPUCount = [self getPhysicalCPUCount];
        self.cpuInfo.physicalCPUMaxCount = [self getPhysicalCPUMaxCount];
        self.cpuInfo.logicalCPUCount = [self getLogicalCPUCount];
        self.cpuInfo.logicalCPUMaxCount = [self getLogicalCPUMaxCount];
        self.cpuInfo.cpuFrequency = [self getCPUFrequency];
        self.cpuInfo.l1DCache = [self getL1DCache];
        self.cpuInfo.l1ICache = [self getL1ICache];
        self.cpuInfo.l2Cache = [self getL2Cache];
        self.cpuInfo.cpuType = [self getCPUType];
        self.cpuInfo.cpuSubtype = [self getCPUSubtype];
        self.cpuInfo.endianess = [self getEndianess];
    }
    
    return self.cpuInfo;
}

- (void)startCPULoadUpdatesWithFrequency:(NSUInteger)frequency
{
    [self stopCPULoadUpdates];
    self.cpuLoadUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / frequency
                                                               target:self
                                                             selector:@selector(cpuLoadUpdateTimerCB:)
                                                             userInfo:nil
                                                              repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.cpuLoadUpdateTimer forMode:NSRunLoopCommonModes];
}

- (void)stopCPULoadUpdates
{
    [self.cpuLoadUpdateTimer invalidate];
    self.cpuLoadUpdateTimer = nil;
}

- (void)setCPULoadHistorySize:(NSUInteger)size
{
    self.cpuLoadHistorySize = size;
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
        val = val;
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
        val = val;
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
        val = val;
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
    cpu_subtype_t cpuSubtype = (cpu_subtype_t)[AMUtils getSysCtl64WithSpecifier:"hw.cpusubtype"];
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
#if !(TARGET_IPHONE_SIMULATOR) // Simulator headers don't include such subtype.
        case CPU_SUBTYPE_ARM64_V8:  return @"ARM64";        break;
#endif
        default:                    return @"Unknown";      break;
    }
}

- (void)pushCPUHistory:(NSArray*)cpuLoads
{
    [self.cpuLoadHistory addObject:cpuLoads];
    
    while (self.cpuLoadHistory.count > self.cpuLoadHistorySize)
    {
        [self.cpuLoadHistory removeObjectAtIndex:0];
    }
}

- (void)cpuLoadUpdateTimerCB:(NSNotification*)notification
{
    NSArray *rawLoadArray = [self calculateCPUUsage];
    
    [self pushCPUHistory:rawLoadArray];
    [self.delegate cpuLoadUpdated:rawLoadArray];
}

- (NSArray*)calculateCPUUsage
{
    // host_info params
    unsigned int                processorCount;
    processor_cpu_load_info_t   processorTickInfo;
    mach_msg_type_number_t      processorMsgCount;
    // Errors
    kern_return_t               kStatus;
    // Loops
    unsigned int                i, j;
    // Data per proc
    unsigned long               system, user, nice, idle;
    unsigned long long          total, totalnonice;
    // Data average for all procs
    unsigned long long          systemall = 0;
    unsigned long long          userall = 0;
    unsigned long long          niceall = 0;
    unsigned long long          idleall = 0;
    unsigned long long          totalall = 0;
    unsigned long long          totalallnonice = 0;
    // Return data
    NSMutableArray *loadArr;
    
    if (!priorCpuTicks)
    {
        goto Error;
    }
    
    // Read the current ticks
    kStatus = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &processorCount,
                                  (processor_info_array_t*)&processorTickInfo, &processorMsgCount);
    if (kStatus != KERN_SUCCESS)
    {
        goto Error;
    }
    
    loadArr = [NSMutableArray arrayWithCapacity:processorCount];
    
    // Loop the processors
    for (i = 0; i < processorCount; ++i)
    {
        // Calc load types and totals, with guards against overflows.
        
        if (processorTickInfo[i].cpu_ticks[CPU_STATE_SYSTEM] >= priorCpuTicks[i].cpu_ticks[CPU_STATE_SYSTEM])
        {
            system = processorTickInfo[i].cpu_ticks[CPU_STATE_SYSTEM] - priorCpuTicks[i].cpu_ticks[CPU_STATE_SYSTEM];
        }
        else
        {
            system = processorTickInfo[i].cpu_ticks[CPU_STATE_SYSTEM] + (ULONG_MAX - priorCpuTicks[i].cpu_ticks[CPU_STATE_SYSTEM] + 1);
        }
        
        if (processorTickInfo[i].cpu_ticks[CPU_STATE_USER] >= priorCpuTicks[i].cpu_ticks[CPU_STATE_USER])
        {
            user = processorTickInfo[i].cpu_ticks[CPU_STATE_USER] - priorCpuTicks[i].cpu_ticks[CPU_STATE_USER];
        }
        else
        {
            user = processorTickInfo[i].cpu_ticks[CPU_STATE_USER] + (ULONG_MAX - priorCpuTicks[i].cpu_ticks[CPU_STATE_USER] + 1);
        }
        
        if (processorTickInfo[i].cpu_ticks[CPU_STATE_NICE] >= priorCpuTicks[i].cpu_ticks[CPU_STATE_NICE])
        {
            nice = processorTickInfo[i].cpu_ticks[CPU_STATE_NICE] - priorCpuTicks[i].cpu_ticks[CPU_STATE_NICE];
        }
        else
        {
            nice = processorTickInfo[i].cpu_ticks[CPU_STATE_NICE] + (ULONG_MAX - priorCpuTicks[i].cpu_ticks[CPU_STATE_NICE] + 1);
        }
        
        if (processorTickInfo[i].cpu_ticks[CPU_STATE_IDLE] >= priorCpuTicks[i].cpu_ticks[CPU_STATE_IDLE])
        {
            idle = processorTickInfo[i].cpu_ticks[CPU_STATE_IDLE] - priorCpuTicks[i].cpu_ticks[CPU_STATE_IDLE];
        }
        else
        {
            idle = processorTickInfo[i].cpu_ticks[CPU_STATE_IDLE] + (ULONG_MAX - priorCpuTicks[i].cpu_ticks[CPU_STATE_IDLE] + 1);
        }
        
        total = system + user + nice + idle;
        totalnonice = system + user + idle;
        
        systemall += system;
        userall += user;
        niceall += nice;
        idleall += idle;
        totalall += total;
        totalallnonice += totalnonice;
        
        // Sanity
        if (total < 1)
        {
            total = 1;
        }
        if (totalnonice < 1)
        {
            totalnonice = 1;
        }
        
        CPULoad *loadObj            = [[CPULoad alloc] init];
        loadObj.system              = MIN(100.0, (double)system / total         * 100.0);
        loadObj.user                = MIN(100.0, (double)user   / total         * 100.0);
        loadObj.nice                = MIN(100.0, (double)nice   / total         * 100.0);
        loadObj.systemWithoutNice   = MIN(100.0, (double)system / totalnonice   * 100.0);
        loadObj.userWithoutNice     = MIN(100.0, (double)user   / totalnonice   * 100.0);
        loadObj.total               = loadObj.system + loadObj.user + loadObj.nice;
        [loadArr addObject:loadObj];
    }
    
    for (i = 0; i < processorCount; ++i)
    {
        for (j = 0; j < CPU_STATE_MAX; ++j)
        {
            priorCpuTicks[i].cpu_ticks[j] = processorTickInfo[i].cpu_ticks[j];
        }
    }
    
    vm_deallocate(mach_task_self(), (vm_address_t)processorTickInfo, (vm_size_t)(processorMsgCount * sizeof(*processorTickInfo)));
    
    return loadArr;
    
Error:
    loadArr = [NSMutableArray arrayWithCapacity:self.cpuInfo.activeCPUCount];
    for (NSUInteger i = 0; i < self.cpuInfo.activeCPUCount; ++i)
    {
        [loadArr addObject:[[CPULoad alloc] init]];
    }
    return loadArr;
}

@end
