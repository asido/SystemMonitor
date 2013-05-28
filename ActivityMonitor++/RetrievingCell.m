//
//  RetrievingCell.m
//  ActivityMonitor++
//
//  Created by st on 28/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "RetrievingCell.h"

enum {
    TAG_ACTIVITY_INDICATOR=1
};

@implementation RetrievingCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ConnectionCell.png"]];
    }
    return self;
}

@end
