//
//  InAppHelper.m
//  Colorer
//
//  Created by illa on 9/1/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import "InAppHelper.h"
#import "MKStoreManager.h"
#import "SoundManager.h"

@implementation InAppHelper

static InAppHelper *instance;
+ (InAppHelper*) shared {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        instance = [storyBoard instantiateViewControllerWithIdentifier:@"InAppViewController"];

  // instance = [[super alloc] initWithNibName:@"InAppViewController" bundle:nil];
        // is 2 boards unlocked

        if ([MKStoreManager isFeaturePurchased:kUnlockBoardsProductID]) {
            instance.isBoardsUnlocked = YES;
        } else {
           instance.isBoardsUnlocked = NO;
        }
        
    });
    
    return instance;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    restoreBtn.titleLabel.font = [UIFont fontWithName:@"Snickles" size:restoreBtn.titleLabel.font.pointSize];
    restoreBtn.transform = CGAffineTransformMakeRotation(-M_PI_2*0.1);
    labelPictures.font = [UIFont fontWithName:@"Snickles" size:labelPictures.font.pointSize];
    label16.font = [UIFont fontWithName:@"Snickles" size:label16.font.pointSize];
    labelPrice.font = [UIFont fontWithName:@"Blenda Script" size:labelPrice.font.pointSize];
    buyBtn.titleLabel.font = [UIFont fontWithName:@"Snickles" size:buyBtn.titleLabel.font.pointSize];
    parentallControll.font = [UIFont fontWithName:@"Snickles" size:parentallControll.font.pointSize];
    answerTextField.font = [UIFont fontWithName:@"Blenda Script" size:answerTextField.font.pointSize];
}

-(void)generateSum{
    int a = arc4random_uniform(49);
    int b = arc4random_uniform(49);
    taskLabel.text = [NSString stringWithFormat:@"%d + %d =",a,b];
    [taskLabel setAttributedText:[self textForFontSize]];
    sum = a+b;
    [answerTextField becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
   [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePriceNotif:) name:kProductFetchedNotification object:nil];
    [self updatePrise];
    [self generateSum];
    
   }

-(void)updatePriceNotif:(NSNotification*) notificationObject {
    [self updatePrise];
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductFetchedNotification object:nil];
}

-(void)updatePrise{
    NSDictionary *prices = [[MKStoreManager sharedManager] pricesDictionary];
    if (prices) {
        labelPrice.text = [prices objectForKey:kUnlockBoardsProductID];
    }

}

-(IBAction)closeInApp:(id)sender{
    [[SoundManager shared] playSound:buttonHitSound];
      [self.popController dismissPopoverAnimated:YES];
}

-(IBAction)buyFeature:(id)sender{
    [[SoundManager shared] playSound:buttonHitSound];
    [[MKStoreManager sharedManager] buyFeature:kUnlockBoardsProductID onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
        instance.isBoardsUnlocked = YES;
        [instance.delegate purchaseCompleated];
    } onCancelled:^{
        
    }];
}

- (IBAction)purchaseRestore:(id)sender {
    [[SoundManager shared] playSound:buttonHitSound];
    [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^{
        
        if([MKStoreManager isFeaturePurchased:kUnlockBoardsProductID])
        {
            instance.isBoardsUnlocked = YES;
            [instance.delegate purchaseCompleated];
        }
        
    } onError:^(NSError *error) {        
        
    }];
}

-(IBAction)closeKeyboard:(id)sender{
    
    if (answerTextField.text.integerValue == sum) {
        parentalLock.hidden = YES;
        [sender resignFirstResponder];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Wrong number" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
        answerTextField.text = @"";
        [self generateSum];
    }   
}


#define atributedText

- (NSAttributedString *)textForFontSize {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:taskLabel.text];
    UIFont *font = [UIFont fontWithName:@"Blenda Script" size:47];
    
    NSUInteger colorLenght = taskLabel.text.length;

    
    for (int i=0; i<colorLenght; i++) {
        UIColor *color = [self returnTextColor:arc4random_uniform(5)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(i, 1)];
        [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(i, 1)];
  
      
    }
    
    return attrStr;
}


-(UIColor*)returnTextColor :(int)colorId{
    UIColor *color;
    switch (colorId) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1:
            color = [UIColor greenColor];
            break;
        case 2:
            color = [UIColor yellowColor];
            break;
        case 3:
            color = [UIColor blueColor];
            break;
        case 4:
            color = [UIColor blackColor];
            break;
            
    }
    
    return color;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self closeKeyboard:nil];
    return answerTextField.text.integerValue == sum;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return (range.location > 1) ? NO : YES;
}

@end
