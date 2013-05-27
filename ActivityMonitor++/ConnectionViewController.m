//
//  ConnectionViewController.m
//  ActivityMonitor++
//
//  Created by st on 27/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "AMLog.h"
#import "AppDelegate.h"
#import "ActiveConnection.h"
#import "ConnectionSectionView.h"
#import "ConnectionViewController.h"

@interface ConnectionViewController()
/* 
 * The dictionary holds arrays of active connections with keys being
 * the connection status: ESTABLISHED, LISTEN...
 */
@property (strong, nonatomic) NSMutableDictionary *activeConnections;

@property (strong, nonatomic) UIImage *greenCircle;
@property (strong, nonatomic) UIImage *orangeCircle;
@property (strong, nonatomic) UIImage *redCircle;
@end

@implementation ConnectionViewController
@synthesize activeConnections;

@synthesize greenCircle;
@synthesize orangeCircle;
@synthesize redCircle;

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
    AppDelegate *app = [AppDelegate sharedDelegate];
    [app.iDevice refreshActiveConnections];
    
    self.activeConnections = [[NSMutableDictionary alloc] init];
    NSArray *connections = [NSArray arrayWithArray:app.iDevice.activeConnections];
    
    for (ActiveConnection *connection in connections)
    {
        if (![self.activeConnections objectForKey:connection.statusString])
        {
            [self.activeConnections setObject:[[NSMutableArray alloc] init] forKey:connection.statusString];
        }
        
        NSMutableArray *connectionsWithLocalIP = [self.activeConnections objectForKey:connection.statusString];
        [connectionsWithLocalIP addObject:connection];
        [self.activeConnections setObject:connectionsWithLocalIP forKey:connection.statusString];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.activeConnections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys           = [self.activeConnections allKeys];
    NSArray *connections    = [self.activeConnections objectForKey:[keys objectAtIndex:section]];
    return connections.count;
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
            NSString *sectionKey = [[self.activeConnections allKeys] objectAtIndex:section];
            [view.label setText:sectionKey];
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
    enum {
        TAG_LOCAL_ADDRESS_LABEL=1,
        TAG_REMOTE_ADDRESS_LABEL=2,
        TAG_STATUS_IMAGEVIEW=3,
        TAG_STATUS_LABEL=4,
        TAG_TX_LABEL=5,
        TAG_RX_LABEL=6
    };
    
    static NSString *CellIdentifier = @"ConnectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
    
    NSString *key = [[self.activeConnections allKeys] objectAtIndex:indexPath.section];
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
    [txLabel setText:[NSString stringWithFormat:@"%0.1f KB", connection.totalTX]];
    [rxLabel setText:[NSString stringWithFormat:@"%0.1f KB", connection.totalRX]];
    
    return cell;
}

@end
