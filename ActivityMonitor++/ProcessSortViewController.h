//
//  ProcessSortViewController.h
//  ActivityMonitor++
//
//  Created by st on 22/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProcessTopView.h"

@protocol ProcessSortViewControllerDelegate
- (void)processSortFilterChanged:(SortFilter_t)newFilter;
@end

@interface ProcessSortViewController : UITableViewController
@property (strong, nonatomic) id<ProcessSortViewControllerDelegate> delegate;
@end
