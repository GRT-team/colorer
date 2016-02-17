//
//  SavedImagesViewController.m
//  Colorer
//
//  Created by illa on 7/17/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import "SavedImagesViewController.h"
#import "MyCollectionCell.h"
#import "DetailImageViewController.h"
#import "SavedImageDetailViewController.h"


@interface SavedImagesViewController ()

@end

@implementation SavedImagesViewController

@synthesize imageArray,imageCollectionView;
#pragma mark - Managing the detail item

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[pageControl setPageIndicatorImage:[UIImage imageNamed:@"pageControllNotSel"]];
	[pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"pageControllSel"]];
	
	parentallControll.font = [UIFont fontWithName:@"Snickles" size:parentallControll.font.pointSize];
	answerTextField.font = [UIFont fontWithName:@"Blenda Script" size:answerTextField.font.pointSize];
	
}

-(void)viewWillAppear:(BOOL)animated{
	NSString* path = [NSHomeDirectory() stringByAppendingString:@"/Documents"];
	NSError *error;
	NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
	imageArray = [NSMutableArray arrayWithArray:fileArray];
	
	for (int i = 0; i < [imageArray count]; i++) {
		NSRange range = [[imageArray objectAtIndex:i] rangeOfString:@".png"];
		BOOL contains = range.location != NSNotFound;
		if (!contains) {
			[imageArray removeObjectAtIndex:i];
		}
	}
	
	UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
	shareViewController = [storyBoard instantiateViewControllerWithIdentifier:@"shareViewController"];
	savedImageArray = [[NSMutableArray alloc] init];
	
	for (NSString *name in imageArray) {
		NSString* path = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",name]];
		NSFileHandle* myFileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
		UIImage* loadedImage = [UIImage imageWithData:[myFileHandle readDataToEndOfFile]];
		
		if (loadedImage) {
			[savedImageArray addObject:loadedImage];
		}
	}
	
	NSInteger itemsCount = [savedImageArray count];
	float imagesCount = (itemsCount/6.);
	
	pageControl.numberOfPages = ceil(imagesCount);
	[imageCollectionView reloadData];
}

-(void)generateSum{
	int a = arc4random_uniform(49);
	int b = arc4random_uniform(49);
	taskLabel.text = [NSString stringWithFormat:@"%d + %d =",a,b];
	[taskLabel setAttributedText:[self textForFontSize]];
	sum = a+b;
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
	
	return [savedImageArray count];
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger row = indexPath.row;
	MyCollectionCell *mycell = (MyCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellId" forIndexPath:indexPath];
	NSString *inageThumb = [imageArray objectAtIndex:row];
	inageThumb = [[inageThumb lastPathComponent] stringByDeletingPathExtension];
	mycell.myImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@th",inageThumb]];
	mycell.savedView.image = [savedImageArray objectAtIndex:row];
	mycell.shareButton.tag = row;
	mycell.editButton.tag = row;
	mycell.deleteButton.tag = row;
	
	return mycell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	[[SoundManager shared] playSound:boardHitSound];
	[self performSegueWithIdentifier:@"detailImage" sender:indexPath];
}

-(IBAction)showPopover:(id)sender{
	[[SoundManager shared] playSound:buttonHitSound];
	[self generateSum];
	shareButton = (UIButton*)sender;
	
	[answerTextField becomeFirstResponder];
	parentalLock.alpha = 1;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	float page = ceil(scrollView.contentOffset.x / scrollView.frame.size.width);
	pageControl.currentPage = page;
}

-(IBAction)editImage:(id)sender{
	[[SoundManager shared] playSound:buttonHitSound];
	[self performSegueWithIdentifier:@"editImage" sender:sender];
}

-(IBAction)deleteImage:(id)sender{
	UIButton *deleteButton = (UIButton*)sender;
	CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
	
	// Add some custom content to the alert view
	[alertView setContainerView:[self createView]];
	
	// Modify the parameters
	[alertView setDelegate:self];
	alertView.tag = deleteButton.tag;
	[alertView setUseMotionEffects:true];
	[alertView show:@" Delete image? "];
	
	[[SoundManager shared] playSound:buttonHitSound];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"editImage"])
	{   UIButton *editButton = (UIButton*)sender;
		DetailImageViewController *detailImageViewController = [segue destinationViewController];
		detailImageViewController.savedImage = [savedImageArray objectAtIndex:editButton.tag];
		detailImageViewController.imageName = [imageArray objectAtIndex:editButton.tag];
	}
	
	if ([segue.identifier isEqualToString:@"detailImage"])
	{   NSIndexPath *indexPath = (NSIndexPath*)sender;
		SavedImageDetailViewController *savedImageDetailViewController = [segue destinationViewController];
		savedImageDetailViewController.savedImageArray = savedImageArray;
		savedImageDetailViewController.savedImageNameArray = imageArray;
		savedImageDetailViewController.currentPage = indexPath;
	}
}

-(IBAction)back{
	[[SoundManager shared] playSound:buttonHitSound];
	[self.navigationController popViewControllerAnimated:YES];
}

//Custom alertView
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[[SoundManager shared] playSound:buttonHitSound];
		NSString* path = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",[imageArray objectAtIndex:alertView.tag]]];
		[imageArray  removeObjectAtIndex:alertView.tag];
		[savedImageArray  removeObjectAtIndex:alertView.tag];
		
		NSError *error;
		[[NSFileManager defaultManager] removeItemAtPath: path error: &error];
		[imageCollectionView reloadData];
		
		NSInteger itemsCount = [savedImageArray count];
		float imagesCount = (itemsCount/6.);
		
		pageControl.numberOfPages = ceil(imagesCount);
	}
	
	[alertView close];
}

- (UIImageView *)createView
{
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 379, 262)];
	[imageView setImage:[UIImage imageNamed:@"alertViewBg"]];
	
	return imageView;
}

-(IBAction)closeParrentalLock:(id)sender{
	parentalLock.alpha = 0;
	[answerTextField resignFirstResponder];
	answerTextField.text = @"";
	
}

-(IBAction)closeKeyboard:(id)sender{
	if (answerTextField.text.integerValue == sum) {
		parentalLock.alpha = 0;
		[answerTextField resignFirstResponder];
		answerTextField.text = @"";
		
		UIImage* loadedImage = [savedImageArray objectAtIndex:shareButton.tag];
		UIImage *bgImage = [UIImage imageNamed:[imageArray objectAtIndex:shareButton.tag]];
		CGSize size = [loadedImage size];
		CGSize bgSize = [bgImage size];
		float scale = MAX(bgSize.height/size.height, bgSize.width/size.width);
		
		// Create a graphic context that you can draw to. You can change the size of the
		// graphics context (your 'canvas') by modifying the parameters inside the
		UIGraphicsBeginImageContext(bgSize);
		// Draw your first image to your graphic context
		[loadedImage drawInRect:CGRectMake(-85,0,size.width*scale,size.height*scale)];
		// Draw the second image to your newly created graphic context
		[bgImage drawInRect:CGRectMake(0,0,bgSize.width,bgSize.height)];
		// Get the new image from the graphic context
		UIImage *theOneImage = UIGraphicsGetImageFromCurrentImageContext();
		
		// Get rid of the graphic context
		UIGraphicsEndImageContext();
		
		shareViewController.sharedImage = theOneImage;
		shareViewController.imageName = [imageArray objectAtIndex:shareButton.tag];
		
		NSIndexPath *inedexPath = [NSIndexPath indexPathForRow:shareButton.tag inSection:0];
		UICollectionViewCell *cell = [imageCollectionView cellForItemAtIndexPath:inedexPath];
		
		UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:shareViewController];
		self.popController = pop;
		[pop presentPopoverFromRect: shareButton.frame inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		// make ourselves delegate so we learn when popover is dismissed
		pop.delegate = self;
	} else {
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
