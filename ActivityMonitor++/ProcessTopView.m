//
//  ProcessTopView.m
//  ActivityMonitor++
//
//  Created by st on 22/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "ProcessSortViewController.h"
#import "ProcessTopView.h"

@interface ProcessTopView() <ProcessSortViewControllerDelegate>
@property (strong, nonatomic) UIPopoverController       *sortPopover;
@property (strong, nonatomic) ProcessSortViewController *sortViewCtrl;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;

@property (weak, nonatomic) IBOutlet UILabel *processCountLabel;
- (IBAction)filterButtonTouchDown:(UIButton*)button;
@end

@implementation ProcessTopView
@synthesize sortPopover;
@synthesize sortViewCtrl;

#pragma mark - override

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]];
        CGRect frame = background.frame;
        frame.size.height = self.frame.size.height;
        background.frame = frame;
        [self addSubview:background];
        [self sendSubviewToBack:background];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - public

- (void)setProcessCount:(NSUInteger)count
{
    [self.processCountLabel setText:[NSString stringWithFormat:@"%d Processes Running", count]];
}

#pragma mark - ProcessSortViewController delegate

- (void)processSortFilterChanged:(SortFilter_t)newFilter
{
    [self.sortPopover dismissPopoverAnimated:YES];
    [self.delegate processTopViewSortFilterChanged:newFilter];
}

#pragma mark - UI interaction

- (IBAction)filterButtonTouchDown:(UIButton*)button
{
    if (!self.sortViewCtrl)
    {
        self.sortViewCtrl = [[ProcessSortViewController alloc] initWithStyle:UITableViewStylePlain];
        self.sortViewCtrl.delegate = self;
    }
    if (!self.sortPopover)
    {
        self.sortPopover = [[UIPopoverController alloc] initWithContentViewController:self.sortViewCtrl];
    }
    
    [self.sortPopover presentPopoverFromRect:button.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

@end
