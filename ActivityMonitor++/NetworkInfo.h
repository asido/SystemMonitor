//
//  NetworkInfo.h
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkInfo : NSObject
@property (strong, nonatomic) NSString  *wifiIPAddress;
@property (strong, nonatomic) NSString  *wifiNetmask;
@property (strong, nonatomic) NSString  *wifiBroadcastAddress;
@property (strong, nonatomic) NSString  *wifiMacAddress;

@property (strong, nonatomic) NSString  *wwanIPAddress;
@property (strong, nonatomic) NSString  *wwanNetmask;
@property (strong, nonatomic) NSString  *wwanBroadcastAddress;
@property (strong, nonatomic) NSString  *wwanMacAddress;
@end
