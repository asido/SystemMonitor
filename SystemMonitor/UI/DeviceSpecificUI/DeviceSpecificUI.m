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
        DeviceInfo *deviceInfo = [AppDelegate sharedDelegate].iDevice.deviceInfo;
        AMAssert(deviceInfo != nil, @"deviceInfo == nil");
        
        
        self.pickViewY = [UIScreen mainScreen].bounds.size.height - 276.0;
        
        self.GLdataLineGraphWidth = ([AMUtils isIPhone] ? [UIScreen mainScreen].bounds.size.width : 703.0);
        self.GLdataLineWidth = (deviceInfo.retinaHD ? 4.0 : deviceInfo.retina ? 3.0 : 2.0);
        
        self.GLtubeTextureSheetW = (deviceInfo.retinaHD ? 256.0 : 128.0);
        self.GLtubeTextureSheetH = (deviceInfo.retina ? 256.0 : 128.0);
        self.GLtubeTextureY = (deviceInfo.retinaHD ? 210.0 : deviceInfo.retina ? 140.0 : 93.0);
        self.GLtubeTextureH = (deviceInfo.retinaHD ? 210.0 : deviceInfo.retina ? 140.0 : 93.0);
        self.GLtubeTextureLeftX = 0.0;
        self.GLtubeTextureLeftW = (deviceInfo.retinaHD ? 42.0 : deviceInfo.retina ? 28.0: 21.0);
        self.GLtubeTextureRightX = (deviceInfo.retinaHD ? 42.0 : deviceInfo.retina ? 28.0 : 21.0);
        self.GLtubeTextureRightW = (deviceInfo.retinaHD ? 42.0 : deviceInfo.retina ? 28.0 : 20.0);
        self.GLtubeTextureLiquidX = (deviceInfo.retinaHD ? 86.0 : deviceInfo.retina ? 57.0 : 43.0);
        self.GLtubeTextureLiquidW = 1.0;
        self.GLtubeTextureLiquidTopX = (deviceInfo.retinaHD ? 87.0 : deviceInfo.retina ? 58.0 : 44.0);
        self.GLtubeTextureLiquidTopW = (deviceInfo.retinaHD ? 78.0 : deviceInfo.retina ? 52.0 : 38.0);
        self.GLtubeTextureGlassX = (deviceInfo.retinaHD ? 84.0 : deviceInfo.retina ? 56.0 : 42.0);
        self.GLtubeTextureGlassW = (deviceInfo.retinaHD ? 2.0 : 1.0);
        self.GLtubeGlowH = (deviceInfo.retinaHD ? 40.0 : deviceInfo.retina ? 27.0 : 17.0);
        self.GLtubeLiquidTopGlowL = (deviceInfo.retina ? 5.0 : 0.0);
        self.GLtubeGLKViewFrame = CGRectMake(5.0,
                                             (deviceInfo.retina ? 16.0 : 12.0),
                                             ([AMUtils isIPhone] ? [UIScreen mainScreen].bounds.size.width - 10.0 : 693.0),
                                             self.GLtubeTextureH / [UIScreen mainScreen].scale);
    }
    return self;
}

@end
