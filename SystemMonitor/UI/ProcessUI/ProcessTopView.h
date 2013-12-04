//
//  ProcessTopView.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <UIKit/UIKit.h>
#import "ProcessViewController.h"

@protocol ProcessTopViewDelegate
- (void)wantsToPresentSortViewForButton:(UIButton*)button;
@end

@interface ProcessTopView : UIView
@property (nonatomic, weak) id<ProcessTopViewDelegate> delegate;

- (void)setProcessCount:(NSUInteger)count;
@end
