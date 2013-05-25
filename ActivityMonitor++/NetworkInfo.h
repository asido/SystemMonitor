//
//  NetworkInfo.h
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkInfo : NSObject
@property (strong, nonatomic) NSString  *readableInterface;
@property (strong, nonatomic) NSString  *externalIPAddress;
@property (strong, nonatomic) NSString  *internalIPAddress;
@property (strong, nonatomic) NSString  *netmask;
@property (strong, nonatomic) NSString  *broadcastAddress;
@property (strong, nonatomic) NSString  *macAddress;
@end
