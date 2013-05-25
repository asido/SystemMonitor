//
//  GLTubeBubbleEffect.h
//  ActivityMonitor++
//
//  Created by st on 25/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
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
@property (assign, nonatomic) GLKMatrix4        mvpMatrix;
@property (assign, nonatomic) GLBubbleBounds_t  bounds;
@property (assign, nonatomic) GLfloat           elapsedSeconds;

- (id)initWithBounds:(GLBubbleBounds_t)bound;
- (void)spawnBubbleEffect;
- (void)render;
@end
