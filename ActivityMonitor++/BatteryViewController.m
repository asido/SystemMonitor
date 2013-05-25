//
//  BatteryViewController.m
//  ActivityMonitor++
//
//  Created by st on 24/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AppDelegate.h"
#import "GLTube.h"
#import "BatteryViewController.h"

enum {
    SECTION_BATTERY_TUBE=1
};

@interface BatteryViewController() <BatteryInfoControllerDelegate>
@property (strong, nonatomic) GLTube    *glBatteryTube;
@property (strong, nonatomic) GLKView   *glView;

@property (weak, nonatomic) IBOutlet UILabel *batteryCapacityLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryVoltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;

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
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]]];
    
    self.glView = [[GLKView alloc] initWithFrame:CGRectMake(5.0f, 10.0f, 693.0f, 100.0f)];
    self.glView.opaque = NO;
    self.glView.backgroundColor = [UIColor clearColor];
    self.glBatteryTube = [[GLTube alloc] initWithGLKView:self.glView fromValue:0.0f toValue:100.0f];
    
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
    
    [self.batteryCapacityLabel setText:[NSString stringWithFormat:@"%d mAh", app.iDevice.batteryInfo.capacity]];
    [self.batteryVoltageLabel setText:[NSString stringWithFormat:@"%0.1f V", app.iDevice.batteryInfo.voltage]];
    [self.batteryStatusLabel setText:app.iDevice.batteryInfo.status];
    [self.batteryLevelLabel setText:[NSString stringWithFormat:@"%d %% (%d mAh)", app.iDevice.batteryInfo.levelPercent, app.iDevice.batteryInfo.levelMAH]];
    
    [self.glBatteryTube setValue:app.iDevice.batteryInfo.levelPercent];
}

#pragma mark - table delegate

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == SECTION_BATTERY_TUBE)
    {
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TubeBackground-180.png"]];
        CGRect frame = backgroundView.frame;
        frame.origin.y = 20;
        backgroundView.frame = frame;
        UIView *view = [[UIView alloc] initWithFrame:self.glView.frame];
        [view addSubview:backgroundView];
        [view sendSubviewToBack:backgroundView];
        [view addSubview:self.glView];
        return view;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == SECTION_BATTERY_TUBE)
    {
        return 120.0f;
    }
    else
    {
        return 0.0f;
    }
}

#pragma mark - BatteryInfoController delegate

- (void)batteryStatusUpdated
{
    [self updateBatteryLabels];
}

@end
