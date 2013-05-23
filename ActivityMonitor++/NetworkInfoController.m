//
//  NetworkInfoController.m
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <netinet/in.h>
#import <net/if.h>
#import <net/if_dl.h>
#import "AMLog.h"
#import "AMUtils.h"
#import "AMDevice.h"
#import "NetworkBandwidth.h"
#import "NetworkInfoController.h"

@interface NetworkInfoController()
@property (strong, nonatomic) NetworkInfo   *networkInfo;
@property (assign, nonatomic) NSUInteger    bandwidthHistorySize;

@property (strong, nonatomic) NSTimer       *networkBandwidthUpdateTimer;
- (void)networkBandwidthUpdateCB:(NSNotification*)notification;

- (NSString*)getIPAddressOfInterface:(NSString*)interface;
- (NSString*)getNetmaskOfInterface:(NSString*)interface;
- (NSString*)getBroadcastAddressOfInterface:(NSString*)interface;
- (NSString*)getMacAddressOfInterface:(NSString*)interface;
- (NetworkBandwidth*)getNetworkBandwidth;

- (void)pushNetworkBandwidth:(NetworkBandwidth*)bandwidth;
@end

@implementation NetworkInfoController
@synthesize delegate;
@synthesize networkBandwidthHistory;

@synthesize networkInfo;
@synthesize networkBandwidthUpdateTimer;

static NSString *kWiFiInterface = @"en0";
static NSString *kWWANInterface = @"pdp_ip0";

#pragma mark - override

- (id)init
{
    if (self = [super init])
    {
        self.networkBandwidthHistory = [[NSMutableArray alloc] init];
        self.networkBandwidthHistorySize = kDefaultDataHistorySize;
    }
    return self;
}

#pragma mark - public

- (NetworkInfo*)getNetworkInfo
{
    self.networkInfo = [[NetworkInfo alloc] init];
    
    self.networkInfo.wifiIPAddress = [self getIPAddressOfInterface:kWiFiInterface];
    self.networkInfo.wifiNetmask = [self getNetmaskOfInterface:kWiFiInterface];
    self.networkInfo.wifiBroadcastAddress = [self getBroadcastAddressOfInterface:kWiFiInterface];
    self.networkInfo.wifiMacAddress = [self getMacAddressOfInterface:kWiFiInterface];
    
    self.networkInfo.wwanIPAddress = [self getIPAddressOfInterface:kWWANInterface];
    self.networkInfo.wwanNetmask = [self getNetmaskOfInterface:kWWANInterface];
    self.networkInfo.wwanBroadcastAddress = [self getBroadcastAddressOfInterface:kWWANInterface];
    self.networkInfo.wwanMacAddress = [self getMacAddressOfInterface:kWWANInterface];
    
    return self.networkInfo;
}

- (void)startNetworkBandwidthUpdatesWithFrequency:(NSUInteger)frequency
{
    [self stopNetworkBandwidthUpdates];
    self.networkBandwidthUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f / frequency
                                                                        target:self
                                                                      selector:@selector(networkBandwidthUpdateCB:)
                                                                      userInfo:nil
                                                                       repeats:YES];
    [self.networkBandwidthUpdateTimer fire];
}

- (void)stopNetworkBandwidthUpdates
{
    [self.networkBandwidthUpdateTimer invalidate];
    self.networkBandwidthUpdateTimer = nil;
}

- (void)setNetworkBandwidthHistorySize:(NSUInteger)size
{
    self.bandwidthHistorySize = size;
}

#pragma mark - private

- (void)networkBandwidthUpdateCB:(NSNotification*)notification
{
    NetworkBandwidth *bandwidth = [self getNetworkBandwidth];
    [self pushNetworkBandwidth:bandwidth];
    [self.delegate networkBandwidthUpdated:bandwidth];
}

- (NSString*)getIPAddressOfInterface:(NSString*)interface
{
    NSString *address = @"-";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    
    if (getifaddrs(&interfaces) == 0)
    {
        temp_addr = interfaces;
        
        while (temp_addr != NULL)
        {
            if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:interface])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

- (NSString*)getNetmaskOfInterface:(NSString*)interface
{
    NSString *netmask = @"-";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    
    if (getifaddrs(&interfaces) == 0)
    {
        temp_addr = interfaces;
        
        while (temp_addr != NULL)
        {
            if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:interface])
                {
                    netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)temp_addr->ifa_netmask)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return netmask;
}

- (NSString*)getBroadcastAddressOfInterface:(NSString*)interface
{
    NSString *address = @"-";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    
    if (getifaddrs(&interfaces) == 0)
    {
        temp_addr = interfaces;
        
        while (temp_addr != NULL)
        {
            if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:interface])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)temp_addr->ifa_dstaddr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

- (NSString*)getMacAddressOfInterface:(NSString*)interface
{
    NSString            *mac = @"-";
    int                 mib[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    
    mib[0] = CTL_NET;       // Network subsystem.
    mib[1] = AF_ROUTE;      // Routing table info
    mib[2] = 0;
    mib[3] = AF_LINK;       // Link layer information
    mib[4] = NET_RT_IFLIST; // All configured interfaces
    
    if ((mib[5] = if_nametoindex([interface cStringUsingEncoding:NSASCIIStringEncoding])) == 0)
    {
        AMWarn(@"%s: if_nametoindex() has failed.", __PRETTY_FUNCTION__);
        return mac;
    }
    else
    {
        if (sysctl(mib, 6, NULL, &length, NULL, 0) < 0)
        {
            AMWarn(@"%s: sysctl() has failed. (1)", __PRETTY_FUNCTION__);
            return mac;
        }
        else
        {
            msgBuffer = malloc(length);
            if (!msgBuffer)
            {
                AMWarn(@"%s: malloc() has failed.", __PRETTY_FUNCTION__);
                return mac;
            }
            
            if (sysctl(mib, 6, msgBuffer, &length, NULL, 0) < 0)
            {
                AMWarn(@"%s: sysctl() has failed. (2)", __PRETTY_FUNCTION__);
                return mac;
            }
        }
    }
    
    interfaceMsgStruct = (struct if_msghdr*) msgBuffer;
    socketStruct = (struct sockaddr_dl*) (interfaceMsgStruct + 1);
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
           macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
    free(msgBuffer);
    
    return mac;
}

- (NetworkBandwidth*)getNetworkBandwidth
{
    struct ifaddrs          *addrs;
    const struct ifaddrs    *cursor;
    const struct if_data    *networkStatistics;
    NetworkBandwidth        *bandwidth = [[NetworkBandwidth alloc] init];
    
    if (getifaddrs(&addrs) != 0)
    {
        AMWarn(@"%s: getifaddrs() has failed.", __PRETTY_FUNCTION__);
        return bandwidth;
    }
    
    cursor = addrs;
    while (cursor != NULL)
    {
        NSString *name = [NSString stringWithFormat:@"%s", cursor->ifa_name];
        
        if (cursor->ifa_addr->sa_family == AF_LINK)
        {
            if ([name isEqualToString:kWiFiInterface])
            {
                networkStatistics = (const struct if_data*) cursor->ifa_data;
                bandwidth.wifiTotalSent += B_TO_MB(networkStatistics->ifi_obytes);
                bandwidth.wifiTotalReceived += B_TO_MB(networkStatistics->ifi_ibytes);
            }
            
            if ([name isEqualToString:kWWANInterface])
            {
                networkStatistics = (const struct if_data*) cursor->ifa_data;
                bandwidth.wwanTotalSent += B_TO_MB(networkStatistics->ifi_obytes);
                bandwidth.wwanTotalReceived += B_TO_MB(networkStatistics->ifi_ibytes);
            }
        }
        
        cursor = cursor->ifa_next;
    }
    
    freeifaddrs(addrs);
    
    if (self.networkBandwidthHistory.count > 0)
    {
        NetworkBandwidth *prevBandwidth = [self.networkBandwidthHistory lastObject];
        bandwidth.wifiSent = B_TO_KB(bandwidth.wifiTotalSent - prevBandwidth.wifiTotalSent);
        bandwidth.wifiReceived = B_TO_KB(bandwidth.wifiTotalReceived - prevBandwidth.wifiTotalReceived);
        bandwidth.wwanSent = B_TO_KB(bandwidth.wwanTotalSent - prevBandwidth.wwanTotalSent);
        bandwidth.wwanReceived = B_TO_KB(bandwidth.wwanTotalReceived - prevBandwidth.wwanTotalReceived);
    }
    
    return bandwidth;
}

- (void)pushNetworkBandwidth:(NetworkBandwidth*)bandwidth
{
    [self.networkBandwidthHistory addObject:bandwidth];
    
    while (self.networkBandwidthHistory.count > self.bandwidthHistorySize)
    {
        [self.networkBandwidthHistory removeObjectAtIndex:0];
    }
}

@end
