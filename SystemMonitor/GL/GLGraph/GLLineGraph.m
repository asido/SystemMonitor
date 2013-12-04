//
//  GLLineGraph.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <OpenGLES/EAGLDrawable.h>
#import "AMLogger.h"
#import "AMUtils.h"
#import "CPULoad.h"
#import "GLDataLine.h"
#import "GLCommon.h"
#import "GLLineGraph.h"

@interface GLLineGraph() <GLKViewDelegate>
@property (nonatomic, assign) BOOL          initialized;

@property (nonatomic, assign) NSUInteger    dataLineCount;
@property (nonatomic, assign) double        fromValue;
@property (nonatomic, assign) double        toValue;
@property (nonatomic, copy)   NSString      *legend;

@property (nonatomic, weak)   GLKView       *glView;
@property (nonatomic, assign) GLfloat       aspectRatio;
@property (nonatomic, assign) GLfloat       drawableWidth;
@property (nonatomic, assign) GLfloat       drawableHeight;

/* Data line */
@property (nonatomic, copy) NSArray       *dataLines;
@property (nonatomic, copy) NSArray       *queuedDataLineData;

/* Reference lines */
@property (nonatomic, assign) GLuint        glVertexArrayReferenceLine;
@property (nonatomic, assign) GLuint        glBufferReferenceLine;

/* Legends */
@property (nonatomic, assign) GLuint        glVertexArrayLegends;
@property (nonatomic, assign) GLuint        glBufferLegends;
@property (nonatomic, strong) GLKTextureInfo *topGraphLegendTexture;

@property (nonatomic, copy)   NSString      *lineLegendPostfix;
@property (nonatomic, assign) NSUInteger    lineLegendDesiredFraction;

- (void)lateInit;

- (void)setupGL;
- (void)setupVBOs;
- (void)tearDownGL;

- (void)renderDataCurve;
- (void)renderReferenceLines;
- (void)renderLegends;
- (void)renderTopLegend;
- (void)renderDataLineLegends;
@end

@implementation GLLineGraph
@synthesize delegate;
@synthesize effect;
@synthesize graphBottom;
@synthesize graphTop;
@synthesize graphRight;
@synthesize graphLeft;

@synthesize useClosestMetrics;

@synthesize initialized;

@synthesize dataLineCount=_dataLineCount;
@synthesize fromValue=_fromValue;
@synthesize toValue=_toValue;
@synthesize legend=_legend;

@synthesize glView=_glView;
@synthesize aspectRatio;
@synthesize drawableWidth;
@synthesize drawableHeight;

@synthesize dataLines=_dataLines;
@synthesize queuedDataLineData=_queuedDataLineData;

@synthesize glVertexArrayReferenceLine=_glVertexArrayReferenceLine;
@synthesize glBufferReferenceLine=_glBufferReferenceLine;

@synthesize glVertexArrayLegends=_glVertexArrayLegends;
@synthesize glBufferLegends=_glBufferLegends;
@synthesize topGraphLegendTexture=_legendsTexture;

@synthesize lineLegendPostfix;
@synthesize lineLegendDesiredFraction;

static const GLfloat kProjectionLeft        = -10.0;
static const GLfloat kProjectionRight       =  10.0;
static const GLfloat kProjectionBottom      = -5.0;
static const GLfloat kProjectionTop         =  5.0;
static const GLfloat kProjectionNear        =  1.0;
static const GLfloat kProjectionFar         =  10.0;

static const GLfloat kGraphGapPercentLeft   = 5;
static const GLfloat kGraphGapPercentTop    = 10;
static const GLfloat kGraphGapPercentRight  = 5;
static const GLfloat kGraphGapPercentBottom = 20;

static const VertexData_t referenceLineData[] = {
    {{ 0.0, 0.0, 0.0 }},
    {{ 1.0, 0.0, 0.0 }}
};

static const VertexData_t legendData[] = {
    {{ 0.0, 0.0, 0.0 }, { 0.0, 0.0 }},
    {{ 1.0, 0.0, 0.0 }, { 1.0, 0.0 }},
    {{ 0.0, 1.0, 0.0 }, { 0.0, 1.0 }},
    {{ 1.0, 0.0, 0.0 }, { 1.0, 0.0 }},
    {{ 1.0, 1.0, 0.0 }, { 1.0, 1.0 }},
    {{ 0.0, 1.0, 0.0 }, { 0.0, 1.0 }}
};

#pragma mark - public

- (id)initWithGLKView:(GLKView*)aGLView
        dataLineCount:(NSUInteger)count
            fromValue:(double)from
              toValue:(double)to
            topLegend:(NSString*)aLegend
{
    if (self = [super init])
    {
        self.dataLineCount = count;
        self.fromValue = from;
        self.toValue = to;
        self.legend = aLegend;
                
        self.glView = aGLView;
        self.view = self.glView;
        
        self.glView.drawableMultisample = GLKViewDrawableMultisample4X;
        
        self.drawableWidth = self.glView.contentScaleFactor * self.glView.bounds.size.width;
        self.drawableHeight = self.glView.contentScaleFactor * self.glView.bounds.size.height;
        self.aspectRatio = fabsf(self.drawableWidth / self.drawableHeight);
                                
        self.graphTop = [AMUtils percentageValueFromMax:kProjectionTop min:kProjectionBottom percent:100-kGraphGapPercentTop];
        self.graphBottom = [AMUtils percentageValueFromMax:kProjectionTop min:kProjectionBottom percent:kGraphGapPercentBottom];
        self.graphLeft = [AMUtils percentageValueFromMax:kProjectionRight min:kProjectionLeft percent:kGraphGapPercentLeft] * self.aspectRatio;
        self.graphRight = [AMUtils percentageValueFromMax:kProjectionRight min:kProjectionLeft percent:100-kGraphGapPercentRight] * self.aspectRatio;
        
        self.lineLegendPostfix = @"";
        self.lineLegendDesiredFraction = 0;
        
        [self setupGL];
        
        // Init data lines.
        NSArray *lineColors = @[ [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0],
                                 [UIColor colorWithRed:171.0/255.0 green:201.0/255.0 blue:255.0/255.0 alpha:1.0] ];
        NSMutableArray *lines = [[NSMutableArray alloc] initWithCapacity:self.dataLineCount];
        for (NSUInteger i = 0; i < self.dataLineCount; ++i)
        {
            GLDataLine *dataLine = [[GLDataLine alloc] initWithColor:lineColors[i] forGraph:self];
            [lines addObject:dataLine];
        }
        self.dataLines = [[NSArray alloc] initWithArray:lines];
    }
    return self;
}

- (void)dealloc
{
    [self tearDownGL];
}

- (void)setDataLineLegendPostfix:(NSString*)postfix
{
    self.lineLegendPostfix = postfix;
}

- (void)setDataLineLegendFraction:(NSUInteger)desiredFraction
{
    self.lineLegendDesiredFraction = desiredFraction;
}

- (void)setDataLineLegendIcon:(UIImage*)image forLineIndex:(NSUInteger)lineIndex
{
    AMAssert(lineIndex < [[self dataLines] count], @"Line index is out of range: %ld. Number of data lines: %ld", (long)lineIndex, (long)[[self dataLines] count]);
    [self.dataLines[lineIndex] setDataLineLegendIcon:image];
}

- (void)addDataValue:(NSArray*)data
{
    assert(data.count == self.dataLines.count);
    AMAssert([data count] == [[self dataLines] count], @"Data count (%ld) doesn't match line count (%ld).", (long)[data count], (long)[[self dataLines] count]);
    
    for (NSUInteger i = 0; i < data.count; ++i)
    {
        NSNumber *number = data[i];
        GLfloat value = [number floatValue];
        GLfloat percent = [AMUtils valuePercentFrom:self.fromValue to:self.toValue value:value];
        GLDataLine *dataLine = self.dataLines[i];
        [dataLine addLineDataValue:percent];
        
        NSString *dataLineLegend = @"";
        if (self.useClosestMetrics)
        {
            dataLineLegend = [NSString stringWithFormat:@"%@%@", [AMUtils toNearestMetric:value desiredFraction:self.lineLegendDesiredFraction], self.lineLegendPostfix];
        }
        else
        {
            NSString *formatter = [NSString stringWithFormat:@"%%0.%ldf%%@", (long)self.lineLegendDesiredFraction];
            dataLineLegend = [NSString stringWithFormat:formatter, value, self.lineLegendPostfix];
        }
        [dataLine setLineDataLegendText:dataLineLegend];
    }
}

- (void)setGraphLegend:(NSString*)aLegend
{
    self.legend = aLegend;
    
    if (self.topGraphLegendTexture)
    {
        GLuint texture = self.topGraphLegendTexture.name;
        glDeleteTextures(1, &texture);
    }
    
    UIImage *img = [GLCommon imageWithText:self.legend font:[UIFont fontWithName:@"Verdana" size:22.0] color:[UIColor lightTextColor]];
    self.topGraphLegendTexture = [GLKTextureLoader textureWithCGImage:img.CGImage options:nil error:NULL];
}

- (void)setZoomLevel:(GLfloat)value
{
    for (GLDataLine *dataLine in self.dataLines)
    {
        [dataLine setDataLineZoom:value];
    }
}

- (void)resetDataArray:(NSArray*)dataArray
{
    if (self.dataLines)
    {
        for (GLDataLine *line in self.dataLines)
        {
            [line resetLineData];
        }
        
        for (NSUInteger i = 0; i < dataArray.count; ++i)
        {
            NSArray *data = dataArray[i];
            [self addDataValue:data];
        }
    }
    else
    {
        self.queuedDataLineData = [NSArray arrayWithArray:dataArray];
    }
}

- (NSUInteger)requiredElementToFillGraph
{
    NSUInteger cnt = 0;
    
    for (GLDataLine *line in self.dataLines)
    {
        cnt = MAX([line maxDataLineElements], cnt);
    }
    
    return cnt;
}

#pragma mark - private

- (void)lateInit
{
    if (self.initialized)
    {
        return;
    }
    
    AMAssert(self.glView.bounds.size.width > 0, @"glView is invisible (0)");
    AMAssert(self.glView.bounds.size.height > 0,  @"glView is invisible (1)");
    
    self.initialized = YES;
    
    self.effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(kProjectionLeft * self.aspectRatio,
                                                                 kProjectionRight * self.aspectRatio,
                                                                 kProjectionBottom,
                                                                 kProjectionTop,
                                                                 kProjectionNear,
                                                                 kProjectionFar);
    if (self.queuedDataLineData)
    {
        [self resetDataArray:self.queuedDataLineData];
        self.queuedDataLineData = nil;
    }
    
    GL_CHECK_ERROR();
}

- (void)setupGL
{
    EAGLContext *glContext = [GLCommon context];
    if (!glContext)
    {
        AMLogWarn(@"EAGLContext == nil");
        return;
    }
    [self.glView setContext:glContext];
    [EAGLContext setCurrentContext:self.glView.context];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -5.0);
    
    [self setGraphLegend:self.legend];
    
    [self setupVBOs];
}

- (void)setupVBOs
{
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
     * Legend VBO.
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
        
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE,
                              sizeof(VertexData_t), NULL + offsetof(VertexData_t, textureCoords));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        
        GL_CHECK_ERROR();
    }
}

- (void)tearDownGL
{
    if (self.topGraphLegendTexture)
    {
        GLuint texture = self.topGraphLegendTexture.name;
        glDeleteTextures(1, &texture);
    }
    
    if (self.glBufferReferenceLine)
    {
        glDeleteBuffers(1, &_glBufferReferenceLine);
    }
    if (self.glBufferLegends)
    {
        glDeleteBuffers(1, &_glBufferLegends);
    }
    
    if (self.glVertexArrayReferenceLine)
    {
        glDeleteVertexArraysOES(1, &_glVertexArrayReferenceLine);
    }
    if (self.glVertexArrayLegends)
    {
        glDeleteVertexArraysOES(1, &_glVertexArrayLegends);
    }
    
    GL_CHECK_ERROR();
}

- (void)renderDataCurve
{    
    for (GLDataLine *line in self.dataLines)
    {
        [line render];
    }
}

- (void)renderReferenceLines
{
    GLfloat x = self.graphLeft;
    GLfloat xScale = self.graphRight - self.graphLeft;
    GLfloat yScale = self.graphTop - self.graphBottom;
    
    /*
     * Top line.
     */
    {
        glBindVertexArrayOES(self.glVertexArrayReferenceLine);
        
        GLKVector3 position = GLKVector3Make(x, self.graphTop, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
        GLKMatrix4 scale = GLKMatrix4MakeScale(xScale, 1.0, 1.0);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(0.25, 0.25, 0.25, 1.0);
        self.effect.texture2d0.enabled = NO;
        [self.effect prepareToDraw];
        
        glLineWidth(1.0);
        glDrawArrays(GL_LINES, 0, sizeof(referenceLineData) / sizeof(VertexData_t));
        
        GL_CHECK_ERROR();
    }
    
    /*
     * Mid line.
     */
    {
        /*
        GLfloat y = [AMUtils percentageValueFromMax:self.graphTop min:self.graphBottom percent:50];
        
        glBindVertexArrayOES(self.glVertexArrayReferenceLine);
        
        GLKVector3 position = GLKVector3Make(x, y, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
        GLKMatrix4 scale = GLKMatrix4MakeScale(xScale, 1.0, 1.0);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(0.25, 0.25, 0.25, 1.0);
        self.effect.texture2d0.enabled = NO;
        [self.effect prepareToDraw];
        
        glLineWidth(1.0);
        glDrawArrays(GL_LINES, 0, sizeof(referenceLineData) / sizeof(VertexData_t));
        */
        GL_CHECK_ERROR();
    }
    
    /*
     * Bottom line.
     */
    {
        glBindVertexArrayOES(self.glVertexArrayReferenceLine);
        
        GLKVector3 position = GLKVector3Make(x, self.graphBottom, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
        GLKMatrix4 scale = GLKMatrix4MakeScale(xScale, 1.0, 1.0);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(0.25, 0.25, 0.25, 1.0);
        self.effect.texture2d0.enabled = NO;
        [self.effect prepareToDraw];
        
        glLineWidth(1.0);
        glDrawArrays(GL_LINES, 0, sizeof(referenceLineData) / sizeof(VertexData_t));
        
        GL_CHECK_ERROR();
    }
    
    /*
     * Right line.
     */
    {
        glBindVertexArrayOES(self.glVertexArrayReferenceLine);
        
        GLfloat xVertical = self.graphRight;
        GLKVector3 position = GLKVector3Make(xVertical, self.graphBottom, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0, 0.0, GLKMathDegreesToRadians(90.0));
        GLKMatrix4 scale = GLKMatrix4MakeScale(1.0, yScale, 1.0);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];

        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
        self.effect.texture2d0.enabled = NO;
        [self.effect prepareToDraw];
        
        glLineWidth(1.0);
        glDrawArrays(GL_LINES, 0, sizeof(referenceLineData) / sizeof(VertexData_t));
        
        GL_CHECK_ERROR();
    }
    
    /*
     * Left line.
     */
    {
        glBindVertexArrayOES(self.glVertexArrayReferenceLine);
        
        GLfloat xVertical = self.graphLeft;
        GLKVector3 position = GLKVector3Make(xVertical, self.graphBottom, kModelZ);
        GLKVector3 rotation = GLKVector3Make(0.0, 0.0, GLKMathDegreesToRadians(90.0));
        GLKMatrix4 scale = GLKMatrix4MakeScale(1.0, yScale, 1.0);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
        self.effect.texture2d0.enabled = NO;
        [self.effect prepareToDraw];
        
        glLineWidth(1.0);
        glDrawArrays(GL_LINES, 0, sizeof(referenceLineData) / sizeof(VertexData_t));
        
        GL_CHECK_ERROR();
    }
}

- (void)renderLegends
{
    [self renderTopLegend];
    [self renderDataLineLegends];
}

- (void)renderTopLegend
{
    GLfloat x = self.graphRight - (self.topGraphLegendTexture.width * kFontScaleMultiplierW) - 2.0;
    GLfloat y = self.graphTop;
    GLfloat xScale = self.topGraphLegendTexture.width * kFontScaleMultiplierW;
    GLfloat yScale = self.topGraphLegendTexture.height * kFontScaleMultiplierH;
    
    glBindVertexArrayOES(self.glVertexArrayLegends);
    
    GLKVector3 position = GLKVector3Make(x, y, kModelZ);
    GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
    GLKMatrix4 scale = GLKMatrix4MakeScale(xScale, yScale, 1.0);
    GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
    
    self.effect.transform.modelviewMatrix = modelMatrix;
    self.effect.useConstantColor = GL_FALSE;
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = self.topGraphLegendTexture.name;
    self.effect.texture2d0.target = GLKTextureTarget2D;
    self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, sizeof(legendData) / sizeof(VertexData_t));
    
    GL_CHECK_ERROR();
}

- (void)renderDataLineLegends
{
    for (NSUInteger i = 0; i < self.dataLines.count; ++i)
    {
        GLDataLine *line = self.dataLines[i];
        [line renderLegend:i];
    }
}


#pragma mark - private override

- (void)viewDidLayoutSubviews
{
    [self lateInit];
}

-(void)update
{
}

#pragma mark - GLKView delegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //glBlendEquation(GL_MAX_EXT);
    
    glViewport(0, 0, (GLsizei)self.glView.drawableWidth, (GLsizei)self.glView.drawableHeight);

    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self renderReferenceLines];
    [self renderDataCurve];
    [self renderLegends];
}

@end
