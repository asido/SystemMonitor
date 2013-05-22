//
//  DefaultCell.m
//  ActivityMonitor++
//
//  Created by st on 22/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "DefaultCell.h"

@implementation DefaultCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellNoJoins.png"]];
        //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CellNoJoins.png"]];
    }
    return self;
}

@end
