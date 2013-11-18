//
//  DeviceInfo.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject
@property (strong, nonatomic) const NSString    *deviceName;
@property (strong, nonatomic) NSString          *hostName;
@property (strong, nonatomic) NSString          *osName;
@property (strong, nonatomic) NSString          *osType;
@property (strong, nonatomic) NSString          *osVersion;
@property (strong, nonatomic) NSString          *osBuild;
@property (assign, nonatomic) NSInteger         osRevision;
@property (strong, nonatomic) NSString          *kernelInfo;
@property (assign, nonatomic) NSUInteger        maxVNodes;
@property (assign, nonatomic) NSUInteger        maxProcesses;
@property (assign, nonatomic) NSUInteger        maxFiles;
@property (assign, nonatomic) NSUInteger        tickFrequency;
@property (assign, nonatomic) NSUInteger        numberOfGroups;
@property (assign, nonatomic) time_t            bootTime;
@property (assign, nonatomic) BOOL              safeBoot;

@property (strong, nonatomic) NSString          *screenResolution;
@property (assign, nonatomic) CGFloat           screenSize;
@property (assign, nonatomic) BOOL              retina;
@property (assign, nonatomic) NSUInteger        ppi;
@property (strong, nonatomic) NSString          *aspectRatio;
@end
