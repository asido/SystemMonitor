//
//  CPUInfo.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "CPUInfo.h"

@implementation CPUInfo
@synthesize cpuName;
@synthesize coprocessor;
@synthesize activeCPUCount;
@synthesize physicalCPUCount;
@synthesize physicalCPUMaxCount;
@synthesize logicalCPUCount;
@synthesize logicalCPUMaxCount;
@synthesize cpuFrequency;
@synthesize l1DCache;
@synthesize l1ICache;
@synthesize l2Cache;
@synthesize cpuType;
@synthesize cpuSubtype;
@synthesize endianess;
@end
