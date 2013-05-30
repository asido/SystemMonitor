//
//  GLDataLineVBO.h
//  ActivityMonitor++
//
//  Created by st on 21/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class GLLineGraph;

@interface GLDataLine : NSObject
@property (strong, nonatomic) UIColor *color;

- (id)initWithColor:(UIColor*)aColor forGraph:(GLLineGraph*)aGraph;
- (void)addLineDataValue:(double)value;
- (void)addLineDataArray:(NSArray*)dataArray;
- (void)resetLineData;
- (void)setLineDataLegendText:(NSString*)text;
- (void)setDataLineLegendIcon:(UIImage*)image;
- (void)render;
- (void)renderLegend:(NSUInteger)lineIndex;
- (NSUInteger)maxDataLineElements;
- (void)setDataLineZoom:(GLfloat)zoom;
@end
