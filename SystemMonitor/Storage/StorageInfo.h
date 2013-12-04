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
@property (nonatomic, assign) uint64_t      totalSapce;
@property (nonatomic, assign) uint64_t      usedSpace;
@property (nonatomic, assign) uint64_t      freeSpace;

@property (nonatomic, assign) NSUInteger    songCount;
@property (nonatomic, assign) NSUInteger    pictureCount;
@property (nonatomic, assign) NSUInteger    videoCount;

@property (nonatomic, assign) uint64_t      totalSongSize;
@property (nonatomic, assign) uint64_t      totalPictureSize;
@property (nonatomic, assign) uint64_t      totalVideoSize;
@end
