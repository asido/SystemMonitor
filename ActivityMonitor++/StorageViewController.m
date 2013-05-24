//
//  StorageViewController.m
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "GLTube.h"
#import "StorageViewController.h"

@interface StorageViewController ()
@property (strong, nonatomic) GLTube    *glTube;
@property (strong, nonatomic) GLKView   *glTubeView;
@end

@implementation StorageViewController
@synthesize glTube;
@synthesize glTubeView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]]];
    
    self.glTubeView = [[GLKView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 703.0f, 100.0f)];
    self.glTubeView.opaque = NO;
    self.glTubeView.backgroundColor = [UIColor clearColor];
    self.glTube = [[GLTube alloc] initWithGLKView:self.glTubeView fromValue:0 toValue:100];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LineGraphBackground-464.png"]];
    CGRect frame = backgroundView.frame;
    frame.origin.y = 20;
    backgroundView.frame = frame;
    UIView *view = [[UIView alloc] initWithFrame:self.glTubeView.frame];
    [view addSubview:backgroundView];
    [view sendSubviewToBack:backgroundView];
    [view addSubview:self.glTubeView];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 180.0f;
}

@end
