//
//  GLTubeBubbleEffect.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AMLog.h"
#import "AMUtils.h"
#import "AppDelegate.h"
#import "GLCommon.h"
#import "GLBubbleEffect.h"

typedef struct {
    GLKVector3  position;
    GLKVector3  velocity;
    GLfloat     size;
    GLfloat     startTime;
} BubbleEffectAttributes_t;

enum AttributeType {
    GLBubbleEffectPosition=0,
    GLBubbleEffectVelocity,
    GLBubbleEffectSize,
    GLBubbleEffectStartTime
};

enum GLBubbleEffectUniforms {
    GLBubbleEffectMVPMatrix=0,
    GLBubbleEffectSamplers2D,
    GLBubbleEffectMaxRightPosition,
    GLBubbleEffectElapsedTime,
    GLBubbleEffectUniformNumUniforms
};

@interface GLBubbleEffect()
@property (strong, nonatomic) NSMutableData *bubbleAttributeData;

@property (assign, nonatomic) GLuint        glVertexArrayBubble;
@property (assign, nonatomic) GLuint        glBufferBubble;
@property (assign, nonatomic) GLuint        bubbleTexture;
@property (assign, nonatomic) GLfloat       bubbleSize;

- (BOOL)loadShaders;
- (void)setupVBO;
- (void)setupTexture;
- (void)tearDownGL;
- (NSUInteger)numberOfBubbles;
- (BubbleEffectAttributes_t)bubbleAtIndex:(NSUInteger)index;
@end

@implementation GLBubbleEffect
{
    GLuint program;
    GLuint vertexShader, fragmentShader;
    GLuint uniforms[GLBubbleEffectUniformNumUniforms];
}

@synthesize mvpMatrix;
@synthesize bounds;
@synthesize elapsedSeconds;

@synthesize bubbleAttributeData;

@synthesize glVertexArrayBubble=_glVertexArrayBubble;
@synthesize glBufferBubble=_glBufferBubble;
@synthesize bubbleTexture=_bubbleTexture;
@synthesize bubbleSize;

#pragma mark - override

- (void)dealloc
{
    [self tearDownGL];
}

#pragma mark - public

- (id)initWithBounds:(GLBubbleBounds_t)bound
{
    if (self = [super init])
    {
        self.bounds = bound;
        self.bubbleAttributeData = [NSMutableData data];
        
        [self setupVBO];
        [self setupTexture];
        [self loadShaders];
    }
    return self;
}

- (void)spawnBubbleEffect
{
    // Take a random value between tube top and bottom.
    GLfloat yPosition = self.bounds.maxBottomPosition +
                        ((self.bounds.maxTopPosition - self.bounds.maxBottomPosition) * [AMUtils random]);
    GLfloat xVelocity = 15.0 + (10.0 * [AMUtils random]);
    
    BubbleEffectAttributes_t bubble;
    bubble.position = GLKVector3Make(self.bounds.maxLeftPosition,
                                     yPosition,
                                     kModelZ);
    bubble.velocity = GLKVector3Make(xVelocity, 0.0f, 0.0f);
    bubble.size = self.bubbleSize;
    bubble.startTime = self.elapsedSeconds;
    
    BOOL slotFound = NO;
    NSUInteger bubbleCount = [self numberOfBubbles];
    
    for (NSUInteger i = 0; i < bubbleCount && !slotFound; ++i)
    {
        BubbleEffectAttributes_t oldBubble = [self bubbleAtIndex:i];
        GLfloat oldBubbleX = (self.elapsedSeconds - oldBubble.startTime) * oldBubble.velocity.x;
        
        if (oldBubbleX > self.bounds.maxRightPosition)
        {
            slotFound = YES;
            
            BubbleEffectAttributes_t *bubblesPtr = [self.bubbleAttributeData mutableBytes];
            bubblesPtr[i] = bubble;
            
            glBindBuffer(GL_ARRAY_BUFFER, self.glBufferBubble);
            glBufferSubData(GL_ARRAY_BUFFER, i * sizeof(BubbleEffectAttributes_t), sizeof(BubbleEffectAttributes_t), &bubblesPtr[i]);
        }
    }
    
    if (!slotFound)
    {
        [self.bubbleAttributeData appendBytes:&bubble length:sizeof(BubbleEffectAttributes_t)];
        
        glBindBuffer(GL_ARRAY_BUFFER, self.glBufferBubble);
        glBufferData(GL_ARRAY_BUFFER, [self.bubbleAttributeData length], [self.bubbleAttributeData bytes], GL_DYNAMIC_DRAW);
    }
    
    GL_CHECK_ERROR();
}

- (void)render
{
    if (!program)
    {
        AMWarn(@"shader program is not loaded.");
        return;
    }
 
    // Trying to render empty array will bug the whole thing and no bubbles will
    // get rendered forever even if you add some.
    if ([self numberOfBubbles] == 0)
    {
        return;
    }
    
    glBindVertexArrayOES(self.glVertexArrayBubble);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.bubbleTexture);
    
    glUseProgram(program);
    glUniformMatrix4fv(uniforms[GLBubbleEffectMVPMatrix], 1, GL_FALSE, self.mvpMatrix.m);
    glUniform1i(uniforms[GLBubbleEffectSamplers2D], 0);
    glUniform1f(uniforms[GLBubbleEffectMaxRightPosition], self.bounds.maxRightPosition);
    glUniform1f(uniforms[GLBubbleEffectElapsedTime], self.elapsedSeconds);

    glDrawArrays(GL_POINTS, 0, (GLsizei)[self numberOfBubbles]);
    
    GL_CHECK_ERROR();
}

#pragma mark - private

- (BOOL)loadShaders
{
    NSString *vertexShaderFilename, *fragmentShaderFilename;
    
    vertexShaderFilename = [[NSBundle mainBundle] pathForResource:@"GLBubbleEffect" ofType:@"vsh"];
    if (![self compileShader:&vertexShader filename:vertexShaderFilename type:GL_VERTEX_SHADER])
    {
        AMWarn(@"vertex shader compilation has failed.");
        return NO;
    }
    
    fragmentShaderFilename = [[NSBundle mainBundle] pathForResource:@"GLBubbleEffect" ofType:@"fsh"];
    if (![self compileShader:&fragmentShader filename:fragmentShaderFilename type:GL_FRAGMENT_SHADER])
    {
        AMWarn(@"fragment shader compilation has failed.");
        return NO;
    }
    
    program = glCreateProgram();
    if (!program)
    {
        AMWarn(@"program creation has failed.");
        return NO;
    }
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // Bind attribute locations.
    glBindAttribLocation(program, GLBubbleEffectPosition, "a_position");
    glBindAttribLocation(program, GLBubbleEffectVelocity, "a_velocity");
    glBindAttribLocation(program, GLBubbleEffectSize, "a_size");
    glBindAttribLocation(program, GLBubbleEffectStartTime, "a_starttime");   
    
    if (![self linkProgram:program])
    {
        AMWarn(@"shader linking has failed.");
        
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
    
    //[self validateProgram:program];
    
    // Get uniform locations.
    uniforms[GLBubbleEffectMVPMatrix] = glGetUniformLocation(program, "u_mvpMatrix");
    uniforms[GLBubbleEffectSamplers2D] = glGetUniformLocation(program, "u_texture0");
    uniforms[GLBubbleEffectMaxRightPosition] = glGetUniformLocation(program, "u_maxRightPosition");
    uniforms[GLBubbleEffectElapsedTime] = glGetUniformLocation(program, "u_elapsedTime");
    uniforms[GLBubbleEffectSamplers2D] = glGetUniformLocation(program, "u_samplers2D");
    
    GL_CHECK_ERROR();

    return YES;
}

- (void)setupVBO
{
    glGenVertexArraysOES(1, &_glVertexArrayBubble);
    glBindVertexArrayOES(self.glVertexArrayBubble);
    
    glGenBuffers(1, &_glBufferBubble);
    glBindBuffer(GL_ARRAY_BUFFER, self.glVertexArrayBubble);
    glBufferData(GL_ARRAY_BUFFER, [self.bubbleAttributeData length], [self.bubbleAttributeData bytes], GL_DYNAMIC_DRAW);
    
    glVertexAttribPointer(GLBubbleEffectPosition, 3, GL_FLOAT, GL_FALSE, sizeof(BubbleEffectAttributes_t),
                          NULL + offsetof(BubbleEffectAttributes_t, position));
    glEnableVertexAttribArray(GLBubbleEffectPosition);
    
    glVertexAttribPointer(GLBubbleEffectVelocity, 3, GL_FLOAT, GL_FALSE, sizeof(BubbleEffectAttributes_t),
                          NULL + offsetof(BubbleEffectAttributes_t, velocity));
    glEnableVertexAttribArray(GLBubbleEffectVelocity);
    
    glVertexAttribPointer(GLBubbleEffectSize, 1, GL_FLOAT, GL_FALSE, sizeof(BubbleEffectAttributes_t),
                          NULL + offsetof(BubbleEffectAttributes_t, size));
    glEnableVertexAttribArray(GLBubbleEffectSize);
    
    glVertexAttribPointer(GLBubbleEffectStartTime, 1, GL_FLOAT, GL_FALSE, sizeof(BubbleEffectAttributes_t),
                          NULL + offsetof(BubbleEffectAttributes_t, startTime));
    glEnableVertexAttribArray(GLBubbleEffectStartTime);
    
    GL_CHECK_ERROR();
}

- (void)setupTexture
{
    DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
    CGImageRef texImage = [UIImage imageNamed:ui.GLtubeBubbleTextureFilename].CGImage;
    if (!texImage)
    {
        AMWarn(@"loading texture has failed: %@.", ui.GLtubeBubbleTextureFilename);
        return;
    }
    
    GLsizei width = (GLsizei)CGImageGetWidth(texImage);
    GLsizei height = (GLsizei)CGImageGetHeight(texImage);
    self.bubbleSize = width;
    
    GLubyte *texData = (GLubyte*) calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef texContext = CGBitmapContextCreate(texData, width, height, 8, width * 4, CGImageGetColorSpace(texImage), kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(texContext, CGRectMake(0, 0, width, height), texImage);
    CGContextRelease(texContext);
    
    glGenTextures(1, &_bubbleTexture);
    glBindTexture(GL_TEXTURE_2D, self.bubbleTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, texData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(texData);

    GL_CHECK_ERROR();
}

- (void)tearDownGL
{
    if (vertexShader)
    {
        glDetachShader(program, vertexShader);
        glDeleteShader(vertexShader);
    }
    if (fragmentShader)
    {
        glDetachShader(program, fragmentShader);
        glDeleteShader(fragmentShader);
    }
    if (program)
    {
        glDeleteProgram(program);
    }
    
    if (self.bubbleTexture)
    {
        glDeleteTextures(1, &_bubbleTexture);
    }
    if (self.glBufferBubble)
    {
        glDeleteBuffers(1, &_glBufferBubble);
    }
    if (self.glVertexArrayBubble)
    {
        glDeleteVertexArraysOES(1, &_glVertexArrayBubble);
    }
    
    GL_CHECK_ERROR();
}

- (NSUInteger)numberOfBubbles
{
    return [self.bubbleAttributeData length] / sizeof(BubbleEffectAttributes_t);
}

- (BubbleEffectAttributes_t)bubbleAtIndex:(NSUInteger)index
{
    assert(index < [self numberOfBubbles]);
    
    BubbleEffectAttributes_t *bubblesPtr = [self.bubbleAttributeData mutableBytes];
    return bubblesPtr[index];
}

@end
