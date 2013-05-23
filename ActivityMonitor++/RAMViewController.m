//
//  RAMViewController.m
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AppDelegate.h"
#import "GLLineGraph.h"
#import "RAMViewController.h"

@interface RAMViewController() <RAMInfoControllerDelegate>
@property (strong, nonatomic) GLLineGraph   *glGraph;
@property (strong, nonatomic) GLKView       *ramUsageGLView;

@property (weak, nonatomic) IBOutlet UILabel *totalRamLabel;
@property (weak, nonatomic) IBOutlet UILabel *ramTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *wiredRamLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeRamLabel;
@property (weak, nonatomic) IBOutlet UILabel *inactiveRamLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeRamLabel;

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
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]]];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    [self.totalRamLabel setText:[NSString stringWithFormat:@"%d MB", app.iDevice.ramInfo.totalRam]];
    [self.ramTypeLabel setText:app.iDevice.ramInfo.ramType];
    
    self.ramUsageGLView = [[GLKView alloc] initWithFrame:CGRectMake(0.0f, 30.0f, 703.0f, 200.0f)];
    self.ramUsageGLView.opaque = NO;
    self.ramUsageGLView.backgroundColor = [UIColor clearColor];
    
    self.glGraph = [[GLLineGraph alloc] initWithGLKView:self.ramUsageGLView
                                          dataLineCount:1
                                              fromValue:0.0f
                                                toValue:app.iDevice.ramInfo.totalRam
                                                legends:[NSArray arrayWithObject:@"RAM used:"]];
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
        RAMUsage *usage = [usageHistory objectAtIndex:i];
        NSNumber *value = [NSNumber numberWithInteger:usage.usedRam];
        [usageArray addObject:[NSArray arrayWithObject:value]];
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
    [self.wiredRamLabel setText:[NSString stringWithFormat:@"%d MB", usage.wiredRam]];
    [self.activeRamLabel setText:[NSString stringWithFormat:@"%d MB", usage.activeRam]];
    [self.inactiveRamLabel setText:[NSString stringWithFormat:@"%d MB", usage.inactiveRam]];
    [self.freeRamLabel setText:[NSString stringWithFormat:@"%d MB", usage.freeRam]];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 280.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CpuGraphBackground-464.png"]];
    CGRect frame = backgroundView.frame;
    frame.origin.y = 20;
    backgroundView.frame = frame;
    UIView *view = [[UIView alloc] initWithFrame:self.ramUsageGLView.frame];
    [view addSubview:backgroundView];
    [view sendSubviewToBack:backgroundView];
    [view addSubview:self.ramUsageGLView];
    return view;
}

#pragma mark - RAMInfoController delegate

- (void)ramUsageUpdated:(RAMUsage*)usage
{
    [self updateUsageLabels:usage];
    
    NSNumber *number = [NSNumber numberWithInteger:usage.usedRam];
    [self.glGraph addDataValue:[NSArray arrayWithObject:number]];
}

@end
