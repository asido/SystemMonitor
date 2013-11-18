//
//  GLCommon.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "AMLogger.h"

#if DEBUG
#define GL_CHECK_ERROR()                        \
    do {                                        \
        GLenum error = glGetError();            \
        if (error != GL_NO_ERROR)               \
        {                                       \
            AMLogWarn("GL Error: 0x%x",  error);\
        }                                       \
    } while (0)
#else
#define GL_CHECK_ERROR()
#endif

#define kModelZ     (-2.0)

static const GLfloat kFontScaleMultiplierW  = 1.0 / 18.0;
static const GLfloat kFontScaleMultiplierH  = 1.0 / 36.0;

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} VertexData_t;

@interface GLCommon : NSObject
+ (EAGLContext*)context;
+ (GLKMatrix4)modelMatrixWithPosition:(GLKVector3)position rotation:(GLKVector3)rotation scale:(GLKMatrix4)scale;
+ (UIImage*)imageWithText:(NSString*)text font:(UIFont*)font color:(UIColor*)color;
@end
