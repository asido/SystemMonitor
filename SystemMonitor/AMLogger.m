//
//  AMLogger.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>
#import "AMLogger.h"

/*
 ===============================================================================
 class AMLogger
 ===============================================================================
 */

@interface AMLogger()
@property (nonatomic, strong) DDFileLogger *fileLogger;
@end

@implementation AMLogger
@synthesize fileLogger;

//-----------------------------------------------
// static
//-----------------------------------------------
#pragma mark - static

+ (AMLogger*)sharedLogger
{
    static AMLogger *instance = nil;
    
    if (instance == nil)
    {
        instance = [[AMLogger alloc] init];
    }
    return instance;
}

//-----------------------------------------------
// override
//-----------------------------------------------
#pragma mark - override

- (id)init
{
    if (self = [super init])
    {
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        static unsigned long long kLoggerMaxFileSize = 1024 * 100;      // 100 KB
        static NSTimeInterval kLoggerRollingFrequency = 60 * 60 * 24;   // 24h
        self.fileLogger = [[DDFileLogger alloc] init];
        [[self fileLogger] setMaximumFileSize:kLoggerMaxFileSize];
        [[self fileLogger] setRollingFrequency:kLoggerRollingFrequency];
        // Don't spam log file as it's for release builds only.
        [DDLog addLogger:[self fileLogger] withLogLevel:LOG_LEVEL_WARN];
    }
    return self;
}

//-----------------------------------------------
// public
//-----------------------------------------------
#pragma mark - public

- (NSString*)getFileLoggerContent
{
    NSMutableString *description = [NSMutableString string];
    
    NSArray *sortedLogFileInfos = [[[self fileLogger] logFileManager] sortedLogFileInfos];
    NSInteger count = [sortedLogFileInfos count];
    
    // Start from the last one
    for (NSInteger index = count - 1; index >= 0; --index)
    {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:index];
        
        NSData *logData = [[NSFileManager defaultManager] contentsAtPath:[logFileInfo filePath]];
        if ([logData length] > 0)
        {
            NSString *result = [[NSString alloc] initWithBytes:[logData bytes] length:[logData length] encoding: NSUTF8StringEncoding];
            [description appendString:result];
        }
    }
    
    return description;
}

@end
