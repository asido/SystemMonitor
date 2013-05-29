//
//  RootTableViewController.m
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMLog.h"
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
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:VIEW_CTRL_GENERAL inSection:0]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionTop];
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
    
    if (viewCtrl == self.currentCtrl)
    {
        return;
    }
    self.currentCtrl = viewCtrl;
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(NSInteger)viewCtrl inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionTop];
    
    NSString *identifier = (NSString*)ViewCtrlIdentifiers[viewCtrl];
    UIViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, ctrl, nil];
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
