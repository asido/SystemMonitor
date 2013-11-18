//
//  DeviceInfo.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "DeviceInfo.h"

@implementation DeviceInfo
@synthesize deviceName;
@synthesize hostName;
@synthesize osName;
@synthesize osType;
@synthesize osVersion;
@synthesize osBuild;
@synthesize osRevision;
@synthesize kernelInfo;
@synthesize maxVNodes;
@synthesize maxProcesses;
@synthesize maxFiles;
@synthesize tickFrequency;
@synthesize numberOfGroups;
@synthesize bootTime;
@synthesize safeBoot;

@synthesize screenResolution;
@synthesize screenSize;
@synthesize retina;
@synthesize ppi;
@synthesize aspectRatio;
@end
