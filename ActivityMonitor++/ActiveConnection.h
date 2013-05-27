//
//  ActiveConnection.h
//  ActivityMonitor++
//
//  Created by st on 26/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
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
