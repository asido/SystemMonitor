//
//  RAMInfo.h
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RAMInfo : NSObject
// Everything is in MB
@property (assign, nonatomic) NSUInteger totalRam;
@property (assign, nonatomic) NSUInteger usedRam;
@property (assign, nonatomic) NSUInteger activeRam;
@property (assign, nonatomic) NSUInteger inactiveRam;
@property (assign, nonatomic) NSUInteger wiredRam;
@end
