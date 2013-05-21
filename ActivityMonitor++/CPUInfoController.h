//
//  CPUInfoController.h
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPULoad.h"
#import "CPUInfo.h"

@protocol CPUInfoControllerDelegate
- (void)cpuLoadUpdated:(NSArray*)loadArray;
@end

@interface CPUInfoController : NSObject
@property (assign, nonatomic) id<CPUInfoControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *cpuLoadHistory;

- (CPUInfo*)getCPUInfo;
- (void)startCPULoadUpdatesWithFrequency:(NSUInteger)frequency;
- (void)stopCPULoadUpdates;
@end
