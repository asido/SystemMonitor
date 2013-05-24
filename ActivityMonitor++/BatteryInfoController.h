//
//  BatteryInfoController.h
//  ActivityMonitor++
//
//  Created by st on 24/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BatteryInfo.h"

@protocol BatteryInfoControllerDelegate
- (void)batteryStatusUpdated;
@end

@interface BatteryInfoController : NSObject
@property (strong, nonatomic) id<BatteryInfoControllerDelegate> delegate;

- (BatteryInfo*)getBatteryInfo;
- (void)startBatteryMonitoring;
- (void)stopBatteryMonitoring;
@end
