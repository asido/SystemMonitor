//
//  CPULoad.h
//  ActivityMonitor++
//
//  Created by st on 08/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPULoad : NSObject
// Values are in %
@property (assign, nonatomic) double system;
@property (assign, nonatomic) double user;
@property (assign, nonatomic) double nice;
@property (assign, nonatomic) double systemWithoutNice;
@property (assign, nonatomic) double userWithoutNice;
@property (assign, nonatomic) double total;
@end
