//
//  StorageInfo.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>

@interface StorageInfo : NSObject
@property (assign, nonatomic) uint64_t      totalSapce;
@property (assign, nonatomic) uint64_t      usedSpace;
@property (assign, nonatomic) uint64_t      freeSpace;

@property (assign, nonatomic) NSUInteger    songCount;
@property (assign, nonatomic) NSUInteger    pictureCount;
@property (assign, nonatomic) NSUInteger    videoCount;

@property (assign, nonatomic) uint64_t      totalSongSize;
@property (assign, nonatomic) uint64_t      totalPictureSize;
@property (assign, nonatomic) uint64_t      totalVideoSize;
@end
