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
@optional
- (void)networkBandwidthUpdated:(NetworkBandwidth*)bandwidth;
- (void)networkStatusUpdated;
- (void)networkExternalIPAddressUpdated;
- (void)networkMaxBandwidthUpdated;
- (void)networkActiveConnectionsUpdated:(NSArray*)connections;
@end

@interface NetworkInfoController : NSObject
@property (weak, nonatomic) id<NetworkInfoControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray    *networkBandwidthHistory;

@property (assign, nonatomic) CGFloat       currentMaxSentBandwidth;
@property (assign, nonatomic) CGFloat       currentMaxReceivedBandwidth; 

- (NetworkInfo*)getNetworkInfo;

- (void)startNetworkBandwidthUpdatesWithFrequency:(NSUInteger)frequency;
- (void)stopNetworkBandwidthUpdates;
- (void)setNetworkBandwidthHistorySize:(NSUInteger)size;

- (void)updateActiveConnections;
@end
