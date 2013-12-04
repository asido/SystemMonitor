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

#import "AMLogger.h"
#import "AMUtils.h"
#import "AppDelegate.h"
#import "DeviceSpecificUI.h"

@implementation DeviceSpecificUI
@synthesize pickViewY;

@synthesize GLdataLineGraphWidth;
@synthesize GLdataLineWidth;

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
        AMAssert(app.iDevice.deviceInfo != nil, @"deviceInfo == nil");
        
        
        self.pickViewY = [UIScreen mainScreen].bounds.size.height - 276.0;
        
        self.GLdataLineGraphWidth = ([AMUtils isIPhone] ? 320.0 : 703.0);
        self.GLdataLineWidth = (app.iDevice.deviceInfo.retina ? 3.0 : 2.0);
        
        self.GLtubeTextureSheetW = 128.0;
        self.GLtubeTextureSheetH = (app.iDevice.deviceInfo.retina ? 256.0 : 128.0);
        self.GLtubeTextureY = (app.iDevice.deviceInfo.retina ? 140.0 : 93.0);
        self.GLtubeTextureH = (app.iDevice.deviceInfo.retina ? 140.0 : 93.0);
        self.GLtubeTextureLeftX = 0.0;
        self.GLtubeTextureLeftW = (app.iDevice.deviceInfo.retina ? 28.0: 21.0);
        self.GLtubeTextureRightX = (app.iDevice.deviceInfo.retina ? 28.0 : 21.0);
        self.GLtubeTextureRightW = (app.iDevice.deviceInfo.retina ? 28.0 : 20.0);
        self.GLtubeTextureLiquidX = (app.iDevice.deviceInfo.retina ? 57.0 : 43.0);
        self.GLtubeTextureLiquidW = 1.0;
        self.GLtubeTextureLiquidTopX = (app.iDevice.deviceInfo.retina ? 58.0 : 44.0);
        self.GLtubeTextureLiquidTopW = (app.iDevice.deviceInfo.retina ? 52.0 : 38.0);
        self.GLtubeTextureGlassX = (app.iDevice.deviceInfo.retina ? 56.0 : 42.0);
        self.GLtubeTextureGlassW = 1.0;
        self.GLtubeGlowH = (app.iDevice.deviceInfo.retina ? 27.0 : 17.0);
        self.GLtubeLiquidTopGlowL = (app.iDevice.deviceInfo.retina ? 5.0 : 0.0);
        self.GLtubeGLKViewFrame = CGRectMake(5.0,
                                             (app.iDevice.deviceInfo.retina ? 16.0 : 12.0),
                                             ([AMUtils isIPhone] ? 310.0 : 693.0),
                                             (app.iDevice.deviceInfo.retina ? self.GLtubeTextureH / 2 : self.GLtubeTextureH));
    }
    return self;
}

@end
