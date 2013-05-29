//
//  RootTableViewController.m
//  ActivityMonitor++
//
//  Created by st on 29/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "RootTableViewController.h"

@implementation RootTableViewController

- (void)switchView:(ViewCtrl_t)viewCtrl
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
