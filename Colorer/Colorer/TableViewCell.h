//
//  TableViewCell.h
//  Painting
//
//  Created by Illya Kyznetsov on 20.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell{
UILabel *name;
UIImageView *photo;
}

@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UIImageView *photo;

@end
