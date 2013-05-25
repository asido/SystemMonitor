//
//  GPUInfoController.m
//  ActivityMonitor++
//
//  Created by st on 09/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "AMLog.h"
#import "GPUInfo.h"
#import "GPUInfoController.h"

@interface GPUInfoController()
@property (strong, nonatomic) GPUInfo *gpuInfo;
@end

@implementation GPUInfoController
@synthesize gpuInfo;

/*
 * TIP: that's how we should fetch info about GPU.
 
 NSString *extensionStr = [NSString stringWithCString:glGetString(GL_EXTENSIONS) encoding:NSASCIIStringEncoding];
 NSArray *arr = [extensionStr componentsSeparatedByString:@" "];
 */

- (GPUInfo*)getGPUInfo
{
    if (!gpuInfo)
    {
        // TODO: this needs to go elsewhere.
        // Maybe when we will start to utilize OpenGL for our drawings.
        EAGLContext *ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:ctx];
        
        self.gpuInfo = [[GPUInfo alloc] init];
        self.gpuInfo.gpuName = [NSString stringWithCString:(const char*)glGetString(GL_RENDERER) encoding:NSASCIIStringEncoding];
        self.gpuInfo.openGLVendor = [NSString stringWithCString:(const char*)glGetString(GL_VENDOR) encoding:NSASCIIStringEncoding];
        self.gpuInfo.openGLVersion = [NSString stringWithCString:(const char*)glGetString(GL_VERSION) encoding:NSASCIIStringEncoding];
        
        NSString *extensions = [NSString stringWithCString:(const char*)glGetString(GL_EXTENSIONS) encoding:NSASCIIStringEncoding];
        NSMutableArray *extArray = [NSMutableArray arrayWithArray:[extensions componentsSeparatedByString:@" "]];
        // Last object is always empty because of trailing space.
        [extArray removeLastObject];
        [extArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        self.gpuInfo.openGLExtensions = extArray;
    
        GLenum glError = glGetError();
        if (glError != GL_NO_ERROR)
        {
            AMWarn(@"glGetError() == %d", glError);
        }
    }
    
    return gpuInfo;
}

@end
