//
//  RAMInfoController.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>
#import "RAMInfo.h"
#import "RAMUsage.h"

@protocol RAMInfoControllerDelegate
- (void)ramUsageUpdated:(RAMUsage*)usage;
@end

@interface RAMInfoController : NSObject
@property (nonatomic, weak) id<RAMInfoControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray              *ramUsageHistory;

- (RAMInfo*)getRAMInfo;
- (void)startRAMUsageUpdatesWithFrequency:(NSUInteger)frequency;
- (void)stopRAMUsageUpdates;
- (void)setRAMUsageHistorySize:(NSUInteger)size;
@end
