//
//  AMGLBlurEffect.h
//  ActivityMonitor++
//
//  Created by st on 19/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "GLEffect.h"

@interface GLBlurEffect : GLEffect
@property (assign, nonatomic) GLKMatrix4    mvpMatrix;
@property (assign, nonatomic) GLuint        texture0;

- (void)prepareToDraw;
@end
