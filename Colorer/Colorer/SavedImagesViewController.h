//
//  SavedImagesViewController.h
//  Colorer
//
//  Created by illa on 7/17/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"
#import "ShareViewController.h"
#import "CustomIOS7AlertView.h"

@interface SavedImagesViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIPopoverControllerDelegate,CustomIOS7AlertViewDelegate>
{
    UICollectionView *imageCollectionView;
    IBOutlet SMPageControl *pageControl;
    ShareViewController *shareViewController;
     NSMutableArray *savedImageArray;
    UIButton *shareButton;
    
    __weak IBOutlet UIView *parentalLock;
    __weak IBOutlet UILabel *taskLabel;
    __weak IBOutlet UITextField *answerTextField;
    __weak IBOutlet UILabel *parentallControll;
    NSInteger sum;
}

@property (nonatomic, retain) NSMutableArray *imageArray;
@property (nonatomic, retain) IBOutlet UICollectionView *imageCollectionView;
@property (nonatomic, strong) UIPopoverController *popController;

@end

