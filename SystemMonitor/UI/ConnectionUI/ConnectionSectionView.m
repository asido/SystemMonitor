//
//  ConnectionSectionView.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "ConnectionSectionView.h"

@interface ConnectionSectionView()
@property (nonatomic, strong) UIImageView *background;
@end

@implementation ConnectionSectionView
@synthesize background;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ConnectionSectionBackground"]];
        [self addSubview:self.background];
        [self sendSubviewToBack:self.background];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGRect backgroundFrame = self.background.frame;
    backgroundFrame.size.width = self.frame.size.width;
    self.background.frame = backgroundFrame;
}

@end
