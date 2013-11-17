//
//  RootTableViewController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AMLogger.h"
#import "AMUtils.h"
#import "RootCell.h"
#import "RootTableViewController.h"
#import "iPadRootTableViewController.h"

@interface iPadRootTableViewController()
@property (assign, nonatomic) ViewCtrl_t currentCtrl;
@end

@implementation iPadRootTableViewController
@synthesize currentCtrl;

#pragma mark - override

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-Left-748.png"]]];
    
    self.currentCtrl = -1;
    NSIndexPath *generalIndexPath = [NSIndexPath indexPathForRow:VIEW_CTRL_GENERAL inSection:0];
    [self tableView:[self tableView] didSelectRowAtIndexPath:generalIndexPath];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // A bit ugly, but for some reason the row gets deselected if setting it selected without delay.
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:VIEW_CTRL_GENERAL inSection:0];
        [[self tableView] selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)switchView:(ViewCtrl_t)viewCtrl
{
    NSParameterAssert(viewCtrl < VIEW_CTRL_MAX);
    
    if (viewCtrl == VIEW_CTRL_RATE_US)
    {
        // Keep the old cell selected.
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(NSInteger)[self currentCtrl] inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        
        [AMUtils openReviewAppPage];
    }
    else
    {
        if (viewCtrl == self.currentCtrl)
        {
            return;
        }
        self.currentCtrl = viewCtrl;
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(NSInteger)viewCtrl inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        
        NSString *identifier = (NSString*)ViewCtrlIdentifiers[viewCtrl];
        UIViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        UINavigationController *navigationCtrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
        [[navigationCtrl navigationBar] setBarStyle:UIBarStyleBlack];
        [[navigationCtrl navigationBar] setTranslucent:YES];
        self.splitViewController.viewControllers = @[[self navigationController], navigationCtrl];
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
