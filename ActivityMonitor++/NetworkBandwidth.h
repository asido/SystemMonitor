//
//  NetworkBandwidth.h
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkBandwidth : NSObject
// In MB
@property (assign, nonatomic) float wifiTotalSent;
@property (assign, nonatomic) float wifiTotalReceived;
@property (assign, nonatomic) float wwanTotalSent;
@property (assign, nonatomic) float wwanTotalReceived;
// In KB
@property (assign, nonatomic) float wifiSent;
@property (assign, nonatomic) float wifiReceived;
@property (assign, nonatomic) float wwanSent;
@property (assign, nonatomic) float wwanReceived;
@end
