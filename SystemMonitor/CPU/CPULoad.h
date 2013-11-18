//
//  CPULoad.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>

@interface CPULoad : NSObject
// Values are in %
@property (assign, nonatomic) double system;
@property (assign, nonatomic) double user;
@property (assign, nonatomic) double nice;
@property (assign, nonatomic) double systemWithoutNice;
@property (assign, nonatomic) double userWithoutNice;
@property (assign, nonatomic) double total;
@end
