//
//  OperatingSystemViewController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AppDelegate.h"
#import "GeneralViewController.h"
#import "AMCommonUI.h"

@interface GeneralViewController ()
@property (nonatomic, weak) IBOutlet UILabel *deviceLabel;
@property (nonatomic, weak) IBOutlet UILabel *hostnameLabel;
@property (nonatomic, weak) IBOutlet UILabel *screenRezolutionLabel;
@property (nonatomic, weak) IBOutlet UILabel *retinaLabel;
@property (nonatomic, weak) IBOutlet UILabel *screenSizeLabel;
@property (nonatomic, weak) IBOutlet UILabel *ppiLabel;
@property (nonatomic, weak) IBOutlet UILabel *aspectRatioLabel;
@property (nonatomic, weak) IBOutlet UILabel *osNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *osTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *osVersionLabel;
@property (nonatomic, weak) IBOutlet UILabel *osBuildLabel;
@property (nonatomic, weak) IBOutlet UILabel *osRevisionLabel;
@property (nonatomic, weak) IBOutlet UITextView *kernelInfoLabel;
@property (nonatomic, weak) IBOutlet UILabel *maxVNodesLabel;
@property (nonatomic, weak) IBOutlet UILabel *maxProcessesLabel;
@property (nonatomic, weak) IBOutlet UILabel *maxFilesLabel;
@property (nonatomic, weak) IBOutlet UILabel *tickFrequencyLabel;
@property (nonatomic, weak) IBOutlet UILabel *safeBootLabel;
@property (nonatomic, weak) IBOutlet UILabel *bootTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *uptimeLabel;

@property (strong, nonatomic) NSTimer *uptimeTimer;
- (void)startUptimeTimer;
- (void)stopUptimeTimer;
- (void)uptimeTimerCB:(NSNotification*)notification;

- (NSString*)formatBootTime:(time_t)time;
- (NSString*)formatUptime:(time_t)bootTime;
@end

@implementation GeneralViewController

#pragma mark - override

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundView:[AMCommonUI sectionBackgroundView]];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    NSString *deviceName = [NSString stringWithFormat:@"Apple %@", app.iDevice.deviceInfo.deviceName];
    [self.deviceLabel setText:deviceName];
    [self.hostnameLabel setText:app.iDevice.deviceInfo.hostName];
    [self.screenRezolutionLabel setText:app.iDevice.deviceInfo.screenResolution];
    [self.screenSizeLabel setText:[NSString stringWithFormat:@"%0.1f\"", app.iDevice.deviceInfo.screenSize]];
    [self.retinaLabel setText:(app.iDevice.deviceInfo.retina ? @"Yes" : @"No")];
    [self.ppiLabel setText:[NSString stringWithFormat:@"%ld ppi", (long)app.iDevice.deviceInfo.ppi]];
    [self.aspectRatioLabel setText:app.iDevice.deviceInfo.aspectRatio];
    [self.osNameLabel setText:app.iDevice.deviceInfo.osName];
    [self.osTypeLabel setText:app.iDevice.deviceInfo.osType];
    [self.osVersionLabel setText:app.iDevice.deviceInfo.osVersion];
    [self.osBuildLabel setText:app.iDevice.deviceInfo.osBuild];
    [self.osRevisionLabel setText:[NSString stringWithFormat:@"%ld", (long)app.iDevice.deviceInfo.osRevision]];
    [self.kernelInfoLabel setText:app.iDevice.deviceInfo.kernelInfo];
    [self.maxVNodesLabel setText:[NSString stringWithFormat:@"%ld", (long)app.iDevice.deviceInfo.maxVNodes]];
    [self.maxProcessesLabel setText:[NSString stringWithFormat:@"%ld", (long)app.iDevice.deviceInfo.maxProcesses]];
    [self.maxFilesLabel setText:[NSString stringWithFormat:@"%ld", (long)app.iDevice.deviceInfo.maxFiles]];
    [self.tickFrequencyLabel setText:[NSString stringWithFormat:@"%ld", (long)app.iDevice.deviceInfo.tickFrequency]];
    [self.safeBootLabel setText:(app.iDevice.deviceInfo.safeBoot ? @"Yes" : @"No")];
    [self.bootTimeLabel setText:[self formatBootTime:app.iDevice.deviceInfo.bootTime]];
    [self.uptimeLabel setText:[self formatUptime:app.iDevice.deviceInfo.bootTime]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self startUptimeTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopUptimeTimer];
}

#pragma mark - private

- (void)startUptimeTimer
{
    [self stopUptimeTimer];
    self.uptimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(uptimeTimerCB:)
                                                      userInfo:nil
                                                       repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.uptimeTimer forMode:NSRunLoopCommonModes];
}

- (void)stopUptimeTimer
{
    [self.uptimeTimer invalidate];
    self.uptimeTimer = nil;
}

- (void)uptimeTimerCB:(NSNotification*)notification
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    [self.uptimeLabel setText:[self formatUptime:app.iDevice.deviceInfo.bootTime]];
}

- (NSString*)formatBootTime:(time_t)time
{    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:time];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                                   fromDate:date];
    NSString *dateString = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %ld:%02ld:%02ld",
                            (long)dateComponents.year, (long)dateComponents.month, (long)dateComponents.day, (long)dateComponents.hour, (long)dateComponents.minute, (long)dateComponents.second];
    return dateString;
}

- (NSString*)formatUptime:(time_t)bootTime
{
    NSDate *fromDate = [[NSDate alloc] initWithTimeIntervalSince1970:bootTime];
    NSDate *toDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                                   fromDate:fromDate toDate:toDate options:0];
    NSString *dateString = [NSString stringWithFormat:@"%ld days %ld:%02ld:%02ld",
                            (long)dateComponents.day, (long)dateComponents.hour, (long)dateComponents.minute, (long)dateComponents.second];
    return dateString;
}

@end
