//
//  GLCommon.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "GLCommon.h"

@implementation GLCommon

+ (EAGLContext*)context
{
    static EAGLContext *instance = nil;
    if (!instance)
    {
        instance = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return instance;
}

+ (GLKMatrix4)modelMatrixWithPosition:(GLKVector3)position rotation:(GLKVector3)rotation scale:(GLKMatrix4)scale
{
    GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(rotation.x);
    GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(rotation.y);
    GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(rotation.z);
    GLKMatrix4 scaleMatrix = scale;
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
    
    GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translateMatrix,
                                                GLKMatrix4Multiply(scaleMatrix,
                                                                   GLKMatrix4Multiply(zRotationMatrix,
                                                                                      GLKMatrix4Multiply(yRotationMatrix,
                                                                                                         xRotationMatrix))));
    return modelMatrix;
}

+ (UIImage*)imageWithText:(NSString*)text font:(UIFont*)font color:(UIColor*)color
{
    UIImage *texture;
    NSDictionary *textTextAttributes = @{ NSFontAttributeName : font,
                                          NSForegroundColorAttributeName : color };
    
    CGSize textureSize = [text sizeWithAttributes:textTextAttributes];
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(NULL, (size_t)textureSize.width, (size_t)textureSize.height, 8,
                                                      (size_t)textureSize.width * 4, // 4 elements per pixel (RGBA)
                                                      rgbColorSpace,
                                                      kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedFirst);
    UIGraphicsPushContext(imageContext);
    
    [text drawAtPoint:CGPointMake(0.0, 0.0) withAttributes:textTextAttributes];
    CGImageRef cgTexture = CGBitmapContextCreateImage(imageContext);
    texture = [UIImage imageWithCGImage:cgTexture];
    
    UIGraphicsPopContext();
    CGImageRelease(cgTexture);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(rgbColorSpace);
    
    return texture;
}

@end
