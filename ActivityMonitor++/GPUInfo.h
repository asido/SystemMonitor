//
//  GPUInfo.h
//  ActivityMonitor++
//
//  Created by st on 09/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPUInfo : NSObject
@property (strong, nonatomic) NSString *gpuName;
@property (strong, nonatomic) NSString *openGLVersion;
@property (strong, nonatomic) NSString *openGLVendor;
@property (strong, nonatomic) NSArray  *openGLExtensions;
@end
