//
//  RAMInfoController.h
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RAMInfo.h"
#import "RAMUsage.h"

@protocol RAMInfoControllerDelegate
- (void)ramUsageUpdated:(RAMUsage*)usage;
@end

@interface RAMInfoController : NSObject
@property (strong, nonatomic) id<RAMInfoControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray                *ramUsageHistory;

- (RAMInfo*)getRAMInfo;
- (void)startRAMUsageUpdatesWithFrequency:(NSUInteger)frequency;
- (void)stopRAMUsageUpdates;
- (void)setRAMUsageHistorySize:(NSUInteger)size;
@end
