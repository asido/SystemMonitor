//
//  GLLineGraph.h
//  ActivityMonitor++
//
//  Created by st on 09/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@protocol GLLineGraphDelegate
- (void)graphFinishedInitializing;
@end

@interface GLLineGraph : GLKViewController
@property (assign, nonatomic) id<GLLineGraphDelegate> delegate;

- (id)initWithGLKView:(GLKView*)aGLView
        dataLineCount:(NSUInteger)count
            fromValue:(float)from
              toValue:(float)to
              legends:(NSArray*)legends
             delegate:(id)aDelegate;

- (void)appendDataValue:(float)value;
@end
