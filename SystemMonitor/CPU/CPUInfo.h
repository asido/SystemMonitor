//
//  CPUInfo.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>

@interface CPUInfo : NSObject
@property (nonatomic, copy)   NSString     *cpuName;
@property (nonatomic, copy)   NSString     *coprocessor;
@property (nonatomic, assign) NSUInteger   activeCPUCount;
@property (nonatomic, assign) NSUInteger   physicalCPUCount;
@property (nonatomic, assign) NSUInteger   physicalCPUMaxCount;
@property (nonatomic, assign) NSUInteger   logicalCPUCount;
@property (nonatomic, assign) NSUInteger   logicalCPUMaxCount;
@property (nonatomic, assign) NSUInteger   cpuFrequency;
@property (nonatomic, assign) NSUInteger   l1DCache;
@property (nonatomic, assign) NSUInteger   l1ICache;
@property (nonatomic, assign) NSUInteger   l2Cache;
@property (nonatomic, copy)   NSString     *cpuType;
@property (nonatomic, copy)   NSString     *cpuSubtype;
@property (nonatomic, copy)   NSString     *endianess;
@end
