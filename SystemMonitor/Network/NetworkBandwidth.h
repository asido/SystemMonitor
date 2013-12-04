//
//  NetworkBandwidth.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>

@interface NetworkBandwidth : NSObject
@property (nonatomic, copy)   NSString  *interface;
@property (nonatomic, strong) NSDate    *timestamp;

@property (nonatomic, assign) float     sent;
@property (nonatomic, assign) uint64_t  totalWiFiSent;
@property (nonatomic, assign) uint64_t  totalWWANSent;
@property (nonatomic, assign) float     received;
@property (nonatomic, assign) uint64_t  totalWiFiReceived;
@property (nonatomic, assign) uint64_t  totalWWANReceived;
@end
