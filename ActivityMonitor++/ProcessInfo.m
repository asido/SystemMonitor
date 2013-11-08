//
//  ProcessInfo.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//
#import "ProcessInfo.h"

@implementation ProcessInfo
@synthesize name;
@synthesize pid;
@synthesize priority;
@synthesize status;
@synthesize startTime;
@synthesize commandLine;
@synthesize icon;

- (NSString*)getStatusString
{
    switch (self.status) {
        case PROCESS_STATUS_FORKED:         return @"Forked";       break;
        case PROCESS_STATUS_RUNNABLE:       return @"Runnable";     break;
        case PROCESS_STATUS_SLEEPING:       return @"Sleeping";     break;
        case PROCESS_STATUS_SUSPENDED:      return @"Suspended";    break;
        case PROCESS_STATUS_ZOMBIE_STATE:   return @"Zombie";       break;
        default:                            return @"Unknown";      break;
    }
}

@end
