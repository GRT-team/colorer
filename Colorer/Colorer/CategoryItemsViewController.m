//
//  DetailViewController.m
//  Painting
//
//  Created by Illya Kyznetsov on 17.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import "CategoryItemsViewController.h"
#import "MyCollectionCell.h"
#import "DetailImageViewController.h"
#import "CustomPopoverBg.h"


@interface CategoryItemsViewController ()

@end

@implementation CategoryItemsViewController

#pragma mark - Managing the detail item


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    pageControl.numberOfPages = ceil([_categoryItems count]/8.);
    [pageControl setPageIndicatorImage:[UIImage imageNamed:@"PageControllNotSel"]];
	[pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"PageControllSel"]];
	
    [[InAppHelper shared] setDelegate:self];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [_categoryItems count];
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	NSDictionary *item = [_categoryItems objectAtIndex:indexPath.row];

    MyCollectionCell *mycell = (MyCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellId" forIndexPath:indexPath];
       mycell.myImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@th",[item objectForKey:@"itemImage"]]];
	
    if (![InAppHelper shared].isBoardsUnlocked && indexPath.row>1){
        mycell.savedView.hidden = NO;
    } else {
        mycell.savedView.hidden = YES;
    }
    
    return mycell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (![InAppHelper shared].isBoardsUnlocked && indexPath.row>1){
         UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
         InAppHelper *inAppHelper = [storyBoard instantiateViewControllerWithIdentifier:@"InAppViewController"];
		
		 CGRect rect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2+133, 0, 0);
		
         UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:inAppHelper];
         pop.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
         popController = pop;
		[pop presentPopoverFromRect: rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
         // make ourselves delegate so we learn when popover is dismissed
         pop.delegate = self;
		
         inAppHelper.popController =  popController;
		
    } else {
        [[SoundManager shared] playSound:boardHitSound];
        selectedRow = indexPath.row;
        [imageCollectionView deselectItemAtIndexPath:indexPath animated:YES];
		[self performSegueWithIdentifier:@"ShowImage" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"InApp"]){
       popController = [(UIStoryboardPopoverSegue *)segue popoverController];
	   popController.popoverBackgroundViewClass = [CustomPopoverBg class];
    }
	
	if ([segue.identifier isEqualToString:@"ShowImage"]){
        DetailImageViewController *detailImageViewController = [segue destinationViewController];
        detailImageViewController.imageName = [[_categoryItems objectAtIndex:selectedRow] objectForKey:@"itemImage"];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    ///Detect current page///
    float page = ceil(scrollView.contentOffset.x / scrollView.frame.size.width);
    pageControl.currentPage = page;
}

-(IBAction)back{
    [[SoundManager shared] playSound:buttonHitSound];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)purchaseCompleated{
    [imageCollectionView reloadData];
}


@end
