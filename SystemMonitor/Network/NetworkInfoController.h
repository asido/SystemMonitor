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

@protocol NetworkInfoControllerDelegate <NSObject>
@optional
- (void)networkBandwidthUpdated:(NetworkBandwidth*)bandwidth;
- (void)networkStatusUpdated;
- (void)networkExternalIPAddressUpdated;
- (void)networkMaxBandwidthUpdated;
- (void)networkActiveConnectionsUpdated:(NSArray*)connections;
@end

@interface NetworkInfoController : NSObject
@property (nonatomic, weak) id<NetworkInfoControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray    *networkBandwidthHistory;

@property (nonatomic, assign) CGFloat       currentMaxSentBandwidth;
@property (nonatomic, assign) CGFloat       currentMaxReceivedBandwidth;

- (NetworkInfo*)getNetworkInfo;

- (void)startNetworkBandwidthUpdatesWithFrequency:(NSUInteger)frequency;
- (void)stopNetworkBandwidthUpdates;
- (void)setNetworkBandwidthHistorySize:(NSUInteger)size;

- (void)updateActiveConnections;
@end
