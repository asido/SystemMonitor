//
//  ConnectionSectionView.m
//  ActivityMonitor++
//
//  Created by st on 27/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "ConnectionSectionView.h"

@interface ConnectionSectionView()
@property (strong, nonatomic) UIImageView *background;
@end

@implementation ConnectionSectionView
@synthesize background;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ConnectionsSectionBackground-60.png"]];
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
