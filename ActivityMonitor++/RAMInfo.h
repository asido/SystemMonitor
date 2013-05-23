//
//  RAMInfo.h
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RAMInfo : NSObject
@property (assign, nonatomic) NSUInteger    totalRam;
@property (strong, nonatomic) NSString      *ramType;
@end
