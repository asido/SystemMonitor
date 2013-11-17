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
@property (strong, nonatomic) NSString     *cpuType;
@property (strong, nonatomic) NSString     *cpuSubtype;
@property (strong, nonatomic) NSString     *endianess;
@end
