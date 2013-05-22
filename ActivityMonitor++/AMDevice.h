//
//  AMDevice.h
//  ActivityMonitor++
//
//  Created by st on 08/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceInfo.h"
#import "CPUInfo.h"
#import "GPUInfo.h"

@interface AMDevice : NSObject
@property (readonly) DeviceInfo     *deviceInfo;
@property (readonly) CPUInfo        *cpuInfo;
@property (readonly) GPUInfo        *gpuInfo;
@property (readonly) NSArray        *processes;

- (void)refreshProcesses;
@end
