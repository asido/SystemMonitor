//
//  GLLineGraph.h
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

@interface GLLineGraph : GLKViewController
@property (nonatomic, strong) GLKBaseEffect *effect;
/* Graph boundaries determined based on projection and viewport. */
@property (nonatomic, assign) GLfloat       graphBottom;
@property (nonatomic, assign) GLfloat       graphTop;
@property (nonatomic, assign) GLfloat       graphRight;
@property (nonatomic, assign) GLfloat       graphLeft;

@property (assign, nonatomic) BOOL          useClosestMetrics;

- (id)initWithGLKView:(GLKView*)aGLView
        dataLineCount:(NSUInteger)count
            fromValue:(double)from
              toValue:(double)to
              topLegend:(NSString*)aLegend;

- (void)setDataLineLegendPostfix:(NSString*)postfix;
- (void)setDataLineLegendFraction:(NSUInteger)desiredFraction;
- (void)setDataLineLegendIcon:(UIImage*)image forLineIndex:(NSUInteger)lineIndex;

- (void)addDataValue:(NSArray*)data;
- (void)setGraphLegend:(NSString*)aLegend;
- (void)setZoomLevel:(GLfloat)value;
- (void)resetDataArray:(NSArray*)dataArray;
- (NSUInteger)requiredElementToFillGraph;
@end
