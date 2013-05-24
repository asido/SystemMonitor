//
//  NetworkViewController.m
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "GLLineGraph.h"
#import "AppDelegate.h"
#import "AMLog.h"
#import "NetworkInfoController.h"
#import "NetworkViewController.h"

enum {
    SECTION_WiFi=0,
    SECTION_WWAN
};

@interface NetworkViewController() <NetworkInfoControllerDelegate>
@property (strong, nonatomic) GLLineGraph   *wifiGraph;
@property (strong, nonatomic) GLKView       *wifiGLView;

@property (weak, nonatomic) IBOutlet UILabel *wifiIPAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiNetmaskLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiBroadcastAdressLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiMacAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiTotalUpLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiTotalDownLabel;


@property (strong, nonatomic) GLLineGraph   *wwanGraph;
@property (strong, nonatomic) GLKView       *wwanGLView;

@property (weak, nonatomic) IBOutlet UILabel *wwanIPAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *wwanNetmaskLabel;
@property (weak, nonatomic) IBOutlet UILabel *wwanBroadcastAddressLabe;
@property (weak, nonatomic) IBOutlet UILabel *wwanMacAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *wwanTotalUpLabel;
@property (weak, nonatomic) IBOutlet UILabel *wwanTotalDownLabel;

- (void)updateBandwidthLabels:(NetworkBandwidth*)bandwidth;
@end

@implementation NetworkViewController
@synthesize wifiGraph;
@synthesize wifiGLView;

@synthesize wwanGraph;
@synthesize wwanGLView;

#pragma mark - override

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]]];

    AppDelegate *app = [AppDelegate sharedDelegate];
    [self.wifiIPAddressLabel setText:app.iDevice.networkInfo.wifiIPAddress];
    [self.wifiNetmaskLabel setText:app.iDevice.networkInfo.wifiNetmask];
    [self.wifiBroadcastAdressLabel setText:app.iDevice.networkInfo.wifiBroadcastAddress];
    [self.wifiMacAddressLabel setText:app.iDevice.networkInfo.wifiMacAddress];
    
    [self.wwanIPAddressLabel setText:app.iDevice.networkInfo.wwanIPAddress];
    [self.wwanNetmaskLabel setText:app.iDevice.networkInfo.wwanNetmask];
    [self.wwanBroadcastAddressLabe setText:app.iDevice.networkInfo.wwanBroadcastAddress];
    [self.wwanMacAddressLabel setText:app.iDevice.networkInfo.wwanMacAddress];
    
    self.wifiGLView = [[GLKView alloc] initWithFrame:CGRectMake(0.0f, 30.0f, 703.0f, 200.0f)];
    self.wifiGLView.opaque = NO;
    self.wifiGLView.backgroundColor = [UIColor clearColor];
    self.wifiGraph = [[GLLineGraph alloc] initWithGLKView:self.wifiGLView dataLineCount:2 fromValue:0.0f toValue:100.0f legends:[NSArray arrayWithObject:@"WiFi"]];
    self.wifiGraph.preferredFramesPerSecond = kNetworkUpdateFrequency;
    
    self.wwanGLView = [[GLKView alloc] initWithFrame:CGRectMake(0.0f, 30.0f, 703.0f, 200.0f)];
    self.wwanGLView.opaque = NO;
    self.wwanGLView.backgroundColor = [UIColor clearColor];
    self.wwanGraph = [[GLLineGraph alloc] initWithGLKView:self.wwanGLView dataLineCount:2 fromValue:0.0f toValue:100.0f legends:[NSArray arrayWithObject:@"WWAN"]];
    self.wwanGraph.preferredFramesPerSecond = kNetworkUpdateFrequency;

    [app.networkInfoCtrl setNetworkBandwidthHistorySize:[self.wifiGraph requiredElementToFillGraph]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    // Make sure the labels are not empty.
    NetworkBandwidth *bandwidth = [app.networkInfoCtrl.networkBandwidthHistory lastObject];
    if (bandwidth)
    {
        [self updateBandwidthLabels:bandwidth];
    }
    
    // Reset WiFi graph.
    {
        NSMutableArray *bandwidthArray = [[NSMutableArray alloc] initWithCapacity:app.networkInfoCtrl.networkBandwidthHistory.count];
        NSArray *bandwidthHistory = [NSArray arrayWithArray:app.networkInfoCtrl.networkBandwidthHistory];
        
        for (NSUInteger i = 0; i < bandwidthHistory.count; ++i)
        {
            NetworkBandwidth *bandwidth = [bandwidthHistory objectAtIndex:i];
            NSNumber *upValue = [NSNumber numberWithFloat:bandwidth.wifiSent];
            NSNumber *downValue = [NSNumber numberWithFloat:bandwidth.wifiReceived];
            [bandwidthArray addObject:[NSArray arrayWithObjects:upValue, downValue, nil]];
        }
        [self.wifiGraph resetDataArray:bandwidthArray];
    }
    
    // Reset WWAN graph.
    {
        NSMutableArray *bandwidthArray = [[NSMutableArray alloc] initWithCapacity:app.networkInfoCtrl.networkBandwidthHistory.count];
        NSArray *bandwidthHistory = [NSArray arrayWithArray:app.networkInfoCtrl.networkBandwidthHistory];
        
        for (NSUInteger i = 0; i < bandwidthHistory.count; ++i)
        {
            NetworkBandwidth *bandwidth = [bandwidthHistory objectAtIndex:i];
            NSNumber *upValue = [NSNumber numberWithFloat:bandwidth.wwanSent];
            NSNumber *downValue = [NSNumber numberWithFloat:bandwidth.wwanReceived];
            [bandwidthArray addObject:[NSArray arrayWithObjects:upValue, downValue, nil]];
        }
        [self.wwanGraph resetDataArray:bandwidthArray];
    }
    
    app.networkInfoCtrl.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    app.networkInfoCtrl.delegate = nil;
}

#pragma mark - private

- (void)updateBandwidthLabels:(NetworkBandwidth*)bandwidth
{
    [self.wifiTotalUpLabel setText:[NSString stringWithFormat:@"%0.1f MB", bandwidth.wifiTotalSent]];
    [self.wifiTotalDownLabel setText:[NSString stringWithFormat:@"%0.1f MB", bandwidth.wifiTotalReceived]];
    [self.wwanTotalUpLabel setText:[NSString stringWithFormat:@"%0.1f MB", bandwidth.wwanTotalSent]];
    [self.wwanTotalDownLabel setText:[NSString stringWithFormat:@"%0.1f MB", bandwidth.wwanTotalReceived]];
}

#pragma mark - Table view data source

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LineGraphBackground-464.png"]];
    CGRect frame = backgroundView.frame;
    frame.origin.y = 20;
    backgroundView.frame = frame;
    
    UIView *view;
    
    if (section == SECTION_WiFi)
    {
        view = [[UIView alloc] initWithFrame:self.wifiGLView.frame];
        [view addSubview:backgroundView];
        [view sendSubviewToBack:backgroundView];
        [view addSubview:self.wifiGLView];
    }
    else if (section == SECTION_WWAN)
    {
        view = [[UIView alloc] initWithFrame:self.wwanGLView.frame];
        [view addSubview:backgroundView];
        [view sendSubviewToBack:backgroundView];
        [view addSubview:self.wwanGLView];
    }
    else
    {
        AMWarn(@"%s: unknown section: %d", __PRETTY_FUNCTION__, section);
        view = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == SECTION_WiFi)
    {
        return 280.0f;
    }
    else if (section == SECTION_WWAN)
    {
        return 280.0f;
    }
    else
    {
        AMWarn(@"%s: unknown section: %d", __PRETTY_FUNCTION__, section);
        return 0.0f;
    }
}

#pragma mark - NetworkInfoController delegate

- (void)networkBandwidthUpdated:(NetworkBandwidth*)bandwidth
{
    [self updateBandwidthLabels:bandwidth];
    
    NSNumber *upValue = [NSNumber numberWithFloat:bandwidth.wifiSent];
    NSNumber *downValue = [NSNumber numberWithFloat:bandwidth.wifiReceived];
    [self.wifiGraph addDataValue:[NSArray arrayWithObjects:upValue, downValue, nil]];
    
    upValue = [NSNumber numberWithFloat:bandwidth.wwanSent];
    downValue = [NSNumber numberWithFloat:bandwidth.wwanReceived];
    [self.wwanGraph addDataValue:[NSArray arrayWithObjects:upValue, downValue, nil]];
}

@end
