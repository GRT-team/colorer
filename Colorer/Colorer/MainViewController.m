//
//  MasterViewController.m
//  Painting
//
//  Created by Illya Kyznetsov on 17.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import "MainViewController.h"



@interface MainViewController ()

@end

@implementation MainViewController


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
	// Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
	
    [SoundManager shared];
}

- (void)didReceiveMemoryWarning
{
	// Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
	
}

-(IBAction)playSound{
     [[SoundManager shared] playSound:boardHitSound];
}

@end
