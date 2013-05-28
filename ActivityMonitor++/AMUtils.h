//
//  AMUtils.h
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AM_UNUSED(var)  (void)(var)

#define B_TO_KB(a)      ((a) / 1024.0f)
#define B_TO_MB(a)      (B_TO_KB(a) / 1024.0f)
#define B_TO_GB(a)      (B_TO_MB(a) / 1024.0f)
#define B_TO_TB(a)      (B_TO_GB(a) / 1024.0f)
#define KB_TO_B(a)      ((a) * 1024.0f)
#define MB_TO_B(a)      (KB_TO_B(a) * 1024.0f)
#define GB_TO_B(a)      (MB_TO_B(a) * 1024.0f)
#define TB_TO_B(a)      (GB_TO_B(a) * 1024.0f)

@interface AMUtils : NSObject
/* SysCtl */
+ (uint64_t)getSysCtl64WithSpecifier:(char*)specifier;
+ (NSString*)getSysCtlChrWithSpecifier:(char*)specifier;
+ (void*)getSysCtlPtrWithSpecifier:(char*)specifier pointer:(void*)ptr size:(size_t)size;
+ (uint64_t)getSysCtlHw:(uint32_t)hwSpecifier;

// Returns a value representing a specified percent of the value between max and min.
// i.e. 20 percent in the range of 0-10 is 2.
+ (double)percentageValueFromMax:(double)max min:(double)min percent:(float)percent;
+ (float)valuePercentFrom:(double)from to:(double)to value:(double)value;

+ (CGFloat)random;

+ (NSString*)toNearestMetric:(uint64_t)value desiredFraction:(NSUInteger)fraction;

+ (BOOL)isIPad;
+ (BOOL)isIPhone;
+ (BOOL)isIPhone5;
@end
