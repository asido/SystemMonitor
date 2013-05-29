//
//  GPUViewController.m
//  ActivityMonitor++
//
//  Created by st on 09/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMLog.h"
#import "AppDelegate.h"
#import "GPUViewController.h"

enum Section {
    SECTION_GPU=0,
    SECTION_OPENGL=1,
    SECTION_OPENGL_EXTENSIONS=2,
    SECTION_MAX=3
};

enum GPURow {
    GPU_ROW_GPU=0,
    GPU_ROW_MAX=1
};

enum OpenGLRow {
    OPENGL_ROW_VERSION=0,
    OPENGL_ROW_VENDOR=1,
    OPENGL_ROW_MAX=2
};

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
    return SECTION_MAX;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_GPU:
            return GPU_ROW_MAX;
        case SECTION_OPENGL:
            return OPENGL_ROW_MAX;
        case SECTION_OPENGL_EXTENSIONS:
            return [AppDelegate sharedDelegate].iDevice.gpuInfo.openGLExtensions.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    switch (indexPath.section) {
        case SECTION_GPU: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"GPUNameCell"];
            if (!cell)
            {
                AMWarn(@"cell == nil with identifier 'GPUNameCell'");
            }
            UILabel *nameLabel = (UILabel*)[cell viewWithTag:1];
            [nameLabel setText:app.iDevice.gpuInfo.gpuName];
            break;
        }
        case SECTION_OPENGL: {
            switch (indexPath.row) {
                case OPENGL_ROW_VERSION: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"OpenGLVersionCell"];
                    if (!cell)
                    {
                        AMWarn(@"cell == nil with identifier 'OpenGLVersionCell'");
                    }
                    UILabel *glVersionLabel = (UILabel*)[cell viewWithTag:1];
                    [glVersionLabel setText:app.iDevice.gpuInfo.openGLVersion];
                    break;
                }
                case OPENGL_ROW_VENDOR: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"OpenGLVendorCell"];
                    if (!cell)
                    {
                        AMWarn(@"cell == nil with identifier 'OpenGLVendorCell'");
                    }
                    UILabel *glVendorLabel = (UILabel*)[cell viewWithTag:1];
                    [glVendorLabel setText:app.iDevice.gpuInfo.openGLVendor];
                    break;
                }
                default:
                    AMWarn(@"invalid row(%d) for section(%d)", indexPath.section, indexPath.row);
                    break;
            }
            break;
        }
        case SECTION_OPENGL_EXTENSIONS: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OpenGLExtensionCell"];
            NSString *extension = [app.iDevice.gpuInfo.openGLExtensions objectAtIndex:indexPath.row];
            UILabel *extensionLabel = (UILabel*)[cell viewWithTag:1];
            [extensionLabel setText:extension];
            break;
        }
        default:
            AMWarn(@"invalid section(%d)", indexPath.section);
            break;
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_GPU:
            return @"GPU Information";
        case SECTION_OPENGL:
            return @"OpenGL Information";
        case SECTION_OPENGL_EXTENSIONS:
            return @"OpenGL Extensions";
        default:
            return nil;
    }
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
