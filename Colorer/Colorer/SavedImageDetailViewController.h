//
//  SavedImageDetailViewController.h
//  Colorer
//
//  Created by illa on 8/1/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"

@interface SavedImageDetailViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>{
    IBOutlet SMPageControl *pageControl;
}

@property (nonatomic, retain) NSIndexPath *currentPage;
@property (nonatomic, retain) NSMutableArray *savedImageArray;
@property (nonatomic, retain) NSMutableArray *savedImageNameArray;
@property (nonatomic, retain) IBOutlet UICollectionView *imageCollectionView;

@end
