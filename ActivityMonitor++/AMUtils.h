//
//  AMUtils.h
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AM_UNUSED(var)  (void)(var)

#define B_TO_KB(a)      ((a) / 1024)

@interface AMUtils : NSObject
/* SysCtl */
+ (uint64_t)getSysCtl64WithSpecifier:(char*)specifier;
+ (NSString*)getSysCtlChrWithSpecifier:(char*)specifier;
+ (uint64_t)getSysCtlHw:(uint32_t)hwSpecifier;

// Returns a value representing a specified percent of the value between max and min.
// i.e. 20 percent in the range of 0-10 is 2.
+ (float)percentageValueFromMax:(float)max min:(float)min percent:(float)percent;
@end
