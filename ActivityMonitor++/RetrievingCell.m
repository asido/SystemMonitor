//
//  RetrievingCell.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
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
