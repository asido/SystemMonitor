//
//  ProcessSortViewController.h
//  ActivityMonitor++
//
//  Created by st on 22/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProcessSort.h"

@interface iPadProcessSortViewController : UITableViewController
@property (weak, nonatomic) id<ProcessSortViewControllerDelegate> sortDelegate;

- (void)setFilter:(SortFilter_t)filter;
@end
