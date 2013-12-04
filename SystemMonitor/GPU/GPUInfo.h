//
//  GPUInfo.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>

@interface GPUInfo : NSObject
@property (nonatomic, copy) NSString *gpuName;
@property (nonatomic, copy) NSString *openGLVersion;
@property (nonatomic, copy) NSString *openGLVendor;
@property (nonatomic, copy) NSArray  *openGLExtensions;
@end
