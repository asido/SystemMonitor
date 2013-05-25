//
//  GLTube.m
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "GLCommon.h"
#import "AMUtils.h"
#import "GLBubbleEffect.h"
#import "GLTube.h"

@interface GLTube()
@property (strong, nonatomic) GLKView           *glView;
@property (strong, nonatomic) GLKBaseEffect     *effect;
@property (strong, nonatomic) GLBubbleEffect    *bubbleEffect;
@property (assign, nonatomic) GLfloat           aspectRatio;
@property (assign, nonatomic) GLfloat           drawableWidth;
@property (assign, nonatomic) GLfloat           drawableHeight;
@property (assign, nonatomic) GLfloat           projectionLeft;
@property (assign, nonatomic) GLfloat           projectionRight;

@property (assign, nonatomic) GLfloat           drawableLiquidMinX;
@property (assign, nonatomic) GLfloat           drawableLiquidMaxX;
@property (assign, nonatomic) GLfloat           drawableLiquidWidth;

@property (assign, nonatomic) GLfloat           drawableGlassX;
@property (assign, nonatomic) GLfloat           drawableGlassWidth;

@property (assign, nonatomic) GLfloat           fromValue;
@property (assign, nonatomic) GLfloat           toValue;
@property (assign, nonatomic) GLfloat           currentPercentage;

@property (assign, nonatomic) GLuint            glVertexArrayTubeLeft;
@property (assign, nonatomic) GLuint            glVertexArrayTubeRight;
@property (assign, nonatomic) GLuint            glVertexArrayTubeLiquid;
@property (assign, nonatomic) GLuint            glVertexArrayTubeLiquidTop;
@property (assign, nonatomic) GLuint            glVertexArrayTubeGlass;

@property (assign, nonatomic) GLuint            glBufferTubeLeft;
@property (assign, nonatomic) GLuint            glBufferTubeRight;
@property (assign, nonatomic) GLuint            glBufferTubeLiquid;
@property (assign, nonatomic) GLuint            glBufferTubeLiquidTop;
@property (assign, nonatomic) GLuint            glBufferTubeGlass;

@property (assign, nonatomic) GLuint            tubeTexture;

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

@synthesize tubeTexture;

static const GLfloat kBubblesPerSecondAvrg = 1.0f;

/*
 * Vertex coordinates are 1-to-1 to the actual texture dimensions.
 * NOTE: keep the texture mapping constants a float or arithmetic will evaluate to 0.
 */

static const GLfloat kTexSheetW = 128.0f;
static const GLfloat kTexSheetH = 128.0f;

static const GLfloat kTexSheetTubeY = 92.0f;
static const GLfloat kTexSheetTubeH = 92.0f;

static const GLfloat kTexSheetTubeLeftX = 0.0f;
static const GLfloat kTexSheetTubeLeftW = 21.0f;
static const VertexData_t tubeLeftVertexData[] = {
    {{               0.0f,           0.0f, kModelZ }, {                        kTexSheetTubeLeftX / kTexSheetW,                    kTexSheetTubeY / kTexSheetH }},
    {{ kTexSheetTubeLeftW,           0.0f, kModelZ }, { (kTexSheetTubeLeftX + kTexSheetTubeLeftW) / kTexSheetW,                    kTexSheetTubeY / kTexSheetH }},
    {{               0.0f, kTexSheetTubeH, kModelZ }, {                        kTexSheetTubeLeftX / kTexSheetW, (kTexSheetTubeY - kTexSheetTubeH) / kTexSheetH }},
    {{ kTexSheetTubeLeftW, kTexSheetTubeH, kModelZ }, { (kTexSheetTubeLeftX + kTexSheetTubeLeftW) / kTexSheetW, (kTexSheetTubeY - kTexSheetTubeH) / kTexSheetH }}
};

static const GLfloat kTexSheetTubeRightX = 21;
static const GLfloat kTexSheetTubeRightW = 20;
static const VertexData_t tubeRightVertexData[] = {
    {{                0.0f,           0.0f, kModelZ }, {                         kTexSheetTubeRightX / kTexSheetW,                    kTexSheetTubeY / kTexSheetH }},
    {{ kTexSheetTubeRightW,           0.0f, kModelZ }, { (kTexSheetTubeRightX + kTexSheetTubeRightW) / kTexSheetW,                    kTexSheetTubeY / kTexSheetH }},
    {{                0.0f, kTexSheetTubeH, kModelZ }, {                         kTexSheetTubeRightX / kTexSheetW, (kTexSheetTubeY - kTexSheetTubeH) / kTexSheetH }},
    {{ kTexSheetTubeRightW, kTexSheetTubeH, kModelZ }, { (kTexSheetTubeRightX + kTexSheetTubeRightW) / kTexSheetW, (kTexSheetTubeY - kTexSheetTubeH) / kTexSheetH }}
};

static const GLfloat kTexSheetTubeLiquidX = 43;
static const GLfloat kTexSheetTubeLiquidW = 1;
static const VertexData_t tubeLiquidVertexData[] = {
    {{                 0.0f,           0.0f, kModelZ }, {                          kTexSheetTubeLiquidX / kTexSheetW, kTexSheetTubeY / kTexSheetH }},
    {{ kTexSheetTubeLiquidW,           0.0f, kModelZ }, { (kTexSheetTubeLiquidX + kTexSheetTubeLiquidW) / kTexSheetW, kTexSheetTubeY / kTexSheetH }},
    {{                 0.0f, kTexSheetTubeH, kModelZ }, {                          kTexSheetTubeLiquidX / kTexSheetW, (kTexSheetTubeY - kTexSheetTubeH) / kTexSheetH }},
    {{ kTexSheetTubeLiquidW, kTexSheetTubeH, kModelZ }, { (kTexSheetTubeLiquidX + kTexSheetTubeLiquidW) / kTexSheetW, (kTexSheetTubeY - kTexSheetTubeH) / kTexSheetH }}
};

static const GLfloat kTexSheetTubeLiquidTopX = 44;
static const GLfloat kTexSheetTubeLiquidTopW = 38;
static const VertexData_t tubeLiquidTopVertexData[] = {
    {{                    0.0f,           0.0f, kModelZ }, {                             kTexSheetTubeLiquidTopX / kTexSheetW, kTexSheetTubeY / kTexSheetH }},
    {{ kTexSheetTubeLiquidTopW,           0.0f, kModelZ }, { (kTexSheetTubeLiquidTopX + kTexSheetTubeLiquidTopW) / kTexSheetW, kTexSheetTubeY / kTexSheetH }},
    {{                    0.0f, kTexSheetTubeH, kModelZ }, {                             kTexSheetTubeLiquidTopX / kTexSheetW, (kTexSheetTubeY - kTexSheetTubeH) / kTexSheetH }},
    {{ kTexSheetTubeLiquidTopW, kTexSheetTubeH, kModelZ }, { (kTexSheetTubeLiquidTopX + kTexSheetTubeLiquidTopW) / kTexSheetW, (kTexSheetTubeY - kTexSheetTubeH) / kTexSheetH }}
};

static const GLfloat kTexSheetTubeGlassX = 42;
static const GLfloat kTexSheetTubeGlassW = 1;
static const VertexData_t tubeGlassVertexData[] = {
    {{                0.0f,           0.0f, kModelZ }, {                         kTexSheetTubeGlassX / kTexSheetW, kTexSheetTubeY / kTexSheetH }},
    {{ kTexSheetTubeGlassW,           0.0f, kModelZ }, { (kTexSheetTubeGlassX + kTexSheetTubeGlassW) / kTexSheetW, kTexSheetTubeY / kTexSheetH }},
    {{                0.0f, kTexSheetTubeH, kModelZ }, {                         kTexSheetTubeGlassX / kTexSheetW, (kTexSheetTubeY - kTexSheetTubeH) / kTexSheetH }},
    {{ kTexSheetTubeGlassW, kTexSheetTubeH, kModelZ }, { (kTexSheetTubeGlassX + kTexSheetTubeGlassW) / kTexSheetW, (kTexSheetTubeY - kTexSheetTubeH) / kTexSheetH }}
};

#pragma mark - public

- (id)initWithGLKView:(GLKView*)aGLView fromValue:(float)from toValue:(float)to
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
        
        self.drawableLiquidMinX = kTexSheetTubeLeftX + kTexSheetTubeLeftW;
        self.drawableLiquidMaxX = self.projectionRight - kTexSheetTubeRightW - kTexSheetTubeLiquidTopW;
        self.drawableLiquidWidth = self.drawableLiquidMaxX - self.drawableLiquidMinX;
        
        self.drawableGlassX = kTexSheetTubeLeftW;
        self.drawableGlassWidth = self.projectionRight - (kTexSheetTubeLeftW + kTexSheetTubeRightW);
        
        self.fromValue = from;
        self.toValue = to;
        
        [self setupGL];
    }
    return self;
}

- (void)setValue:(CGFloat)value
{
    assert(value >= self.fromValue && value <= self.toValue);
    self.currentPercentage = [AMUtils valuePercentFrom:self.fromValue to:self.toValue value:value];
    
    GLBubbleBounds_t bounds = self.bubbleEffect.bounds;
    bounds.maxRightPosition = [AMUtils percentageValueFromMax:self.drawableLiquidMaxX min:self.drawableLiquidMinX percent:self.currentPercentage];
    bounds.maxRightPosition += kTexSheetTubeLiquidTopW;
    self.bubbleEffect.bounds = bounds;
}

#pragma mark - private

- (void)setupGL
{
    EAGLContext *glContext = [GLCommon context];
    if (!glContext)
    {
        AMWarn(@"%s: EAGLContext == nil", __PRETTY_FUNCTION__);
        return;
    }
    self.glView.context = glContext;
    [EAGLContext setCurrentContext:glContext];
    
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0.0f, self.drawableWidth, 0.0f, self.drawableHeight, 1.0f, 10.0f);
    self.effect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0f);
    
    GLBubbleBounds_t bubbleBounds = {
        .maxLeftPosition = self.drawableLiquidMinX - 5, // Subtract in order to start rendering behind the tube side
        .maxRightPosition = self.drawableLiquidMaxX + kTexSheetTubeLiquidTopW,
        .maxTopPosition = kTexSheetTubeH - 23,  // Subtracted tube glow area from top
        .maxBottomPosition = 0 + 22             // Added tube glow area to bottom
    };
    self.bubbleEffect = [[GLBubbleEffect alloc] initWithBounds:bubbleBounds];
    
    self.tubeTexture = [self setupTexture:@"TubeTexture.png"];
    
    [self setupVBOs];
}

- (void)setupVBOs
{
    self.glVertexArrayTubeLeft = [self setupVertexArray];
    self.glBufferTubeLeft = [self setupBufferData:tubeLeftVertexData size:sizeof(tubeLeftVertexData)];
    
    self.glVertexArrayTubeRight = [self setupVertexArray];
    self.glBufferTubeRight = [self setupBufferData:tubeRightVertexData size:sizeof(tubeRightVertexData)];
    
    self.glVertexArrayTubeLiquid = [self setupVertexArray];
    self.glBufferTubeLiquid = [self setupBufferData:tubeLiquidVertexData size:sizeof(tubeLiquidVertexData)];
    
    self.glVertexArrayTubeLiquidTop = [self setupVertexArray];
    self.glBufferTubeLiquidTop = [self setupBufferData:tubeLiquidTopVertexData size:sizeof(tubeLiquidTopVertexData)];
    
    self.glVertexArrayTubeGlass = [self setupVertexArray];
    self.glBufferTubeGlass = [self setupBufferData:tubeGlassVertexData size:sizeof(tubeGlassVertexData)];
}

- (void)tearDownGL
{
    // TODO: dealloc all GL resources.
}

- (GLuint)setupTexture:(NSString*)filename
{
    CGImageRef texImage = [UIImage imageNamed:filename].CGImage;
    if (!texImage)
    {
        AMWarn(@"%s: loading texture has failed: %@.", __PRETTY_FUNCTION__, filename);
        return -1;
    }
    
    size_t width = CGImageGetWidth(texImage);
    size_t height = CGImageGetHeight(texImage);
    
    GLubyte *texData = (GLubyte*) calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef texContext = CGBitmapContextCreate(texData, width, height, 8, width * 4, CGImageGetColorSpace(texImage), kCGImageAlphaPremultipliedLast);
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
        
        GLKVector3 position = GLKVector3Make(x, 0.0f, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKMatrix4 scale = GLKMatrix4MakeScale(1.0f, 1.0f, 1.0f);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.texture2d0.enabled = GL_TRUE;
        self.effect.texture2d0.name = self.tubeTexture;
        self.effect.texture2d0.target = GLKTextureTarget2D;
        self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        [self.effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(tubeLeftVertexData) / sizeof(VertexData_t));
        GL_CHECK_ERROR();
        
        self.effect.transform.modelviewMatrix = save;
    }
    
    /*
     * Right side
     */
    {
        GLKMatrix4 save = self.effect.transform.modelviewMatrix;
        
        GLfloat x = self.projectionRight - kTexSheetTubeRightW;
        
        glBindVertexArrayOES(self.glVertexArrayTubeRight);
        
        GLKVector3 position = GLKVector3Make(x, 0.0f, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKMatrix4 scale = GLKMatrix4MakeScale(1.0f, 1.0f, 1.0f);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.texture2d0.enabled = GL_TRUE;
        self.effect.texture2d0.name = self.tubeTexture;
        self.effect.texture2d0.target = GLKTextureTarget2D;
        self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        [self.effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(tubeLeftVertexData) / sizeof(VertexData_t));
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
        
        GLKVector3 position = GLKVector3Make(x, 0.0f, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKMatrix4 scale = GLKMatrix4MakeScale(scaleX, 1.0f, 1.0f);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.texture2d0.enabled = GL_TRUE;
        self.effect.texture2d0.name = self.tubeTexture;
        self.effect.texture2d0.target = GLKTextureTarget2D;
        self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        [self.effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(tubeLeftVertexData) / sizeof(VertexData_t));
        GL_CHECK_ERROR();
        
        self.effect.transform.modelviewMatrix = save;
    }
    
    /*
     * Liquid top
     */
    {
        GLKMatrix4 save = self.effect.transform.modelviewMatrix;
        
        GLfloat x = [AMUtils percentageValueFromMax:self.drawableLiquidMaxX min:self.drawableLiquidMinX percent:self.currentPercentage] + kTexSheetTubeLeftW;
        
        glBindVertexArrayOES(self.glVertexArrayTubeLiquidTop);
        
        GLKVector3 position = GLKVector3Make(x, 0.0f, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKMatrix4 scale = GLKMatrix4MakeScale(1.0f, 1.0f, 1.0f);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.texture2d0.enabled = GL_TRUE;
        self.effect.texture2d0.name = self.tubeTexture;
        self.effect.texture2d0.target = GLKTextureTarget2D;
        self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        [self.effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(tubeLeftVertexData) / sizeof(VertexData_t));
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
    
    GLKVector3 position = GLKVector3Make(x, 0.0f, kModelZ);
    GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
    GLKMatrix4 scale = GLKMatrix4MakeScale(scaleX, 1.0f, 1.0f);
    GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
    
    self.effect.transform.modelviewMatrix = modelMatrix;
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = self.tubeTexture;
    self.effect.texture2d0.target = GLKTextureTarget2D;
    self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(tubeLeftVertexData) / sizeof(VertexData_t));
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
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self renderLiquid];
    
    self.bubbleEffect.mvpMatrix = GLKMatrix4Multiply(self.effect.transform.projectionMatrix, self.effect.transform.modelviewMatrix);
    [self.bubbleEffect render];

    [self renderTubeSides];
    [self renderGlass];
}

@end

