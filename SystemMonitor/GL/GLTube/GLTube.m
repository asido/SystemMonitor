//
//  GLTube.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "GLCommon.h"
#import "AMUtils.h"
#import "AppDelegate.h"
#import "GLBubbleEffect.h"
#import "GLTube.h"

@interface GLTube()
@property (nonatomic, weak) GLKView             *glView;
@property (nonatomic, strong) GLKBaseEffect     *effect;
@property (nonatomic, strong) GLBubbleEffect    *bubbleEffect;
@property (nonatomic, assign) GLfloat           aspectRatio;
@property (nonatomic, assign) GLfloat           drawableWidth;
@property (nonatomic, assign) GLfloat           drawableHeight;
@property (nonatomic, assign) GLfloat           projectionLeft;
@property (nonatomic, assign) GLfloat           projectionRight;

@property (nonatomic, assign) GLfloat           drawableLiquidMinX;
@property (nonatomic, assign) GLfloat           drawableLiquidMaxX;
@property (nonatomic, assign) GLfloat           drawableLiquidWidth;

@property (nonatomic, assign) GLfloat           drawableGlassX;
@property (nonatomic, assign) GLfloat           drawableGlassWidth;

@property (nonatomic, assign) double            fromValue;
@property (nonatomic, assign) double            toValue;
@property (nonatomic, assign) GLfloat           currentPercentage;

@property (nonatomic, assign) GLuint            glVertexArrayTubeLeft;
@property (nonatomic, assign) GLuint            glVertexArrayTubeRight;
@property (nonatomic, assign) GLuint            glVertexArrayTubeLiquid;
@property (nonatomic, assign) GLuint            glVertexArrayTubeLiquidTop;
@property (nonatomic, assign) GLuint            glVertexArrayTubeGlass;

@property (nonatomic, assign) GLuint            glBufferTubeLeft;
@property (nonatomic, assign) GLuint            glBufferTubeRight;
@property (nonatomic, assign) GLuint            glBufferTubeLiquid;
@property (nonatomic, assign) GLuint            glBufferTubeLiquidTop;
@property (nonatomic, assign) GLuint            glBufferTubeGlass;

@property (nonatomic, assign) GLuint            tubeVertexCountLeft;
@property (nonatomic, assign) GLuint            tubeVertexCountRight;
@property (nonatomic, assign) GLuint            tubeVertexCountLiquid;
@property (nonatomic, assign) GLuint            tubeVertexCountLiquidTop;
@property (nonatomic, assign) GLuint            tubeVertexCountGlass;

@property (nonatomic, assign) GLuint            tubeTexture;

- (void)setupGL;
- (void)setupVBOs;
- (void)tearDownGL;
- (GLuint)setupTexture:(NSString*)filename;
- (GLuint)setupVertexArray;
- (GLuint)setupBufferData:(const VertexData_t[])data size:(NSUInteger)size;

- (void)renderTubeSides;
- (void)renderLiquid;
- (void)renderGlass;
@end

@implementation GLTube
@synthesize glView;
@synthesize effect;
@synthesize bubbleEffect;
@synthesize aspectRatio;
@synthesize drawableWidth;
@synthesize drawableHeight;
@synthesize projectionLeft;
@synthesize projectionRight;

@synthesize drawableLiquidMinX;
@synthesize drawableLiquidMaxX;
@synthesize drawableLiquidWidth;

@synthesize drawableGlassX;
@synthesize drawableGlassWidth;

@synthesize fromValue;
@synthesize toValue;
@synthesize currentPercentage;

@synthesize glVertexArrayTubeLeft=_glVertexArrayTubeLeft;
@synthesize glVertexArrayTubeRight=_glVertexArrayTubeRight;
@synthesize glVertexArrayTubeLiquid=_glVertexArrayTubeLiquid;
@synthesize glVertexArrayTubeLiquidTop=_glVertexArrayTubeLiquidTop;
@synthesize glVertexArrayTubeGlass=_glVertexArrayTubeGlass;

@synthesize glBufferTubeLeft=_glBufferTubeLeft;
@synthesize glBufferTubeRight=_glBufferTubeRight;
@synthesize glBufferTubeLiquid=_glBufferTubeLiquid;
@synthesize glBufferTubeLiquidTop=_glBufferTubeLiquidTop;
@synthesize glBufferTubeGlass=_glBufferTubeGlass;

@synthesize tubeVertexCountLeft;
@synthesize tubeVertexCountRight;
@synthesize tubeVertexCountLiquid;
@synthesize tubeVertexCountLiquidTop;
@synthesize tubeVertexCountGlass;

@synthesize tubeTexture=_tubeTexture;

static const GLfloat kBubblesPerSecondAvrg = 1.0;

#pragma mark - override

- (void)dealloc
{
    [self tearDownGL];
}

#pragma mark - public

- (id)initWithGLKView:(GLKView*)aGLView fromValue:(double)from toValue:(double)to
{
    if (self = [super init])
    {
        self.glView = aGLView;
        self.view = self.glView;
        
        self.drawableWidth = self.glView.bounds.size.width * self.glView.contentScaleFactor;
        self.drawableHeight = self.glView.bounds.size.height * self.glView.contentScaleFactor;
        self.aspectRatio = fabs(self.drawableWidth / self.drawableHeight);
        
        self.projectionLeft = 0;
        self.projectionRight = self.drawableWidth;
        
        DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
        
        self.drawableLiquidMinX = ui.GLtubeTextureLeftX + ui.GLtubeTextureLeftW;
        self.drawableLiquidMaxX = self.projectionRight - ui.GLtubeTextureRightW - ui.GLtubeTextureLiquidTopW;
        self.drawableLiquidWidth = self.drawableLiquidMaxX - self.drawableLiquidMinX;
        
        self.drawableGlassX = ui.GLtubeTextureLeftW;
        self.drawableGlassWidth = self.projectionRight - (ui.GLtubeTextureLeftW + ui.GLtubeTextureRightW);
        
        self.fromValue = from;
        self.toValue = to;
        
        [self setupGL];
    }
    return self;
}

- (void)setValue:(double)value
{
    AMAssert(value >= self.fromValue && value <= self.toValue, @"Data is out of range. Value=%f, Bounds: %f - %f", value, [self fromValue], [self toValue]);
    self.currentPercentage = [AMUtils valuePercentFrom:self.fromValue to:self.toValue value:value];
    
    GLBubbleBounds_t bounds = self.bubbleEffect.bounds;
    bounds.maxRightPosition = [AMUtils percentageValueFromMax:self.drawableLiquidMaxX min:self.drawableLiquidMinX percent:self.currentPercentage];
    DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
    bounds.maxRightPosition += ui.GLtubeTextureLiquidTopW - ui.GLtubeLiquidTopGlowL;
    self.bubbleEffect.bounds = bounds;
}

#pragma mark - private

- (void)setupGL
{
    EAGLContext *glContext = [GLCommon context];
    if (!glContext)
    {
        AMLogWarn(@"EAGLContext == nil");
        return;
    }
    self.glView.context = glContext;
    [EAGLContext setCurrentContext:glContext];
    
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0.0, self.drawableWidth, 0.0, self.drawableHeight, 1.0, 10.0);
    self.effect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -5.0);
    
    DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
    
    GLBubbleBounds_t bubbleBounds = {
        .maxLeftPosition = self.drawableLiquidMinX - 5, // Subtract in order to start rendering behind the tube side
        .maxRightPosition = self.drawableLiquidMaxX + ui.GLtubeTextureLiquidTopW - ui.GLtubeLiquidTopGlowL,
        .maxTopPosition = ui.GLtubeTextureH - ui.GLtubeGlowH - 5, // Make sure bubbles don't show up outside the tube.
        .maxBottomPosition = 0 + ui.GLtubeGlowH + 5
    };
    self.bubbleEffect = [[GLBubbleEffect alloc] initWithBounds:bubbleBounds];
    
    self.tubeTexture = [self setupTexture:@"TubeTexture"];
    
    [self setupVBOs];
}

- (void)setupVBOs
{
    /*
     * We do this ugly vertex data initialization in order to provide equal experience on retina and non-retina displays.
     * Retina displays need bigger textures and because we map them 1-to-1 to display pixels, we have to calculate this on runtime.
     */
    
    DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
    
    /*
     * Left tube side.
     */
    const VertexData_t tubeLeftVertexData[] = {
        {{                   0.0,                    0.0, kModelZ }, {                           ui.GLtubeTextureLeftX / ui.GLtubeTextureSheetW,                            ui.GLtubeTextureY / ui.GLtubeTextureSheetH }},
        {{ ui.GLtubeTextureLeftW,                    0.0, kModelZ }, { (ui.GLtubeTextureLeftX + ui.GLtubeTextureLeftW) / ui.GLtubeTextureSheetW,                            ui.GLtubeTextureY / ui.GLtubeTextureSheetH }},
        {{                   0.0, ui.GLtubeTextureSheetH, kModelZ }, {                           ui.GLtubeTextureLeftX / ui.GLtubeTextureSheetW, (ui.GLtubeTextureY - ui.GLtubeTextureSheetH) / ui.GLtubeTextureSheetH }},
        {{ ui.GLtubeTextureLeftW, ui.GLtubeTextureSheetH, kModelZ }, { (ui.GLtubeTextureLeftX + ui.GLtubeTextureLeftW) / ui.GLtubeTextureSheetW, (ui.GLtubeTextureY - ui.GLtubeTextureSheetH) / ui.GLtubeTextureSheetH }}
    };
    self.tubeVertexCountLeft = sizeof(tubeLeftVertexData) / sizeof(VertexData_t);
    self.glVertexArrayTubeLeft = [self setupVertexArray];
    self.glBufferTubeLeft = [self setupBufferData:tubeLeftVertexData size:sizeof(tubeLeftVertexData)];
    
    /*
     * Right tube side.
     */
    const VertexData_t tubeRightVertexData[] = {
        {{                    0.0,                    0.0, kModelZ }, {                            ui.GLtubeTextureRightX / ui.GLtubeTextureSheetW,                            ui.GLtubeTextureY / ui.GLtubeTextureSheetH }},
        {{ ui.GLtubeTextureRightW,                    0.0, kModelZ }, { (ui.GLtubeTextureRightX + ui.GLtubeTextureRightW) / ui.GLtubeTextureSheetW,                            ui.GLtubeTextureY / ui.GLtubeTextureSheetH }},
        {{                    0.0, ui.GLtubeTextureSheetH, kModelZ }, {                            ui.GLtubeTextureRightX / ui.GLtubeTextureSheetW, (ui.GLtubeTextureY - ui.GLtubeTextureSheetH) / ui.GLtubeTextureSheetH }},
        {{ ui.GLtubeTextureRightW, ui.GLtubeTextureSheetH, kModelZ }, { (ui.GLtubeTextureRightX + ui.GLtubeTextureRightW) / ui.GLtubeTextureSheetW, (ui.GLtubeTextureY - ui.GLtubeTextureSheetH) / ui.GLtubeTextureSheetH }}
    };
    self.tubeVertexCountRight = sizeof(tubeRightVertexData) / sizeof(VertexData_t);
    self.glVertexArrayTubeRight = [self setupVertexArray];
    self.glBufferTubeRight = [self setupBufferData:tubeRightVertexData size:sizeof(tubeRightVertexData)];
    
    /*
     * Liquid.
     */
    const VertexData_t tubeLiquidVertexData[] = {
        {{                     0.0,                    0.0, kModelZ }, {                             ui.GLtubeTextureLiquidX / ui.GLtubeTextureSheetW,                            ui.GLtubeTextureY / ui.GLtubeTextureSheetH }},
        {{ ui.GLtubeTextureLiquidW,                    0.0, kModelZ }, { (ui.GLtubeTextureLiquidX + ui.GLtubeTextureLiquidW) / ui.GLtubeTextureSheetW,                            ui.GLtubeTextureY / ui.GLtubeTextureSheetH }},
        {{                     0.0, ui.GLtubeTextureSheetH, kModelZ }, {                             ui.GLtubeTextureLiquidX / ui.GLtubeTextureSheetW, (ui.GLtubeTextureY - ui.GLtubeTextureSheetH) / ui.GLtubeTextureSheetH }},
        {{ ui.GLtubeTextureLiquidW, ui.GLtubeTextureSheetH, kModelZ }, { (ui.GLtubeTextureLiquidX + ui.GLtubeTextureLiquidW) / ui.GLtubeTextureSheetW, (ui.GLtubeTextureY - ui.GLtubeTextureSheetH) / ui.GLtubeTextureSheetH }}
    };
    self.tubeVertexCountLiquid = sizeof(tubeLiquidVertexData) / sizeof(VertexData_t);
    self.glVertexArrayTubeLiquid = [self setupVertexArray];
    self.glBufferTubeLiquid = [self setupBufferData:tubeLiquidVertexData size:sizeof(tubeLiquidVertexData)];
    
    /*
     * Liquid top.
     */
    const VertexData_t tubeLiquidTopVertexData[] = {
        {{                        0.0,                    0.0, kModelZ }, {                                ui.GLtubeTextureLiquidTopX / ui.GLtubeTextureSheetW,                            ui.GLtubeTextureY / ui.GLtubeTextureSheetH }},
        {{ ui.GLtubeTextureLiquidTopW,                    0.0, kModelZ }, { (ui.GLtubeTextureLiquidTopX + ui.GLtubeTextureLiquidTopW) / ui.GLtubeTextureSheetW,                            ui.GLtubeTextureY / ui.GLtubeTextureSheetH }},
        {{                        0.0, ui.GLtubeTextureSheetH, kModelZ }, {                                ui.GLtubeTextureLiquidTopX / ui.GLtubeTextureSheetW, (ui.GLtubeTextureY - ui.GLtubeTextureSheetH) / ui.GLtubeTextureSheetH }},
        {{ ui.GLtubeTextureLiquidTopW, ui.GLtubeTextureSheetH, kModelZ }, { (ui.GLtubeTextureLiquidTopX + ui.GLtubeTextureLiquidTopW) / ui.GLtubeTextureSheetW, (ui.GLtubeTextureY - ui.GLtubeTextureSheetH) / ui.GLtubeTextureSheetH }}
    };
    self.tubeVertexCountLiquidTop = sizeof(tubeLiquidTopVertexData) / sizeof(VertexData_t);
    self.glVertexArrayTubeLiquidTop = [self setupVertexArray];
    self.glBufferTubeLiquidTop = [self setupBufferData:tubeLiquidTopVertexData size:sizeof(tubeLiquidTopVertexData)];
    
    
    const VertexData_t tubeGlassVertexData[] = {
        {{                    0.0,                    0.0, kModelZ }, {                            ui.GLtubeTextureGlassX / ui.GLtubeTextureSheetW,                            ui.GLtubeTextureY / ui.GLtubeTextureSheetH }},
        {{ ui.GLtubeTextureGlassW,                    0.0, kModelZ }, { (ui.GLtubeTextureGlassX + ui.GLtubeTextureGlassW) / ui.GLtubeTextureSheetW,                            ui.GLtubeTextureY / ui.GLtubeTextureSheetH }},
        {{                    0.0, ui.GLtubeTextureSheetH, kModelZ }, {                            ui.GLtubeTextureGlassX / ui.GLtubeTextureSheetW, (ui.GLtubeTextureY - ui.GLtubeTextureSheetH) / ui.GLtubeTextureSheetH }},
        {{ ui.GLtubeTextureGlassW, ui.GLtubeTextureSheetH, kModelZ }, { (ui.GLtubeTextureGlassX + ui.GLtubeTextureGlassW) / ui.GLtubeTextureSheetW, (ui.GLtubeTextureY - ui.GLtubeTextureSheetH) / ui.GLtubeTextureSheetH }}
    };
    self.tubeVertexCountGlass = sizeof(tubeGlassVertexData) / sizeof(VertexData_t);
    self.glVertexArrayTubeGlass = [self setupVertexArray];
    self.glBufferTubeGlass = [self setupBufferData:tubeGlassVertexData size:sizeof(tubeGlassVertexData)];
}

- (void)tearDownGL
{
    if (self.tubeTexture)
    {
        glDeleteTextures(1, &_tubeTexture);
    }
    
    if (self.glBufferTubeLeft)
    {
        glDeleteBuffers(1, &_glBufferTubeLeft);
    }
    if (self.glBufferTubeRight)
    {
        glDeleteBuffers(1, &_glBufferTubeRight);
    }
    if (self.glBufferTubeLiquid)
    {
        glDeleteBuffers(1, &_glBufferTubeLiquid);
    }
    if (self.glBufferTubeLiquidTop)
    {
        glDeleteBuffers(1, &_glBufferTubeLiquidTop);
    }
    if (self.glBufferTubeGlass)
    {
        glDeleteBuffers(1, &_glBufferTubeGlass);
    }
    
    if (self.glVertexArrayTubeLeft)
    {
        glDeleteVertexArraysOES(1, &_glVertexArrayTubeLeft);
    }
    if (self.glVertexArrayTubeRight)
    {
        glDeleteVertexArraysOES(1, &_glVertexArrayTubeRight);
    }
    if (self.glVertexArrayTubeLiquid)
    {
        glDeleteVertexArraysOES(1, &_glVertexArrayTubeLiquid);
    }
    if (self.glVertexArrayTubeLiquidTop)
    {
        glDeleteVertexArraysOES(1, &_glVertexArrayTubeLiquidTop);
    }
    if (self.glVertexArrayTubeGlass)
    {
        glDeleteVertexArraysOES(1, &_glVertexArrayTubeGlass);
    }
    
    GL_CHECK_ERROR();
}

- (GLuint)setupTexture:(NSString*)filename
{
    CGImageRef texImage = [UIImage imageNamed:filename].CGImage;
    if (!texImage)
    {
        AMLogWarn(@"loading texture has failed: %@.", filename);
        return -1;
    }
    
    GLsizei width = (GLsizei)CGImageGetWidth(texImage);
    GLsizei height = (GLsizei)CGImageGetHeight(texImage);
    
    GLubyte *texData = (GLubyte*) calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef texContext = CGBitmapContextCreate(texData, width, height, 8, width * 4, CGImageGetColorSpace(texImage), kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(texContext, CGRectMake(0, 0, width, height), texImage);
    CGContextRelease(texContext);
    
    GLuint tex;
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, texData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    GL_CHECK_ERROR();
    
    free(texData);
    return tex;
}

- (GLuint)setupVertexArray
{
    GLuint vbo;
    
    glGenVertexArraysOES(1, &vbo);
    glBindVertexArrayOES(vbo);
    
    GL_CHECK_ERROR();
    
    return vbo;
}

- (GLuint)setupBufferData:(const VertexData_t*)data size:(NSUInteger)size
{
    GLuint buffer;
    
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, size, data, GL_STATIC_DRAW);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                          sizeof(VertexData_t), NULL + offsetof(VertexData_t, positionCoords));
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE,
                          sizeof(VertexData_t), NULL + offsetof(VertexData_t, textureCoords));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    GL_CHECK_ERROR();

    return buffer;
}

- (void)renderTubeSides
{
    /*
     * Left side
     */
    {
        GLKMatrix4 save = self.effect.transform.modelviewMatrix;
        
        GLfloat x = self.projectionLeft;
        
        glBindVertexArrayOES(self.glVertexArrayTubeLeft);
        
        GLKVector3 position = GLKVector3Make(x, 0.0, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
        GLKMatrix4 scale = GLKMatrix4MakeScale(1.0, 1.0, 1.0);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.texture2d0.enabled = GL_TRUE;
        self.effect.texture2d0.name = self.tubeTexture;
        self.effect.texture2d0.target = GLKTextureTarget2D;
        self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        [self.effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, self.tubeVertexCountLeft);
        GL_CHECK_ERROR();
        
        self.effect.transform.modelviewMatrix = save;
    }
    
    /*
     * Right side
     */
    {
        GLKMatrix4 save = self.effect.transform.modelviewMatrix;
        
        DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
        GLfloat x = self.projectionRight - ui.GLtubeTextureRightW;
        
        glBindVertexArrayOES(self.glVertexArrayTubeRight);
        
        GLKVector3 position = GLKVector3Make(x, 0.0, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
        GLKMatrix4 scale = GLKMatrix4MakeScale(1.0, 1.0, 1.0);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.texture2d0.enabled = GL_TRUE;
        self.effect.texture2d0.name = self.tubeTexture;
        self.effect.texture2d0.target = GLKTextureTarget2D;
        self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        [self.effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, self.tubeVertexCountRight);
        GL_CHECK_ERROR();
        
        self.effect.transform.modelviewMatrix = save;
    }
}

- (void)renderLiquid
{
    /*
     * Whole liquid
     */
    {
        GLKMatrix4 save = self.effect.transform.modelviewMatrix;
        
        GLfloat x = self.drawableLiquidMinX;
        GLfloat scaleX = [AMUtils percentageValueFromMax:self.drawableLiquidMaxX min:self.drawableLiquidMinX percent:self.currentPercentage];
        
        glBindVertexArrayOES(self.glVertexArrayTubeLiquid);
        
        GLKVector3 position = GLKVector3Make(x, 0.0, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
        GLKMatrix4 scale = GLKMatrix4MakeScale(scaleX, 1.0, 1.0);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.texture2d0.enabled = GL_TRUE;
        self.effect.texture2d0.name = self.tubeTexture;
        self.effect.texture2d0.target = GLKTextureTarget2D;
        self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        [self.effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, self.tubeVertexCountLiquid);
        GL_CHECK_ERROR();
        
        self.effect.transform.modelviewMatrix = save;
    }
    
    /*
     * Liquid top
     */
    {
        GLKMatrix4 save = self.effect.transform.modelviewMatrix;
        
        DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
        GLfloat x = [AMUtils percentageValueFromMax:self.drawableLiquidMaxX min:self.drawableLiquidMinX percent:self.currentPercentage] + ui.GLtubeTextureLeftW;
        
        glBindVertexArrayOES(self.glVertexArrayTubeLiquidTop);
        
        GLKVector3 position = GLKVector3Make(x, 0.0, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
        GLKMatrix4 scale = GLKMatrix4MakeScale(1.0, 1.0, 1.0);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.texture2d0.enabled = GL_TRUE;
        self.effect.texture2d0.name = self.tubeTexture;
        self.effect.texture2d0.target = GLKTextureTarget2D;
        self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        [self.effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, self.tubeVertexCountLiquidTop);
        GL_CHECK_ERROR();
        
        self.effect.transform.modelviewMatrix = save;
    }
}

- (void)renderGlass
{
    GLKMatrix4 save = self.effect.transform.modelviewMatrix;
    
    GLfloat x = self.drawableGlassX;
    GLfloat scaleX = self.drawableGlassWidth;
    
    glBindVertexArrayOES(self.glVertexArrayTubeGlass);
    
    GLKVector3 position = GLKVector3Make(x, 0.0, kModelZ);
    GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
    GLKMatrix4 scale = GLKMatrix4MakeScale(scaleX, 1.0, 1.0);
    GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
    
    self.effect.transform.modelviewMatrix = modelMatrix;
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = self.tubeTexture;
    self.effect.texture2d0.target = GLKTextureTarget2D;
    self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, self.tubeVertexCountGlass);
    GL_CHECK_ERROR();
    
    self.effect.transform.modelviewMatrix = save;
}

#pragma mark - override

- (void)update
{
    /*
     * This is *so* ugly, but damn self.timeSinceLastResume remains always zero #%$@ !
     */
    static NSTimeInterval lastResume = 0;
    lastResume += self.timeSinceLastUpdate;
    self.bubbleEffect.elapsedSeconds = lastResume;
    
    GLfloat roll = self.timeSinceLastUpdate * [AMUtils random];
    GLfloat chance = self.timeSinceLastUpdate / self.framesPerSecond * kBubblesPerSecondAvrg;
    
    if (roll < chance)
    {
        [self.bubbleEffect spawnBubbleEffect];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self renderLiquid];
    
    self.bubbleEffect.mvpMatrix = GLKMatrix4Multiply(self.effect.transform.projectionMatrix, self.effect.transform.modelviewMatrix);
    [self.bubbleEffect render];

    [self renderTubeSides];
    [self renderGlass];
}

@end

