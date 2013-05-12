//
//  GLLineGraph.m
//  ActivityMonitor++
//
//  Created by st on 09/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMLog.h"
#import "AMUtils.h"
#import "GLLineGraph.h"

#if DEBUG
#define GL_CHECK_ERROR()                        \
    do {                                        \
        GLenum error = glGetError();            \
        if (error != GL_NO_ERROR)               \
        {                                       \
            AMWarn("%s: GL Error: 0x%x",        \
                   __PRETTY_FUNCTION__, error); \
        }                                       \
    }                                           \
    while (0)
#else
#define CHECK_GL_ERROR()
#endif

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} VertexData_t;

@interface GLLineGraph() <GLKViewDelegate>
@property (assign, nonatomic) BOOL          initialized;

@property (assign, nonatomic) NSUInteger    dataLineCount;
@property (assign, nonatomic) float         fromValue;
@property (assign, nonatomic) float         toValue;
@property (strong, nonatomic) NSArray       *legendStrings; // NSString* array

@property (strong, nonatomic) GLKView       *glView;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (assign, nonatomic) GLfloat       aspectRatio;

/* Data line
 * TODO: this will need to be dynamic based on data line count */
@property (assign, nonatomic) GLuint        glVertexArrayDataLine;
@property (assign, nonatomic) GLuint        glBufferDataLine;
@property (assign, nonatomic) GLuint        dataLineDataValidSize;  /* Valid buffer index count */
@property (assign, nonatomic) GLuint        dataLineDataCurrIdx;    /* Current index to be written new values to */
@property (assign, nonatomic) GLfloat       dataLineDataNextX;      /* Each added data element gets it's own unique X position */
/* dataLineData is a circular array and so in order to utilize GL_LINE_STRIP without creating an
 * impression of GL_LINE_LOOP we declare 2 matrixes.
 * The first translates 0 - dataLineDataCurrIdx verticies.
 * The second translates dataLineDataCurrIdx+1 - dataLineDataValidSize-1 verticies. */
@property (assign, nonatomic) GLKVector3    dataLinePosition1;
@property (assign, nonatomic) GLKVector3    dataLinePosition2;

/* Reference lines */
@property (assign, nonatomic) GLuint        glVertexArrayReferenceLine;
@property (assign, nonatomic) GLuint        glBufferReferenceLine;

/* Legends */
@property (assign, nonatomic) GLuint        glVertexArrayLegends;
@property (assign, nonatomic) GLuint        glBufferLegends;

/* Graph boundaries determined based on projection and viewport. */
@property (assign, nonatomic) GLfloat       graphBottom;
@property (assign, nonatomic) GLfloat       graphTop;
@property (assign, nonatomic) GLfloat       graphRight;
@property (assign, nonatomic) GLfloat       graphLeft;

- (void)setupGL;
- (void)tearDownGL;

- (void)renderDataCurve;
- (void)renderReferenceLines;
- (void)renderLegends;

- (UIImage*)imageWithText:(NSString*)text
                 fontName:(NSString*)fontName
                    color:(UIColor*)color
                    width:(float)width
                   height:(float)height
               rightAlign:(BOOL)rightAlign;
@end

@implementation GLLineGraph
@synthesize initialized;

@synthesize dataLineCount=_dataLineCount;
@synthesize fromValue=_fromValue;
@synthesize toValue=_toValue;
@synthesize legendStrings=_legendStrings;

@synthesize glView=_glView;
@synthesize effect=_effect;
@synthesize aspectRatio=_aspectRatio;

@synthesize glVertexArrayDataLine=_glVertexArrayDataLine;
@synthesize glBufferDataLine=_glBufferDataLine;
@synthesize dataLineDataValidSize=_dataLineDataValidSize;
@synthesize dataLineDataCurrIdx=_dataLineDataCurrIdx;
@synthesize dataLineDataNextX=_dataLineDataNextX;
@synthesize dataLinePosition1=_dataLinePosition1;
@synthesize dataLinePosition2=_dataLinePosition2;

@synthesize glVertexArrayReferenceLine=_glVertexArrayReferenceLine;
@synthesize glBufferReferenceLine=_glBufferReferenceLine;

@synthesize glVertexArrayLegends=_glVertexArrayLegends;
@synthesize glBufferLegends=_glBufferLegends;

static const GLfloat kProjectionLeft    = -10.0f;
static const GLfloat kProjectionRight   =  10.0f;
static const GLfloat kProjectionBottom  = -5.0f;
static const GLfloat kProjectionTop     =  5.0f;
static const GLfloat kProjectionNear    =  1.0f;
static const GLfloat kProjectionFar     =  10.0f;

static const GLfloat kModelZ            = -2.0f;

// TODO: we should make required buffer size calculate dynamically based on each line
// segment width and total available screen/projection area.
// WARNING: THE VALUE MUST BE EVEN!
static const GLuint kMaxDataLineData    = 1500;
static VertexData_t dataLineData[kMaxDataLineData];
static const GLfloat kDataLineShiftSize = 0.05f;

static const VertexData_t referenceLineData[] = {
    {{ 0.0f, 0.0f, 0.0f }},
    {{ 1.0f, 0.0f, 0.0f }}
};

static const VertexData_t legendData[] = {
    {{ 0.0f, 0.0f, 0.0f }, { 0.0f, 0.0f }},
    {{ 1.0f, 0.0f, 0.0f }, { 1.0f, 0.0f }},
    {{ 0.0f, 1.0f, 0.0f }, { 0.0f, 1.0f }},
    {{ 1.0f, 0.0f, 0.0f }, { 1.0f, 0.0f }},
    {{ 1.0f, 1.0f, 0.0f }, { 1.0f, 1.0f }},
    {{ 0.0f, 1.0f, 0.0f }, { 0.0f, 1.0f }}
};

#pragma mark - public

- (id)initWithGLKView:(GLKView*)aGLView
        dataLineCount:(NSUInteger)count
            fromValue:(float)from
              toValue:(float)to
              legends:(NSArray*)legends
             delegate:(id)aDelegate
{
    if (self = [super init])
    {
        self.delegate = aDelegate;
        
        self.dataLineCount = count;
        self.fromValue = from;
        self.toValue = to;
        self.legendStrings = legends;
        
        self.glView = aGLView;
        self.view = self.glView;
                
        self.graphTop = [AMUtils percentageValueFromMax:kProjectionTop min:kProjectionBottom percent:90];
        self.graphBottom = [AMUtils percentageValueFromMax:kProjectionTop min:kProjectionBottom percent:20];
        self.graphLeft = [AMUtils percentageValueFromMax:kProjectionRight min:kProjectionLeft percent:5];
        self.graphRight = [AMUtils percentageValueFromMax:kProjectionRight min:kProjectionLeft percent:95];
        
        self.dataLineDataValidSize = 0;
        self.dataLineDataCurrIdx = 0;
        
        [self setupGL];
    }
    return self;
}

- (void)dealloc
{
    [self tearDownGL];
}

- (void)appendDataValue:(float)value
{
    GLfloat vX = self.dataLineDataNextX++;
    GLfloat vY = [AMUtils percentageValueFromMax:self.graphTop min:self.graphBottom percent:value];
    BOOL bufferSizeIncreased = NO;
    
    if (self.dataLineDataValidSize == 0)
    {
        dataLineData[0].positionCoords.x = vX;
        dataLineData[0].positionCoords.y = vY;
        dataLineData[0].positionCoords.z = kModelZ;
        
        self.dataLineDataCurrIdx++;
        self.dataLineDataValidSize++;
        bufferSizeIncreased = YES;
    }
    else
    {        
        dataLineData[self.dataLineDataCurrIdx].positionCoords.x = vX;
        dataLineData[self.dataLineDataCurrIdx].positionCoords.y = vY;
        dataLineData[self.dataLineDataCurrIdx].positionCoords.z = kModelZ;
        
        self.dataLineDataCurrIdx++;
        
        if (self.dataLineDataValidSize < kMaxDataLineData)
        {
            self.dataLineDataValidSize++;
            bufferSizeIncreased = YES;
        }
    }
    
    // Check if we need to wrap the circular data line buffer.
    if (self.dataLineDataCurrIdx >= kMaxDataLineData)
    {
        // First we move the first data position vector to the second in order to keep the old values moving.
        // It is assumed that the old values which dataLinePosition2 was moving before this assignment
        // are already offscreen.
        self.dataLinePosition2 = self.dataLinePosition1;
        
        // Then re-init the first data position vector to starting position.
        GLfloat xTranslate = self.graphRight * self.aspectRatio;
        self.dataLinePosition1 = GLKVector3Make(xTranslate, 0.0f, kModelZ);
        
        self.dataLineDataNextX = 0;
        self.dataLineDataCurrIdx = 0;
    }
    else
    {
        // Shift data line translation matrixes.
        GLKVector3 shift = GLKVector3Make(-kDataLineShiftSize, 0.0f, 0.0f);
        self.dataLinePosition1 = GLKVector3Add(self.dataLinePosition1, shift);
        self.dataLinePosition2 = GLKVector3Add(self.dataLinePosition2, shift);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, self.glBufferDataLine);
    
    if (bufferSizeIncreased)
    {
        glBufferData(GL_ARRAY_BUFFER,
                     self.dataLineDataValidSize * sizeof(VertexData_t),
                     dataLineData, GL_DYNAMIC_DRAW);
    }
    else
    {
        glBufferSubData(GL_ARRAY_BUFFER, 0,
                        self.dataLineDataValidSize * sizeof(VertexData_t),
                        dataLineData);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

#pragma mark - private

- (void)setupGL
{
    EAGLContext *glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!glContext)
    {
        AMWarn(@"%s: EAGLContext == nil", __PRETTY_FUNCTION__);
        return;
    }
    
    [self.glView setContext:glContext];
    [EAGLContext setCurrentContext:self.glView.context];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    // Enable for performance reasons as it removes many of the triangles to draw.
    glEnable(GL_CULL_FACE);
    // Enabled by default.
    glDisable(GL_DITHER);
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0f);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
    
    /*
     * Data line VBO.
     */
    {
        glGenVertexArraysOES(1, &_glVertexArrayDataLine);
        glBindVertexArrayOES(self.glVertexArrayDataLine);
        
        glGenBuffers(1, &_glBufferDataLine);
        glBindBuffer(GL_ARRAY_BUFFER, self.glBufferDataLine);
        glBufferData(GL_ARRAY_BUFFER, self.dataLineDataValidSize * sizeof(VertexData_t), dataLineData, GL_DYNAMIC_DRAW);
        
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData_t),
                              NULL + offsetof(VertexData_t, positionCoords));
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        
        GL_CHECK_ERROR();
    }
    
    /*
     * Reference lines VBO.
     */
    {
        glGenVertexArraysOES(1, &_glVertexArrayReferenceLine);
        glBindVertexArrayOES(self.glVertexArrayReferenceLine);
        
        glGenBuffers(1, &_glBufferReferenceLine);
        glBindBuffer(GL_ARRAY_BUFFER, self.glBufferReferenceLine);
        glBufferData(GL_ARRAY_BUFFER, sizeof(referenceLineData), referenceLineData, GL_STATIC_DRAW);
        
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData_t),
                              NULL + offsetof(VertexData_t, positionCoords));
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        
        GL_CHECK_ERROR();
    }
    
    /*
     * Legend lines VBO.
     */
    {
        glGenVertexArraysOES(1, &_glVertexArrayLegends);
        glBindVertexArrayOES(self.glVertexArrayLegends);
        
        glGenBuffers(1, &_glBufferLegends);
        glBindBuffer(GL_ARRAY_BUFFER, self.glBufferLegends);
        glBufferData(GL_ARRAY_BUFFER, sizeof(legendData), legendData, GL_STATIC_DRAW);
        
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                              sizeof(VertexData_t), NULL + offsetof(VertexData_t, positionCoords));
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        GL_CHECK_ERROR();
    }
}

- (void)tearDownGL
{
    glDeleteBuffers(1, &_glBufferDataLine);
    glDeleteVertexArraysOES(1, &_glVertexArrayDataLine);
    glDeleteBuffers(1, &_glBufferReferenceLine);
    glDeleteVertexArraysOES(1, &_glVertexArrayReferenceLine);
    glDeleteBuffers(1, &_glBufferLegends);
    glDeleteVertexArraysOES(1, &_glVertexArrayLegends);
    self.effect = nil;
    
    GL_CHECK_ERROR();
}

- (void)renderDataCurve
{
    if (self.dataLineDataValidSize == 0)
    {
        // No verticies to draw.
        return;
    }
    
    /*
     * Render the first batch starting from 0 to self.dataLineDataCurrIdx.
     */
    {
        glBindVertexArrayOES(self.glVertexArrayDataLine);
        
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKVector3 position = self.dataLinePosition1;
        GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(rotation.x);
        GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(rotation.y);
        GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(rotation.z);
        GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(kDataLineShiftSize, 1.0f, 1.0f);
        GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
        
        GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translateMatrix,
                                                    GLKMatrix4Multiply(scaleMatrix,
                                                                       GLKMatrix4Multiply(zRotationMatrix,
                                                                                          GLKMatrix4Multiply(yRotationMatrix,
                                                                                                             xRotationMatrix))));
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(1.0f, 1.0f, 0.0f, 1.0f);
        [self.effect prepareToDraw];
        
        glLineWidth(3.0f);
        glDrawArrays(GL_LINE_STRIP, 0, self.dataLineDataCurrIdx);
        
        GL_CHECK_ERROR();
    }
    
    /*
     * Render the second batch starting from self.dataLineDataCurrIdx+1 to the end.
     */
    if (self.dataLineDataValidSize > self.dataLineDataCurrIdx)
    {
        glBindVertexArrayOES(self.glVertexArrayDataLine);
        
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKVector3 position = self.dataLinePosition2;
        GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(rotation.x);
        GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(rotation.y);
        GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(rotation.z);
        GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(kDataLineShiftSize, 1.0f, 1.0f);
        GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
        
        GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translateMatrix,
                                                    GLKMatrix4Multiply(scaleMatrix,
                                                                       GLKMatrix4Multiply(zRotationMatrix,
                                                                                          GLKMatrix4Multiply(yRotationMatrix,
                                                                                                             xRotationMatrix))));
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(1.0f, 1.0f, 0.0f, 1.0f);
        [self.effect prepareToDraw];
        
        glLineWidth(3.0f);
        glDrawArrays(GL_LINE_STRIP, self.dataLineDataCurrIdx, self.dataLineDataValidSize - self.dataLineDataCurrIdx);
        
        GL_CHECK_ERROR();
    }
}

- (void)renderReferenceLines
{
    GLfloat x = self.graphLeft * self.aspectRatio;
    GLfloat xScale = (self.graphRight - self.graphLeft) * self.aspectRatio;
    
    /*
     * Top reference line.
     */
    {
        glBindVertexArrayOES(self.glVertexArrayReferenceLine);
        
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKVector3 position = GLKVector3Make(x, self.graphTop, kModelZ);
        GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(rotation.x);
        GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(rotation.y);
        GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(rotation.z);
        GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(xScale, 1.0f, 1.0f);
        GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
        
        GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translateMatrix,
                                                    GLKMatrix4Multiply(scaleMatrix,
                                                                       GLKMatrix4Multiply(zRotationMatrix,
                                                                                          GLKMatrix4Multiply(yRotationMatrix,
                                                                                                             xRotationMatrix))));
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(0.25f, 0.25f, 0.25f, 1.0f);
        [self.effect prepareToDraw];
        
        glLineWidth(1.0f);
        glDrawArrays(GL_LINES, 0, sizeof(referenceLineData) / sizeof(VertexData_t));
        
        GL_CHECK_ERROR();
    }
    
    /*
     * Mid reference line.
     */
    {
        GLfloat y = [AMUtils percentageValueFromMax:self.graphTop min:self.graphBottom percent:50];
        
        glBindVertexArrayOES(self.glVertexArrayReferenceLine);
        
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKVector3 position = GLKVector3Make(x, y, kModelZ);
        GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(rotation.x);
        GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(rotation.y);
        GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(rotation.z);
        GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(xScale, 1.0f, 1.0f);
        GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
        
        GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translateMatrix,
                                                    GLKMatrix4Multiply(scaleMatrix,
                                                                       GLKMatrix4Multiply(zRotationMatrix,
                                                                                          GLKMatrix4Multiply(yRotationMatrix,
                                                                                                             xRotationMatrix))));
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(0.25f, 0.25f, 0.25f, 1.0f);
        [self.effect prepareToDraw];
        
        glLineWidth(1.0f);
        glDrawArrays(GL_LINES, 0, sizeof(referenceLineData) / sizeof(VertexData_t));
        
        GL_CHECK_ERROR();
    }
    
    /*
     * Bottom reference line.
     */
    {
        glBindVertexArrayOES(self.glVertexArrayReferenceLine);
        
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKVector3 position = GLKVector3Make(x, self.graphBottom, kModelZ);
        GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(rotation.x);
        GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(rotation.y);
        GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(rotation.z);
        GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(xScale, 1.0f, 1.0f);
        GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
        
        GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translateMatrix,
                                                    GLKMatrix4Multiply(scaleMatrix,
                                                                       GLKMatrix4Multiply(zRotationMatrix,
                                                                                          GLKMatrix4Multiply(yRotationMatrix,
                                                                                                             xRotationMatrix))));
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(0.25f, 0.25f, 0.25f, 1.0f);
        [self.effect prepareToDraw];
        
        glLineWidth(1.0f);
        glDrawArrays(GL_LINES, 0, sizeof(referenceLineData) / sizeof(VertexData_t));
        
        GL_CHECK_ERROR();
    }
}

- (void)renderLegends
{
    /*
    glBindVertexArrayOES(self.legendsGlVAO);
    [self.legendsEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sizeof(legendsData) / sizeof(LegendVertexData_t));
    
    GL_CHECK_ERROR();
     */
}

- (UIImage*)imageWithText:(NSString*)text
                 fontName:(NSString*)fontName
                    color:(UIColor*)color
                    width:(float)width
                   height:(float)height
               rightAlign:(BOOL)rightAlign
{
    // TODO: finish implementation.
    return nil;
}

#pragma mark - private override

-(void)update
{
    if (!initialized)
    {
        self.initialized = YES;
        
        self.aspectRatio = fabsf((GLfloat)self.view.bounds.size.width / (GLfloat)self.view.bounds.size.height);
        
        GLfloat xTranslate = self.graphRight * self.aspectRatio;
        self.dataLinePosition1 = GLKVector3Make(xTranslate, 0.0f, kModelZ);
        self.dataLinePosition2 = GLKVector3Make(xTranslate, 0.0f, kModelZ);
        
        [self.delegate graphFinishedInitializing];
    }
    
    self.effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(kProjectionLeft * self.aspectRatio,
                                                                 kProjectionRight * self.aspectRatio,
                                                                 kProjectionBottom,
                                                                 kProjectionTop,
                                                                 kProjectionNear,
                                                                 kProjectionFar);
}

#pragma mark - GLKView delegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self renderReferenceLines];
    [self renderLegends];
    [self renderDataCurve];
}

@end
