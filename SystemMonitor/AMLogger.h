//
//  AMLogger.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

/*
 ===============================================================================
    class AMLogger
        Logger class.
 ===============================================================================
 */

@interface AMLogger : NSObject
+ (AMLogger*)sharedLogger;

- (NSString*)getFileLoggerContent;
@end

// Use the following macros for all the logging.
#define AMLogError(_format, ...)   do { DDLogError(@"%s [ERROR]: "     #_format, __PRETTY_FUNCTION__, ##__VA_ARGS__); } while (0)
#define AMLogWarn(_format, ...)    do { DDLogWarn(@"%s [WARNING]: "    #_format, __PRETTY_FUNCTION__, ##__VA_ARGS__); } while (0)
#define AMLogInfo(_format, ...)    do { DDLogInfo(@"%s [INFO]: "       #_format, __PRETTY_FUNCTION__, ##__VA_ARGS__); } while (0)
#define AMLogSpam(_format, ...)    do { DDLogVerbose(@"%s [SPAM]: "    #_format, __PRETTY_FUNCTION__, ##__VA_ARGS__); } while (0)

#ifdef DEBUG
#   define AMAssert(_cond, _format, ...)                                                        \
        do {                                                                                    \
            BOOL _condEval = (_cond);                                                           \
            if (!_condEval)                                                                     \
            {                                                                                   \
                NSString *_msg = [[NSString alloc] initWithFormat:@"%s [ASSERT] `" #_cond "`: " #_format,   \
                                                                  __PRETTY_FUNCTION__, ##__VA_ARGS__];      \
                NSAssert(_condEval, _msg);                                                      \
            }                                                                                   \
        } while (0)
#else
#   define AMAssert(_cond, _format, ...)                                                        \
        if (!(_cond))                                                                           \
        {                                                                                       \
            DDLogError(@"%s [ASSERT]: "    #_format, __PRETTY_FUNCTION__, ##__VA_ARGS__);       \
        }
#endif