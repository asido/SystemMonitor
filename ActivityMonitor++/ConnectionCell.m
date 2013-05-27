//
//  ConnectionCell.m
//  ActivityMonitor++
//
//  Created by st on 27/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "ConnectionCell.h"

@implementation ConnectionCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ConnectionCell.png"]];
    }
    return self;
}
@end
