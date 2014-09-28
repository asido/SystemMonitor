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
@property (nonatomic, copy)   const NSString    *deviceName;
@property (nonatomic, copy)   NSString          *hostName;
@property (nonatomic, copy)   NSString          *osName;
@property (nonatomic, copy)   NSString          *osType;
@property (nonatomic, copy)   NSString          *osVersion;
@property (nonatomic, copy)   NSString          *osBuild;
@property (nonatomic, assign) NSInteger         osRevision;
@property (nonatomic, copy)   NSString          *kernelInfo;
@property (nonatomic, assign) NSUInteger        maxVNodes;
@property (nonatomic, assign) NSUInteger        maxProcesses;
@property (nonatomic, assign) NSUInteger        maxFiles;
@property (nonatomic, assign) NSUInteger        tickFrequency;
@property (nonatomic, assign) NSUInteger        numberOfGroups;
@property (nonatomic, assign) time_t            bootTime;
@property (nonatomic, assign) BOOL              safeBoot;

@property (nonatomic, copy)   NSString          *screenResolution;
@property (nonatomic, assign) CGFloat           screenSize;
@property (nonatomic, assign) BOOL              retina;
@property (nonatomic, assign) BOOL              retinaHD;
@property (nonatomic, assign) NSUInteger        ppi;
@property (nonatomic, copy)   NSString          *aspectRatio;
@end
