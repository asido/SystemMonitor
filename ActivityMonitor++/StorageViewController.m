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
    
    AppDelegate      *app = [AppDelegate sharedDelegate];
    DeviceSpecificUI *ui = app.deviceSpecificUI;

    [self updateInfoLabels];
    
    self.glTubeView = [[GLKView alloc] initWithFrame:ui.GLtubeGLKViewFrame];
    self.glTubeView.opaque = NO;
    self.glTubeView.backgroundColor = [UIColor clearColor];
    self.glTube = [[GLTube alloc] initWithGLKView:self.glTubeView fromValue:0 toValue:app.iDevice.storageInfo.totalSapce];
    
    [self.glTube setValue:app.iDevice.storageInfo.usedSpace];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    app.storageInfoCtrl.delegate = self;
    
    [app.iDevice refreshStorageInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    app.storageInfoCtrl.delegate = nil;
}

#pragma mark - private

- (void)updateInfoLabels
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    [self.totalStorageLabel setText:[AMUtils toNearestMetric:app.iDevice.storageInfo.totalSapce desiredFraction:2]];
    [self.freeStorageLabel setText:[AMUtils toNearestMetric:app.iDevice.storageInfo.freeSpace desiredFraction:2]];
    [self.usedStorageLabel setText:[AMUtils toNearestMetric:app.iDevice.storageInfo.usedSpace desiredFraction:2]];
    [self.numberOfSongsLabel setText:[NSString stringWithFormat:@"%d", app.iDevice.storageInfo.songCount]];
    [self.numberOfPicturesLabel setText:[NSString stringWithFormat:@"%d (%@)", app.iDevice.storageInfo.pictureCount, [AMUtils toNearestMetric:app.iDevice.storageInfo.totalPictureSize desiredFraction:1]]];
    [self.numberOfVideosLabel setText:[NSString stringWithFormat:@"%d (%@)", app.iDevice.storageInfo.videoCount, [AMUtils toNearestMetric:app.iDevice.storageInfo.totalVideoSize desiredFraction:1]]];
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
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    [self.glTube setValue:app.iDevice.storageInfo.usedSpace];
}

@end
