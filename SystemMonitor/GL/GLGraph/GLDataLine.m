//
//  GLDataLineVBO.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AMUtils.h"
#import "AppDelegate.h"
#import "GLCommon.h"
#import "GLLineGraph.h"
#import "GLDataLine.h"

@interface GLDataLine()
@property (weak, nonatomic) GLLineGraph     *graph;

@property (assign, nonatomic) GLuint        glVertexArrayDataLine;
@property (assign, nonatomic) GLuint        glBufferDataLine;
@property (assign, nonatomic) VertexData_t  *dataLineData;
@property (assign, nonatomic) NSUInteger    dataLineDataSize;
@property (assign, nonatomic) GLuint        dataLineDataValidSize;  /* Valid buffer index count */
@property (assign, nonatomic) GLuint        dataLineDataCurrIdx;    /* Current index to be written new values to */
@property (assign, nonatomic) GLfloat       dataLineDataNextX;      /* Each added data element gets it's own unique X position */
/* dataLineData is a circular array and so in order to utilize GL_LINE_STRIP without creating an
 * impression of GL_LINE_LOOP we declare 2 matrixes.
 * The first translates 0 - dataLineDataCurrIdx verticies.
 * The second translates dataLineDataCurrIdx+1 - dataLineDataValidSize-1 verticies. */
@property (assign, nonatomic) GLKVector3    dataLinePosition1;
@property (assign, nonatomic) GLKVector3    dataLinePosition2;

@property (assign, nonatomic) GLuint        glVertexArrayLineLegend;
@property (assign, nonatomic) GLuint        glBufferLineLegend;
@property (strong, nonatomic) GLKTextureInfo *lineLegendTextTexture;
@property (strong, nonatomic) GLKTextureInfo *lineLegendIconTexture;

@property (assign, nonatomic) GLfloat       zoom;

- (void)setupVBO;
- (void)renderDataLine;
- (void)tearDownGL;
@end

@implementation GLDataLine
@synthesize color;

@synthesize graph;

@synthesize glVertexArrayDataLine=_glVertexArrayDataLine;
@synthesize glBufferDataLine=_glBufferDataLine;
@synthesize dataLineData=_dataLineData;
@synthesize dataLineDataSize=_dataLineDataSize;
@synthesize dataLineDataValidSize=_dataLineDataValidSize;
@synthesize dataLineDataCurrIdx=_dataLineDataCurrIdx;
@synthesize dataLineDataNextX=_dataLineDataNextX;
@synthesize dataLinePosition1=_dataLinePosition1;
@synthesize dataLinePosition2=_dataLinePosition2;

@synthesize glVertexArrayLineLegend=_glVertexArrayLineLegend;
@synthesize glBufferLineLegend=_glBufferLineLegend;
@synthesize lineLegendTextTexture;
@synthesize lineLegendIconTexture;

@synthesize zoom;

static const GLfloat kDataLineShiftSize     = 0.25f;

static const VertexData_t lineLegendData[] = {
    {{ 0.0f, 0.0f, kModelZ }, { 0.0f, 0.0f }},
    {{ 1.0f, 0.0f, kModelZ }, { 1.0f, 0.0f }},
    {{ 0.0f, 1.0f, kModelZ }, { 0.0f, 1.0f }},
    {{ 1.0f, 1.0f, kModelZ }, { 1.0f, 1.0f }}
};

#pragma mark - public

- (id)initWithColor:(UIColor*)aColor forGraph:(GLLineGraph*)aGraph
{
    if (self = [super init])
    {
        self.color = aColor;
        self.graph = aGraph;
        self.dataLineDataValidSize = 0;
        self.dataLineDataCurrIdx = 0;
        
        self.dataLineDataSize = (self.graph.graphRight - self.graph.graphLeft) / kDataLineShiftSize;
        _dataLineData = malloc(self.dataLineDataSize * sizeof(VertexData_t));
        
        self.zoom = 1.0f;
        
        [self resetLineData];
        
        [self setupVBO];
    }
    return self;
}

- (void)dealloc
{
    [self tearDownGL];
    
    free(_dataLineData);
}

- (void)addLineDataValue:(double)value
{
    GLfloat vX = self.dataLineDataNextX++;
    GLfloat vY = [AMUtils percentageValueFromMax:self.graph.graphTop-self.graph.graphBottom min:0.0 percent:value];
    BOOL bufferSizeIncreased = NO;
    
    if (self.dataLineDataValidSize == 0)
    {
        self.dataLineData[0].positionCoords.x = vX;
        self.dataLineData[0].positionCoords.y = vY;
        self.dataLineData[0].positionCoords.z = kModelZ;
        
        self.dataLineDataCurrIdx++;
        self.dataLineDataValidSize++;
        bufferSizeIncreased = YES;
    }
    else
    {
        self.dataLineData[self.dataLineDataCurrIdx].positionCoords.x = vX;
        self.dataLineData[self.dataLineDataCurrIdx].positionCoords.y = vY;
        self.dataLineData[self.dataLineDataCurrIdx].positionCoords.z = kModelZ;
        
        if (self.dataLineDataCurrIdx == 0)
        {
            // Previous data add wrapped the lines.
            // It's best to set last value Y to current Y or otherwise the line might have a gap.
            // It is quite an ugly solution because the previous data will be lost, but I can't
            // figure anything better now.
            self.dataLineData[self.dataLineDataSize-1].positionCoords.y = vY;
        }
        
        self.dataLineDataCurrIdx++;
        
        if (self.dataLineDataValidSize < self.dataLineDataSize)
        {
            self.dataLineDataValidSize++;
            bufferSizeIncreased = YES;
        }
    }
    
    // Check if we need to wrap the circular data line buffer.
    if (self.dataLineDataCurrIdx >= self.dataLineDataSize)
    {
        // First we move the first data position vector to the second in order to keep the old values moving.
        // It is assumed that the old values which dataLinePosition2 was moving before this assignment
        // are already offscreen.
        self.dataLinePosition2 = self.dataLinePosition1;
        
        // Then re-init the first data position vector to starting position.
        GLfloat xTranslate = self.graph.graphRight;
        self.dataLinePosition1 = GLKVector3Make(xTranslate, self.graph.graphBottom, kModelZ);
        
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
                     _dataLineData, GL_DYNAMIC_DRAW);
    }
    else
    {
        glBufferSubData(GL_ARRAY_BUFFER, 0,
                        self.dataLineDataValidSize * sizeof(VertexData_t),
                        _dataLineData);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)addLineDataArray:(NSArray*)dataArray
{
    
}

- (void)resetLineData
{
    GLfloat xTranslate = self.graph.graphRight;
    self.dataLinePosition1 = GLKVector3Make(xTranslate, self.graph.graphBottom, kModelZ);
    self.dataLinePosition2 = GLKVector3Make(xTranslate, self.graph.graphBottom, kModelZ);
    
    self.dataLineDataValidSize = 0;
    self.dataLineDataCurrIdx = 0;
    self.dataLineDataNextX = 0;
}

- (void)setLineDataLegendText:(NSString*)text
{
    // Apparently GLKTextureInfo leaks memory if you don't delete textures explicitly.
    if (self.lineLegendTextTexture)
    {
        GLuint texture = self.lineLegendTextTexture.name;
        glDeleteTextures(1, &texture);
    }
    
    UIImage *tex = [GLCommon imageWithText:text font:[UIFont fontWithName:@"Verdana" size:22.0f] color:self.color];
    self.lineLegendTextTexture = [GLKTextureLoader textureWithCGImage:tex.CGImage options:nil error:nil];
}

- (void)setDataLineLegendIcon:(UIImage*)image
{
    NSError *error = nil;
    self.lineLegendIconTexture = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:&error];
    if (lineLegendIconTexture == nil)
    {
        AMLogError(@"GLKTextureLoader failed to load texture: %@", [error localizedDescription]);
    }
}

- (void)render
{
    if (self.dataLineDataValidSize == 0)
    {
        // No verticies to draw.
        return;
    }
    
    [self renderDataLine];
}

- (void)renderLegend:(NSUInteger)lineIndex
{
    /*
     * Icon
     */
    if (self.lineLegendIconTexture)
    {
        GLfloat x = self.graph.graphRight - 6.5f - (lineIndex * 9.0f);
        GLfloat y = self.graph.graphBottom - 1.2f;
        GLfloat xScale = 1.0f * (self.lineLegendIconTexture.width / self.lineLegendIconTexture.height);
        GLfloat yScale = 1.0f;
        
        glBindVertexArrayOES(self.glVertexArrayLineLegend);
        
        GLKVector3 position = GLKVector3Make(x, y, 0.0f);
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKMatrix4 scale = GLKMatrix4MakeScale(xScale, yScale, 1.0f);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.graph.effect.transform.modelviewMatrix = modelMatrix;
        self.graph.effect.texture2d0.enabled = GL_TRUE;
        self.graph.effect.texture2d0.target = GLKTextureTarget2D;
        self.graph.effect.texture2d0.name = self.lineLegendIconTexture.name;
        self.graph.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        [self.graph.effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(lineLegendData) / sizeof(VertexData_t));
    }
    
    /*
     * Text
     */
    if (self.lineLegendTextTexture)
    {
        GLfloat x = self.graph.graphRight - 5.0f - (lineIndex * 9.0f);
        GLfloat y = self.graph.graphBottom - 1.0f;
        GLfloat xScale = self.lineLegendTextTexture.width * kFontScaleMultiplierW;
        GLfloat yScale = self.lineLegendTextTexture.height * kFontScaleMultiplierH;
        
        glBindVertexArrayOES(self.glVertexArrayLineLegend);
        
        GLKVector3 position = GLKVector3Make(x, y, 0.0f);
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKMatrix4 scale = GLKMatrix4MakeScale(xScale, yScale, 1.0f);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.graph.effect.transform.modelviewMatrix = modelMatrix;
        self.graph.effect.texture2d0.enabled = GL_TRUE;
        self.graph.effect.texture2d0.target = GLKTextureTarget2D;
        self.graph.effect.texture2d0.name = self.lineLegendTextTexture.name;
        self.graph.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        [self.graph.effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(lineLegendData) / sizeof(VertexData_t));
    }
}

- (NSUInteger)maxDataLineElements
{
    return self.dataLineDataSize;
}

- (void)setDataLineZoom:(GLfloat)aZoom
{
    self.zoom = aZoom;
}

#pragma mark - private

- (void)setupVBO
{
    /*
     * Data line.
     */
    {
        glGenVertexArraysOES(1, &_glVertexArrayDataLine);
        glBindVertexArrayOES(self.glVertexArrayDataLine);
        
        glGenBuffers(1, &_glBufferDataLine);
        glBindBuffer(GL_ARRAY_BUFFER, self.glBufferDataLine);
        glBufferData(GL_ARRAY_BUFFER, self.dataLineDataValidSize * sizeof(VertexData_t), _dataLineData, GL_DYNAMIC_DRAW);
        
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData_t),
                              NULL + offsetof(VertexData_t, positionCoords));
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        
        GL_CHECK_ERROR();
    }
    
    /*
     * Line legend.
     */
    {
        glGenVertexArraysOES(1, &_glVertexArrayLineLegend);
        glBindVertexArrayOES(self.glVertexArrayLineLegend);
        
        glGenBuffers(1, &_glBufferLineLegend);
        glBindBuffer(GL_ARRAY_BUFFER, self.glBufferLineLegend);
        glBufferData(GL_ARRAY_BUFFER, sizeof(lineLegendData), lineLegendData, GL_STATIC_DRAW);
        
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData_t),
                              NULL + offsetof(VertexData_t, positionCoords));
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VertexData_t),
                              NULL + offsetof(VertexData_t, textureCoords));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    }
}

- (void)renderDataLine
{
    GLfloat yScale = 1.0f / self.zoom;
    
    /*
     * Render the first batch starting from 0 to self.dataLineDataCurrIdx.
     */
    {
        GLfloat yScale = 1.0f / self.zoom;
        
        glBindVertexArrayOES(self.glVertexArrayDataLine);
        
        GLKVector3 position = self.dataLinePosition1;
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKMatrix4 scale = GLKMatrix4MakeScale(kDataLineShiftSize, yScale, 1.0f);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.graph.effect.transform.modelviewMatrix = modelMatrix;
        self.graph.effect.useConstantColor = YES;
        self.graph.effect.texture2d0.enabled = NO;
        
        const CGFloat *components = CGColorGetComponents(self.color.CGColor);
        self.graph.effect.constantColor = GLKVector4Make(components[0], components[1], components[2], CGColorGetAlpha(self.color.CGColor));
        [self.graph.effect prepareToDraw];
        
        DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
        glLineWidth(ui.GLdataLineWidth);
        glDrawArrays(GL_LINE_STRIP, 0, self.dataLineDataCurrIdx);
        
        GL_CHECK_ERROR();
    }
    
    /*
     * Render the second batch starting from self.dataLineDataCurrIdx+1 to the end.
     */
    if (self.dataLineDataValidSize > self.dataLineDataCurrIdx)
    {
        glBindVertexArrayOES(self.glVertexArrayDataLine);
        
        GLKVector3 position = self.dataLinePosition2;
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKMatrix4 scale = GLKMatrix4MakeScale(kDataLineShiftSize, yScale, 1.0f);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.graph.effect.transform.modelviewMatrix = modelMatrix;
        self.graph.effect.useConstantColor = YES;
        const CGFloat *components = CGColorGetComponents(self.color.CGColor);
        self.graph.effect.constantColor = GLKVector4Make(components[0], components[1], components[2], CGColorGetAlpha(self.color.CGColor));
        self.graph.effect.texture2d0.enabled = NO;
        [self.graph.effect prepareToDraw];
        
        DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
        glLineWidth(ui.GLdataLineWidth);
        glDrawArrays(GL_LINE_STRIP, self.dataLineDataCurrIdx, self.dataLineDataValidSize - self.dataLineDataCurrIdx);
        
        GL_CHECK_ERROR();
    }
}

- (void)tearDownGL
{
    // Apparently GLKTextureInfo leaks memory if you don't delete textures explicitly.
    if (self.lineLegendIconTexture)
    {
        GLuint texture = self.lineLegendIconTexture.name;
        glDeleteTextures(1, &texture);
    }
    if (self.lineLegendTextTexture)
    {
        GLuint texture = self.lineLegendTextTexture.name;
        glDeleteTextures(1, &texture);
    }
    
    if (self.glBufferDataLine)
    {
        glDeleteBuffers(1, &_glBufferDataLine);
    }
    if (self.glBufferLineLegend)
    {
        glDeleteBuffers(1, &_glBufferLineLegend);
    }
    
    if (self.glVertexArrayDataLine)
    {
        glDeleteVertexArraysOES(1, &_glVertexArrayDataLine);
    }
    if (self.glVertexArrayLineLegend)
    {
        glDeleteVertexArraysOES(1, &_glVertexArrayLineLegend);
    }
    
    GL_CHECK_ERROR();
}

@end
