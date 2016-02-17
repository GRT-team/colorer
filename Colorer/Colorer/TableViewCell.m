//
//  TableViewCell.m
//  Painting
//
//  Created by Illya Kyznetsov on 20.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

@synthesize name;
@synthesize photo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
       return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
