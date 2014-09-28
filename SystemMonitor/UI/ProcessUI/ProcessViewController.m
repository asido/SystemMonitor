//
//  ProcessViewController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AppDelegate.h"
#import "iPadProcessSortViewController.h"
#import "iPhoneProcessSortViewController.h"
#import "AMLogger.h"
#import "AMUtils.h"
#import "ProcessInfo.h"
#import "ProcessTopView.h"
#import "ProcessViewController.h"
#import "AMCommonUI.h"

@interface ProcessViewController() <ProcessTopViewDelegate, ProcessSortViewControllerDelegate>
@property (nonatomic, strong) ProcessTopView                    *topView;
@property (nonatomic, strong) iPhoneProcessSortViewController   *iPhoneSortViewCtrl;
@property (nonatomic, strong) UIView                            *sortSheet;
@property (nonatomic, strong) iPadProcessSortViewController     *iPadSortViewCtrl;
@property (nonatomic, strong) UIPopoverController               *sortPopover;

@property (nonatomic, copy) NSArray                           *filteredProcesses;

- (NSString*)formatStartTime:(time_t)unixTime;
@end

@implementation ProcessViewController
@synthesize topView;
@synthesize iPhoneSortViewCtrl;
@synthesize sortSheet;
@synthesize iPadSortViewCtrl;
@synthesize sortPopover;

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
    [self.tableView setBackgroundView:[AMCommonUI sectionBackgroundView]];
    
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
    
    self.filteredProcesses = [NSArray arrayWithArray:app.iDevice.processes];
    [self processSortFilterChanged:SORT_DEFAULT];
    
    [self.topView setProcessCount:self.filteredProcesses.count];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // For some reason iPhone does't scroll without this.
    [self.tableView reloadData];
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
    NSString *dateString = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %ld:%02ld:%02ld",
                            (long)dateComponents.year, (long)dateComponents.month, (long)dateComponents.day, (long)dateComponents.hour, (long)dateComponents.minute, (long)dateComponents.second];
    return dateString;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.topView.frame.size.height;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.topView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredProcesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    enum {
        TAG_ICON_VIEW=1,
        TAG_NAME_LABEL=2,
        TAG_STATUS_LABEL=3,
        TAG_START_TIME_LABEL=4,
        TAG_PID_LABEL=5,
        TAG_PRIORITY_LABEL=6,
        TAG_COMMAND_LINE_LABEL=7
    };
    
    static NSString *CellIdentifier = @"ProcessCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        AMLogWarn(@"attempt to dequeue reusable cell has failed.");
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
    
    ProcessInfo *process = self.filteredProcesses[indexPath.row];
    
    //[iconView setImage:process.icon];
    [nameLabel setText:process.name];
    [statusLabel setText:[process getStatusString]];
    [startTimeLabel setText:[self formatStartTime:process.startTime]];
    [pidLabel setText:[NSString stringWithFormat:@"%ld", (long)process.pid]];
    [priorityLabel setText:[NSString stringWithFormat:@"%ld", (long)process.priority]];
    [commandLineLabel setText:process.commandLine];
    
    return cell;
}

#pragma mark - ProcessTopView delegate

- (void)wantsToPresentSortViewForButton:(UIButton*)button
{
    if ([AMUtils isIPhone])
    {
        if (!self.iPhoneSortViewCtrl)
        {
            self.iPhoneSortViewCtrl = [[iPhoneProcessSortViewController alloc] init];
            [self.iPhoneSortViewCtrl setFilter:SORT_DEFAULT];
            self.iPhoneSortViewCtrl.sortDelegate = self;
        }
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 40.0)];
        toolbar.barStyle = UIBarStyleBlackOpaque;
        UILabel *pickerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, toolbar.frame.size.width, 25)];
        pickerTitleLabel.text = @"Choose";
        pickerTitleLabel.backgroundColor = [UIColor clearColor];
        pickerTitleLabel.textColor = [UIColor whiteColor];
        pickerTitleLabel.textAlignment = NSTextAlignmentCenter;
        pickerTitleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [toolbar addSubview:pickerTitleLabel];
        
        self.sortSheet = [AMCommonUI showActionSheetSimulationInViewController:self WithPickerView:self.iPhoneSortViewCtrl withToolbar:toolbar];
    }
    else
    {
        if (!self.iPadSortViewCtrl)
        {
            self.iPadSortViewCtrl = [[iPadProcessSortViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.iPadSortViewCtrl setFilter:SORT_DEFAULT];
            self.iPadSortViewCtrl.sortDelegate = self;
        }
        if (!self.sortPopover)
        {
            self.sortPopover = [[UIPopoverController alloc] initWithContentViewController:self.iPadSortViewCtrl];
        }
        
        CGRect popoverPoint = button.frame;
        popoverPoint.origin.y = popoverPoint.origin.y + self.tableView.contentOffset.y + 65.0;
        [self.sortPopover presentPopoverFromRect:popoverPoint inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - ProcessSortViewControllerDelegate

- (void)processSortFilterChanged:(SortFilter_t)newFilter
{
    if (self.sortSheet)
    {
        [AMCommonUI dismissActionSheetSimulationInViewController:self simulation:self.sortSheet];
    }
    if (self.sortPopover)
    {
        [self.sortPopover dismissPopoverAnimated:YES];
    }
    
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
            AMLogWarn(@"unknown filter: %d", newFilter);
            break;
    }
    
    [self.tableView reloadData];
}

@end
