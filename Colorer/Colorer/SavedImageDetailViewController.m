//
//  SavedImageDetailViewController.m
//  Colorer
//
//  Created by illa on 8/1/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import "SavedImageDetailViewController.h"
#import "MyCollectionCell.h"

@interface SavedImageDetailViewController ()

@end

@implementation SavedImageDetailViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	 NSInteger itemsCount = [_savedImageArray count];
	
    [pageControl setPageIndicatorImage:[UIImage imageNamed:@"pageControllNotSel"]];
    [pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"pageControllSel"]];
    pageControl.numberOfPages = itemsCount;
    pageControl.currentPage = _currentPage.row;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_imageCollectionView scrollToItemAtIndexPath:_currentPage atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_savedImageNameArray count];
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    MyCollectionCell *mycell = (MyCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellId" forIndexPath:indexPath];
    mycell.myImageView.image = [UIImage imageNamed:[_savedImageNameArray objectAtIndex:row]];
    mycell.savedView.image = [_savedImageArray objectAtIndex:indexPath.row];
    return mycell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {    
    float page = ceil(scrollView.contentOffset.x / scrollView.frame.size.width);
    pageControl.currentPage = page;
}

-(IBAction)back{
    [[SoundManager shared] playSound:buttonHitSound];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
