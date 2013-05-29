//
//  RootTableViewController.h
//  ActivityMonitor++
//
//  Created by st on 29/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    VIEW_CTRL_GENERAL=0,
    VIEW_CTRL_CPU,
    VIEW_CTRL_PROCESSES,
    VIEW_CTRL_RAM,
    VIEW_CTRL_GPU,
    VIEW_CTRL_NETWORK,
    VIEW_CTRL_CONNECTIONS,
    VIEW_CTRL_STORAGE,
    VIEW_CTRL_BATTERY,
    VIEW_CTRL_MAX
} ViewCtrl_t;

static NSString *ViewCtrlIdentifiers[] = {
    [VIEW_CTRL_GENERAL]     = @"GeneralViewController",
    [VIEW_CTRL_CPU]         = @"CPUViewController",
    [VIEW_CTRL_PROCESSES]   = @"ProcessViewController",
    [VIEW_CTRL_RAM]         = @"RAMViewController",
    [VIEW_CTRL_GPU]         = @"GPUViewController",
    [VIEW_CTRL_NETWORK]     = @"NetworkViewController",
    [VIEW_CTRL_CONNECTIONS] = @"ConnectionViewController",
    [VIEW_CTRL_STORAGE]     = @"StorageViewController",
    [VIEW_CTRL_BATTERY]     = @"BatteryViewController"
};

static NSString *CellImageFilenames[] = {
    [VIEW_CTRL_GENERAL]     = @"GeneralIcon-normal.png",
    [VIEW_CTRL_CPU]         = @"CpuIcon-normal.png",
    [VIEW_CTRL_PROCESSES]   = @"ProcessesIcon-normal.png",
    [VIEW_CTRL_RAM]         = @"RamIcon-normal.png",
    [VIEW_CTRL_GPU]         = @"GpuIcon-normal.png",
    [VIEW_CTRL_NETWORK]     = @"NetworkIcon-normal.png",
    [VIEW_CTRL_CONNECTIONS] = @"ConnectionsIcon-normal.png",
    [VIEW_CTRL_STORAGE]     = @"StorageIcon-normal.png",
    [VIEW_CTRL_BATTERY]     = @"BatteryIcon-normal.png"
};

static NSString *CellHighlightImageFilenames[] = {
    [VIEW_CTRL_GENERAL]     = @"GeneralIcon-highlight.png",
    [VIEW_CTRL_CPU]         = @"CpuIcon-highlight.png",
    [VIEW_CTRL_PROCESSES]   = @"ProcessesIcon-highlight.png",
    [VIEW_CTRL_RAM]         = @"RamIcon-highlight.png",
    [VIEW_CTRL_GPU]         = @"GpuIcon-highlight.png",
    [VIEW_CTRL_NETWORK]     = @"NetworkIcon-highlight.png",
    [VIEW_CTRL_CONNECTIONS] = @"ConnectionsIcon-highlight.png",
    [VIEW_CTRL_STORAGE]     = @"StorageIcon-highlight.png",
    [VIEW_CTRL_BATTERY]     = @"BatteryIcon-highlight.png"
};

@interface RootTableViewController : UITableViewController
- (void)switchView:(ViewCtrl_t)viewCtrl;
@end
