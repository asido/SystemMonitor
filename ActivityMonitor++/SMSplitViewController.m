//
//  SMSplitViewController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "SMSplitViewController.h"

@interface SMSplitViewController ()

@end

@implementation SMSplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // In order to change color of 1px vertical line joining left and right view controllers of the split.
    [[self view] setBackgroundColor:[UIColor darkGrayColor]];
}

@end
