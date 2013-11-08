//
//  DeviceSpecificUI.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AMLog.h"
#import "AMUtils.h"
#import "AppDelegate.h"
#import "iPhoneSpecificUI.h"
#import "iPadSpecificUI.h"
#import "DeviceSpecificUI.h"

@implementation DeviceSpecificUI
@synthesize pickViewY;

@synthesize GLdataLineGraphWidth;
@synthesize GLdataLineWidth;

@synthesize GLtubeBackgroundFilename;
@synthesize GLtubeTextureFilename;
@synthesize GLtubeBubbleTextureFilename;
@synthesize GLtubeTextureSheetW;
@synthesize GLtubeTextureSheetH;
@synthesize GLtubeTextureY;
@synthesize GLtubeTextureH;
@synthesize GLtubeTextureLeftX;
@synthesize GLtubeTextureLeftW;
@synthesize GLtubeTextureRightX;
@synthesize GLtubeTextureRightW;
@synthesize GLtubeTextureLiquidX;
@synthesize GLtubeTextureLiquidW;
@synthesize GLtubeTextureLiquidTopX;
@synthesize GLtubeTextureLiquidTopW;
@synthesize GLtubeTextureGlassX;
@synthesize GLtubeTextureGlassW;
@synthesize GLtubeGlowH;
@synthesize GLtubeLiquidTopGlowL;
@synthesize GLtubeGLKViewFrame;

#pragma mark - override

- (id)init
{
    if (self = [super init])
    {
        AppDelegate *app = [AppDelegate sharedDelegate];
        assert(app.iDevice.deviceInfo != nil);
        
        self.pickViewY = [UIScreen mainScreen].bounds.size.height - 276.0f;
        
        self.GLdataLineGraphWidth = ([AMUtils isIPhone] ? 320.0f : 703.0f);
        self.GLdataLineWidth = (app.iDevice.deviceInfo.retina ? 3.0f : 2.0f);
        
        self.GLtubeBackgroundFilename = (app.iDevice.deviceInfo.retina ? @"TubeBackground-retina.png" : @"TubeBackground-nonretina.png");
        self.GLtubeTextureFilename = (app.iDevice.deviceInfo.retina ? @"TubeTexture-retina.png" : @"TubeTexture-nonretina.png");
        self.GLtubeBubbleTextureFilename = (app.iDevice.deviceInfo.retina ? @"BubbleTexture-retina.png" : @"BubbleTexture-nonretina.png");
        self.GLtubeTextureSheetW = 128.0f;
        self.GLtubeTextureSheetH = (app.iDevice.deviceInfo.retina ? 256.0f : 128.0f);
        self.GLtubeTextureY = (app.iDevice.deviceInfo.retina ? 140.0f : 93.0f);
        self.GLtubeTextureH = (app.iDevice.deviceInfo.retina ? 140.0f : 93.0f);
        self.GLtubeTextureLeftX = 0.0f;
        self.GLtubeTextureLeftW = (app.iDevice.deviceInfo.retina ? 28.0f: 21.0f);
        self.GLtubeTextureRightX = (app.iDevice.deviceInfo.retina ? 28.0f : 21.0f);
        self.GLtubeTextureRightW = (app.iDevice.deviceInfo.retina ? 28.0f : 20.0f);
        self.GLtubeTextureLiquidX = (app.iDevice.deviceInfo.retina ? 57.0f : 43.0f);
        self.GLtubeTextureLiquidW = 1.0f;
        self.GLtubeTextureLiquidTopX = (app.iDevice.deviceInfo.retina ? 58.0f: 44.0f);
        self.GLtubeTextureLiquidTopW = (app.iDevice.deviceInfo.retina ? 52.0f : 38.0f);
        self.GLtubeTextureGlassX = (app.iDevice.deviceInfo.retina ? 56.0f : 42.0f);
        self.GLtubeTextureGlassW = 1.0f;
        self.GLtubeGlowH = (app.iDevice.deviceInfo.retina ? 27.0f : 17.0f);
        self.GLtubeLiquidTopGlowL = (app.iDevice.deviceInfo.retina ? 5.0f : 0.0f);
        self.GLtubeGLKViewFrame = CGRectMake(5.0f,
                                             (app.iDevice.deviceInfo.retina ? 16.0f : 12.0f),
                                             ([AMUtils isIPhone] ? 310.0f : 693.0f),
                                             (app.iDevice.deviceInfo.retina ? self.GLtubeTextureH / 2 : self.GLtubeTextureH));
    }
    return self;
}

@end
