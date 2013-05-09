//
//  GPUInfo.h
//  ActivityMonitor++
//
//  Created by st on 09/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPUInfo : NSObject
@property (retain) NSString *gpuName;
@property (retain) NSString *openGLVersion;
@property (retain) NSString *openGLVendor;
@property (retain) NSArray  *openGLExtensions;
@end
