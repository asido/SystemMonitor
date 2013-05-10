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
- (id)initWithGLKView:(GLKView*)aGLView;
- (void)appendValue:(float)value;
@end
