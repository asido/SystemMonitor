//
//  AMUtils.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
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
+ (CGFloat)percentageValueFromMax:(CGFloat)max min:(CGFloat)min percent:(CGFloat)percent;
+ (CGFloat)valuePercentFrom:(CGFloat)from to:(CGFloat)to value:(CGFloat)value;

+ (CGFloat)random;

+ (NSString*)toNearestMetric:(uint64_t)value desiredFraction:(NSUInteger)fraction;

+ (BOOL)isIPad;
+ (BOOL)isIPhone;
+ (BOOL)isIPhone5;

+ (BOOL)dateDidTimeout:(NSDate*)date seconds:(double)sec;

+ (void)openReviewAppPage;
@end
