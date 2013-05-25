//
//  GLEffect.m
//  ActivityMonitor++
//
//  Created by st on 25/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "AMLog.h"
#import "GLEffect.h"

@implementation GLEffect

- (BOOL)compileShader:(GLuint*)shader filename:(NSString*)filename type:(GLenum)type
{
    if (!filename || filename.length == 0)
    {
        AMWarn(@"%s: filename is empty.", __PRETTY_FUNCTION__);
        return NO;
    }
    
    const GLchar *source;
    GLint compiled;
    GLint s = glCreateShader(type);
    
    if (!s)
    {
        AMWarn(@"%s: shader creation has failed.", __PRETTY_FUNCTION__);
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
            AMWarn(@"%s: shader compilation has failed: %s", __PRETTY_FUNCTION__, infoLog);
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
            AMWarn(@"%s: program linking has failed: %s", __PRETTY_FUNCTION__, infoLog);
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
            AMWarn(@"%s: program validation has failed: %s", __PRETTY_FUNCTION__, infoLog);
            free(infoLog);
        }
    }
    
    return valid;
}

@end
