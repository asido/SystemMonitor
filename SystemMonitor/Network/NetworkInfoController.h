//
//  NetworkInfoController.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
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
