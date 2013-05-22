//
//  CPUViewController.m
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "GLLineGraph.h"
#import "AppDelegate.h"
#import "CPUInfoController.h"
#import "CPUViewController.h"

@interface CPUViewController() <CPUInfoControllerDelegate, GLLineGraphDelegate>
@property (strong, nonatomic) GLKView       *cpuUsageGLView;
@property (strong, nonatomic) GLLineGraph   *glGraph;

@property (weak, nonatomic) IBOutlet UILabel *cpuNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *architectureLabel;
@property (weak, nonatomic) IBOutlet UILabel *physicalCoresLabel;
@property (weak, nonatomic) IBOutlet UILabel *logicalCoresLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxLogicalCoresLabel;
@property (weak, nonatomic) IBOutlet UILabel *frequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *l1iCacheLabel;
@property (weak, nonatomic) IBOutlet UILabel *l1dCacheLabel;
@property (weak, nonatomic) IBOutlet UILabel *l2CacheLabel;
@property (weak, nonatomic) IBOutlet UILabel *l3CacheLabel;
@property (weak, nonatomic) IBOutlet UILabel *endianessLabel;
@end

@implementation CPUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]]];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    [self.cpuNameLabel setText:app.iDevice.cpuInfo.cpuName];
    [self.architectureLabel setText:app.iDevice.cpuInfo.cpuSubtype];
    [self.physicalCoresLabel setText:[NSString stringWithFormat:@"%u", app.iDevice.cpuInfo.physicalCPUCount]];
    [self.logicalCoresLabel setText:[NSString stringWithFormat:@"%u", app.iDevice.cpuInfo.logicalCPUCount]];
    [self.maxLogicalCoresLabel setText:[NSString stringWithFormat:@"%u", app.iDevice.cpuInfo.logicalCPUMaxCount]];
    [self.frequencyLabel setText:[NSString stringWithFormat:@"%u MHz", app.iDevice.cpuInfo.cpuFrequency]];
    [self.l1iCacheLabel setText:(app.iDevice.cpuInfo.l1ICache == 0 ? @"-" : [NSString stringWithFormat:@"%d KB", app.iDevice.cpuInfo.l1ICache])];
    [self.l1dCacheLabel setText:(app.iDevice.cpuInfo.l1DCache == 0 ? @"-" : [NSString stringWithFormat:@"%d KB", app.iDevice.cpuInfo.l1DCache])];
    [self.l2CacheLabel setText:(app.iDevice.cpuInfo.l2Cache == 0 ? @"-" : [NSString stringWithFormat:@"%d KB", app.iDevice.cpuInfo.l2Cache])];
    [self.l3CacheLabel setText:(app.iDevice.cpuInfo.l3Cache == 0 ? @"-" : [NSString stringWithFormat:@"%d KB", app.iDevice.cpuInfo.l3Cache])];
    [self.endianessLabel setText:app.iDevice.cpuInfo.endianess];
    
    self.cpuUsageGLView = [[GLKView alloc] initWithFrame:CGRectMake(0.0f, 30.0f, 703.0f, 200.0f)];
    self.cpuUsageGLView.opaque = NO;
    self.cpuUsageGLView.backgroundColor = [UIColor clearColor];
    
    self.glGraph = [[GLLineGraph alloc] initWithGLKView:self.cpuUsageGLView
                                          dataLineCount:1
                                              fromValue:0.0f toValue:100.0f
                                                legends:[NSArray arrayWithObjects:@"0%", @"50%", @"100%", nil]
                                               delegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    NSArray *cpuLoadArray = [app.cpuInfoCtrl cpuLoadHistory];
    NSMutableArray *graphData = [NSMutableArray arrayWithCapacity:cpuLoadArray.count];
    CGFloat avr;
    
    for (NSUInteger i = 0; i < cpuLoadArray.count; ++i)
    {
        NSArray *data = [cpuLoadArray objectAtIndex:i];
        avr = 0;
        
        for (NSUInteger j = 0; j < data.count; ++j)
        {
            CPULoad *load = [data objectAtIndex:j];
            avr += load.total;
        }
        avr /= data.count;
        
        [graphData addObject:[NSArray arrayWithObject:[NSNumber numberWithFloat:avr]]];
    }
    
    [self.glGraph resetDataArray:graphData];
    app.cpuInfoCtrl.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    app.cpuInfoCtrl.delegate = nil;
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
    UIView *view = [[UIView alloc] initWithFrame:self.cpuUsageGLView.frame];
    [view addSubview:backgroundView];
    [view sendSubviewToBack:backgroundView];
    [view addSubview:self.cpuUsageGLView];
    return view;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - CPUInfoController delegate

- (void)cpuLoadUpdated:(NSArray *)loadArray
{
    CGFloat avr = 0;
    
    for (CPULoad *load in loadArray)
    {
        avr += load.total;
    }
    avr /= loadArray.count;
    
    NSNumber *number = [NSNumber numberWithFloat:avr];
    [self.glGraph addDataValue:[NSArray arrayWithObject:number]];
}

#pragma mark - GLLineGraph delegate

- (void)graphFinishedInitializing
{
  //  AppDelegate *app = [AppDelegate sharedDelegate];
  //  [app.cpuInfoCtrl setDelegate:self];
}

@end
