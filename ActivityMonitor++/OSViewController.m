//
//  OperatingSystemViewController.m
//  ActivityMonitor++
//
//  Created by st on 08/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AppDelegate.h"
#import "OSViewController.h"

@interface OSViewController ()
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *osNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *osTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *osVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *osBuildLabel;
@property (weak, nonatomic) IBOutlet UILabel *osRevisionLabel;
@property (weak, nonatomic) IBOutlet UITextView *kernelInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxVNodesLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxProcessesLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxFilesLabel;
@property (weak, nonatomic) IBOutlet UILabel *tickFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *safeBootLabel;
@property (weak, nonatomic) IBOutlet UILabel *bootTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *uptimeLabel;

@property (strong, nonatomic) NSTimer *uptimeTimer;
- (void)startUptimeTimer;
- (void)stopUptimeTimer;
- (void)uptimeTimerCB:(NSNotification*)notification;

- (NSString*)formatBootTime:(time_t)time;
- (NSString*)formatUptime:(time_t)bootTime;
@end

@implementation OSViewController

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
    NSString *deviceName = [NSString stringWithFormat:@"Apple %@", app.iDevice.deviceInfo.deviceName];
    [self.deviceLabel setText:deviceName];
    [self.hostnameLabel setText:app.iDevice.deviceInfo.hostName];
    [self.osNameLabel setText:app.iDevice.deviceInfo.osName];
    [self.osTypeLabel setText:app.iDevice.deviceInfo.osType];
    [self.osVersionLabel setText:app.iDevice.deviceInfo.osVersion];
    [self.osBuildLabel setText:app.iDevice.deviceInfo.osBuild];
    [self.osRevisionLabel setText:[NSString stringWithFormat:@"%d", app.iDevice.deviceInfo.osRevision]];
    [self.kernelInfoLabel setText:app.iDevice.deviceInfo.kernelInfo];
    [self.maxVNodesLabel setText:[NSString stringWithFormat:@"%d", app.iDevice.deviceInfo.maxVNodes]];
    [self.maxProcessesLabel setText:[NSString stringWithFormat:@"%d", app.iDevice.deviceInfo.maxProcesses]];
    [self.maxFilesLabel setText:[NSString stringWithFormat:@"%d", app.iDevice.deviceInfo.maxFiles]];
    [self.tickFrequencyLabel setText:[NSString stringWithFormat:@"%d", app.iDevice.deviceInfo.tickFrequency]];
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
    self.uptimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(uptimeTimerCB:) userInfo:nil repeats:YES];
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
    NSString *dateString = [NSString stringWithFormat:@"%04d-%02d-%02d %d:%02d:%02d",
                            dateComponents.year, dateComponents.month, dateComponents.day, dateComponents.hour, dateComponents.minute, dateComponents.second];
    return dateString;
}

- (NSString*)formatUptime:(time_t)bootTime
{
    NSDate *fromDate = [[NSDate alloc] initWithTimeIntervalSince1970:bootTime];
    NSDate *toDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                                   fromDate:fromDate toDate:toDate options:0];
    NSString *dateString = [NSString stringWithFormat:@"%d days %d:%02d:%02d",
                            dateComponents.day, dateComponents.hour, dateComponents.minute, dateComponents.second];
    return dateString;
}

@end
