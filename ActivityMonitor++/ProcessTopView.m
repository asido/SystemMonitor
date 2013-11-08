//
//  ProcessTopView.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AppDelegate.h"
#import "AMUtils.h"
#import "ProcessSort.h"
#import "iPhoneProcessSortViewController.h"
#import "iPadProcessSortViewController.h"
#import "ProcessTopView.h"

@interface ProcessTopView()
@property (weak, nonatomic) IBOutlet UIButton *sortButton;

@property (weak, nonatomic) IBOutlet UILabel *processCountLabel;
- (IBAction)filterButtonTouchDown:(UIButton*)button;
@end

@implementation ProcessTopView

#pragma mark - override

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
        CGRect frame = self.frame;
        frame.size.width = ui.GLdataLineGraphWidth;
        self.frame = frame;
        
        UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]];
        frame = background.frame;
        frame.size.height = self.frame.size.height;
        background.frame = frame;
        [self addSubview:background];
        [self sendSubviewToBack:background];
    }
    return self;
}

#pragma mark - public

- (void)setProcessCount:(NSUInteger)count
{
    [self.processCountLabel setText:[NSString stringWithFormat:@"%d Processes Running", count]];
}

#pragma mark - UI interaction

- (IBAction)filterButtonTouchDown:(UIButton*)button
{
    [self.delegate wantsToPresentSortViewForButton:button];
}

@end
