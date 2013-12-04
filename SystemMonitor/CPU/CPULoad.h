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
@property (nonatomic, assign) double system;
@property (nonatomic, assign) double user;
@property (nonatomic, assign) double nice;
@property (nonatomic, assign) double systemWithoutNice;
@property (nonatomic, assign) double userWithoutNice;
@property (nonatomic, assign) double total;
@end
