//
//  BatteryViewController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AppDelegate.h"
#import "GLTube.h"
#import "BatteryViewController.h"

enum {
    SECTION_BATTERY_TUBE=1
};

@interface BatteryViewController() <BatteryInfoControllerDelegate>
@property (nonatomic, strong) GLTube    *glBatteryTube;
@property (nonatomic, strong) GLKView   *glView;

@property (nonatomic, weak) IBOutlet UILabel *batteryCapacityLabel;
@property (nonatomic, weak) IBOutlet UILabel *batteryVoltageLabel;
@property (nonatomic, weak) IBOutlet UILabel *batteryStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *batteryLevelLabel;

- (void)updateBatteryLabels;
@end

@implementation BatteryViewController

#pragma mark - override

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ViewBackground-1496"]]];
    
    DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
    self.glView = [[GLKView alloc] initWithFrame:ui.GLtubeGLKViewFrame];
    self.glView.opaque = NO;
    self.glView.backgroundColor = [UIColor clearColor];
    self.glBatteryTube = [[GLTube alloc] initWithGLKView:self.glView fromValue:0.0 toValue:100.0];
    
    [self updateBatteryLabels];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    app.batteryInfoCtrl.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    app.batteryInfoCtrl.delegate = nil;
}

#pragma mark - private

- (void)updateBatteryLabels
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    [self.batteryCapacityLabel setText:[NSString stringWithFormat:@"%ld mAh", (long)app.iDevice.batteryInfo.capacity]];
    [self.batteryVoltageLabel setText:[NSString stringWithFormat:@"%0.1f V", app.iDevice.batteryInfo.voltage]];
    [self.batteryStatusLabel setText:app.iDevice.batteryInfo.status];
    [self.batteryLevelLabel setText:[NSString stringWithFormat:@"%ld %% (%ld mAh)", (long)app.iDevice.batteryInfo.levelPercent, (long)app.iDevice.batteryInfo.levelMAH]];
    
    [self.glBatteryTube setValue:app.iDevice.batteryInfo.levelPercent];
}

#pragma mark - table delegate

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == SECTION_BATTERY_TUBE)
    {
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TubeBackground"]];
        CGRect frame = backgroundView.frame;
        frame.origin.y = 20;
        backgroundView.frame = frame;
        UIView *view = [[UIView alloc] initWithFrame:self.glView.frame];
        [view addSubview:backgroundView];
        [view sendSubviewToBack:backgroundView];
        [view addSubview:self.glView];
        return view;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == SECTION_BATTERY_TUBE)
    {
        DeviceSpecificUI *ui = [AppDelegate sharedDelegate].deviceSpecificUI;
        return ui.GLtubeGLKViewFrame.size.height + 20;
    }
    
    return 0.0;
}

#pragma mark - BatteryInfoController delegate

- (void)batteryStatusUpdated
{
    [self updateBatteryLabels];
}

@end
