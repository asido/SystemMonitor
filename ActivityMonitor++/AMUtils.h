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
+ (uint64_t)getSysCtl64WithSpecifier:(char*)specifier;
+ (NSString*)getSysCtlChrWithSpecifier:(char*)specifier;
+ (uint64_t)getSysCtlHw:(uint32_t)hwSpecifier;
@end
