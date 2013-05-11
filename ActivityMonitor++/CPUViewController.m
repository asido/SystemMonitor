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

@interface CPUViewController() <CPUInfoControllerDelegate>
@property (retain) GLLineGraph *glGraph;
@property (weak, nonatomic) IBOutlet GLKView *cpuUsageGLView;

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

static const NSUInteger CPU_LOAD_UPDATES_PER_SEC = 5;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
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
    
    [app.cpuInfoCtrl setDelegate:self];
    [app.cpuInfoCtrl startCPULoadUpdatesWithFrequency:CPU_LOAD_UPDATES_PER_SEC];
    
    self.glGraph = [[GLLineGraph alloc] initWithGLKView:self.cpuUsageGLView
                                          dataLineCount:1
                                              fromValue:0.0f toValue:100.0f
                                            rangeTitles:[NSArray arrayWithObjects:@"0%", @"50%", @"100%", nil]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - CPUInfoController delegate

- (void)cpuLoadUpdated:(NSArray *)loadArray
{
//    for (NSUInteger i = 0; i < loadArray.count; ++i)
    {
        CPULoad *cpuLoad = [loadArray objectAtIndex:0];
        double totalLoad = cpuLoad.system + cpuLoad.user + cpuLoad.nice;
        NSLog(@"CORE %d  [[ %d%% ]]", 1, (NSUInteger)totalLoad);
        
        [self.glGraph appendDataValue:totalLoad];
    }
}

@end
