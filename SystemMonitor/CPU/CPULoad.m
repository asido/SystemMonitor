//
//  CPULoad.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "CPULoad.h"

@implementation CPULoad
@synthesize system;
@synthesize user;
@synthesize nice;
@synthesize systemWithoutNice;
@synthesize userWithoutNice;
@synthesize total;
@end
