//
//  ProcessSort.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "ProcessSort.h"

NSString* SortChoices[] = {
    [SORT_BY_ID] = @"Sort by ID",
    [SORT_BY_NAME] = @"Sort by Name",
    [SORT_BY_PRIORITY] = @"Sort by Priority",
    [SORT_BY_START_TIME] = @"Sort by Start Time"
};