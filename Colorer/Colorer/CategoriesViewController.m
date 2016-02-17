//
//  CategoriesViewController.m
//  Colorer
//
//  Created by illa on 7/17/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import "CategoriesViewController.h"
#import "MyCollectionCell.h"
#import "CategoryItemsViewController.h"

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Get categoryImages from plist
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ImagesInfo" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
    categoryArray = [dict objectForKey:@"Categories"];

    //Create pagind indicator
    NSInteger itemsCount = categoryArray.count;
    float imagesCount = (itemsCount/6.);
    pageControl.numberOfPages = ceil(imagesCount);
    [pageControl setPageIndicatorImage:[UIImage imageNamed:@"pageControllNotSel"]];
	[pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"pageControllSel"]];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [categoryArray count];
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCollectionCell *mycell = (MyCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellId" forIndexPath:indexPath];
    NSDictionary *item = [categoryArray objectAtIndex:indexPath.row];
    mycell.myImageView.image = [UIImage imageNamed:[item objectForKey:@"categoryImage"]];
    mycell.categoryName.text = [item objectForKey:@"categoryName"];
    return mycell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [[SoundManager shared] playSound:boardHitSound];
    selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"toSubcategory" sender:self];
    [categoriesCollectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([segue.identifier isEqualToString:@"toSubcategory"])
	{
        CategoryItemsViewController *categoryItemsViewController = [segue destinationViewController];
        categoryItemsViewController.categoryItems = [[categoryArray objectAtIndex:selectedRow] objectForKey:@"categoryItems"];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //Detect current page
    float page = ceil(scrollView.contentOffset.x / scrollView.frame.size.width);
    pageControl.currentPage = page;
}

-(IBAction)back{
    [[SoundManager shared] playSound:buttonHitSound];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
