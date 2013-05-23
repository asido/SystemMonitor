//
//  GLCommon.h
//  ActivityMonitor++
//
//  Created by st on 21/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "AMLog.h"

#if DEBUG
#define GL_CHECK_ERROR()                        \
    do {                                        \
        GLenum error = glGetError();            \
        if (error != GL_NO_ERROR)               \
        {                                       \
            AMWarn("%s: GL Error: 0x%x",        \
                   __PRETTY_FUNCTION__, error); \
        }                                       \
    } while (0)
#else
#define GL_CHECK_ERROR()
#endif

#define kModelZ     (-2.0f)

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} VertexData_t;

@interface GLCommon : NSObject
+ (EAGLContext*)context;
+ (GLKMatrix4)modelMatrixWithPosition:(GLKVector3)position rotation:(GLKVector3)rotation scale:(GLKMatrix4)scale;
@end
