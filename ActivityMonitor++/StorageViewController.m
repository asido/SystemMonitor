//
//  StorageViewController.m
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AppDelegate.h"
#import "AMUtils.h"
#import "GLTube.h"
#import "StorageViewController.h"

enum {
    SECTION_STORAGE_TUBE=0
};

@interface StorageViewController() <StorageInfoControllerDelegate>
@property (strong, nonatomic) GLTube    *glTube;
@property (strong, nonatomic) GLKView   *glTubeView;

- (void)updateInfoLabels;

@property (weak, nonatomic) IBOutlet UILabel *totalStorageLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeStorageLabel;
@property (weak, nonatomic) IBOutlet UILabel *usedStorageLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSongsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPicturesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfVideosLabel;
@end

@implementation StorageViewController
@synthesize glTube;
@synthesize glTubeView;

#pragma mark - override

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]]];
    
    [self updateInfoLabels];
    
    AppDelegate      *app = [AppDelegate sharedDelegate];
    DeviceSpecificUI *ui = app.deviceSpecificUI;
    
    self.glTubeView = [[GLKView alloc] initWithFrame:ui.GLtubeGLKViewFrame];
    self.glTubeView.opaque = NO;
    self.glTubeView.backgroundColor = [UIColor clearColor];
    self.glTube = [[GLTube alloc] initWithGLKView:self.glTubeView fromValue:0 toValue:app.iDevice.storageInfo.totalSapce];
    
    [self.glTube setValue:app.iDevice.storageInfo.usedSpace];
}

#pragma mark - private

- (void)updateInfoLabels
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    [self.totalStorageLabel setText:[NSString stringWithFormat:@"%0.2f GB", KB_TO_GB(app.iDevice.storageInfo.totalSapce)]];
    [self.freeStorageLabel setText:[NSString stringWithFormat:@"%0.2f GB", KB_TO_GB(app.iDevice.storageInfo.freeSpace)]];
    [self.usedStorageLabel setText:[NSString stringWithFormat:@"%0.2f GB", KB_TO_GB(app.iDevice.storageInfo.usedSpace)]];
    [self.numberOfSongsLabel setText:[NSString stringWithFormat:@"%d", app.iDevice.storageInfo.songCount]];
    [self.numberOfPicturesLabel setText:[NSString stringWithFormat:@"%d (%0.1f MB)", app.iDevice.storageInfo.pictureCount, KB_TO_MB(app.iDevice.storageInfo.totalPictureSize)]];
    [self.numberOfVideosLabel setText:[NSString stringWithFormat:@"%d (%0.1f MB)", app.iDevice.storageInfo.videoCount, KB_TO_MB(app.iDevice.storageInfo.totalVideoSize)]];
}

#pragma mark - Table view data source

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ui.GLtubeBackgroundFilename]];
        CGRect frame = backgroundView.frame;
        frame.origin.y = 20;
        backgroundView.frame = frame;
        UIView *view = [[UIView alloc] initWithFrame:self.glTubeView.frame];
        [view addSubview:backgroundView];
        [view sendSubviewToBack:backgroundView];
        [view addSubview:self.glTubeView];
        return view;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == SECTION_STORAGE_TUBE)
    {
        DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
        return ui.GLtubeGLKViewFrame.size.height + 20;
    }

    return 0.0f;
}

#pragma mark - StorageInfoController delegate

- (void)storageInfoUpdated
{
    [self updateInfoLabels];
}

@end
