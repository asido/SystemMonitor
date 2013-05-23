//
//  GLLineGraph.h
//  ActivityMonitor++
//
//  Created by st on 09/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLLineGraph : GLKViewController
@property (strong, nonatomic) GLKBaseEffect *effect;
/* Graph boundaries determined based on projection and viewport. */
@property (assign, nonatomic) GLfloat       graphBottom;
@property (assign, nonatomic) GLfloat       graphTop;
@property (assign, nonatomic) GLfloat       graphRight;
@property (assign, nonatomic) GLfloat       graphLeft;

- (id)initWithGLKView:(GLKView*)aGLView
        dataLineCount:(NSUInteger)count
            fromValue:(float)from
              toValue:(float)to
              legends:(NSArray*)legends;

- (void)addDataValue:(NSArray*)data;
- (void)resetDataArray:(NSArray*)dataArray;
- (NSUInteger)requiredElementToFillGraph;
@end
