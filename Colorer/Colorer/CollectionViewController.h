//
//  DetailViewController.h
//  Painting
//
//  Created by Illya Kyznetsov on 17.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TableViewData,ColectionViewData;
@interface CollectionViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray *imageArray;
    TableViewData *tableViewData;
    ColectionViewData *colectionViewData;
    UICollectionView *imageCollectionView;
    NSManagedObjectContext *managedObjectContext;

}

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) NSMutableArray *imageArray;
@property (nonatomic, retain) TableViewData *tableViewData;
@property (nonatomic, retain) ColectionViewData *colectionViewData;
@property (nonatomic, retain) IBOutlet UICollectionView *imageCollectionView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
