//
//  CustopPopoverBg.h
//  Colorer
//
//  Created by illya on 9/4/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

/**
 Image-specific values for calulating the background's layout.
 */
static const CGFloat kPopoverArrowWidth         = 37.0; // Returned by +arrowBase, irrespective of orientation. The length of the base of the arrow's triangle.
static const CGFloat kPopoverArrowHeight        = 19.0; // Returned by +arrowHeight, irrespective of orientation. The height of the arrow from base to tip.
/**
 Content and background insets.
 */
static const UIEdgeInsets kPopoverEdgeInsets = { 8.0,  8.0,  8.0,  8.0}; // Distance between the edge of the background view and the edge of the content view.

#import <UIKit/UIKit.h>



@interface CustomPopoverBg : UIPopoverBackgroundView{
        UIPopoverArrowDirection _arrowDirection;
        CGFloat _arrowCenter;
}

@property (nonatomic, assign) CGFloat arrowOfset;
@property (nonatomic, assign) UIPopoverArrowDirection arrowDirection;

+ (CGFloat)arrowHeight;
+ (CGFloat)arrowBase;
+ (UIEdgeInsets)contentViewInsets;

@end
