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

typedef enum {
    VIEW_CTRL_GENERAL=0,
    VIEW_CTRL_CPU,
    VIEW_CTRL_PROCESSES,
    VIEW_CTRL_RAM,
    VIEW_CTRL_GPU,
    VIEW_CTRL_NETWORK,
    VIEW_CTRL_CONNECTIONS,
    VIEW_CTRL_STORAGE,
    VIEW_CTRL_BATTERY,
    VIEW_CTRL_MAX
} ViewCtrl_t;

@interface RootTableViewController ()
@property (assign, nonatomic) ViewCtrl_t currentCtrl;

- (void)switchView:(ViewCtrl_t)viewCtrl;
@end

@implementation RootTableViewController
@synthesize currentCtrl;

static const NSString *ViewCtrlIdentifiers[] = {
    [VIEW_CTRL_GENERAL]     = @"GeneralViewController",
    [VIEW_CTRL_CPU]         = @"CPUViewController",
    [VIEW_CTRL_PROCESSES]   = @"ProcessViewController",
    [VIEW_CTRL_RAM]         = @"RAMViewController",
    [VIEW_CTRL_GPU]         = @"GPUViewController",
    [VIEW_CTRL_NETWORK]     = @"NetworkViewController",
    [VIEW_CTRL_CONNECTIONS] = @"ConnectionViewController",
    [VIEW_CTRL_STORAGE]     = @"StorageViewController",
    [VIEW_CTRL_BATTERY]     = @"BatteryViewController"
};

static NSString *CellImageFilenames[] = {
    [VIEW_CTRL_GENERAL]     = @"GeneralIcon-normal.png",
    [VIEW_CTRL_CPU]         = @"CpuIcon-normal.png",
    [VIEW_CTRL_PROCESSES]   = @"ProcessesIcon-normal.png",
    [VIEW_CTRL_RAM]         = @"RamIcon-normal.png",
    [VIEW_CTRL_GPU]         = @"GpuIcon-normal.png",
    [VIEW_CTRL_NETWORK]     = @"NetworkIcon-normal.png",
    [VIEW_CTRL_CONNECTIONS] = @"ConnectionsIcon-normal.png",
    [VIEW_CTRL_STORAGE]     = @"StorageIcon-normal.png",
    [VIEW_CTRL_BATTERY]     = @"BatteryIcon-normal.png"
};

static NSString *CellHighlightImageFilenames[] = {
    [VIEW_CTRL_GENERAL]     = @"GeneralIcon-highlight.png",
    [VIEW_CTRL_CPU]         = @"CpuIcon-highlight.png",
    [VIEW_CTRL_PROCESSES]   = @"ProcessesIcon-highlight.png",
    [VIEW_CTRL_RAM]         = @"RamIcon-highlight.png",
    [VIEW_CTRL_GPU]         = @"GpuIcon-highlight.png",
    [VIEW_CTRL_NETWORK]     = @"NetworkIcon-highlight.png",
    [VIEW_CTRL_CONNECTIONS] = @"ConnectionsIcon-highlight.png",
    [VIEW_CTRL_STORAGE]     = @"StorageIcon-highlight.png",
    [VIEW_CTRL_BATTERY]     = @"BatteryIcon-highlight.png"
};

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

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
