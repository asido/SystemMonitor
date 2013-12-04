//
//  GLDataLine.h
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

@class GLLineGraph;

@interface GLDataLine : NSObject
@property (nonatomic, strong) UIColor *color;

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
