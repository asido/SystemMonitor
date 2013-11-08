//
//  NetworkInfoController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <sys/param.h>
#import <netinet/in.h>
#import <netinet/tcp.h>
#import <netinet/in_systm.h>
#import <netinet/ip.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <netdb.h>
#import "AMLog.h"
#import "AMUtils.h"
#import "AMDevice.h"
#import "ActiveConnection.h"
#import "NetworkBandwidth.h"
#import "NetworkInfoController.h"

typedef enum {
    CONNECTION_TYPE_TCP4,
    CONNECTION_TYPE_UDP4
} ConnectionType_t;

@interface NetworkInfoController()
@property (strong, nonatomic) NetworkInfo   *networkInfo;
@property (strong, nonatomic) NSString      *currentInterface;
@property (assign, nonatomic) NSUInteger    bandwidthHistorySize;

@property (assign, nonatomic) NSUInteger    maxSentBandwidthTimes;
@property (assign, nonatomic) NSUInteger    maxReceivedBandwidthTimes;

@property (strong, nonatomic) NSTimer       *networkBandwidthUpdateTimer;
- (void)networkBandwidthUpdateCB:(NSNotification*)notification;

@property (assign, nonatomic) SCNetworkReachabilityRef reachability;

- (void)initReachability;
- (BOOL)internetConnected;
- (NSString*)internetInterface;
- (NSString*)readableCurrentInterface;
- (void)reachabilityStatusChangedCB;

- (NetworkInfo*)populateNetworkInfo;

- (NSString*)getExternalIPAddress;
- (NSString*)getInternalIPAddressOfInterface:(NSString*)interface;
- (NSString*)getNetmaskOfInterface:(NSString*)interface;
- (NSString*)getBroadcastAddressOfInterface:(NSString*)interface;
- (NSString*)getMacAddressOfInterface:(NSString*)interface;
- (NetworkBandwidth*)getNetworkBandwidth;
- (void)adjustMaxBandwidth:(NetworkBandwidth*)bandwidth;

- (void)pushNetworkBandwidth:(NetworkBandwidth*)bandwidth;

- (NSArray*)getActiveConnectionsOfType:(ConnectionType_t)connectionType;
- (NSString*)ipToString:(struct in_addr *)in;
- (NSString*)portToString:(int)port;
- (NSString*)portToServiceName:(int)port connectionType:(ConnectionType_t)connectionType;
- (NSString*)stateToString:(int)state;
- (NSString*)stateStringPostfix:(u_int)connectionFlags;
- (ConnectionStatus_t)connectionStatusFromState:(NSString*)stateString;
@end

@implementation NetworkInfoController
{
    CGFloat _currentMaxSentBandwidth;
    CGFloat _currentMaxReceivedBandwidth;
}
@synthesize delegate;
@synthesize networkBandwidthHistory;

@synthesize maxSentBandwidthTimes;
@synthesize maxReceivedBandwidthTimes;

@synthesize networkInfo;
@synthesize currentInterface;
@synthesize networkBandwidthUpdateTimer;

@synthesize reachability;

static NSString *kInterfaceWiFi = @"en0";
static NSString *kInterfaceWWAN = @"pdp_ip0";
static NSString *kInterfaceNone = @"";

#pragma mark - synthesize

- (void)setCurrentMaxSentBandwidth:(CGFloat)currentMaxSentBandwidth
{
    _currentMaxSentBandwidth = currentMaxSentBandwidth;
    if ([(NSObject*)self.delegate respondsToSelector:@selector(networkMaxBandwidthUpdated)])
    {
        [self.delegate networkMaxBandwidthUpdated];
    }
}

- (CGFloat)currentMaxSentBandwidth
{
    return _currentMaxSentBandwidth;
}

- (void)setCurrentMaxReceivedBandwidth:(CGFloat)currentMaxReceivedBandwidth
{
    _currentMaxReceivedBandwidth = currentMaxReceivedBandwidth;
    if ([(NSObject*)self.delegate respondsToSelector:@selector(networkMaxBandwidthUpdated)])
    {
        [self.delegate networkMaxBandwidthUpdated];
    }
}

- (CGFloat)currentMaxReceivedBandwidth
{
    return _currentMaxReceivedBandwidth;
}

#pragma mark - override

- (id)init
{
    if (self = [super init])
    {
        self.networkInfo = [[NetworkInfo alloc] init];
        self.networkBandwidthHistory = [[NSMutableArray alloc] init];
        self.networkBandwidthHistorySize = kDefaultDataHistorySize;
    }
    return self;
}

- (void)dealloc
{
    if (self.reachability)
    {
        CFRelease(self.reachability);
    }
}

#pragma mark - public

- (NetworkInfo*)getNetworkInfo
{
    self.networkInfo = [self populateNetworkInfo];
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
    [[NSRunLoop mainRunLoop] addTimer:self.networkBandwidthUpdateTimer forMode:NSRunLoopCommonModes];
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

- (void)updateActiveConnections
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *tcpConnections = [self getActiveConnectionsOfType:CONNECTION_TYPE_TCP4];
        //NSArray *udpConnections = [self getActiveConnectionsOfType:CONNECTION_TYPE_UDP4];
        
        NSMutableSet *set = [NSMutableSet setWithArray:tcpConnections];
        //[set addObjectsFromArray:udpConnections];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([(NSObject*)self.delegate respondsToSelector:@selector(networkActiveConnectionsUpdated:)])
            {
                [self.delegate networkActiveConnectionsUpdated:[set allObjects]];
            }
        });
    });
}

#pragma mark - private

- (void)networkBandwidthUpdateCB:(NSNotification*)notification
{
    NetworkBandwidth *bandwidth = [self getNetworkBandwidth];
    [self pushNetworkBandwidth:bandwidth];
    if ([(NSObject*)self.delegate respondsToSelector:@selector(networkBandwidthUpdated:)])
    {
        [self.delegate networkBandwidthUpdated:bandwidth];
    }
}

static void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
    assert(info != NULL);
    assert([(__bridge NSObject*)(info) isKindOfClass:[NetworkInfoController class]]);
    
    NetworkInfoController *networkCtrl = (__bridge NetworkInfoController*)(info);
    [networkCtrl reachabilityStatusChangedCB];
}

- (void)initReachability
{
    if (!self.reachability)
    {
        struct sockaddr_in hostAddress;
        bzero(&hostAddress, sizeof(hostAddress));
        hostAddress.sin_len = sizeof(hostAddress);
        hostAddress.sin_family = AF_INET;
        
        self.reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&hostAddress);
    
        if (!self.reachability)
        {
            AMWarn(@"reachability create has failed.");
            return;
        }
        
        BOOL result;
        SCNetworkReachabilityContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
        
        result = SCNetworkReachabilitySetCallback(self.reachability, reachabilityCallback, &context);
        if (!result)
        {
            AMWarn(@"error setting reachability callback.");
            return;
        }
        
        result = SCNetworkReachabilityScheduleWithRunLoop(self.reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        if (!result)
        {
            AMWarn(@"error setting runloop mode.");
            return;
        }
    }
}

- (BOOL)internetConnected
{
    if (!self.reachability)
    {
        [self initReachability];
    }
    
    if (!self.reachability)
    {
        AMWarn(@"cannot initialize reachability.");
        return NO;
    }
    
    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(self.reachability, &flags))
    {
        AMWarn(@"failed to retrieve reachability flags.");
        return NO;
    }

    BOOL isReachable = (flags & kSCNetworkReachabilityFlagsReachable);
    BOOL noConnectionRequired = !(flags & kSCNetworkReachabilityFlagsConnectionRequired);
    
    if (flags & kSCNetworkReachabilityFlagsIsWWAN)
    {
        noConnectionRequired = YES;
    }
    
    return ((isReachable && noConnectionRequired) ? YES : NO);
}

- (NSString*)internetInterface
{
    if (!self.reachability)
    {
        [self initReachability];
    }
    
    if (!self.reachability)
    {
        AMWarn(@"cannot initialize reachability.");
        return kInterfaceNone;
    }
    
    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(self.reachability, &flags))
    {
        AMWarn(@"failed to retrieve reachability flags.");
        return kInterfaceNone;
    }

    if ((flags & kSCNetworkFlagsReachable) &&
        (!(flags & kSCNetworkReachabilityFlagsIsWWAN)))
    {
        return kInterfaceWiFi;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) &&
        (flags & kSCNetworkReachabilityFlagsIsWWAN))
    {
        return kInterfaceWWAN;
    }
    
    return kInterfaceNone;
}

- (NSString*)readableCurrentInterface
{
    if ([self.currentInterface isEqualToString:kInterfaceWiFi])
    {
        return @"WiFi";
    }
    else if ([self.currentInterface isEqualToString:kInterfaceWWAN])
    {
        return @"Cellular";
    }
    else
    {
        return @"Not Connected";
    }
}

- (void)reachabilityStatusChangedCB
{
    [self populateNetworkInfo];
    if ([(NSObject*)self.delegate respondsToSelector:@selector(networkStatusUpdated)])
    {
        [self.delegate networkStatusUpdated];
    }
}

- (NetworkInfo*)populateNetworkInfo
{
    self.currentInterface = [self internetInterface];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.networkInfo.externalIPAddress = @"-"; // Placeholder while fetching.
        self.networkInfo.externalIPAddress = [self getExternalIPAddress];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([(NSObject*)self.delegate respondsToSelector:@selector(networkStatusUpdated)])
            {
                [self.delegate networkStatusUpdated];
            }
        });
    });
    
    self.networkInfo.readableInterface = [self readableCurrentInterface];
    self.networkInfo.internalIPAddress = [self getInternalIPAddressOfInterface:self.currentInterface];
    self.networkInfo.netmask = [self getNetmaskOfInterface:self.currentInterface];
    self.networkInfo.broadcastAddress = [self getBroadcastAddressOfInterface:self.currentInterface];
    self.networkInfo.macAddress = [self getMacAddressOfInterface:self.currentInterface];
    return self.networkInfo;
}

- (NSString*)getExternalIPAddress
{
    NSString *ip = @"-";
    
    if (![self internetConnected])
    {
        return ip;
    }
    
    NSURL *url = [NSURL URLWithString:@"http://www.dyndns.org/cgi-bin/check_ip.cgi"];
    if (!url)
    {
        AMWarn(@"failed to create NSURL.");
        return ip;
    }

    NSError *error = nil;
    NSString *ipHtml = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        AMWarn(@"failed to fetch IP content: %@", error.description);
        return ip;
    }

    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})"
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:&error];
    if (error)
    {
        AMWarn(@"failed to create regexp: %@", error.description);
        return ip;
    }
    NSRange regexpRange = [regexp rangeOfFirstMatchInString:ipHtml options:NSMatchingReportCompletion range:NSMakeRange(0, ipHtml.length)];
    NSString *match = [ipHtml substringWithRange:regexpRange];
    
    if (match && match.length > 0)
    {
        ip = [NSString stringWithString:match];
    }
    
    return ip;
}

- (NSString*)getInternalIPAddressOfInterface:(NSString*)interface
{    
    NSString *address = @"-";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    
    if (!interface || interface.length == 0)
    {
        return address;
    }
    
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
    
    if (!interface || interface.length == 0)
    {
        return netmask;
    }
    
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
    
    if (!interface || interface.length == 0)
    {
        return address;
    }
    
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
    
    if (!interface || interface.length == 0)
    {
        return mac;
    }
    
    mib[0] = CTL_NET;       // Network subsystem.
    mib[1] = AF_ROUTE;      // Routing table info
    mib[2] = 0;
    mib[3] = AF_LINK;       // Link layer information
    mib[4] = NET_RT_IFLIST; // All configured interfaces
    
    if ((mib[5] = if_nametoindex([interface cStringUsingEncoding:NSASCIIStringEncoding])) == 0)
    {
        AMWarn(@"if_nametoindex() has failed for interface %@.", interface);
        return mac;
    }
    else
    {
        if (sysctl(mib, 6, NULL, &length, NULL, 0) < 0)
        {
            AMWarn(@"sysctl() has failed. (1)");
            return mac;
        }
        else
        {
            msgBuffer = malloc(length);
            if (!msgBuffer)
            {
                AMWarn(@"malloc() has failed.");
                return mac;
            }
            
            if (sysctl(mib, 6, msgBuffer, &length, NULL, 0) < 0)
            {
                AMWarn(@"sysctl() has failed. (2)");
                goto exit;
            }
        }
    }
    
    interfaceMsgStruct = (struct if_msghdr*) msgBuffer;
    socketStruct = (struct sockaddr_dl*) (interfaceMsgStruct + 1);
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
           macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
    
    if ([mac hasPrefix:@"00:00:00:00:00"])
    {
        mac = @"-";
    }
    
exit:
    free(msgBuffer);
    return mac;
}

- (NetworkBandwidth*)getNetworkBandwidth
{
    NetworkBandwidth *bandwidth = [[NetworkBandwidth alloc] init];
    bandwidth.timestamp = [NSDate date];
    bandwidth.interface = self.currentInterface;
    
    int mib[] = {
        CTL_NET,
        PF_ROUTE,
        0,
        0,
        NET_RT_IFLIST2,
        0
    };
    
    size_t len;
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0)
    {
        AMWarn(@"sysctl failed (1)");
        return bandwidth;
    }
    
    char *buf = malloc(len);
    if (!buf)
    {
        AMWarn(@"malloc() for buf has failed.");
        return bandwidth;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0)
    {
        AMWarn(@"sysctl failed (2)");
        free(buf);
        return bandwidth;
    }
    char *lim = buf + len;
    char *next = NULL;
    for (next = buf; next < lim; )
    {
        struct if_msghdr *ifm = (struct if_msghdr *)next;
        next += ifm->ifm_msglen;
        
/* iOS does't include <net/route.h>, so we define our own macros. */
#define RTM_IFINFO2 0x12
        if (ifm->ifm_type == RTM_IFINFO2)
#undef RTM_IFINFO2
        {
            struct if_msghdr2 *if2m = (struct if_msghdr2 *)ifm;
            
            char ifnameBuf[IF_NAMESIZE];
            if (!if_indextoname(ifm->ifm_index, ifnameBuf))
            {
                AMWarn(@"if_indextoname() has failed.");
                continue;
            }
            NSString *ifname = [NSString stringWithCString:ifnameBuf encoding:NSASCIIStringEncoding];
            
            if ([ifname isEqualToString:kInterfaceWiFi])
            {
                bandwidth.totalWiFiSent += if2m->ifm_data.ifi_obytes;
                bandwidth.totalWiFiReceived += if2m->ifm_data.ifi_ibytes;
            }
            else if ([ifname isEqualToString:kInterfaceWWAN])
            {
                bandwidth.totalWWANSent += if2m->ifm_data.ifi_obytes;
                bandwidth.totalWWANReceived += if2m->ifm_data.ifi_ibytes;
            }
        }
    }
    
    if (self.networkBandwidthHistory.count > 0)
    {
        NetworkBandwidth *prevBandwidth = [self.networkBandwidthHistory lastObject];
        
        // Make sure previous bandwidth was at the same interface and measured during last second.
        if ([prevBandwidth.interface isEqualToString:self.currentInterface] &&
            ![AMUtils dateDidTimeout:prevBandwidth.timestamp seconds:2])
        {
            if ([self.currentInterface isEqualToString:kInterfaceWiFi])
            {
                bandwidth.sent = bandwidth.totalWiFiSent - prevBandwidth.totalWiFiSent;
                bandwidth.received = bandwidth.totalWiFiReceived - prevBandwidth.totalWiFiReceived;
            }
            else if ([self.currentInterface isEqualToString:kInterfaceWWAN])
            {
                bandwidth.sent = bandwidth.totalWWANSent - prevBandwidth.totalWWANSent;
                bandwidth.received = bandwidth.totalWWANReceived - prevBandwidth.totalWWANReceived;
            }
            
            [self adjustMaxBandwidth:bandwidth];
        }
    }
    
    free(buf);
    return bandwidth;
}

- (void)adjustMaxBandwidth:(NetworkBandwidth*)bandwidth
{
    if (bandwidth.sent > self.currentMaxSentBandwidth)
    {
        self.currentMaxSentBandwidth = bandwidth.sent;
        self.maxSentBandwidthTimes = 0;
    }
    if (bandwidth.received > self.currentMaxReceivedBandwidth)
    {
        self.currentMaxReceivedBandwidth = bandwidth.received;
        self.maxReceivedBandwidthTimes = 0;
    }
    
    self.maxSentBandwidthTimes++;
    self.maxReceivedBandwidthTimes++;
    
    if (self.maxSentBandwidthTimes > self.bandwidthHistorySize)
    {
        CGFloat newMaxSent = 0;
        for (NetworkBandwidth *b in self.networkBandwidthHistory)
        {
            newMaxSent = MAX(newMaxSent, b.sent);
        }
        self.currentMaxSentBandwidth = newMaxSent;
        self.maxSentBandwidthTimes = 0;
        
        CGFloat newMaxReceived = 0;
        for (NetworkBandwidth *b in self.networkBandwidthHistory)
        {
            newMaxReceived = MAX(newMaxReceived, b.received);
        }
        self.currentMaxReceivedBandwidth = newMaxReceived;
        self.maxReceivedBandwidthTimes = 0;
    }
}

- (void)pushNetworkBandwidth:(NetworkBandwidth*)bandwidth
{
    [self.networkBandwidthHistory addObject:bandwidth];
    
    while (self.networkBandwidthHistory.count > self.bandwidthHistorySize)
    {
        [self.networkBandwidthHistory removeObjectAtIndex:0];
    }
}

#import "bsd_var.h"

- (NSArray*)getActiveConnectionsOfType:(ConnectionType_t)connectionType
{
    uint32_t            proto;
    char                *mib;
    char                *buf, *next;
    struct xinpgen      *xig, *oxig;
    struct xgen_n       *xgn;
    size_t              len;
    struct xtcpcb_n     *tp = NULL;
    struct xinpcb_n     *inp = NULL;
    struct xsocket_n    *so = NULL;
    struct xsockbuf_n   *so_rcv = NULL;
    struct xsockbuf_n   *so_snd = NULL;
    struct xsockstat_n  *so_stat = NULL;
    int                 which = 0;
    NSMutableArray      *result = [[NSMutableArray alloc] init];
    
    switch (connectionType) {
        case CONNECTION_TYPE_TCP4:
            proto = IPPROTO_TCP;
            mib = "net.inet.tcp.pcblist_n";
            break;
        case CONNECTION_TYPE_UDP4:
            proto = IPPROTO_UDP;
            mib = "net.inet.udp.pcblist_n";
            break;
        default:
            AMWarn(@"unknown connection type: %d", connectionType);
            return result;
    }
    
    if (sysctlbyname(mib, 0, &len, 0, 0) < 0)
    {
        AMWarn(@"sysctlbyname() for len has failed with mib: %s.", mib);
        return result;
    }
    
    buf = malloc(len);
    if (!buf)
    {
        AMWarn(@"malloc() for buf has failed with mib: %s.", mib);
        return result;
    }
    
    if (sysctlbyname(mib, buf, &len, 0, 0) < 0)
    {
        AMWarn(@"sysctlbyname() for buf has failed with mib: %s.", mib);
        free(buf);
        return result;
    }
    
    // Bail-out if there is no more control block to process.
    if (len <= sizeof(struct xinpgen))
    {
        free(buf);
        return result;
    }
    
#define ROUNDUP64(a)    \
    ((a) > 0 ? (1 + (((a) - 1) | (sizeof(uint64_t) - 1))) : sizeof(uint64_t))
    
    oxig = xig = (struct xinpgen *)buf;
    for (next = buf + ROUNDUP64(xig->xig_len); next < buf + len; next += ROUNDUP64(xgn->xgn_len))
    {
        xgn = (struct xgen_n *)next;
        if (xgn->xgn_len <= sizeof(struct xinpgen))
        {
            break;
        }
        
        if ((which & xgn->xgn_kind) == 0)
        {
            which |= xgn->xgn_kind;
            
            switch (xgn->xgn_kind) {
                case XSO_SOCKET:
                    so = (struct xsocket_n *)xgn;
                    break;
                case XSO_RCVBUF:
                    so_rcv = (struct xsockbuf_n *)xgn;
                    break;
                case XSO_SNDBUF:
                    so_snd = (struct xsockbuf_n *)xgn;
                    break;
                case XSO_STATS:
                    so_stat = (struct xsockstat_n *)xgn;
                    break;
                case XSO_INPCB:
                    inp = (struct xinpcb_n *)xgn;
                    break;
                case XSO_TCPCB:
                    tp = (struct xtcpcb_n *)xgn;
                    break;
                default:
                    AMWarn(@"unknown kind %d", xgn->xgn_kind);
                    break;
            }
        }
        else
        {
            AMWarn(@"got %d twice.", xgn->xgn_kind);
        }
        
        if ((connectionType == CONNECTION_TYPE_TCP4 && which != ALL_XGN_KIND_TCP) ||
            (connectionType != CONNECTION_TYPE_TCP4 && which != ALL_XGN_KIND_INP))
        {
            continue;
        }
        
        which = 0;
        
        assert(inp != NULL);
        assert(so != NULL);
        
        // Ignore sockets for protocols other than the desired one.
        if (so->xso_protocol != (int)proto)
        {
        //    continue;
        }
        // Ignore PCBs which were freed during copyout.
        if (inp->inp_gencnt > oxig->xig_gen)
        {
            continue;
        }
        
        if ((inp->inp_vflag & INP_IPV4) == 0)
        {
            continue;
        }
        
        // Ignore when both local and remote IPs are LOOPBACK.
        if (ntohl(inp->inp_laddr.s_addr) == INADDR_LOOPBACK &&
            ntohl(inp->inp_faddr.s_addr) == INADDR_LOOPBACK)
        {
            continue;
        }
        
        /* 
         * Local address is not an indication of listening socket or server socket,
         * but just rather the socket has been bound.
         * Thats why many UDP sockets were not displayed in the original code.
         */
        
        ActiveConnection *connection = [[ActiveConnection alloc] init];
        connection.localIP = [self ipToString:&inp->inp_laddr];
        connection.localPort = [self portToString:(int)inp->inp_lport];
        connection.localPortService = [self portToServiceName:(int)inp->inp_lport connectionType:connectionType];
        connection.remoteIP = [self ipToString:&inp->inp_faddr];
        connection.remotePort = [self portToString:(int)inp->inp_fport];
        connection.remotePortService = [self portToServiceName:(int)inp->inp_fport connectionType:connectionType];
        if (connectionType == CONNECTION_TYPE_TCP4)
        {
            connection.statusString = [self stateToString:tp->t_state];
            connection.statusString = [NSString stringWithFormat:@"%@%@", connection.statusString, [self stateStringPostfix:tp->t_flags]];
        }
        else
        {
            connection.statusString = @"";
        }
        connection.status = [self connectionStatusFromState:connection.statusString];
        
        for (NSUInteger i = 0; i < SO_TC_STATS_MAX; ++i)
        {
            connection.totalRX += so_stat->xst_tc_stats[i].rxbytes;
            connection.totalTX += so_stat->xst_tc_stats[i].txbytes;
        }
        
        [result addObject:connection];
    }
    
    free(buf);
    return result;
}

- (NSString*)ipToString:(struct in_addr *)in
{
    if (!in)
    {
        AMWarn(@"in == NULL");
        return @"";
    }
    
    if (in->s_addr == INADDR_ANY)
    {
        return @"*";
    }
    else
    {
        return [NSString stringWithCString:inet_ntoa(*in) encoding:NSASCIIStringEncoding];
    }
}

- (NSString*)portToString:(int)port
{
    return (port == 0 ? @"*" : [NSString stringWithFormat:@"%d", port]);
}

- (NSString*)portToServiceName:(int)port connectionType:(ConnectionType_t)connectionType
{
    NSString *serviceName = @"";
    struct servent *servent;
    const char *proto;
    
    if (connectionType == CONNECTION_TYPE_TCP4)
    {
        proto = "tcp";
    }
    else if (connectionType == CONNECTION_TYPE_UDP4)
    {
        proto = "udp";
    }
    else
    {
        AMWarn(@"unknown connection type: %d", connectionType);
        return serviceName;
    }
    
    servent = getservbyport(port, proto);
    
    if (!servent)
    {
        return serviceName;
    }
    
    serviceName = [NSString stringWithCString:servent->s_name encoding:NSASCIIStringEncoding];
    return serviceName;
}

- (NSString*)stateToString:(int)state
{
    return [NSString stringWithCString:tcpstates[state] encoding:NSASCIIStringEncoding];
}

- (NSString*)stateStringPostfix:(u_int)connectionFlags
{
    if (connectionFlags & (TF_NEEDSYN|TF_NEEDFIN))
    {
        return @"*";
    }

    return @"";
}

- (ConnectionStatus_t)connectionStatusFromState:(NSString*)stateString
{
    if (stateString.length == 0)
    {
        // UDP has no status. Interpret it as active.
        return CONNECTION_STATUS_ESTABLISHED;
    }
    else if ([stateString hasPrefix:@"ESTABLISHED"])
    {
        return CONNECTION_STATUS_ESTABLISHED;
    }
    else if ([stateString hasPrefix:@"CLOSED"])
    {
        return CONNECTION_STATUS_CLOSED;
    }
    else
    {
        return CONNECTION_STATUS_OTHER;
    }
}

@end
