//
//  GLTubeBubbleEffect.h
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
#import "GLEffect.h"

typedef struct {
    GLfloat maxLeftPosition;
    GLfloat maxRightPosition;
    GLfloat maxTopPosition;
    GLfloat maxBottomPosition;
} GLBubbleBounds_t;

@interface GLBubbleEffect : GLEffect
@property (nonatomic, assign) GLKMatrix4        mvpMatrix;
@property (nonatomic, assign) GLBubbleBounds_t  bounds;
@property (nonatomic, assign) GLfloat           elapsedSeconds;

- (id)initWithBounds:(GLBubbleBounds_t)bound;
- (void)spawnBubbleEffect;
- (void)render;
@end
