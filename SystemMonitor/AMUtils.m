//
//  AMUtils.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <sys/sysctl.h>
#import "AMLogger.h"
#import "AMUtils.h"

@interface AMUtils()
@end

@implementation AMUtils

#pragma mark - static public

+ (uint64_t)getSysCtl64WithSpecifier:(char*)specifier
{
    size_t size = -1;
    uint64_t val = 0;
    
    if (!specifier)
    {
        AMLogWarn(@"specifier == NULL");
        return -1;
    }
    if (strlen(specifier) == 0)
    {
        AMLogWarn(@"strlen(specifier) == 0");
        return -1;
    }
    
    if (sysctlbyname(specifier, NULL, &size, NULL, 0) == -1)
    {
        AMLogWarn(@"sysctlbyname size with specifier '%s' has failed: %s", specifier, strerror(errno));
        return -1;
    }
    
    if (size == -1)
    {
        AMLogWarn(@"sysctlbyname with specifier '%s' returned invalid size", specifier);
        return -1;
    }
    
    
    if (sysctlbyname(specifier, &val, &size, NULL, 0) == -1)
    {
        AMLogWarn(@"sysctlbyname value with specifier '%s' has failed: %s", specifier, strerror(errno));
        return -1;
    }
    
    return val;
}

+ (NSString*)getSysCtlChrWithSpecifier:(char*)specifier
{
    size_t size = -1;
    char *val;
    NSString *result = @"";
    
    if (!specifier)
    {
        AMLogWarn(@"specifier == NULL");
        return result;
    }
    if (strlen(specifier) == 0)
    {
        AMLogWarn(@"strlen(specifier) == 0");
        return result;
    }
    
    if (sysctlbyname(specifier, NULL, &size, NULL, 0) == -1)
    {
        AMLogWarn(@"sysctlbyname size with specifier '%s' has failed: %s", specifier, strerror(errno));
        return result;
    }
    
    if (size == -1)
    {
        AMLogWarn(@"sysctlbyname with specifier '%s' returned invalid size", specifier);
        return result;
    }
    
    val = (char*)malloc(size);
    
    if (sysctlbyname(specifier, val, &size, NULL, 0) == -1)
    {
        AMLogWarn(@"sysctlbyname value with specifier '%s' has failed: %s", specifier, strerror(errno));
        free(val);
        return result;
    }
    
    result = [NSString stringWithUTF8String:val];
    free(val);
    return result;
}

+ (void*)getSysCtlPtrWithSpecifier:(char*)specifier pointer:(void*)ptr size:(size_t)size
{    
    if (!specifier)
    {
        AMLogWarn(@"specifier == NULL");
        return nil;
    }
    if (strlen(specifier) == 0)
    {
        AMLogWarn(@"strlen(specifier) == 0");
        return nil;
    }
    
    if (sysctlbyname(specifier, ptr, &size, NULL, 0) == -1)
    {
        AMLogWarn(@"sysctlbyname value with specifier '%s' has failed: %s", specifier, strerror(errno));
        return nil;
    }
    
    return ptr;
}

+ (uint64_t)getSysCtlHw:(uint32_t)hwSpecifier
{
    size_t size = 0;
    uint64_t val = -1;
    int mib[2] = { CTL_HW, hwSpecifier };
    
    if (sysctl(mib, 2, NULL, &size, NULL, 0) == -1)
    {
        AMLogWarn(@"sysctlbyname size with specifier %u has failed: %s", hwSpecifier, strerror(errno));
        return -1;
    }
    
    if (size > sizeof(uint64_t))
    {
        AMLogWarn(@"sysctlbyname with specifier %u size > sizeof(uint64_t). Expect corrupted data.", hwSpecifier);
    }
    
    if (sysctl(mib, 2, &val, &size, NULL, 0) == -1)
    {
        AMLogWarn(@"sysctlbyname size with specifier %u has failed: %s", hwSpecifier, strerror(errno));
        return -1;
    }
    
    return val;
}

+ (CGFloat)percentageValueFromMax:(CGFloat)max min:(CGFloat)min percent:(CGFloat)percent
{
    AMAssert(max > min, @"max=%f, min=%f", max, min);
    return min + ((max - min) / 100 * percent);
}

+ (CGFloat)valuePercentFrom:(CGFloat)from to:(CGFloat)to value:(CGFloat)value
{
    // In simulator returned memory is always 0 and so messes the statistics very much.
#if !TARGET_IPHONE_SIMULATOR
    AMAssert(from < to, @"from=%f, to=%f", from, to);
#endif
    
    CGFloat phase = from;
    CGFloat zeroBasedValue = value - phase;
    return 100 / (to - from) * zeroBasedValue;
}

+ (CGFloat)random
{
#define ARC4RANDOM_MAX  0x100000000
    return (CGFloat)arc4random() / ARC4RANDOM_MAX;
#undef ARC4RANDOM_MAX
}

+ (NSString*)toNearestMetric:(uint64_t)value desiredFraction:(NSUInteger)fraction
{
    static const uint64_t  B  = 0;
    static const uint64_t KB  = 1024;
    static const uint64_t MB  = KB * 1024;
    static const uint64_t GB  = MB * 1024;
    static const uint64_t TB  = GB * 1024;
    
    uint64_t absValue = llabs((long long)value);
    double metricValue;
    NSString *specifier = [NSString stringWithFormat:@"%%0.%ldf", (long)fraction];
    NSString *format;
    
    if (absValue >= B && absValue < KB)
    {
        metricValue = value;
        format = [NSString stringWithFormat:@"%@ B", specifier];
    }
    else if (absValue >= KB && absValue < MB)
    {
        metricValue = B_TO_KB(value);
        format = [NSString stringWithFormat:@"%@ KB", specifier];
    }
    else if (absValue >= MB && absValue < GB)
    {
        metricValue = B_TO_MB(value);
        format = [NSString stringWithFormat:@"%@ MB", specifier];
    }
    else if (absValue >= GB && absValue < TB)
    {
        metricValue = B_TO_GB(value);
        format = [NSString stringWithFormat:@"%@ GB", specifier];
    }
    else
    {
        metricValue = B_TO_TB(value);
        format = [NSString stringWithFormat:@"%@ TB", specifier];
    }
    
    return [NSString stringWithFormat:format, metricValue];
}

+ (BOOL)isIPad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (BOOL)isIPhone
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (BOOL)isIPhone5
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0);
    CGFloat pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale);
    
    return pixelHeight == 1136.0;
}

+ (BOOL)dateDidTimeout:(NSDate*)date seconds:(double)sec
{
    if (date == nil)
        return YES;
    
    return [date timeIntervalSinceNow] < -sec;
}

+ (void)openReviewAppPage
{
    NSString *appReviewLink = @"itms-apps://itunes.apple.com/app/id740765454";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:appReviewLink]];
}

@end
