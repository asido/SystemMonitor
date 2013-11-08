//
//  Batterynfo.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>

@interface BatteryInfo : NSObject
@property (assign, nonatomic) NSUInteger    capacity;
@property (assign, nonatomic) CGFloat       voltage;

@property (assign, nonatomic) NSUInteger    levelPercent;
@property (assign, nonatomic) NSUInteger    levelMAH;
@property (assign, nonatomic) NSString      *status;
@end
