//
//  ProcessInfo.h
//  ActivityMonitor++
//
//  Created by st on 21/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
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
