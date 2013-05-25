//
//  BatteryInfo.h
//  ActivityMonitor++
//
//  Created by st on 24/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BatteryInfo : NSObject
@property (assign, nonatomic) NSUInteger    capacity;
@property (assign, nonatomic) CGFloat       voltage;

@property (assign, nonatomic) NSUInteger    levelPercent;
@property (assign, nonatomic) NSUInteger    levelMAH;
@property (assign, nonatomic) NSString      *status;
@end
