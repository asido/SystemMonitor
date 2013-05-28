//
//  ConnectionViewController.m
//  ActivityMonitor++
//
//  Created by st on 27/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMLog.h"
#import "AMUtils.h"
#import "AppDelegate.h"
#import "ActiveConnection.h"
#import "ConnectionSectionView.h"
#import "ConnectionViewController.h"

@interface ConnectionViewController() <NetworkInfoControllerDelegate>
/* 
 * The dictionary holds arrays of active connections with keys being
 * the connection status: ESTABLISHED, LISTEN...
 */
@property (strong, nonatomic) NSMutableDictionary *activeConnections;
@property (assign, nonatomic) BOOL refreshingConnections;

@property (strong, nonatomic) UIImage *greenCircle;
@property (strong, nonatomic) UIImage *orangeCircle;
@property (strong, nonatomic) UIImage *redCircle;

- (UITableViewCell*)dequeueRefreshingCellForTable:(UITableView*)table indexPath:(NSIndexPath*)indexPath;
- (UITableViewCell*)dequeueConnectionCellForTable:(UITableView*)table indexPath:(NSIndexPath*)indexPath;
@end

@implementation ConnectionViewController
@synthesize activeConnections;

@synthesize greenCircle;
@synthesize orangeCircle;
@synthesize redCircle;

#pragma mark - override

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Set background.
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-1496.png"]]];
    
    self.greenCircle = [UIImage imageNamed:@"GreenCircle.png"];
    self.orangeCircle = [UIImage imageNamed:@"OrangeCircle.png"];
    self.redCircle = [UIImage imageNamed:@"RedCircle.png"];
    
    // Refresh active connection list.
    self.refreshingConnections = YES;
    AppDelegate *app = [AppDelegate sharedDelegate];
    app.networkInfoCtrl.delegate = self;
    [app.networkInfoCtrl updateActiveConnections];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    app.networkInfoCtrl.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    app.networkInfoCtrl.delegate = nil;
}

#pragma mark - private

- (UITableViewCell*)dequeueRefreshingCellForTable:(UITableView*)table indexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"RetrievingCell";
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        AMWarn(@"attempt to dequeue reusable cell has failed.");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (UITableViewCell*)dequeueConnectionCellForTable:(UITableView*)table indexPath:(NSIndexPath*)indexPath
{
    enum {
        TAG_LOCAL_ADDRESS_LABEL=1,
        TAG_REMOTE_ADDRESS_LABEL=2,
        TAG_STATUS_IMAGEVIEW=3,
        TAG_STATUS_LABEL=4,
        TAG_TX_LABEL=5,
        TAG_RX_LABEL=6
    };
    
    static NSString *CellIdentifier = @"ConnectionCell";
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        AMWarn(@"attempt to dequeue reusable cell has failed.");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UILabel     *localAddressLabel  = (UILabel*)    [cell viewWithTag:TAG_LOCAL_ADDRESS_LABEL];
    UILabel     *remoteAddressLabel = (UILabel*)    [cell viewWithTag:TAG_REMOTE_ADDRESS_LABEL];
    UIImageView *statusImageView    = (UIImageView*)[cell viewWithTag:TAG_STATUS_IMAGEVIEW];
    UILabel     *statusLabel        = (UILabel*)    [cell viewWithTag:TAG_STATUS_LABEL];
    UILabel     *txLabel            = (UILabel*)    [cell viewWithTag:TAG_TX_LABEL];
    UILabel     *rxLabel            = (UILabel*)    [cell viewWithTag:TAG_RX_LABEL];
    
    NSArray *allKeys = [[self.activeConnections allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *key = [allKeys objectAtIndex:indexPath.section];
    NSArray *connections = [self.activeConnections objectForKey:key];
    ActiveConnection *connection = [connections objectAtIndex:indexPath.row];
    
    [localAddressLabel setText:[NSString stringWithFormat:@"%@:%@ %@", connection.localIP, connection.localPort,
                                (connection.localPortService.length > 0 ? [NSString stringWithFormat:@"(%@)", connection.localPortService] : @"")]];
    [remoteAddressLabel setText:[NSString stringWithFormat:@"%@:%@ %@", connection.remoteIP, connection.remotePort,
                                 (connection.remotePortService.length > 0 ? [NSString stringWithFormat:@"(%@)", connection.remotePortService] : @"")]];
    switch (connection.status) {
        case CONNECTION_STATUS_ESTABLISHED:
            [statusImageView setImage:self.greenCircle];
            break;
        case CONNECTION_STATUS_CLOSED:
            [statusImageView setImage:self.redCircle];
            break;
        case CONNECTION_STATUS_OTHER:
            [statusImageView setImage:self.orangeCircle];
            break;
        default:
            AMWarn(@"unknown connection status: %d. Defaulting to red circle.", connection.status);
            [statusImageView setImage:self.redCircle];
            break;
    }
    [statusLabel setText:connection.statusString];
    [txLabel setText:[AMUtils toNearestMetric:(uint64_t)connection.totalTX desiredFraction:1]];
    [rxLabel setText:[AMUtils toNearestMetric:(uint64_t)connection.totalRX desiredFraction:1]];
    
    return cell;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.refreshingConnections)
    {
        return 1;
    }
    else
    {
        return [[self.activeConnections allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)].count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.refreshingConnections)
    {
        return 1;
    }
    else
    {
        NSArray *keys           = [self.activeConnections allKeys];
        NSArray *connections    = [self.activeConnections objectForKey:[keys objectAtIndex:section]];
        return connections.count;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ConnectionSectionView *view = nil;
    
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"ConnectionSectionView" owner:self options:nil];
    for (id obj in bundle)
    {
        if ([obj isKindOfClass:[ConnectionSectionView class]])
        {
            view = (ConnectionSectionView*) obj;
            view.frame = CGRectMake(0, 0, tableView.frame.size.width, 30);
            
            if (self.activeConnections)
            {
                NSString *sectionKey = [[self.activeConnections allKeys] objectAtIndex:section];
                [view.label setText:sectionKey];
            }
            else
            {
                [view.label setText:@""];
            }
        }
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.refreshingConnections)
    {
        return [self dequeueRefreshingCellForTable:tableView indexPath:indexPath];
    }
    else
    {
        return [self dequeueConnectionCellForTable:tableView indexPath:indexPath];
    }
}

#pragma mark - NetworkInfoController delegate

- (void)networkActiveConnectionsUpdated:(NSArray *)connections
{
    self.activeConnections = [[NSMutableDictionary alloc] init];
    
    for (ActiveConnection *connection in connections)
    {
        if (![self.activeConnections objectForKey:connection.statusString])
        {
            [self.activeConnections setObject:[[NSMutableArray alloc] init] forKey:connection.statusString];
        }
        
        NSMutableArray *connectionsWithStatus = [self.activeConnections objectForKey:connection.statusString];
        [connectionsWithStatus addObject:connection];
        [self.activeConnections setObject:connectionsWithStatus forKey:connection.statusString];
    }
    
    self.refreshingConnections = NO;
    [self.tableView reloadData];
}

@end
