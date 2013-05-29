//
//  ProcessSort.h
//  ActivityMonitor++
//
//  Created by st on 29/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#ifndef ActivityMonitor___ProcessSort_h
#define ActivityMonitor___ProcessSort_h

#import "ProcessTopView.h"

typedef enum {
    SORT_BY_ID=0,
    SORT_BY_NAME,
    SORT_BY_PRIORITY,
    SORT_BY_START_TIME
} SortFilter_t;
#define SORT_DEFAULT SORT_BY_NAME

static char *sortChoices[] = {
    "Sort by ID",
    "Sort by Name",
    "Sort by Priority",
    "Sort by Start Time"
};
#define SORT_CHOICE_COUNT   4

@protocol ProcessSortViewControllerDelegate
- (void)processSortFilterChanged:(SortFilter_t)newFilter;
@end

#endif
