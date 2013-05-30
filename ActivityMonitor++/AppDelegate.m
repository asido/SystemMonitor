//
//  AppDelegate.m
//  ActivityMonitor++
//
//  Created by st on 06/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "AppDelegate.h"

@interface AppDelegate()
- (void)customizeAppearance;
@end

@implementation AppDelegate
@synthesize iDevice;
@synthesize cpuInfoCtrl;
@synthesize deviceInfoCtrl;
@synthesize gpuInfoCtrl;
@synthesize processInfoCtrl;
@synthesize ramInfoCtrl;
@synthesize networkInfoCtrl;
@synthesize storageInfoCtrl;
@synthesize batteryInfoCtrl;

@synthesize deviceSpecificUI;

#pragma mark - static

+ (AppDelegate*)sharedDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

#pragma mark - private

- (void)customizeAppearance
{
    // Make table header text match the colorscheme.
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setColor:[UIColor lightTextColor]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setShadowColor:[UIColor blackColor]];
}

#pragma mark - override

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize logger
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[[DDFileLogger alloc] init]];
    
    [self customizeAppearance];
    
    self.cpuInfoCtrl = [[CPUInfoController alloc] init];
    self.deviceInfoCtrl = [[DeviceInfoController alloc] init];
    self.gpuInfoCtrl = [[GPUInfoController alloc] init];
    self.processInfoCtrl = [[ProcessInfoController alloc] init];
    self.ramInfoCtrl = [[RAMInfoController alloc] init];
    self.networkInfoCtrl = [[NetworkInfoController alloc] init];
    self.storageInfoCtrl = [[StorageInfoController alloc] init];
    self.batteryInfoCtrl = [[BatteryInfoController alloc] init];
    // AMDevice uses all the controllers above therefore should be initialized last.
    self.iDevice = [[AMDevice alloc] init];
    
    [self.cpuInfoCtrl startCPULoadUpdatesWithFrequency:kCpuLoadUpdateFrequency];
    [self.ramInfoCtrl startRAMUsageUpdatesWithFrequency:kRamUsageUpdateFrequency];
    [self.networkInfoCtrl startNetworkBandwidthUpdatesWithFrequency:kNetworkUpdateFrequency];
    [self.batteryInfoCtrl startBatteryMonitoring];
    
    self.deviceSpecificUI = [[DeviceSpecificUI alloc] init];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
