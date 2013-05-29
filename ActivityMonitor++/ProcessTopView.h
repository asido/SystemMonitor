//
//  ProcessTopView.h
//  ActivityMonitor++
//
//  Created by st on 22/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProcessViewController.h"

@protocol ProcessTopViewDelegate
- (void)wantsToPresentSortViewForButton:(UIButton*)button;
@end

@interface ProcessTopView : UIView
@property (weak, nonatomic) id<ProcessTopViewDelegate> delegate;

- (void)setProcessCount:(NSUInteger)count;
@end
