//
//  DetailViewController.m
//  Painting
//
//  Created by Illya Kyznetsov on 17.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionCell.h"
#import "TableViewData.h"
#import "ColectionViewData.h"
#import "DetailImageViewController.h"
@interface CollectionViewController ()
- (void)configureView;
@end

@implementation CollectionViewController
@synthesize tableViewData,colectionViewData;
@synthesize imageArray,managedObjectContext,imageCollectionView;
#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    
             
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"colId" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
        
        
        NSMutableArray *sortedTasks = [[NSMutableArray alloc] initWithArray:[tableViewData.imageincollection allObjects]];
       
      // NSMutableArray *sortedTasks = [[NSMutableArray alloc] initWithObjects:@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG",@"PIC_0008.JPG", nil];
    
        [sortedTasks sortUsingDescriptors:sortDescriptors];
        
        self.imageArray = sortedTasks;
    /*
    if (sortedTasks.count < 5) {
        self.imageArray = sortedTasks;
    }
    else{
    self.imageArray = [sortedTasks objectsAtIndexes:
                       [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sortedTasks.count - 2)]];
    }
        [self.imageCollectionView reloadData];
 */   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    imageCollectionView.backgroundColor = [UIColor whiteColor];
    [self configureView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [imageArray count];
    
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
     NSInteger row = indexPath.row;
    CollectionCell *mycell = (CollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellId" forIndexPath:indexPath];
    
   ColectionViewData *tas = [imageArray objectAtIndex:row];
   mycell.imageView.image = [UIImage imageWithData:tas.colViewImage];
   //mycell.imageView.image = [UIImage imageNamed:[imageArray objectAtIndex:row]];
         return mycell;
                         
}
                         


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
      ColectionViewData *tas = [imageArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ShowImage" sender:tas];
    [self.imageCollectionView deselectItemAtIndexPath:indexPath animated:YES];
 
    
        } 

    
    


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ShowImage"])
	{
        DetailImageViewController *flickrPhotoViewController = segue.destinationViewController;
        flickrPhotoViewController.colViewData = sender;
	}
}


@end
