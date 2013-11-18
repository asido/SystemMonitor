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
@property (strong, nonatomic) NSString  *interface;
@property (strong, nonatomic) NSDate    *timestamp;

@property (assign, nonatomic) float     sent;
@property (assign, nonatomic) uint64_t  totalWiFiSent;
@property (assign, nonatomic) uint64_t  totalWWANSent;
@property (assign, nonatomic) float     received;
@property (assign, nonatomic) uint64_t  totalWiFiReceived;
@property (assign, nonatomic) uint64_t  totalWWANReceived;
@end
