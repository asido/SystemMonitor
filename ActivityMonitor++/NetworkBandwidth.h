//
//  NetworkBandwidth.h
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
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
