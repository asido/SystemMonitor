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
@property (assign) double system;
@property (assign) double user;
@property (assign) double nice;
@property (assign) double systemWithoutNice;
@property (assign) double userWithoutNice;
@end
