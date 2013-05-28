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
            fromValue:(double)from
              toValue:(double)to
              topLegend:(NSString*)aLegend;

- (void)addDataValue:(NSArray*)data;
- (void)setTopLegend:(NSString*)aLegend;
- (void)setZoomLevel:(GLfloat)value;
- (void)resetDataArray:(NSArray*)dataArray;
- (NSUInteger)requiredElementToFillGraph;
@end
