//
//  CPUInfo.h
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPUInfo : NSObject
@property (assign) NSUInteger   activeCPUCount;
@property (assign) NSUInteger   physicalCPUCount;
@property (assign) NSUInteger   physicalCPUMaxCount;
@property (assign) NSUInteger   logicalCPUCount;
@property (assign) NSUInteger   logicalCPUMaxCount;
@property (retain) NSString     *cpuType;
@property (retain) NSString     *cpuSubtype;
@property (retain) NSString     *cpuModel;
@property (retain) NSString     *endianess;
@end
