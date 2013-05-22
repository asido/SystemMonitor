//
//  GLDataLineVBO.m
//  ActivityMonitor++
//
//  Created by st on 21/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMUtils.h"
#import "GLCommon.h"
#import "GLLineGraph.h"
#import "DataLine.h"

@interface DataLine()
@property (strong, nonatomic) GLLineGraph   *graph;

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

- (void)setupVBO;
@end

@implementation DataLine
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

static const GLfloat kDataLineShiftSize     = 0.25f;

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
        
        [self resetLineData];
        
        [self setupVBO];
    }
    return self;
}

- (void)dealloc
{
    free(_dataLineData);
}

- (void)addLineDataValue:(float)value
{
    GLfloat vX = self.dataLineDataNextX++;
    GLfloat vY = [AMUtils percentageValueFromMax:self.graph.graphTop min:self.graph.graphBottom percent:value];
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
    self.dataLinePosition1 = GLKVector3Make(xTranslate, 0.0f, kModelZ);
    self.dataLinePosition2 = GLKVector3Make(xTranslate, 0.0f, kModelZ);
    
    self.dataLineDataValidSize = 0;
    self.dataLineDataCurrIdx = 0;
    self.dataLineDataNextX = 0;
}

- (void)render
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
        
        GLKVector3 position = self.dataLinePosition1;
        GLKVector3 rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKMatrix4 scale = GLKMatrix4MakeScale(kDataLineShiftSize, 1.0f, 1.0f);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.graph.effect.transform.modelviewMatrix = modelMatrix;
        self.graph.effect.useConstantColor = YES;
        self.graph.effect.texture2d0.enabled = NO;
        
        const CGFloat *components = CGColorGetComponents(self.color.CGColor);
        self.graph.effect.constantColor = GLKVector4Make(components[0], components[1], components[2], CGColorGetAlpha(self.color.CGColor));
        [self.graph.effect prepareToDraw];
        glLineWidth(2.0f);
        glDrawArrays(GL_LINE_STRIP, 0, self.dataLineDataCurrIdx);
        /*
         self.effect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
         [self.effect prepareToDraw];
         glLineWidth(1.0f);
         glDrawArrays(GL_LINE_STRIP, 0, self.dataLineDataCurrIdx);
         */
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
        GLKMatrix4 scale = GLKMatrix4MakeScale(kDataLineShiftSize, 1.0f, 1.0f);
        GLKMatrix4 modelMatrix = [GLCommon modelMatrixWithPosition:position rotation:rotation scale:scale];
        
        self.graph.effect.transform.modelviewMatrix = modelMatrix;
        self.graph.effect.useConstantColor = YES;
        const CGFloat *components = CGColorGetComponents(self.color.CGColor);
        self.graph.effect.constantColor = GLKVector4Make(components[0], components[1], components[2], CGColorGetAlpha(self.color.CGColor));
        self.graph.effect.texture2d0.enabled = NO;
        
        [self.graph.effect prepareToDraw];
        glLineWidth(2.0f);
        
        glDrawArrays(GL_LINE_STRIP, self.dataLineDataCurrIdx, self.dataLineDataValidSize - self.dataLineDataCurrIdx);
        /*
         self.effect.constantColor = GLKVector4Make(230.0f/255.0f, 230.0f/255.0f, 0.0f, 1.0f);
         glLineWidth(1.0f);
         [self.effect prepareToDraw];
         glDrawArrays(GL_LINE_STRIP, self.dataLineDataCurrIdx, self.dataLineDataValidSize - self.dataLineDataCurrIdx);
         */
        GL_CHECK_ERROR();
    }

}

#pragma mark - private

- (void)setupVBO
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

@end
