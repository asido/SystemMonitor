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
@property (strong, nonatomic) NSString              *localIP;
@property (strong, nonatomic) NSString              *localPort;
@property (strong, nonatomic) NSString              *localPortService;

@property (strong, nonatomic) NSString              *remoteIP;
@property (strong, nonatomic) NSString              *remotePort;
@property (strong, nonatomic) NSString              *remotePortService;

@property (assign, nonatomic) ConnectionStatus_t    status;
@property (strong, nonatomic) NSString              *statusString;

@property (assign, nonatomic) CGFloat               totalTX;
@property (assign, nonatomic) CGFloat               totalRX;
@end
