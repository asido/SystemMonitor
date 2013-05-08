//
//  CPUInfo.h
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPUInfo : NSObject
@property (retain) NSString     *cpuName;
@property (assign) NSUInteger   activeCPUCount;
@property (assign) NSUInteger   physicalCPUCount;
@property (assign) NSUInteger   physicalCPUMaxCount;
@property (assign) NSUInteger   logicalCPUCount;
@property (assign) NSUInteger   logicalCPUMaxCount;
@property (assign) NSUInteger   cpuFrequency;
@property (assign) NSUInteger   l1DCache;
@property (assign) NSUInteger   l1ICache;
@property (assign) NSUInteger   l2Cache;
@property (assign) NSUInteger   l3Cache;
@property (retain) NSString     *cpuType;
@property (retain) NSString     *cpuSubtype;
@property (retain) NSString     *endianess;
@end
