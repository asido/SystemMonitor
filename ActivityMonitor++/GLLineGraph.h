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
@property (assign) float    fromValue;
@property (assign) float    toValue;
@property (retain) NSArray  *rangeTitles; // NSString* array

- (id)initWithGLKView:(GLKView*)aGLView
        dataLineCount:(NSUInteger)count
            fromValue:(float)from
              toValue:(float)to
          rangeTitles:(NSArray*)titles;

- (void)appendDataValue:(float)value;
@end
