//
//  StorageInfo.h
//  ActivityMonitor++
//
//  Created by st on 24/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StorageInfo : NSObject
@property (assign, nonatomic) CGFloat       totalSapce;
@property (assign, nonatomic) CGFloat       usedSpace;
@property (assign, nonatomic) CGFloat       freeSpace;

@property (assign, nonatomic) NSUInteger    songCount;
@property (assign, nonatomic) NSUInteger    pictureCount;
@property (assign, nonatomic) NSUInteger    videoCount;

@property (assign, nonatomic) NSUInteger    totalSongSize;
@property (assign, nonatomic) NSUInteger    totalPictureSize;
@property (assign, nonatomic) NSUInteger    totalVideoSize;
@end
