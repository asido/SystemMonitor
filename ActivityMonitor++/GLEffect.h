//
//  GLEffect.h
//  ActivityMonitor++
//
//  Created by st on 25/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GLEffectProtected
- (BOOL)compileShader:(GLuint*)shader filename:(NSString*)filename type:(GLenum)type;
- (BOOL)linkProgram:(GLuint)program;
- (BOOL)validateProgram:(GLuint)program;
@end

@interface GLEffect : NSObject <GLEffectProtected>
@end
