//
//  NetworkBandwidth.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "NetworkBandwidth.h"

@implementation NetworkBandwidth
@synthesize interface;
@synthesize timestamp;

@synthesize sent;
@synthesize totalWiFiSent;
@synthesize totalWWANSent;
@synthesize received;
@synthesize totalWiFiReceived;
@synthesize totalWWANReceived;
@end
