//
//  ProcessSort.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "ProcessTopView.h"

typedef enum {
    SORT_BY_ID=0,
    SORT_BY_NAME,
    SORT_BY_PRIORITY,
    SORT_BY_START_TIME,
    
    SORT_CHOICE_COUNT
} SortFilter_t;
#define SORT_DEFAULT SORT_BY_NAME

extern NSString* SortChoices[];

@protocol ProcessSortViewControllerDelegate
- (void)processSortFilterChanged:(SortFilter_t)newFilter;
@end
