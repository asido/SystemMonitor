//
//  HardcodedData.h
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HardcodedDeviceData : NSObject
+ (HardcodedDeviceData*)sharedDeviceData;
- (void)setHwMachine:(NSString*)hwMachine;

- (const NSString*)getiDeviceName;
- (const NSString*)getCPUName;
- (NSUInteger)getCPUFrequency;
- (const NSString*)getGPUName;
@end
