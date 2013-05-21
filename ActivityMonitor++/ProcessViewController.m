//
//  ProcessViewController.m
//  ActivityMonitor++
//
//  Created by st on 21/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AppDelegate.h"
#import "AMLog.h"
#import "ProcessInfo.h"
#import "ProcessViewController.h"

@interface ProcessViewController ()
- (NSString*)formatStartTime:(time_t)unixTime;
@end

@implementation ProcessViewController

#pragma mark - override

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (NSString*)formatStartTime:(time_t)unixTime
{
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:unixTime];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                                   fromDate:date];
    NSString *dateString = [NSString stringWithFormat:@"%04d-%02d-%02d %d:%02d:%02d",
                            dateComponents.year, dateComponents.month, dateComponents.day, dateComponents.hour, dateComponents.minute, dateComponents.second];
    return dateString;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    return app.iDevice.processes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    enum {
        TAG_ICON_VIEW=1,
        TAG_NAME_LABEL,
        TAG_STATUS_LABEL,
        TAG_START_TIME_LABEL,
        TAG_PID_LABEL,
        TAG_PRIORITY_LABEL,
        TAG_COMMAND_LINE_LABEL
    };
    
    static NSString *CellIdentifier = @"ProcessCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        AMWarn(@"%s: attempt to dequeue reusable cell has failed.", __PRETTY_FUNCTION__);
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIImageView *iconView = (UIImageView*) [cell viewWithTag:TAG_ICON_VIEW];
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:TAG_NAME_LABEL];
    UILabel *statusLabel = (UILabel*) [cell viewWithTag:TAG_STATUS_LABEL];
    UILabel *startTimeLabel = (UILabel*) [cell viewWithTag:TAG_START_TIME_LABEL];
    UILabel *pidLabel = (UILabel*) [cell viewWithTag:TAG_PID_LABEL];
    UILabel *priorityLabel = (UILabel*) [cell viewWithTag:TAG_PRIORITY_LABEL];
    UILabel *commandLineLabel = (UILabel*) [cell viewWithTag:TAG_COMMAND_LINE_LABEL];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    ProcessInfo *process = [app.iDevice.processes objectAtIndex:indexPath.row];
    
    [iconView setImage:process.icon];
    [nameLabel setText:process.name];
    [statusLabel setText:[process getStatusString]];
    [startTimeLabel setText:[self formatStartTime:process.startTime]];
    [pidLabel setText:[NSString stringWithFormat:@"%d", process.pid]];
    [priorityLabel setText:[NSString stringWithFormat:@"%d", process.priority]];
    [commandLineLabel setText:process.commandLine];
    
    return cell;
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

@end
