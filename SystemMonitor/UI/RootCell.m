//
//  RootCell.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "AMLogger.h"
#import "RootCell.h"

enum {
    TAG_CELL_IMAGE=1,
    TAG_CELL_LABEL=2
};

@interface RootCell()
- (void)refreshCellImage;

@property (nonatomic, strong) UIImage *cellImage;
@property (nonatomic, strong) UIImage *cellHighlightImage;
@end

@implementation RootCell

#pragma mark - override

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

    UILabel *label = (UILabel*) [self viewWithTag:TAG_CELL_LABEL];
    
    if (selected)
    {
        label.textColor = [UIColor colorWithRed:167.0/255.0 green:190.0/255.0 blue:231.0/255.0 alpha:255.0/255.0];
        label.font = [UIFont boldSystemFontOfSize:17.0];
    }
    else
    {
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:17.0];
    }
    
    [self refreshCellImage];
}

#pragma mark - public

- (void)setCellIconImage:(UIImage*)image
{
    self.cellImage = image;
    [self refreshCellImage];
}

- (void)setHighlightedCellIconImage:(UIImage*)image
{
    self.cellHighlightImage = image;
    [self refreshCellImage];
}

#pragma mark - private

- (void)refreshCellImage
{
    if (!self.cellImage || !self.cellHighlightImage)
    {
        return;
    }
    
    UIImageView *imageView = (UIImageView*)[self viewWithTag:TAG_CELL_IMAGE];
    
    if (self.selected)
    {
        [imageView setImage:self.cellHighlightImage];
    }
    else
    {
        [imageView setImage:self.cellImage];
    }
}

@end
