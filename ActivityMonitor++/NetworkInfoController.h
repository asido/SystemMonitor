//
//  NetworkInfoController.h
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkBandwidth.h"
#import "NetworkInfo.h"

@protocol NetworkInfoControllerDelegate
- (void)networkBandwidthUpdated:(NetworkBandwidth*)bandwidth;
- (void)networkStatusUpdated;
@end

@interface NetworkInfoController : NSObject
@property (strong, nonatomic) id<NetworkInfoControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray                    *networkBandwidthHistory;

- (NetworkInfo*)getNetworkInfo;
- (void)startNetworkBandwidthUpdatesWithFrequency:(NSUInteger)frequency;
- (void)stopNetworkBandwidthUpdates;
- (void)setNetworkBandwidthHistorySize:(NSUInteger)size;
@end
