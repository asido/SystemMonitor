//
//  NetworkViewController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "GLLineGraph.h"
#import "AppDelegate.h"
#import "AMLogger.h"
#import "AMUtils.h"
#import "NetworkInfoController.h"
#import "NetworkViewController.h"

enum {
    SECTION_NETWORK_INFORMATION=0
};

@interface NetworkViewController() <NetworkInfoControllerDelegate>
@property (strong, nonatomic) GLLineGraph   *networkGraph;
@property (strong, nonatomic) GLKView       *networkGLView;

- (void)updateStatusLabels;
- (void)updateBandwidthLabels:(NetworkBandwidth*)bandwidth;
- (void)updateGraphZoomLevel;

@property (weak, nonatomic) IBOutlet UILabel *networkTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *externalIPLabel;
@property (weak, nonatomic) IBOutlet UILabel *internalIPLabel;
@property (weak, nonatomic) IBOutlet UILabel *netmaskLabel;
@property (weak, nonatomic) IBOutlet UILabel *broadcastAddressLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalWiFiDownloadsLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalWiFiUploadsLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalWWANDownloadsLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalWWANUploadsLabel;
@end

@implementation NetworkViewController
@synthesize networkGraph;
@synthesize networkGLView;

static const double kNetworkGraphMaxValue = MB_TO_B(100);

#pragma mark - override

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]]];

    [self updateStatusLabels];

    AppDelegate *app = [AppDelegate sharedDelegate];
    
    self.networkGLView = [[GLKView alloc] initWithFrame:CGRectMake(0.0f, 30.0f, app.deviceSpecificUI.GLdataLineGraphWidth, 200.0f)];
    self.networkGLView.opaque = NO;
    self.networkGLView.backgroundColor = [UIColor clearColor];
    self.networkGraph = [[GLLineGraph alloc] initWithGLKView:self.networkGLView dataLineCount:2 fromValue:0.0f toValue:kNetworkGraphMaxValue topLegend:@"0 B/s"];
    self.networkGraph.useClosestMetrics = YES;
    [self.networkGraph setDataLineLegendFraction:1];
    [self.networkGraph setDataLineLegendPostfix:@"/s"];
    [self.networkGraph setDataLineLegendIcon:[UIImage imageNamed:@"arrow-down.png"] forLineIndex:0];
    [self.networkGraph setDataLineLegendIcon:[UIImage imageNamed:@"arrow-up.png"] forLineIndex:1];
    self.networkGraph.preferredFramesPerSecond = kNetworkUpdateFrequency;

    [app.networkInfoCtrl setNetworkBandwidthHistorySize:[self.networkGraph requiredElementToFillGraph]];
    
    [self updateGraphZoomLevel];
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

    NSMutableArray *bandwidthArray = [[NSMutableArray alloc] initWithCapacity:app.networkInfoCtrl.networkBandwidthHistory.count];
    NSArray *bandwidthHistory = [NSArray arrayWithArray:app.networkInfoCtrl.networkBandwidthHistory];
    
    for (NSUInteger i = 0; i < bandwidthHistory.count; ++i)
    {
        NetworkBandwidth *bandwidth = [bandwidthHistory objectAtIndex:i];
        NSNumber *upValue = [NSNumber numberWithFloat:bandwidth.sent];
        NSNumber *downValue = [NSNumber numberWithFloat:bandwidth.received];
        [bandwidthArray addObject:[NSArray arrayWithObjects:upValue, downValue, nil]];
    }
    [self.networkGraph resetDataArray:bandwidthArray];
    
    app.networkInfoCtrl.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    app.networkInfoCtrl.delegate = nil;
}

#pragma mark - private

- (void)updateStatusLabels
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    [self.networkTypeLabel setText:app.iDevice.networkInfo.readableInterface];
    [self.externalIPLabel setText:app.iDevice.networkInfo.externalIPAddress];
    [self.internalIPLabel setText:app.iDevice.networkInfo.internalIPAddress];
    [self.netmaskLabel setText:app.iDevice.networkInfo.netmask];
    [self.broadcastAddressLabel setText:app.iDevice.networkInfo.broadcastAddress];
}

- (void)updateBandwidthLabels:(NetworkBandwidth*)bandwidth
{
    [self.totalWiFiDownloadsLabel setText:[AMUtils toNearestMetric:bandwidth.totalWiFiReceived desiredFraction:1]];
    [self.totalWiFiUploadsLabel setText:[AMUtils toNearestMetric:bandwidth.totalWiFiSent desiredFraction:1]];
    [self.totalWWANDownloadsLabel setText:[AMUtils toNearestMetric:bandwidth.totalWWANReceived desiredFraction:1]];
    [self.totalWWANUploadsLabel setText:[AMUtils toNearestMetric:bandwidth.totalWWANSent desiredFraction:1]];
}

- (void)updateGraphZoomLevel
{
    NetworkInfoController *networkCtrl = [AppDelegate sharedDelegate].networkInfoCtrl;
    GLfloat zoomLevel = MAX(networkCtrl.currentMaxSentBandwidth, networkCtrl.currentMaxReceivedBandwidth) / kNetworkGraphMaxValue;
    zoomLevel = MAX(zoomLevel, FLT_MIN); // Make sure it's not 0
    GLfloat topValue = kNetworkGraphMaxValue * zoomLevel;
    [self.networkGraph setZoomLevel:zoomLevel];
    [self.networkGraph setGraphLegend:[NSString stringWithFormat:@"%@/s", [AMUtils toNearestMetric:topValue desiredFraction:0]]];
}

#pragma mark - Table view data source

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == SECTION_NETWORK_INFORMATION)
    {
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LineGraphBackground-414.png"]];
        CGRect frame = backgroundView.frame;
        frame.origin.y = 20;
        backgroundView.frame = frame;
        
        UIView *view;
        view = [[UIView alloc] initWithFrame:self.networkGLView.frame];
        [view addSubview:backgroundView];
        [view sendSubviewToBack:backgroundView];
        [view addSubview:self.networkGLView];
        return view;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == SECTION_NETWORK_INFORMATION)
    {
        return 240.0f;
    }
    else
    {
        return 0.0f;
    }
}

#pragma mark - NetworkInfoController delegate

- (void)networkBandwidthUpdated:(NetworkBandwidth*)bandwidth
{
    [self updateBandwidthLabels:bandwidth];
    
    NSNumber *upValue = [NSNumber numberWithFloat:bandwidth.sent];
    NSNumber *downValue = [NSNumber numberWithFloat:bandwidth.received];
    [self.networkGraph addDataValue:[NSArray arrayWithObjects:upValue, downValue, nil]];
}

- (void)networkStatusUpdated
{
    [self updateStatusLabels];
}

- (void)networkExternalIPAddressUpdated
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    [self.externalIPLabel setText:app.iDevice.networkInfo.externalIPAddress];
}

- (void)networkMaxBandwidthUpdated
{
    [self updateGraphZoomLevel];
}

@end
