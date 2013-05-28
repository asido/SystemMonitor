//
//  StorageInfoController.h
//  ActivityMonitor++
//
//  Created by st on 24/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StorageInfo.h"

@protocol StorageInfoControllerDelegate
- (void)storageInfoUpdated;
@end

@interface StorageInfoController : NSObject
@property (weak, nonatomic) id<StorageInfoControllerDelegate> delegate;

- (StorageInfo*)getStorageInfo;
@end
