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

@interface DataLine : NSObject
@property (strong, nonatomic) UIColor *color;

- (id)initWithColor:(UIColor*)aColor forGraph:(GLLineGraph*)aGraph;
- (void)addLineDataValue:(float)value;
- (void)addLineDataArray:(NSArray*)dataArray;
- (void)resetLineData;
- (void)render;
- (NSUInteger)maxDataLineElements;
@end
