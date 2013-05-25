//
//  AMGLBlurEffect.m
//  ActivityMonitor++
//
//  Created by st on 19/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMLog.h"
#import "GLBlurEffect.h"

enum GLBlurEffectUniforms {
    GLBlurEffectMVPMatrix=0,
    GLBlurEffectTexture0Sampler2D,
    GLBlurEffectUniformNumUniforms
};

@interface GLBlurEffect()
- (BOOL)loadShaders;
@end

@implementation GLBlurEffect
{
    GLuint program;
    GLuint uniforms[GLBlurEffectUniformNumUniforms];
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
    
    glUniformMatrix4fv(uniforms[GLBlurEffectMVPMatrix], 1, GL_FALSE, self.mvpMatrix.m);
    glUniform1i(uniforms[GLBlurEffectTexture0Sampler2D], 0);
}

#pragma mark - private

- (BOOL)loadShaders
{
    GLuint vertexShader, fragmentShader;
    NSString *vertexShaderFilename, *fragmentShaderFilename;
    
    vertexShaderFilename = [[NSBundle mainBundle] pathForResource:@"GLBlurEffect" ofType:@"vsh"];
    if (![self compileShader:&vertexShader filename:vertexShaderFilename type:GL_VERTEX_SHADER])
    {
        AMWarn(@"%s: vertex shader compilation has failed.", __PRETTY_FUNCTION__);
        return NO;
    }
    
    fragmentShaderFilename = [[NSBundle mainBundle] pathForResource:@"GLBlurEffect" ofType:@"fsh"];
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
    
    if (![self linkProgram:program])
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
    uniforms[GLBlurEffectMVPMatrix] = glGetUniformLocation(program, "u_mvpMatrix");
    uniforms[GLBlurEffectTexture0Sampler2D] = glGetUniformLocation(program, "u_texture0");
    
    return YES;
}

@end
