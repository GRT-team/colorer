//
//  DrawingView.h
//  Colorer
//
//  Created by illa on 7/10/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingView : UIView{
    CGPoint currentPoint;
    CGPoint previousPoint;
    CGPoint previousPreviousPoint;
    CGMutablePathRef tempPath;
    //CGContextRef context;
    UIImage *image;
    BOOL changeColor;
 }


@property int lineWidth;
@property (nonatomic,retain) UIColor  *currentColor;
@property float  lineAlpha;

-(void)changedColor;


@end
