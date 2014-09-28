//
//  AMCommonUI.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Arvydas Sidorenko
//

#import "AMCommonUI.h"

@implementation AMCommonUI

+ (UIView *)mainMenuBackgroundView
{
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainMenuBackground"]];
    background.contentMode = UIViewContentModeCenter;
    return background;
}

+ (UIView *)sectionBackgroundView
{
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ViewBackground-1496"]];
    background.contentMode = UIViewContentModeCenter;
    return background;
}

@end
