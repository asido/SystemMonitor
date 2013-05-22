//
//  GPUViewController.m
//  ActivityMonitor++
//
//  Created by st on 09/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AppDelegate.h"
#import "GPUViewController.h"

@interface GPUViewController ()
@end

@implementation GPUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    
    if (section == 0)
    {
        rows = 3;
    }
    else if (section == 1)
    {
        AppDelegate *app = [AppDelegate sharedDelegate];
        rows = app.iDevice.gpuInfo.openGLExtensions.count;
    }
    else
    {
        rows = 0;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0: {
                cell = [tableView dequeueReusableCellWithIdentifier:@"GPUNameCell"];
                UILabel *nameLabel = (UILabel*)[cell viewWithTag:1];
                [nameLabel setText:app.iDevice.gpuInfo.gpuName];
                break;
            }
            case 1: {
                cell = [tableView dequeueReusableCellWithIdentifier:@"OpenGLVersionCell"];
                UILabel *glVersionLabel = (UILabel*)[cell viewWithTag:1];
                [glVersionLabel setText:app.iDevice.gpuInfo.openGLVersion];
                break;
            }
            case 2: {
                cell = [tableView dequeueReusableCellWithIdentifier:@"OpenGLVendorCell"];
                UILabel *glVendorLabel = (UILabel*)[cell viewWithTag:1];
                [glVendorLabel setText:app.iDevice.gpuInfo.openGLVendor];
                break;
            }
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"OpenGLExtensionCell"];
        NSString *extension = [app.iDevice.gpuInfo.openGLExtensions objectAtIndex:indexPath.row];
        UILabel *extensionLabel = (UILabel*)[cell viewWithTag:1];
        [extensionLabel setText:extension];
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return @"OpenGL Extensions";
    }
    
    return nil;
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
