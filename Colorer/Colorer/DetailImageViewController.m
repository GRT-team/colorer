//
//  DetailImageViewController.m
//  Painting
//
//  Created by Illya Kyznetsov on 18.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import "DetailImageViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "GAI.h"

#define CleanAlert 1
#define SaveAlert 2

@interface DetailImageViewController (){
    float redColor,greenColor,blueColor;
}

@end

@implementation DetailImageViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    bgImage.image = [UIImage imageNamed:_imageName];
   
    //find PaintingView in the storyboard/
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[PaintingView class]]) {
            paintingView = (PaintingView*)view;
            
            /// Refer to the OpenGL view to set the brush color
            [self changeColor:basicColor];
            currentColor.backgroundColor = [UIColor colorWithRed:(156./255.) green:(204./255.) blue:(101/255.) alpha:1];
            paintingView.delegate = self;
            paintingView.paletteShown = YES;
            paintingView.optionsShown = YES;
            [paintingView.layer setCornerRadius:60.0f];
            
            break;
        }
    }
    
    //Customize sliders
    UIImage *minLineImage = [[UIImage imageNamed:@"sliderLineWidth.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxLineImage = [[UIImage imageNamed:@"sliderLineWidth.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    UIImage *thumbImage = [UIImage imageNamed:@"sliderThumb.png"];
    
    [lineWidthSlider setMaximumTrackImage:maxLineImage forState:UIControlStateNormal];
    [lineWidthSlider setMinimumTrackImage:minLineImage forState:UIControlStateNormal];
    [lineWidthSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    UIImage *minAlphaImage = [[UIImage imageNamed:@"sliderAlpha.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxAlphaImage = [[UIImage imageNamed:@"sliderAlpha.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    
    [alphaSlider setMaximumTrackImage:minAlphaImage forState:UIControlStateNormal];
    [alphaSlider setMinimumTrackImage:maxAlphaImage forState:UIControlStateNormal];
    [alphaSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    alphaSlider.transform = CGAffineTransformMakeRotation(M_PI/2);
    lineWidthSlider.transform = CGAffineTransformMakeRotation(M_PI/2);
    imageSaved = YES;
    
    [[SoundManager shared] soundForBrush:drawSound];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    //if image is saved - load it
    if (_savedImage) {
        [paintingView setImage:_savedImage];
    }
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    paintingView.alpha = 1;
    bgImage.alpha = 1;
    [UIView commitAnimations];
    
    [super viewDidAppear:animated];
}


-(IBAction)changeColor:(id)sender{
    UIButton *color = (UIButton*)sender;
    NSString *cId = color.restorationIdentifier;
    NSString *colorName;
    switch (cId.intValue) {
        case red:
            redColor = (255./255.);
            greenColor = (61./255.);
            blueColor = (0./255.);
            colorName = @"red";
            break;
        case orange:
            redColor = (255./255.);
            greenColor = (145./255.);
            blueColor = (0./255.);
            colorName = @"orange";
            break;
        case yellow:
            redColor = (255./255.);
            greenColor = (234./255.);
            blueColor = (0./255.);
            colorName = @"yellow";
            break;
        case lime:
            redColor = (198./255.);
            greenColor = (255./255.);
            blueColor = (0./255.);
            colorName = @"lime";
            break;
        case green:
            redColor = (156./255.);
            greenColor = (204./255.);
            blueColor = (101./255.);
            colorName = @"lime";
            break;
        case turquoise:
            redColor = (0./255.);
            greenColor = (229./255.);
            blueColor = (255./255.);
            colorName = @"turquoise";
            break;
        case blue:
            redColor = (68./255.);
            greenColor = (138./255.);
            blueColor = (255./255.);
            colorName = @"blue";
            break;
        case purple:
            redColor = (149./255.);
            greenColor = (117./255.);
            blueColor = (205./255.);
            colorName = @"purple";
            break;
        case brown:
            redColor = (109./255.);
            greenColor = (76./255.);
            blueColor = (65./255.);
            colorName = @"brown";
            break;
            
        default:
            break;
    }
	
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"color_changed"     // Event category (required)
                                                          action:colorName         // Event action (required)
                                                           label:nil          // Event label
                                                           value:nil] build]];    // Event value
    
    currentColor.backgroundColor = [UIColor colorWithRed:redColor green:greenColor blue:blueColor alpha:1];
    [paintingView setBrushColorWithRed:redColor green:greenColor blue:blueColor opacity:alphaSlider.value];
    [paintingView eraseModeOff];
    [[SoundManager shared] soundForBrush:drawSound];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hidePalette];
    [self hideOptions];
    
    paintingView.paletteShown = NO;
}

-(IBAction)showPalette:(id)sender{
    //palette is opening & small color indicator change its color to basic
    int x = CGRectGetMaxX(paletteButton.frame);
    int y = CGRectGetMaxY(paletteButton.frame);
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y/2);
    transform = CGAffineTransformRotate(transform, 0);
    transform = CGAffineTransformTranslate(transform,-x,-y/2);
    paletteView.transform = transform;
    currentColorSmallButton.backgroundColor = [UIColor colorWithRed:(109./255.) green:(76./255.) blue:(65./255.) alpha:1];
    [UIView commitAnimations];
	
    paintingView.paletteShown = YES;
    paletteButton.userInteractionEnabled = NO;
}

-(IBAction)showOptions{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    optionsView.center = CGPointMake(self.view.frame.size.width - optionsView.frame.size.width/2+ 10 , self.view.frame.size.height/2);
    [UIView commitAnimations];
    paintingView.optionsShown = YES;
}

-(IBAction)hideOptions{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    optionsView.center = CGPointMake(self.view.frame.size.width + (optionsView.frame.size.width/2)*0.2, self.view.frame.size.height/2);
    [UIView commitAnimations];
    paintingView.optionsShown = NO;
    
}

-(void)hidePalette{
    //palette is hiding & small color indicator change its colorto selected one
    int x = CGRectGetMaxX(paletteButton.frame);
    int y = CGRectGetMaxY(paletteButton.frame);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y+y/1.5);
    transform = CGAffineTransformRotate(transform,M_PI);
    transform = CGAffineTransformTranslate(transform,x,y);
    paletteView.transform = transform;
    currentColorSmallButton.backgroundColor = currentColor.backgroundColor;
    [UIView commitAnimations];
    paletteButton.userInteractionEnabled = YES;
}


-(IBAction)showBrushes:(id)sender{
    UIButton *showBrushBtn = (UIButton*)sender;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    if (brushesView.alpha == 0) {
        brushesView.alpha = 1;
        brushesView.frame = CGRectMake(-20, showBrushBtn.frame.origin.y, 60, 300);
    } else {
        [self hideBrushes];
    }
    [UIView commitAnimations];
}

-(IBAction)hideBrushes{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    brushesView.alpha = 0;
    brushesView.frame = CGRectMake (91, 140, 0, 0);
    [UIView commitAnimations];
}

-(void)selectedTool:(NSString*)name{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"brush_changed"     // Event category (required)
                                                          action:name         // Event action (required)
                                                           label:nil          // Event label
                                                           value:nil] build]];    // Event value
    
    [[SoundManager shared] soundForBrush:drawSound];
    [showBrushButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Tool",name]] forState:UIControlStateNormal];
    [showBrushButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"a_%@Tool",name]] forState:UIControlStateHighlighted];
}

-(IBAction)saveImage{
    [[SoundManager shared] playSound:savedSound];
    
    //save drawn image
    UIImage *viewImage = [paintingView imageRepresentation];
    
    NSString *imageExtension = @".png";
    if ([_imageName containsString:imageExtension]) {
        imageExtension = @"";
    }
    
    NSString* path = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@%@",_imageName,imageExtension]];
    
    BOOL ok = [[NSFileManager defaultManager] createFileAtPath:path
                                                      contents:nil attributes:nil];
    if (!ok)
    {
        NSLog(@"Error creating file %@", path);
    }
    else
    {
        NSFileHandle* myFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        [myFileHandle writeData:UIImagePNGRepresentation(viewImage)];
        [myFileHandle closeFile];
        imageSaved = YES;
        paintingView.lineDrawn = NO;
    }
}

-(IBAction)changeAlpha:(id)sender{
    [paintingView setBrushColorWithRed:redColor green:greenColor blue:blueColor opacity:alphaSlider.value];
}

-(IBAction)changeLineWidth:(id)sender{
    [paintingView changeWidth:lineWidthSlider.value];
}

-(IBAction)clearImage{
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    [[SoundManager shared] playSound:clearSound];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createView]];
    
    // Modify the parameters
    [alertView setDelegate:self];
    alertView.tag = CleanAlert;
    [alertView setUseMotionEffects:true];
    [alertView show:@" Clear all? "];
    
}

//Custom alertView
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex{
    [[SoundManager shared] playSound:buttonHitSound];
	
    if (alertView.tag == CleanAlert) {
        if (buttonIndex == 1) {
            [paintingView erase];
        }
    }
	
    if (alertView.tag == SaveAlert) {
        if (buttonIndex == 1) {
            [self saveImage];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [alertView close];
}

- (UIImageView *)createView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 379, 262)];
    [imageView setImage:[UIImage imageNamed:@"alertViewBg"]];
    
    return imageView;
}


-(IBAction)eraseMode{
    [[SoundManager shared] soundForBrush:eraseSound];
    [paintingView eraseMode];
}

-(IBAction)back{
    [[SoundManager shared] playSound:buttonHitSound];
	
    if (imageSaved && !paintingView.lineDrawn) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
        
        // Add some custom content to the alert view
        [alertView setContainerView:[self createView]];        
        // Modify the parameters
        [alertView setDelegate:self];
        alertView.tag = SaveAlert;
        [alertView setUseMotionEffects:true];
        [alertView show:@" Save changes? "];
    }
}



@end