//
//  ProcessViewController.m
//  ActivityMonitor++
//
//  Created by st on 21/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AppDelegate.h"
#import "AMLog.h"
#import "ProcessInfo.h"
#import "ProcessTopView.h"
#import "ProcessViewController.h"

@interface ProcessViewController() <ProcessTopViewDelegate>
@property (strong, nonatomic) ProcessTopView    *topView;
@property (strong, nonatomic) NSArray           *filteredProcesses;

- (NSString*)formatStartTime:(time_t)unixTime;
@end

@implementation ProcessViewController
@synthesize topView;
@synthesize filteredProcesses;

#pragma mark - override

- (void)viewDidLoad
{    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Set background.
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]]];
    
    // Refresh process list.
    AppDelegate *app = [AppDelegate sharedDelegate];
    [app.iDevice refreshProcesses];
    
    // Load top view.
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"ProcessTopView" owner:self options:nil];
    for (id obj in bundle)
    {
        if ([obj isKindOfClass:[ProcessTopView class]])
        {
            self.topView = (ProcessTopView*) obj;
            self.topView.delegate = self;
        }
    }
    [self.view addSubview:self.topView];
    
    
    self.filteredProcesses = [NSArray arrayWithArray:app.iDevice.processes];
    
    [self.topView setProcessCount:self.filteredProcesses.count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // We don't want top view to scroll.
    CGRect newFrame = self.topView.frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.tableView.contentOffset.y;
    self.topView.frame = newFrame;
}

#pragma mark - private

- (NSString*)formatStartTime:(time_t)unixTime
{
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:unixTime];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                                   fromDate:date];
    NSString *dateString = [NSString stringWithFormat:@"%04d-%02d-%02d %d:%02d:%02d",
                            dateComponents.year, dateComponents.month, dateComponents.day, dateComponents.hour, dateComponents.minute, dateComponents.second];
    return dateString;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.topView.frame.size.height;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *dummyView = [[UIView alloc] init];
    dummyView.backgroundColor = [UIColor clearColor];
    // During reloadData the header goes on top of the top view block UI interaction.
    // Disabling interactions on the header will make it go through to topView.
    dummyView.userInteractionEnabled = NO;
    return dummyView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredProcesses.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    enum {
        TAG_ICON_VIEW=1,
        TAG_NAME_LABEL,
        TAG_STATUS_LABEL,
        TAG_START_TIME_LABEL,
        TAG_PID_LABEL,
        TAG_PRIORITY_LABEL,
        TAG_COMMAND_LINE_LABEL
    };
    
    static NSString *CellIdentifier = @"ProcessCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        AMWarn(@"%s: attempt to dequeue reusable cell has failed.", __PRETTY_FUNCTION__);
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //UIImageView *iconView = (UIImageView*) [cell viewWithTag:TAG_ICON_VIEW];
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:TAG_NAME_LABEL];
    UILabel *statusLabel = (UILabel*) [cell viewWithTag:TAG_STATUS_LABEL];
    UILabel *startTimeLabel = (UILabel*) [cell viewWithTag:TAG_START_TIME_LABEL];
    UILabel *pidLabel = (UILabel*) [cell viewWithTag:TAG_PID_LABEL];
    UILabel *priorityLabel = (UILabel*) [cell viewWithTag:TAG_PRIORITY_LABEL];
    UILabel *commandLineLabel = (UILabel*) [cell viewWithTag:TAG_COMMAND_LINE_LABEL];
    
    ProcessInfo *process = [self.filteredProcesses objectAtIndex:indexPath.row];
    
    //[iconView setImage:process.icon];
    [nameLabel setText:process.name];
    [statusLabel setText:[process getStatusString]];
    [startTimeLabel setText:[self formatStartTime:process.startTime]];
    [pidLabel setText:[NSString stringWithFormat:@"%d", process.pid]];
    [priorityLabel setText:[NSString stringWithFormat:@"%d", process.priority]];
    [commandLineLabel setText:process.commandLine];
    
    return cell;
}

#pragma mark - ProcessTopView delegate

- (void)processTopViewSortFilterChanged:(SortFilter_t)newFilter
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    switch (newFilter) {
        case SORT_BY_ID:
            self.filteredProcesses = [app.iDevice.processes sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                ProcessInfo *p1 = (ProcessInfo*) a;
                ProcessInfo *p2 = (ProcessInfo*) b;
                                
                if (p1.pid > p2.pid) {
                    return NSOrderedDescending;
                } else if (p1.pid < p2.pid) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedSame;
                }
            }];
            break;
        case SORT_BY_NAME:
            self.filteredProcesses = [app.iDevice.processes sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                ProcessInfo *p1 = (ProcessInfo*) a;
                ProcessInfo *p2 = (ProcessInfo*) b;
                
                return [p1.name compare:p2.name];
            }];
            break;
        case SORT_BY_PRIORITY:
            self.filteredProcesses = [app.iDevice.processes sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                ProcessInfo *p1 = (ProcessInfo*) a;
                ProcessInfo *p2 = (ProcessInfo*) b;
                
                if (p1.priority > p2.priority) {
                    return NSOrderedDescending;
                } else if (p1.priority < p2.priority) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedSame;
                }
            }];
            break;
        case SORT_BY_START_TIME:
            self.filteredProcesses = [app.iDevice.processes sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                ProcessInfo *p1 = (ProcessInfo*) a;
                ProcessInfo *p2 = (ProcessInfo*) b;
                
                if (p1.startTime > p2.startTime) {
                    return NSOrderedDescending;
                } else if (p1.startTime < p2.startTime) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedSame;
                }
            }];
            break;
        default:
            AMWarn(@"%s: unknown filter: %d", __PRETTY_FUNCTION__, newFilter);
            break;
    }
    
    [self.tableView reloadData];
}

@end
