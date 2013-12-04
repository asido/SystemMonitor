//
//  ConnectionViewController.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AMLogger.h"
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
@property (nonatomic, strong) NSMutableDictionary   *activeConnections;
@property (nonatomic, copy)   NSArray               *activeConnectionKeys;
@property (nonatomic, assign) BOOL refreshingConnections;
@property (nonatomic, assign) BOOL nothingToSee;

@property (nonatomic, strong) UIImage *greenCircle;
@property (nonatomic, strong) UIImage *orangeCircle;
@property (nonatomic, strong) UIImage *redCircle;

- (UITableViewCell*)dequeueRefreshingCellForTable:(UITableView*)table indexPath:(NSIndexPath*)indexPath;
- (UITableViewCell*)dequeueNothingToSeeCellForTable:(UITableView*)table indexPath:(NSIndexPath*)indexPath;
- (UITableViewCell*)dequeueConnectionCellForTable:(UITableView*)table indexPath:(NSIndexPath*)indexPath;
@end

@implementation ConnectionViewController
@synthesize activeConnections;
@synthesize activeConnectionKeys;
@synthesize refreshingConnections;
@synthesize nothingToSee;

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
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ViewBackground-1496"]]];
    
    self.greenCircle = [UIImage imageNamed:@"ConnectionGreenCircle"];
    self.orangeCircle = [UIImage imageNamed:@"ConnectionOrangeCircle"];
    self.redCircle = [UIImage imageNamed:@"ConnectionRedCircle"];
    
    [self setNothingToSee:NO];
    
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
        AMLogWarn(@"attempt to dequeue reusable cell has failed.");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (UITableViewCell*)dequeueNothingToSeeCellForTable:(UITableView*)table indexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"NothingToSeeCell";
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
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
        AMLogWarn(@"attempt to dequeue reusable cell has failed.");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UILabel     *localAddressLabel  = (UILabel*)    [cell viewWithTag:TAG_LOCAL_ADDRESS_LABEL];
    UILabel     *remoteAddressLabel = (UILabel*)    [cell viewWithTag:TAG_REMOTE_ADDRESS_LABEL];
    UIImageView *statusImageView    = (UIImageView*)[cell viewWithTag:TAG_STATUS_IMAGEVIEW];
    UILabel     *statusLabel        = (UILabel*)    [cell viewWithTag:TAG_STATUS_LABEL];
    UILabel     *txLabel            = (UILabel*)    [cell viewWithTag:TAG_TX_LABEL];
    UILabel     *rxLabel            = (UILabel*)    [cell viewWithTag:TAG_RX_LABEL];
    
    NSString *key = self.activeConnectionKeys[indexPath.section];
    NSArray *connections = self.activeConnections[key];
    ActiveConnection *connection = connections[indexPath.row];
    
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
            AMLogWarn(@"unknown connection status: %d. Defaulting to red circle.", connection.status);
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
    if (self.refreshingConnections || self.nothingToSee)
    {
        return 1;
    }
    else
    {
        return self.activeConnectionKeys.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.refreshingConnections || self.nothingToSee)
    {
        return 1;
    }
    else
    {
        NSString *key = self.activeConnectionKeys[section];
        NSArray *connections = self.activeConnections[key];
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
            
            if (self.activeConnections != nil && self.activeConnections.count > 0)
            {
                [view.label setText:self.activeConnectionKeys[section]];
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
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // iPad uses 60px for both refreshing and connection cells,
    // while iPhone exlusively requires 92px for connections cell to fit everything in.
    if (self.refreshingConnections || self.nothingToSee || [AMUtils isIPad])
    {
        return 60.0f;
    }
    else
    {
        return 92.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.refreshingConnections)
    {
        return [self dequeueRefreshingCellForTable:tableView indexPath:indexPath];
    }
    else if (self.nothingToSee)
    {
        return [self dequeueNothingToSeeCellForTable:tableView indexPath:indexPath];
    }
    else
    {
        return [self dequeueConnectionCellForTable:tableView indexPath:indexPath];
    }
}

#pragma mark - NetworkInfoController delegate

- (void)networkActiveConnectionsUpdated:(NSArray *)connections
{
    self.activeConnections = [@{} mutableCopy];
    NSArray *currentConnections = [NSArray arrayWithArray:connections];
    
    for (ActiveConnection *connection in currentConnections)
    {
        if (self.activeConnections[connection.statusString] == nil)
        {
            self.activeConnections[connection.statusString] = [@[] mutableCopy];
        }
        
        NSMutableArray *connectionsWithStatus = self.activeConnections[connection.statusString];
        [connectionsWithStatus addObject:connection];
        self.activeConnections[connection.statusString] = connectionsWithStatus;
    }
    self.activeConnectionKeys = [[self.activeConnections allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    self.refreshingConnections = NO;
    self.nothingToSee = (self.activeConnectionKeys.count == 0);
    [self.tableView reloadData];
}

@end
