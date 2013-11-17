//
//  iPhoneRootTableViewController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "RootCell.h"
#import "RootTableViewController.h"
#import "iPhoneRootTableViewController.h"
#import "AMUtils.h"

@implementation iPhoneRootTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-Left-748.png"]]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - private

- (void)switchView:(ViewCtrl_t)viewCtrl
{
    NSParameterAssert(viewCtrl < VIEW_CTRL_MAX);
    
    if (viewCtrl == VIEW_CTRL_RATE_US)
    {
        // Deselect the row.
        NSIndexPath *rateUsIndexPath = [[self tableView] indexPathForSelectedRow];
        [[self tableView] deselectRowAtIndexPath:rateUsIndexPath animated:YES];
        
        [AMUtils openReviewAppPage];
    }
    else
    {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(NSInteger)viewCtrl inSection:0]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionTop];
        
        NSString *identifier = (NSString*)ViewCtrlIdentifiers[viewCtrl];
        UIViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RootCell *cell = (RootCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    assert(cell);
    
    NSString *cellBg = nil;
    if (indexPath.row == 0)
    {
        cellBg = @"RootCellTop-dark-88.png";
    }
    else
    {
        cellBg = @"RootCellFollowing-dark-88.png";
    }
    [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:cellBg]]];
    
    [cell setCellIconImage:[UIImage imageNamed:CellImageFilenames[indexPath.row]]];
    [cell setHighlightedCellIconImage:[UIImage imageNamed:CellHighlightImageFilenames[indexPath.row]]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewCtrl_t viewCtrl = (ViewCtrl_t)indexPath.row;
    [self switchView:viewCtrl];
}

@end
