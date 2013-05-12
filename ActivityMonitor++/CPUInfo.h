//
//  CPUInfo.h
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPUInfo : NSObject
@property (strong, nonatomic) NSString     *cpuName;
@property (assign, nonatomic) NSUInteger   activeCPUCount;
@property (assign, nonatomic) NSUInteger   physicalCPUCount;
@property (assign, nonatomic) NSUInteger   physicalCPUMaxCount;
@property (assign, nonatomic) NSUInteger   logicalCPUCount;
@property (assign, nonatomic) NSUInteger   logicalCPUMaxCount;
@property (assign, nonatomic) NSUInteger   cpuFrequency;
@property (assign, nonatomic) NSUInteger   l1DCache;
@property (assign, nonatomic) NSUInteger   l1ICache;
@property (assign, nonatomic) NSUInteger   l2Cache;
@property (assign, nonatomic) NSUInteger   l3Cache;
@property (strong, nonatomic) NSString     *cpuType;
@property (strong, nonatomic) NSString     *cpuSubtype;
@property (strong, nonatomic) NSString     *endianess;
@end
