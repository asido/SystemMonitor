//
//  ProcessInfo.m
//  ActivityMonitor++
//
//  Created by st on 21/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
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
