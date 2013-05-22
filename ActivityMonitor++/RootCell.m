//
//  RootCell.m
//  ActivityMonitor++
//
//  Created by st on 22/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import "RootCell.h"

@interface RootCell()

@end

@implementation RootCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    UILabel *label = (UILabel*) [self viewWithTag:1];
    
    if (selected)
    {
        label.textColor = [UIColor colorWithRed:167.0f/255.0f green:190.0f/255.0f blue:231.0f/255.0f alpha:255.0f/255.0f];
        label.font = [UIFont boldSystemFontOfSize:17.0f];
    }
    else
    {
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:17.0f];
    }
}

@end
