//
//  ProcessInfo.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>
#import <sys/sysctl.h>

typedef enum {
    PROCESS_STATUS_FORKED       = SIDL,
    PROCESS_STATUS_RUNNABLE     = SRUN,
    PROCESS_STATUS_SLEEPING     = SSLEEP,
    PROCESS_STATUS_SUSPENDED    = SSTOP,
    PROCESS_STATUS_ZOMBIE_STATE = SZOMB
} ProcessStatus_t;

@interface ProcessInfo : NSObject
@property (strong, nonatomic) NSString          *name;
@property (assign, nonatomic) NSInteger         pid;
@property (assign, nonatomic) NSInteger         priority;
@property (assign, nonatomic) ProcessStatus_t   status;
@property (assign, nonatomic) time_t            startTime;
@property (strong, nonatomic) NSString          *commandLine;
@property (strong, nonatomic) UIImage           *icon;

- (NSString*)getStatusString;
@end
