//
//  RAMUsage.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
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
