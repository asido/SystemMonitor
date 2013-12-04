//
//  StorageInfoController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "AMLogger.h"
#import "AMUtils.h"
#import "StorageInfoController.h"

@interface StorageInfoController()
@property (nonatomic, strong) StorageInfo *storageInfo;

- (uint64_t)getTotalSpace;
- (uint64_t)getUsedSpace;
- (uint64_t)getFreeSpace;
- (NSUInteger)getSongCount;
- (NSUInteger)getTotalSongSize;
- (NSUInteger)updatePictureCount;
- (NSUInteger)updateVideoCount;

- (void)assetsLibraryDidChange:(NSNotification*)notification;
@end

@implementation StorageInfoController
@synthesize delegate;

@synthesize storageInfo;

#pragma mark - override

- (id)init
{
    if (self = [super init])
    {
        self.storageInfo = [[StorageInfo alloc] init];
    }
    return self;
}

#pragma mark - public

- (StorageInfo*)getStorageInfo
{
    self.storageInfo.totalSapce = [self getTotalSpace];
    self.storageInfo.usedSpace = [self getUsedSpace];
    self.storageInfo.freeSpace = [self getFreeSpace];
    self.storageInfo.songCount = [self getSongCount];
    self.storageInfo.totalSongSize = [self getTotalSongSize];
    
    [self updatePictureCount];
    [self updateVideoCount];
    
    return self.storageInfo;
}

#pragma mark - private

- (uint64_t)getTotalSpace
{    
    NSError         *error = nil;
    NSArray         *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary    *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:paths.lastObject error:&error];

    if (dictionary)
    {
        NSNumber *fileSystemSizeInBytes = dictionary[NSFileSystemSize];
        return [fileSystemSizeInBytes unsignedLongLongValue];
    }
    else
    {
        AMLogWarn(@"attributesOfFileSystemForPat() has failed: %@", error.description);
        return 0.0;
    }
}

- (uint64_t)getUsedSpace
{
    NSError         *error = nil;
    NSArray         *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary    *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:paths.lastObject error:&error];
    
    if (dictionary)
    {
        NSNumber *fileSystemSize = dictionary[NSFileSystemSize];
        NSNumber *fileSystemFreeSize = dictionary[NSFileSystemFreeSize];
        uint64_t usedSize = [fileSystemSize unsignedLongLongValue] - [fileSystemFreeSize unsignedLongLongValue];
        return usedSize;
    }
    else
    {
        AMLogWarn(@"attributesOfFileSystemForPat() has failed: %@", error.description);
        return 0.0;
    }
}

- (uint64_t)getFreeSpace
{
    NSError         *error = nil;
    NSArray         *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary    *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:paths.lastObject error:&error];
    
    if (dictionary)
    {
        NSNumber *fileSystemFreeSize = dictionary[NSFileSystemFreeSize];
        return [fileSystemFreeSize unsignedLongLongValue];
    }
    else
    {
        AMLogWarn(@"attributesOfFileSystemForPat() has failed: %@", error.description);
        return 0.0;
    }
}

- (NSUInteger)getSongCount
{
    return [[MPMediaQuery songsQuery] items].count;
}

- (NSUInteger)getTotalSongSize
{
    // TODO:
    /*
    NSUInteger size = 0;
    NSArray *songs = [[MPMediaQuery songsQuery] items];
    
    for (MPMediaItem *item in songs)
    {
        NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: url options:nil];
        CMTime duration = songAsset.duration;
        float durationSeconds = CMTimeGetSeconds(duration);
        AVAssetTrack *track = songAsset.tracks[0];
        [track loadValuesAsynchronouslyForKeys:@[@"estimatedDataRate"] completionHandler:^() { NSLog(@"%f", track.estimatedDataRate); }];
        float dr = track.estimatedDataRate;
        NSLog(@"dr: %f", dr);
    }
    */
    return 0;
}

- (NSUInteger)updatePictureCount
{
    self.storageInfo.pictureCount = 0;
    self.storageInfo.totalPictureSize = 0;
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset)
            {
                NSString *type = [asset  valueForProperty:ALAssetPropertyType];
                if ([type isEqualToString:ALAssetTypePhoto])
                {
                    self.storageInfo.pictureCount++;
                    
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    self.storageInfo.totalPictureSize += rep.size;
                }
            }
            else
            {
                [self.delegate storageInfoUpdated];
            }
        }];
    } failureBlock:^(NSError *error) {
        AMLogWarn(@"Failed to enumerate asset groups: %@", error.description);
    }];
    
    return 0;
}

- (NSUInteger)updateVideoCount
{
    self.storageInfo.videoCount = 0;
    self.storageInfo.totalVideoSize = 0;
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset)
            {
                NSString *type = [asset  valueForProperty:ALAssetPropertyType];
                if ([type isEqualToString:ALAssetTypeVideo])
                {
                    self.storageInfo.videoCount++;
                    
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    self.storageInfo.totalVideoSize += rep.size;
                }
            }
            else
            {
                [self.delegate storageInfoUpdated];
            }
        }];
    } failureBlock:^(NSError *error) {
        AMLogWarn(@"Failed to enumerate asset groups: %@", error.description);
    }];
    
    return 0;
}

- (void)assetsLibraryDidChange:(NSNotification*)notification
{
    [self updatePictureCount];
    [self updateVideoCount];
}

@end
