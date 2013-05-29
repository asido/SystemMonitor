//
//  DeviceSpecificUI.h
//  ActivityMonitor++
//
//  Created by st on 26/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceSpecificUI : NSObject
@property (assign, nonatomic) CGFloat   pickViewY;

@property (assign, nonatomic) GLfloat   GLdataLineGraphWidth;
@property (assign, nonatomic) GLfloat   GLdataLineWidth;

@property (strong, nonatomic) NSString  *GLtubeBackgroundFilename;
@property (strong, nonatomic) NSString  *GLtubeTextureFilename;
@property (strong, nonatomic) NSString  *GLtubeBubbleTextureFilename;
@property (assign, nonatomic) GLfloat   GLtubeTextureSheetW;
@property (assign, nonatomic) GLfloat   GLtubeTextureSheetH;
@property (assign, nonatomic) GLfloat   GLtubeTextureY;
@property (assign, nonatomic) GLfloat   GLtubeTextureH;
@property (assign, nonatomic) GLfloat   GLtubeTextureLeftX;
@property (assign, nonatomic) GLfloat   GLtubeTextureLeftW;
@property (assign, nonatomic) GLfloat   GLtubeTextureRightX;
@property (assign, nonatomic) GLfloat   GLtubeTextureRightW;
@property (assign, nonatomic) GLfloat   GLtubeTextureLiquidX;
@property (assign, nonatomic) GLfloat   GLtubeTextureLiquidW;
@property (assign, nonatomic) GLfloat   GLtubeTextureLiquidTopX;
@property (assign, nonatomic) GLfloat   GLtubeTextureLiquidTopW;
@property (assign, nonatomic) GLfloat   GLtubeTextureGlassX;
@property (assign, nonatomic) GLfloat   GLtubeTextureGlassW;
@property (assign, nonatomic) GLfloat   GLtubeGlowH;
@property (assign, nonatomic) GLfloat   GLtubeLiquidTopGlowL;
@property (assign, nonatomic) CGRect    GLtubeGLKViewFrame;
@end