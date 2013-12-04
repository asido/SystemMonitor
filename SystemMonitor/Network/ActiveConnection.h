//
//  ActiveConnection.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>

typedef enum {
    CONNECTION_STATUS_ESTABLISHED,
    CONNECTION_STATUS_CLOSED,
    CONNECTION_STATUS_OTHER
} ConnectionStatus_t;

@interface ActiveConnection : NSObject
@property (nonatomic, copy) NSString              *localIP;
@property (nonatomic, copy) NSString              *localPort;
@property (nonatomic, copy) NSString              *localPortService;

@property (nonatomic, copy) NSString              *remoteIP;
@property (nonatomic, copy) NSString              *remotePort;
@property (nonatomic, copy) NSString              *remotePortService;

@property (nonatomic, assign) ConnectionStatus_t    status;
@property (nonatomic, copy) NSString                *statusString;

@property (nonatomic, assign) CGFloat               totalTX;
@property (nonatomic, assign) CGFloat               totalRX;
@end
