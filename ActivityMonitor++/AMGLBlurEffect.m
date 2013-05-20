//
//  AMGLBlurEffect.m
//  ActivityMonitor++
//
//  Created by st on 19/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMLog.h"
#import "AMGLBlurEffect.h"

enum AMGLUniforms {
    AMGLMVPMatrix=0,
    AMGLTexture0Sampler2D,
    AMGLUniformNumUniforms
};

@interface AMGLBlurEffect()
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint*)shader filename:(NSString*)filename type:(GLenum)type;
- (BOOL)linkProgram;
- (BOOL)validateProgram;
@end

@implementation AMGLBlurEffect
{
    GLuint program;
    GLuint uniforms[AMGLUniformNumUniforms];
}

@synthesize mvpMatrix;
@synthesize texture0;

#pragma mark - override

- (id)init
{
    if (self = [super init])
    {
        [self loadShaders];
    }
    return self;
}

#pragma mark - public

- (void)prepareToDraw
{
    if (!program)
    {
        AMWarn(@"%s: shader program is not loaded.", __PRETTY_FUNCTION__);
        return;
    }
    
    glUseProgram(program);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture0);
    
    glUniformMatrix4fv(uniforms[AMGLMVPMatrix], 1, GL_FALSE, self.mvpMatrix.m);
    glUniform1i(uniforms[AMGLTexture0Sampler2D], 0);
}

#pragma mark - private

- (BOOL)loadShaders
{
    GLuint vertexShader, fragmentShader;
    NSString *vertexShaderFilename, *fragmentShaderFilename;
    
    vertexShaderFilename = [[NSBundle mainBundle] pathForResource:@"AMGLBlurEffect" ofType:@"vsh"];
    if (![self compileShader:&vertexShader filename:vertexShaderFilename type:GL_VERTEX_SHADER])
    {
        AMWarn(@"%s: vertex shader compilation has failed.", __PRETTY_FUNCTION__);
        return NO;
    }
    
    fragmentShaderFilename = [[NSBundle mainBundle] pathForResource:@"AMGLBlurEffect" ofType:@"fsh"];
    if (![self compileShader:&fragmentShader filename:fragmentShaderFilename type:GL_FRAGMENT_SHADER])
    {
        AMWarn(@"%s: fragment shader compilation has failed.", __PRETTY_FUNCTION__);
        return NO;
    }
    
    program = glCreateProgram();
    if (!program)
    {
        AMWarn(@"%s: program creation has failed.", __PRETTY_FUNCTION__);
        return NO;
    }
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // Bind attribute locations.
    glBindAttribLocation(program, GLKVertexAttribPosition, "a_position");
    glBindAttribLocation(program, GLKVertexAttribTexCoord0, "a_texCoord0");
    
    if (![self linkProgram])
    {
        AMWarn(@"%s: shader linking has failed.", __PRETTY_FUNCTION__);
        
        if (vertexShader)
        {
            glDetachShader(program, vertexShader);
            glDeleteShader(vertexShader);
            vertexShader = 0;
        }
        if (fragmentShader)
        {
            glDetachShader(program, fragmentShader);
            glDeleteShader(fragmentShader);
            fragmentShader = 0;
        }
        
        glDeleteProgram(program);
        
        return NO;
    }
    
    //[self validateProgram];
    
    // Get uniform locations.
    uniforms[AMGLMVPMatrix] = glGetUniformLocation(program, "u_mvpMatrix");
    uniforms[AMGLTexture0Sampler2D] = glGetUniformLocation(program, "u_texture0");
    
    return YES;
}

- (BOOL)compileShader:(GLuint*)shader filename:(NSString*)filename type:(GLenum)type
{
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

- (BOOL)linkProgram
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

- (BOOL)validateProgram
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
