//
//  StorageViewController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AppDelegate.h"
#import "AMUtils.h"
#import "GLTube.h"
#import "StorageViewController.h"

enum {
    SECTION_STORAGE_TUBE=0
};

@interface StorageViewController() <StorageInfoControllerDelegate>
@property (nonatomic, strong) GLTube    *glTube;
@property (nonatomic, strong) GLKView   *glTubeView;

- (void)updateInfoLabels;

@property (nonatomic, weak) IBOutlet UILabel *totalStorageLabel;
@property (nonatomic, weak) IBOutlet UILabel *freeStorageLabel;
@property (nonatomic, weak) IBOutlet UILabel *usedStorageLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfSongsLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfPicturesLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfVideosLabel;
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
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ViewBackground-1496"]]];
    
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
    [self.numberOfSongsLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)app.iDevice.storageInfo.songCount]];
    [self.numberOfPicturesLabel setText:[NSString stringWithFormat:@"%lu (%@)", (unsigned long)app.iDevice.storageInfo.pictureCount, [AMUtils toNearestMetric:app.iDevice.storageInfo.totalPictureSize desiredFraction:1]]];
    [self.numberOfVideosLabel setText:[NSString stringWithFormat:@"%lu (%@)", (unsigned long)app.iDevice.storageInfo.videoCount, [AMUtils toNearestMetric:app.iDevice.storageInfo.totalVideoSize desiredFraction:1]]];
}

#pragma mark - Table view data source

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TubeBackground"]];
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

    return 0.0;
}

#pragma mark - StorageInfoController delegate

- (void)storageInfoUpdated
{
    [self updateInfoLabels];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    [self.glTube setValue:app.iDevice.storageInfo.usedSpace];
}

@end
