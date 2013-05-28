//
//  AMUtils.m
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <sys/sysctl.h>
#import "AMLog.h"
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
        AMWarn(@"specifier == NULL");
        return -1;
    }
    if (strlen(specifier) == 0)
    {
        AMWarn(@"strlen(specifier) == 0");
        return -1;
    }
    
    if (sysctlbyname(specifier, NULL, &size, NULL, 0) == -1)
    {
        AMWarn(@"sysctlbyname size with specifier '%s' has failed: %s", specifier, strerror(errno));
        return -1;
    }
    
    if (size == -1)
    {
        AMWarn(@"sysctlbyname with specifier '%s' returned invalid size", specifier);
        return -1;
    }
    
    
    if (sysctlbyname(specifier, &val, &size, NULL, 0) == -1)
    {
        AMWarn(@"sysctlbyname value with specifier '%s' has failed: %s", specifier, strerror(errno));
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
        AMWarn(@"specifier == NULL");
        return result;
    }
    if (strlen(specifier) == 0)
    {
        AMWarn(@"strlen(specifier) == 0");
        return result;
    }
    
    if (sysctlbyname(specifier, NULL, &size, NULL, 0) == -1)
    {
        AMWarn(@"sysctlbyname size with specifier '%s' has failed: %s", specifier, strerror(errno));
        return result;
    }
    
    if (size == -1)
    {
        AMWarn(@"sysctlbyname with specifier '%s' returned invalid size", specifier);
        return result;
    }
    
    val = (char*)malloc(size);
    
    if (sysctlbyname(specifier, val, &size, NULL, 0) == -1)
    {
        AMWarn(@"sysctlbyname value with specifier '%s' has failed: %s", specifier, strerror(errno));
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
        AMWarn(@"specifier == NULL");
        return nil;
    }
    if (strlen(specifier) == 0)
    {
        AMWarn(@"strlen(specifier) == 0");
        return nil;
    }
    
    if (sysctlbyname(specifier, ptr, &size, NULL, 0) == -1)
    {
        AMWarn(@"sysctlbyname value with specifier '%s' has failed: %s", specifier, strerror(errno));
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
        AMWarn(@"sysctlbyname size with specifier %u has failed: %s", hwSpecifier, strerror(errno));
        return -1;
    }
    
    if (size > sizeof(uint64_t))
    {
        AMWarn(@"sysctlbyname with specifier %u size > sizeof(uint64_t). Expect corrupted data.", hwSpecifier);
    }
    
    if (sysctl(mib, 2, &val, &size, NULL, 0) == -1)
    {
        AMWarn(@"sysctlbyname size with specifier %u has failed: %s", hwSpecifier, strerror(errno));
        return -1;
    }
    
    return val;
}

+ (double)percentageValueFromMax:(double)max min:(double)min percent:(float)percent
{
    assert(max > min);
    return min + ((max - min) / 100 * percent);
}

+ (float)valuePercentFrom:(double)from to:(double)to value:(double)value
{
    assert(from < to);
    
    float phase = from;
    float zeroBasedValue = value - phase;
    return 100 / (to - from) * zeroBasedValue;
}

+ (CGFloat)random
{
#define ARC4RANDOM_MAX  0x100000000
    return (double)arc4random() / ARC4RANDOM_MAX;
#undef ARC4RANDOM_MAX
}

+ (NSString*)toNearestMetric:(uint64_t)value desiredFraction:(NSUInteger)fraction
{
    static const uint64_t  B  = 0;
    static const uint64_t KB  = 1024;
    static const uint64_t MB  = KB * 1024;
    static const uint64_t GB  = MB * 1024;
    static const uint64_t TB  = GB * 1024;
    
    uint64_t absValue = fabs(value);
    double metricValue;
    NSString *specifier = [NSString stringWithFormat:@"%%0.%df", fraction];
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
    CGFloat scale = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
    CGFloat pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale);
    
    return pixelHeight == 1136.0f;
}

+ (BOOL)dateDidTimeout:(NSDate*)date seconds:(double)sec
{
    if (date == nil)
        return YES;
    
    return [date timeIntervalSinceNow] < -sec;
}

@end
