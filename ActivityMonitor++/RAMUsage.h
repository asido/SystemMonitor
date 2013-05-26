//
//  RAMUsage.h
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RAMUsage : NSObject
@property (assign, nonatomic) uint64_t usedRam;
@property (assign, nonatomic) uint64_t activeRam;
@property (assign, nonatomic) uint64_t inactiveRam;
@property (assign, nonatomic) uint64_t wiredRam;
@property (assign, nonatomic) uint64_t freeRam;
@property (assign, nonatomic) uint64_t pageIns;
@property (assign, nonatomic) uint64_t pageOuts;
@property (assign, nonatomic) uint64_t pageFaults;
@end
