//
//  Photo.h
//  Drawer
//
//  Created by Illya Kyznetsov on 11.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ANImageBitmapRep.h"

@protocol AppDelegate
- (void)colorChanged:(UIColor *)newColor;
@end


@interface ImageView : UIView {
	UIImage *wheel;
	UIImage *brightness;
	UIColor *lastColor;
	ANImageBitmapRep *wheelAdjusted;
	CGRect colorFrame;
	CGRect circleFrame;
	float brightnessPCT;
	CGPoint selectedPoint;
	id<AppDelegate> delegate;
	BOOL drawsSquareIndicator;
	BOOL drawsBrightnessChanger;
    
    
    UIView * colorView;
    NSMutableArray *items;
    UIImageView *drawImage;
    BOOL mouseSwiped;
    int mouseMoved;
    UIColor *currentColor;
    CGPoint lastPoint;
    UIView *PaintView;
}
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic,retain) UIColor *currentColor;
@property (nonatomic, retain) IBOutlet     UIView *PaintView;
- (IBAction)brightnessChange:(id)sender;
- (void)saveState;



@property (nonatomic, readwrite) id <AppDelegate> delegate;
@property (readwrite) BOOL drawsSquareIndicator;
@property (readwrite) BOOL drawsBrightnessChanger;

-(void)encodeWithCoder:(NSCoder*)aCoder;

-(UIColor*)color;
-(void)setBrightness:(float)_brightness;
-(float)brightness;


@end


