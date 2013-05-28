//
//  ProcessTopView.h
//  ActivityMonitor++
//
//  Created by st on 22/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SORT_BY_ID=0,
    SORT_BY_NAME,
    SORT_BY_PRIORITY,
    SORT_BY_START_TIME
} SortFilter_t;

@protocol ProcessTopViewDelegate
- (void)processTopViewSortFilterChanged:(SortFilter_t)newFilter;
@end

@interface ProcessTopView : UIView
@property (weak, nonatomic) id<ProcessTopViewDelegate> delegate;

- (void)setProcessCount:(NSUInteger)count;
@end
