//
//  BatteryInfoController.m
//  ActivityMonitor++
//
//  Created by st on 24/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
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
    self.batteryInfo.level = [[UIDevice currentDevice] batteryLevel] * 100;
    
    switch ([[UIDevice currentDevice] batteryState]) {
        case UIDeviceBatteryStateCharging:
            self.batteryInfo.status = @"Charging";
            break;
        case UIDeviceBatteryStateFull:
            self.batteryInfo.status = @"Fully charged";
            break;
        case UIDeviceBatteryStateUnplugged:
            self.batteryInfo.status = @"Discharging";
            break;
        case UIDeviceBatteryStateUnknown:
            self.batteryInfo.status = @"Unknown";
            break;
    }
    
    [self.delegate batteryStatusUpdated];
}

@end
