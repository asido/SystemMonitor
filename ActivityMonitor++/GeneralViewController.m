//
//  OperatingSystemViewController.m
//  ActivityMonitor++
//
//  Created by st on 08/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AppDelegate.h"
#import "GeneralViewController.h"

@interface GeneralViewController ()
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@end

@implementation GeneralViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    NSString *deviceName = [NSString stringWithFormat:@"Apple %@", app.iDevice.deviceInfo.deviceName];
    [self.deviceLabel setText:deviceName];
}

@end
