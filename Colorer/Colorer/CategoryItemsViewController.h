//
//  DetailViewController.h
//  Painting
//
//  Created by Illya Kyznetsov on 17.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"
#import "InAppHelper.h"

@interface CategoryItemsViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIPopoverControllerDelegate,InAppHelperDelegate>
{
   IBOutlet UICollectionView *imageCollectionView;
    IBOutlet SMPageControl *pageControl;
    NSInteger selectedRow;
    UIPopoverController *popController;
}

@property (nonatomic, retain) NSMutableArray *categoryItems;

-(IBAction)back;
-(void)purchaseCompleated;

@end
