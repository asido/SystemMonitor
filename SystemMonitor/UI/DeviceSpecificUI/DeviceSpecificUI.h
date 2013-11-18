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
@property (assign, nonatomic) CGFloat   pickViewY;

@property (assign, nonatomic) GLfloat   GLdataLineGraphWidth;
@property (assign, nonatomic) GLfloat   GLdataLineWidth;

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