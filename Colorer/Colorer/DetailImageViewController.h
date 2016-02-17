//
//  DetailImageViewController.h
//  Painting
//
//  Created by Illya Kyznetsov on 18.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintingView.h"
#import "CustomIOS7AlertView.h"

typedef enum {    
    red=0,
    orange,
    yellow,
    lime,
    green,
    turquoise,
    blue,
    purple,
    brown,
} colors;

@interface DetailImageViewController : UIViewController<PaintingViewDelegate,CustomIOS7AlertViewDelegate>{
   PaintingView *paintingView;
   IBOutlet UIImageView *bgImage;
   IBOutlet UIView *paletteView;
   IBOutlet UIView *currentColor;
   IBOutlet UIButton *paletteButton;
   IBOutlet UIButton *currentColorSmallButton;
   IBOutlet UIButton *basicColor;
   IBOutlet UIButton *showBrushButton;
   IBOutlet UIView *optionsView;
   IBOutlet UIView *brushesView;
   IBOutlet UISlider *alphaSlider;
   IBOutlet UISlider *lineWidthSlider;
   BOOL imageSaved;
}

@property NSString *imageName;
@property (nonatomic,retain) UIImage *savedImage;

-(IBAction)back;
    
@end

