//
//  BatteryInfoController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "HardcodedDeviceData.h"
#import "BatteryInfoController.h"

@interface BatteryInfoController()
@property (strong, nonatomic) BatteryInfo   *batteryInfo;
@property (assign, nonatomic) BOOL          batteryMonitoringEnabled;

- (NSUInteger)getBatteryCapacity;
- (CGFloat)getBatteryVoltage;

- (void)batteryLevelUpdatedCB:(NSNotification*)notification;
- (void)batteryStatusUpdatedCB:(NSNotification*)notification;
- (void)doUpdateBatteryStatus;
@end

@implementation BatteryInfoController
@synthesize delegate;

@synthesize batteryInfo;
@synthesize batteryMonitoringEnabled;

#pragma mark - public

- (BatteryInfo*)getBatteryInfo
{
    self.batteryInfo = [[BatteryInfo alloc] init];
    
    self.batteryInfo.capacity = [self getBatteryCapacity];
    self.batteryInfo.voltage = [self getBatteryVoltage];

    return self.batteryInfo;
}

- (void)startBatteryMonitoring
{
    if (!self.batteryMonitoringEnabled)
    {
        self.batteryMonitoringEnabled = YES;
        UIDevice *device = [UIDevice currentDevice];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryLevelUpdatedCB:)
                                                     name:UIDeviceBatteryLevelDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryStatusUpdatedCB:)
                                                     name:UIDeviceBatteryStateDidChangeNotification
                                                   object:nil];
        
        [device setBatteryMonitoringEnabled:YES];
        
        // If by any chance battery value is available - update it immediately
        if ([device batteryState] != UIDeviceBatteryStateUnknown)
        {
            [self doUpdateBatteryStatus];
        }
    }
}

- (void)stopBatteryMonitoring
{
    if (self.batteryMonitoringEnabled)
    {
        self.batteryMonitoringEnabled = NO;
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - private

- (NSUInteger)getBatteryCapacity
{
    HardcodedDeviceData *hardcode = [HardcodedDeviceData sharedDeviceData];
    return [hardcode getBatteryCapacity];
}

- (CGFloat)getBatteryVoltage
{
    HardcodedDeviceData *hardcode = [HardcodedDeviceData sharedDeviceData];
    return [hardcode getBatteryVoltage];
}

- (void)batteryLevelUpdatedCB:(NSNotification*)notification
{
    [self doUpdateBatteryStatus];
}

- (void)batteryStatusUpdatedCB:(NSNotification*)notification
{
    [self doUpdateBatteryStatus];
}

- (void)doUpdateBatteryStatus
{
    float batteryMultiplier = [[UIDevice currentDevice] batteryLevel];
    self.batteryInfo.levelPercent = batteryMultiplier * 100;
    self.batteryInfo.levelMAH =  self.batteryInfo.capacity * batteryMultiplier;
    
    switch ([[UIDevice currentDevice] batteryState]) {
        case UIDeviceBatteryStateCharging:
            // UIDeviceBatteryStateFull seems to be overwritten by UIDeviceBatteryStateCharging
            // when charging therefore it's more reliable if we check the battery level here
            // explicitly.
            if (self.batteryInfo.levelPercent == 100)
            {
                self.batteryInfo.status = @"Fully charged";
            }
            else
            {
                self.batteryInfo.status = @"Charging";
            }
            break;
        case UIDeviceBatteryStateFull:
            self.batteryInfo.status = @"Fully charged";
            break;
        case UIDeviceBatteryStateUnplugged:
            self.batteryInfo.status = @"Unplugged";
            break;
        case UIDeviceBatteryStateUnknown:
            self.batteryInfo.status = @"Unknown";
            break;
    }
    
    [self.delegate batteryStatusUpdated];
}

@end
