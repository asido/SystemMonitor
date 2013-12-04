//
//  DeviceSpecificUI.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>

@interface DeviceSpecificUI : NSObject
@property (nonatomic, assign) CGFloat   pickViewY;

@property (nonatomic, assign) GLfloat   GLdataLineGraphWidth;
@property (nonatomic, assign) GLfloat   GLdataLineWidth;

@property (nonatomic, assign) GLfloat   GLtubeTextureSheetW;
@property (nonatomic, assign) GLfloat   GLtubeTextureSheetH;
@property (nonatomic, assign) GLfloat   GLtubeTextureY;
@property (nonatomic, assign) GLfloat   GLtubeTextureH;
@property (nonatomic, assign) GLfloat   GLtubeTextureLeftX;
@property (nonatomic, assign) GLfloat   GLtubeTextureLeftW;
@property (nonatomic, assign) GLfloat   GLtubeTextureRightX;
@property (nonatomic, assign) GLfloat   GLtubeTextureRightW;
@property (nonatomic, assign) GLfloat   GLtubeTextureLiquidX;
@property (nonatomic, assign) GLfloat   GLtubeTextureLiquidW;
@property (nonatomic, assign) GLfloat   GLtubeTextureLiquidTopX;
@property (nonatomic, assign) GLfloat   GLtubeTextureLiquidTopW;
@property (nonatomic, assign) GLfloat   GLtubeTextureGlassX;
@property (nonatomic, assign) GLfloat   GLtubeTextureGlassW;
@property (nonatomic, assign) GLfloat   GLtubeGlowH;
@property (nonatomic, assign) GLfloat   GLtubeLiquidTopGlowL;
@property (nonatomic, assign) CGRect    GLtubeGLKViewFrame;
@end