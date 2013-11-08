//
//  AMLog.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#ifndef ActivityMonitor___AMLog_h
#define ActivityMonitor___AMLog_h

#import "DDLog.h"

#ifdef DEBUG
#define AMLog(str, ...)     DDLogInfo(str, ##__VA_ARGS__)
#else
#define AMLog(str, ...)
#endif

#define AMWarn(str, ...)    DDLogInfo(@"<%s> Warning: " #str, __PRETTY_FUNCTION__, ##__VA_ARGS__)

#endif
