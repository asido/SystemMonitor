//
//  AMLog.h
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#ifndef ActivityMonitor___AMLog_h
#define ActivityMonitor___AMLog_h

#import "DDLog.h"

#ifdef DEBUG
#define AMLog(str, ...)     DDLogInfo(str, ##__VA_ARGS__)
#else
#define AMLog(str, ...)
#endif

#define AMWarn(str, ...)    DDLogInfo(@"Warning: " #str, ##__VA_ARGS__)

#endif
