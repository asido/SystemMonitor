//
//  GLLineGraph.m
//  ActivityMonitor++
//
//  Created by st on 09/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMLog.h"
#import "GLLineGraph.h"

@interface GLLineGraph() <GLKViewDelegate>
@property (retain) GLKView          *glView;
@property (retain) GLKBaseEffect    *baseEffect;
@property (assign) GLuint           lineVertexBuffer;
@property (assign) GLuint           lineVertexBufferSize;
@end

@implementation GLLineGraph
@synthesize glView;
@synthesize baseEffect;
@synthesize lineVertexBuffer;

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} LineVertex_t;

static const GLuint kVerticiesPerLineSegment    = 6;
static const GLuint kMaxLineSegments            = 4096;
static LineVertex_t lineVertexData[kMaxLineSegments * kVerticiesPerLineSegment];
/*
{
    {{ -0.1f, -0.4f, 0.0f }}, // First triangle
    {{ -0.1f,  0.4f, 0.0f }},
    {{  0.1f, -0.4f, 0.0f }},
    {{  0.1f, -0.4f, 0.0f }}, // Second triangle
    {{  0.1f,  0.4f, 0.0f }},
    {{ -0.1f,  0.4f, 0.0f }},
};
*/
static const GLfloat kLineWidth   = 0.2f;
static const GLfloat kLineVertexZ = 0.0f;

static const GLfloat kProjectionLeft    = -10.0f;
static const GLfloat kProjectionRight   =  10.0f;
static const GLfloat kProjectionBottom  = -5.0f;
static const GLfloat kProjectionTop     =  5.0f;
static const GLfloat kProjectionNear    =  1.0f;
static const GLfloat kProjectionFar     =  100.0f;

#pragma mark - public

- (id)initWithGLKView:(GLKView*)aGLView
{
    if (self = [super init])
    {
        self.glView = aGLView;
        self.view = self.glView;
        
        self.lineVertexBufferSize = 0;
        
        EAGLContext *glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!glContext)
        {
            AMWarn(@"%s: EAGLContext == nil", __PRETTY_FUNCTION__);
            return nil;
        }
        
        [self.glView setContext:glContext];
        [EAGLContext setCurrentContext:self.glView.context];
        
        self.baseEffect = [[GLKBaseEffect alloc] init];
        self.baseEffect.useConstantColor = GL_TRUE;
        self.baseEffect.constantColor = GLKVector4Make(0.7f,  // R
                                                       0.7f,  // G
                                                       0.7f,  // B
                                                       1.0f); // A
        
        // Init textures
        CGImageRef imgRef = [[UIImage imageNamed:@"GraphLine4.png"] CGImage];
        GLKTextureInfo *lineTexture = [GLKTextureLoader textureWithCGImage:imgRef options:nil error:NULL];
        self.baseEffect.texture2d0.name = lineTexture.name;
        self.baseEffect.texture2d0.target = lineTexture.target;
        
        self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0f);
        
        glGenBuffers(1, &lineVertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, self.lineVertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, 0, lineVertexData, GL_DYNAMIC_DRAW);
    }
    return self;
}

- (void)appendValue:(float)value
{
    GLfloat vX, vY;
    
    if (self.lineVertexBufferSize == 0)
    {
        vX = kProjectionRight;
        vY = (kProjectionTop + kProjectionBottom) / 2;
    }
    else
    {
        LineVertex_t prevVertex = lineVertexData[self.lineVertexBufferSize - 2];
        vX = prevVertex.positionCoords.x;
        vY = (kProjectionTop + kProjectionBottom) / 2;
    }

    // First triangle
    lineVertexData[self.lineVertexBufferSize].positionCoords.x = vX;
    lineVertexData[self.lineVertexBufferSize].positionCoords.y = vY;
    lineVertexData[self.lineVertexBufferSize].positionCoords.z = kLineVertexZ;
    lineVertexData[self.lineVertexBufferSize].textureCoords.s = 1.0f;
    lineVertexData[self.lineVertexBufferSize].textureCoords.t = 0.0f;
    self.lineVertexBufferSize++;
    
    lineVertexData[self.lineVertexBufferSize].positionCoords.x = vX;
    lineVertexData[self.lineVertexBufferSize].positionCoords.y = vY + kLineWidth;
    lineVertexData[self.lineVertexBufferSize].positionCoords.z = kLineVertexZ;
    lineVertexData[self.lineVertexBufferSize].textureCoords.s = 1.0f;
    lineVertexData[self.lineVertexBufferSize].textureCoords.t = 1.0f;
    self.lineVertexBufferSize++;
    
    lineVertexData[self.lineVertexBufferSize].positionCoords.x = vX - 0.005f;
    lineVertexData[self.lineVertexBufferSize].positionCoords.y = vY;
    lineVertexData[self.lineVertexBufferSize].positionCoords.z = kLineVertexZ;
    lineVertexData[self.lineVertexBufferSize].textureCoords.s = 0.0f;
    lineVertexData[self.lineVertexBufferSize].textureCoords.t = 0.0f;
    self.lineVertexBufferSize++;
    
    // Second triangle
    lineVertexData[self.lineVertexBufferSize].positionCoords.x = vX - 0.005f;
    lineVertexData[self.lineVertexBufferSize].positionCoords.y = vY;
    lineVertexData[self.lineVertexBufferSize].positionCoords.z = kLineVertexZ;
    lineVertexData[self.lineVertexBufferSize].textureCoords.s = 0.0f;
    lineVertexData[self.lineVertexBufferSize].textureCoords.t = 0.0f;
    self.lineVertexBufferSize++;
    
    lineVertexData[self.lineVertexBufferSize].positionCoords.x = vX - 0.005f;
    lineVertexData[self.lineVertexBufferSize].positionCoords.y = vY + kLineWidth;
    lineVertexData[self.lineVertexBufferSize].positionCoords.z = kLineVertexZ;
    lineVertexData[self.lineVertexBufferSize].textureCoords.s = 0.0f;
    lineVertexData[self.lineVertexBufferSize].textureCoords.t = 1.0f;
    self.lineVertexBufferSize++;
    
    lineVertexData[self.lineVertexBufferSize].positionCoords.x = vX;
    lineVertexData[self.lineVertexBufferSize].positionCoords.y = vY + kLineWidth;
    lineVertexData[self.lineVertexBufferSize].positionCoords.z = kLineVertexZ;
    lineVertexData[self.lineVertexBufferSize].textureCoords.s = 1.0f;
    lineVertexData[self.lineVertexBufferSize].textureCoords.t = 1.0f;
    self.lineVertexBufferSize++;
    
    glBindBuffer(GL_ARRAY_BUFFER, self.lineVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER,
                 self.lineVertexBufferSize * sizeof(LineVertex_t),
                 lineVertexData, GL_DYNAMIC_DRAW);
}

#pragma mark - private

#pragma mark - private override

-(void)update
{
}

#pragma mark - GLKView delegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
 
    CGFloat aspectRatio = (GLfloat)self.glView.drawableWidth / (GLfloat)self.glView.drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(kProjectionLeft * aspectRatio,
                                                                     kProjectionRight * aspectRatio,
                                                                     kProjectionBottom,
                                                                     kProjectionTop,
                                                                     kProjectionNear,
                                                                     kProjectionFar);
    if (self.lineVertexBufferSize == 0)
    {
        // No verticies to draw.
        return;
    }
    
    // Prepare verticies.
    glBindBuffer(GL_ARRAY_BUFFER, self.lineVertexBuffer);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,                                        // Components per vertex
                          GL_FLOAT,                                 // Data is float
                          GL_FALSE,                                 // No fixed point scaling
                          sizeof(LineVertex_t),                     // No gaps in data
                          NULL + offsetof(LineVertex_t, positionCoords));  // Data offset
    
    // Prepare textures.
    glBindBuffer(GL_ARRAY_BUFFER, self.lineVertexBuffer);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(LineVertex_t),
                          NULL + offsetof(LineVertex_t, textureCoords));
    
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, self.lineVertexBufferSize);
}

@end
