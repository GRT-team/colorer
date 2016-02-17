//
//  CategoriesViewController.h
//  Colorer
//
//  Created by illa on 7/17/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"

@interface CategoriesViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>{
	UICollectionView *categoriesCollectionView;
	NSArray *categoryArray;
	IBOutlet SMPageControl *pageControl;
	NSInteger selectedRow;
}

-(IBAction)back;

@end
