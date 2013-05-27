//
//  ActiveConnection.h
//  ActivityMonitor++
//
//  Created by st on 26/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActiveConnection : NSObject
@property (strong, nonatomic) NSString  *localAddress;
@property (strong, nonatomic) NSString  *foreignAddress;
@end
