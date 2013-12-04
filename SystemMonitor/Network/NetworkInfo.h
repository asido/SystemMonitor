//
//  NetworkInfo.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>

@interface NetworkInfo : NSObject
@property (nonatomic, copy) NSString  *readableInterface;
@property (nonatomic, copy) NSString  *externalIPAddress;
@property (nonatomic, copy) NSString  *internalIPAddress;
@property (nonatomic, copy) NSString  *netmask;
@property (nonatomic, copy) NSString  *broadcastAddress;
@end
