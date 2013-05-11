//
//  GLLineGraph.m
//  ActivityMonitor++
//
//  Created by st on 09/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMLog.h"
#import "GLLineGraph.h"

#if DEBUG
#define CHECK_GL_ERROR()                        \
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

@interface GLLineGraph() <GLKViewDelegate>
@property (assign) NSUInteger       dataLineCount;

@property (retain) GLKView          *glView;

/*
 * Data line.
 */
@property (retain) GLKBaseEffect    *dataLineBaseEffect;
@property (assign) GLuint           dataLineGlBuffer;       /* GL line vertex buffer */
@property (assign) GLuint           dataLineGlBufferSize;   /* Valid buffer index count */
@property (assign) GLuint           dataLineGlBufferCurrIdx;/* Current index to be written new values to */

/*
 * Reference lines.
 */
@property (retain) GLKBaseEffect    *referenceLineBaseEffect;
@property (assign) GLuint           referenceLineGlBuffer;

- (void)initDataLines;
- (void)shiftDataCurve:(GLfloat)shiftSize;
- (void)drawDataCurve;

- (void)initReferenceLines;
- (void)drawReferenceLines;

- (void)initLegends;
- (void)drawLegends;
@end

@implementation GLLineGraph
@synthesize dataLineCount;

@synthesize glView;
@synthesize dataLineBaseEffect;
@synthesize dataLineGlBuffer;
@synthesize dataLineGlBufferSize;
@synthesize dataLineGlBufferCurrIdx;

@synthesize referenceLineBaseEffect;
@synthesize referenceLineGlBuffer;

@synthesize fromValue;
@synthesize toValue;
@synthesize rangeTitles;

typedef struct {
    GLKVector3 positionCoords;
} LineSegment_t;

static const GLfloat kProjectionLeft    = -10.0f;
static const GLfloat kProjectionRight   =  10.0f;
static const GLfloat kProjectionBottom  = -5.0f;
static const GLfloat kProjectionTop     =  5.0f;
static const GLfloat kProjectionNear    =  1.0f;
static const GLfloat kProjectionFar     =  100.0f;

static const GLfloat kGraphBottom       = kProjectionBottom + 1.5f;
static const GLfloat kGraphTop          = kProjectionTop - 1.5f;
static const GLfloat kGraphRight        = kProjectionRight - 1.0f;
static const GLfloat kGraphLeft         = kProjectionLeft + 0.5f;

/*
 * Data line
 */
static const GLfloat kDataLineSegmentHeight = 3.0f;
static const GLfloat kDataLineSegmentWidth  = 0.05f;
static const GLfloat kDataLineVertexZ       = 0.0f;
// TODO: we should make required buffer size calculate dynamically based on each line
// segment width and total available screen/projection area.
// WARNING: THE VALUE MUST BE EVEN!
static const GLuint kMaxDataLineSegments            = 3072;
static LineSegment_t dataLineBufferData[kMaxDataLineSegments];

/*
 * Reference lines
 */
static const GLfloat kReferenceLineHeight   = 1.0f;
static const GLfloat kReferenceLineVertexZ  = 0.0f;
static const LineSegment_t referenceLinesBufferData[] = {
    {{ kGraphLeft , kGraphBottom                    , kReferenceLineVertexZ }}, // Bottom line
    {{ kGraphRight, kGraphBottom                    , kReferenceLineVertexZ }},
    {{ kGraphLeft , (kGraphTop + kGraphBottom) / 2  , kReferenceLineVertexZ }}, // Mid line
    {{ kGraphRight, (kGraphTop + kGraphBottom) / 2  , kReferenceLineVertexZ }},
    {{ kGraphLeft , kGraphTop                       , kReferenceLineVertexZ }}, // Top line
    {{ kGraphRight, kGraphTop                       , kReferenceLineVertexZ }}
};

#pragma mark - public

- (id)initWithGLKView:(GLKView*)aGLView
        dataLineCount:(NSUInteger)count
            fromValue:(float)from
              toValue:(float)to
          rangeTitles:(NSArray*)titles
{
    if (self = [super init])
    {
        self.dataLineCount = count;
        self.fromValue = from;
        self.toValue = to;
        self.rangeTitles = titles;
        
        self.glView = aGLView;
        self.view = self.glView;
        
        EAGLContext *glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!glContext)
        {
            AMWarn(@"%s: EAGLContext == nil", __PRETTY_FUNCTION__);
            return nil;
        }
        
        [self.glView setContext:glContext];
        [EAGLContext setCurrentContext:self.glView.context];
        
        // Enable for performance reasons as it removes many of the triangles to draw.
        glEnable(GL_CULL_FACE);
        // Enabled by default.
        glDisable(GL_DITHER);
        CHECK_GL_ERROR();

        [self initDataLines];
        [self initReferenceLines];
        [self initLegends];
    }
    return self;
}

- (void)appendDataValue:(float)value
{
    CGFloat aspectRatio = (GLfloat)self.glView.drawableWidth / (GLfloat)self.glView.drawableHeight;
    GLfloat vX = kGraphRight * aspectRatio;
    GLfloat vY = kGraphBottom + ((kGraphTop - kGraphBottom) / 100 * value);
    
    [self shiftDataCurve:kDataLineSegmentWidth];
    
    if (self.dataLineGlBufferSize > 0)
    {
        NSUInteger prevIdx;
        
        if (self.dataLineGlBufferCurrIdx == 0)
        {
            prevIdx = self.dataLineGlBufferSize - 1;
        }
        else
        {
            prevIdx = self.dataLineGlBufferCurrIdx - 1;
        }
        
        dataLineBufferData[self.dataLineGlBufferCurrIdx].positionCoords.x = dataLineBufferData[prevIdx].positionCoords.x;
        dataLineBufferData[self.dataLineGlBufferCurrIdx].positionCoords.y = dataLineBufferData[prevIdx].positionCoords.y;
        dataLineBufferData[self.dataLineGlBufferCurrIdx].positionCoords.z = dataLineBufferData[prevIdx].positionCoords.z;
        
        self.dataLineGlBufferCurrIdx++;
    }
    else
    {
        dataLineBufferData[0].positionCoords.x = vX - kDataLineSegmentWidth;
        dataLineBufferData[0].positionCoords.y = vY;
        dataLineBufferData[0].positionCoords.z = kDataLineVertexZ;
        
        self.dataLineGlBufferCurrIdx++;
    }

    dataLineBufferData[self.dataLineGlBufferCurrIdx].positionCoords.x = vX;
    dataLineBufferData[self.dataLineGlBufferCurrIdx].positionCoords.y = vY;
    dataLineBufferData[self.dataLineGlBufferCurrIdx].positionCoords.z = kDataLineVertexZ;
    self.dataLineGlBufferCurrIdx++;
    
    if (self.dataLineGlBufferSize < kMaxDataLineSegments)
    {
        // Increase GL buffer size.
        self.dataLineGlBufferSize += 2;
    }
    
    if (self.dataLineGlBufferCurrIdx >= kMaxDataLineSegments)
    {
        // Start filling the array from the beginning.
        self.dataLineGlBufferCurrIdx = 0;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, self.dataLineGlBuffer);
    glBufferData(GL_ARRAY_BUFFER,
                 self.dataLineGlBufferSize * sizeof(LineSegment_t),
                 dataLineBufferData, GL_DYNAMIC_DRAW);
}

#pragma mark - private

- (void)initDataLines
{
    self.dataLineGlBufferSize = 0;
    self.dataLineGlBufferCurrIdx = 0;
    
    // Color
    self.dataLineBaseEffect = [[GLKBaseEffect alloc] init];
    self.dataLineBaseEffect.useConstantColor = GL_TRUE;    // Yellow
    self.dataLineBaseEffect.constantColor = GLKVector4Make(1.0f,  // R
                                                           1.0f,  // G
                                                           0.0f,  // B
                                                           1.0f); // A
    
    // Transformation
    self.dataLineBaseEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0f);
    
    // Data
    glGenBuffers(1, &dataLineGlBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, self.dataLineGlBuffer);
    glBufferData(GL_ARRAY_BUFFER, 0, dataLineBufferData, GL_DYNAMIC_DRAW);
    
    CHECK_GL_ERROR();
}

- (void)shiftDataCurve:(GLfloat)shiftSize
{
    NSUInteger idx;
    
    if (self.dataLineGlBufferSize == 0)
    {
        return;
    }
    
    // First we shift the values which are ahead of current index in the array.
    idx = self.dataLineGlBufferCurrIdx;
    while (idx < self.dataLineGlBufferSize)
    {
        dataLineBufferData[idx].positionCoords.x -= shiftSize;
        idx++;
    }
    
    // Lastly shift the values which are before current index.
    idx = 0;
    while (idx != self.dataLineGlBufferCurrIdx)
    {
        dataLineBufferData[idx].positionCoords.x -= shiftSize;
        idx++;
    }
}

- (void)drawDataCurve
{
    if (self.dataLineGlBufferSize == 0)
    {
        // No verticies to draw.
        return;
    }
    
    CGFloat aspectRatio = (GLfloat)self.glView.drawableWidth / (GLfloat)self.glView.drawableHeight;
    self.dataLineBaseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(kProjectionLeft * aspectRatio,
                                                                             kProjectionRight * aspectRatio,
                                                                             kProjectionBottom,
                                                                             kProjectionTop,
                                                                             kProjectionNear,
                                                                             kProjectionFar);
    
    glLineWidth(kDataLineSegmentHeight);
    
    // Prepare verticies.
    glBindBuffer(GL_ARRAY_BUFFER, self.dataLineGlBuffer);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,                                        // Components per vertex
                          GL_FLOAT,                                 // Data is float
                          GL_FALSE,                                 // No fixed point scaling
                          sizeof(LineSegment_t),                    // No gaps in data
                          NULL + offsetof(LineSegment_t, positionCoords));  // Data offset
    
    [self.dataLineBaseEffect prepareToDraw];
    glDrawArrays(GL_LINES, 0, self.dataLineGlBufferSize);
    
    CHECK_GL_ERROR();
}

- (void)initReferenceLines
{    
    // Color
    self.referenceLineBaseEffect = [[GLKBaseEffect alloc] init];
    self.referenceLineBaseEffect.useConstantColor = GL_TRUE;
    self.referenceLineBaseEffect.constantColor = GLKVector4Make(0.25f, 0.25f, 0.25f, 1.0f);
    
    // Projection
    self.referenceLineBaseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(kProjectionLeft,
                                                                                  kProjectionRight,
                                                                                  kProjectionBottom,
                                                                                  kProjectionTop,
                                                                                  kProjectionNear,
                                                                                  kProjectionFar);
    
    // Transformation
    self.referenceLineBaseEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0f);
    
    // Data
    glGenBuffers(1, &referenceLineGlBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, self.referenceLineGlBuffer);
    glBufferData(GL_ARRAY_BUFFER,
                 sizeof(referenceLinesBufferData),
                 referenceLinesBufferData,
                 GL_STATIC_DRAW);

    CHECK_GL_ERROR();
}

- (void)drawReferenceLines
{    
    glLineWidth(kReferenceLineHeight);
    
    // Prepare verticies.
    glBindBuffer(GL_ARRAY_BUFFER, self.referenceLineGlBuffer);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(LineSegment_t),
                          NULL + offsetof(LineSegment_t, positionCoords));
    
    [self.referenceLineBaseEffect prepareToDraw];
    glDrawArrays(GL_LINES,
                 0,
                 sizeof(referenceLinesBufferData) / sizeof(LineSegment_t));
    
    CHECK_GL_ERROR();
}

- (void)initLegends
{    
    CHECK_GL_ERROR();
}

- (void)drawLegends
{    
    CHECK_GL_ERROR();
}

#pragma mark - private override

-(void)update
{
}

#pragma mark - GLKView delegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self drawReferenceLines];
    [self drawLegends];
    [self drawDataCurve];
}

@end
