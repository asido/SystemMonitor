//
//  GLEffect.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <GLKit/GLKit.h>
#import "AMLogger.h"
#import "GLEffect.h"

@implementation GLEffect

- (BOOL)compileShader:(GLuint*)shader filename:(NSString*)filename type:(GLenum)type
{
    if (!filename || filename.length == 0)
    {
        AMLogWarn(@"filename is empty.");
        return NO;
    }
    
    const GLchar *source;
    GLint compiled;
    GLint s = glCreateShader(type);
    
    if (!s)
    {
        AMLogWarn(@"shader creation has failed.");
        return NO;
    }
    
    source = [[NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil] UTF8String];
    glShaderSource(s, 1, &source, NULL);
    glCompileShader(s);
    glGetShaderiv(s, GL_COMPILE_STATUS, &compiled);
    if (!compiled)
    {
        GLint infoLen = 0;
        glGetShaderiv(s, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1)
        {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog(s, infoLen, NULL, infoLog);
            AMLogWarn(@"shader compilation has failed: %s", infoLog);
            free(infoLog);
        }
        
        glDeleteShader(s);
        return NO;
    }
    
    (*shader) = s;
    return YES;
}

- (BOOL)linkProgram:(GLuint)program
{
    GLint linked;
    
    glLinkProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    if (!linked)
    {
        GLint infoLen = 0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1)
        {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(program, infoLen, NULL, infoLog);
            AMLogWarn(@"program linking has failed: %s", infoLog);
            free(infoLog);
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)program
{
    GLint valid;
    glValidateProgram(program);
    glGetProgramiv(program, GL_VALIDATE_STATUS, &valid);
    
    if (!valid)
    {
        GLint infoLen;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1)
        {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(program, infoLen, NULL, infoLog);
            AMLogWarn(@"program validation has failed: %s", infoLog);
            free(infoLog);
        }
    }
    
    return valid;
}

@end
