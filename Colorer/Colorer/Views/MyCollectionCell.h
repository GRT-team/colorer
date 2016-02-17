//
//  CollectionCell.h
//  Painting
//
//  Created by Illya Kyznetsov on 17.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCollectionCell : UICollectionViewCell

@property (weak,nonatomic) IBOutlet UIImageView *myImageView;
@property (weak,nonatomic) IBOutlet UIImageView *savedView;
@property (weak,nonatomic) IBOutlet UILabel *categoryName;
@property (weak,nonatomic) IBOutlet UIButton *shareButton;
@property (weak,nonatomic) IBOutlet UIButton *editButton;
@property (weak,nonatomic) IBOutlet UIButton *deleteButton;

@end
