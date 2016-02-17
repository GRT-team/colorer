//
//  InAppHelper.h
//  Colorer
//
//  Created by illa on 9/1/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InAppHelperDelegate <NSObject>

-(void)purchaseCompleated;

@end

@interface InAppHelper : UIViewController{
    __weak IBOutlet UIButton *restoreBtn;
    __weak IBOutlet UILabel *labelPictures;
    __weak IBOutlet UILabel *label16;
    __weak IBOutlet UILabel *labelPrice;
    __weak IBOutlet UIButton *buyBtn;
    __weak IBOutlet UIView *parentalLock;
    __weak IBOutlet UILabel *taskLabel;
    __weak IBOutlet UITextField *answerTextField;
    __weak IBOutlet UILabel *parentallControll;
    NSInteger sum;
}


@property (nonatomic, assign) BOOL isBoardsUnlocked;
@property (nonatomic, strong) UIPopoverController *popController;
@property (assign, nonatomic) id<InAppHelperDelegate> delegate;

+ (InAppHelper*) shared;
@end
