//
//  HardcodedDeviceData.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>

@interface HardcodedDeviceData : NSObject
+ (HardcodedDeviceData*)sharedDeviceData;
- (void)setHwMachine:(NSString*)hwMachine;

- (const NSString*)getiDeviceName;
- (const NSString*)getCPUName;
- (NSUInteger)getCPUFrequency;
- (const NSString*)getCoprocessorName;
- (const NSString*)getGraphicCardName;
- (const NSString*)getRAMType;
- (NSUInteger)getBatteryCapacity;
- (CGFloat)getBatteryVoltage;
- (CGFloat)getScreenSize;
- (NSUInteger)getPPI;
- (NSString*)getAspectRatio;
@end
