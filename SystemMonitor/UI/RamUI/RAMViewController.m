//
//  RAMViewController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AMUtils.h"
#import "AppDelegate.h"
#import "GLLineGraph.h"
#import "RAMViewController.h"
#import "AMCommonUI.h"

enum {
    SECTION_MEMORY_INFO=0,
    SECTION_MEMORY_USAGE
};

@interface RAMViewController() <RAMInfoControllerDelegate>
@property (nonatomic, strong) GLLineGraph   *glGraph;
@property (nonatomic, strong) GLKView       *ramUsageGLView;

@property (nonatomic, weak) IBOutlet UILabel *totalRamLabel;
@property (nonatomic, weak) IBOutlet UILabel *ramTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *wiredRamLabel;
@property (nonatomic, weak) IBOutlet UILabel *activeRamLabel;
@property (nonatomic, weak) IBOutlet UILabel *inactiveRamLabel;
@property (nonatomic, weak) IBOutlet UILabel *freeRamLabel;
@property (nonatomic, weak) IBOutlet UILabel *pageInsLabel;
@property (nonatomic, weak) IBOutlet UILabel *pageOutsLabel;
@property (nonatomic, weak) IBOutlet UILabel *pageFaultsLabel;

- (void)updateUsageLabels:(RAMUsage*)usage;
@end

@implementation RAMViewController
@synthesize glGraph;
@synthesize ramUsageGLView;

#pragma mark - override

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundView:[AMCommonUI sectionBackgroundView]];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    [self.totalRamLabel setText:[AMUtils toNearestMetric:(uint64_t)app.iDevice.ramInfo.totalRam desiredFraction:0]];
    [self.ramTypeLabel setText:app.iDevice.ramInfo.ramType];
    
    self.ramUsageGLView = [[GLKView alloc] initWithFrame:CGRectMake(0.0, 30.0, app.deviceSpecificUI.GLdataLineGraphWidth, 200.0)];
    self.ramUsageGLView.opaque = NO;
    self.ramUsageGLView.backgroundColor = [UIColor clearColor];
    
    self.glGraph = [[GLLineGraph alloc] initWithGLKView:self.ramUsageGLView
                                          dataLineCount:1
                                              fromValue:0.0
                                                toValue:app.iDevice.ramInfo.totalRam
                                                topLegend:[AMUtils toNearestMetric:(uint64_t)app.iDevice.ramInfo.totalRam desiredFraction:0]];
    self.glGraph.useClosestMetrics = YES;
    self.glGraph.preferredFramesPerSecond = kRamUsageUpdateFrequency;
    
    [app.ramInfoCtrl setRAMUsageHistorySize:[self.glGraph requiredElementToFillGraph]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    // Make sure the labels are not empty.
    RAMUsage *usage = [app.ramInfoCtrl.ramUsageHistory lastObject];
    if (usage)
    {
        [self updateUsageLabels:usage];
    }
    
    NSMutableArray *usageArray = [[NSMutableArray alloc] initWithCapacity:app.ramInfoCtrl.ramUsageHistory.count];
    NSArray *usageHistory = [NSArray arrayWithArray:app.ramInfoCtrl.ramUsageHistory];
    
    for (NSUInteger i = 0; i < usageHistory.count; ++i)
    {
        RAMUsage *usage = usageHistory[i];
        [usageArray addObject:@[ @(usage.usedRam) ]];
    }
    [self.glGraph resetDataArray:usageArray];
    
    app.ramInfoCtrl.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    app.ramInfoCtrl.delegate = nil;
}

#pragma mark - private

- (void)updateUsageLabels:(RAMUsage*)usage
{
    [self.wiredRamLabel setText:[AMUtils toNearestMetric:usage.wiredRam desiredFraction:1]];
    [self.activeRamLabel setText:[AMUtils toNearestMetric:usage.activeRam desiredFraction:1]];
    [self.inactiveRamLabel setText:[AMUtils toNearestMetric:usage.inactiveRam desiredFraction:1]];
    [self.freeRamLabel setText:[AMUtils toNearestMetric:usage.freeRam desiredFraction:1]];
    [self.pageInsLabel setText:[NSString stringWithFormat:@"%lld", usage.pageIns]];
    [self.pageOutsLabel setText:[NSString stringWithFormat:@"%lld", usage.pageOuts]];
    [self.pageFaultsLabel setText:[NSString stringWithFormat:@"%lld", usage.pageFaults]];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == SECTION_MEMORY_USAGE)
    {
        return 240.0;
    }
    else
    {
        return 0.0;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == SECTION_MEMORY_USAGE)
    {
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LineGraphBackground-414"]];
        CGRect frame = backgroundView.frame;
        frame.origin.y = 20;
        backgroundView.frame = frame;
        UIView *view = [[UIView alloc] initWithFrame:self.ramUsageGLView.frame];
        [view addSubview:backgroundView];
        [view sendSubviewToBack:backgroundView];
        [view addSubview:self.ramUsageGLView];
        return view;
    }
    else
    {
        return nil;
    }
}

#pragma mark - RAMInfoController delegate

- (void)ramUsageUpdated:(RAMUsage*)usage
{
    [self updateUsageLabels:usage];
    [self.glGraph addDataValue:@[ @(usage.usedRam) ]];
}

@end
