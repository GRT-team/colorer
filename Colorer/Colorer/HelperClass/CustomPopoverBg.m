//
//  CustopPopoverBg.m
//  Colorer
//
//  Created by illya on 9/4/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import "CustomPopoverBg.h"

@implementation CustomPopoverBg
@synthesize arrowOffset = _arrowOffset;
@synthesize arrowDirection = _arrowDirection;
+ (UIEdgeInsets)contentViewInsets
{
    return kPopoverEdgeInsets;
}

+ (CGFloat)arrowHeight
{
    return kPopoverArrowHeight;
}

+ (CGFloat)arrowBase
{
    return kPopoverArrowWidth;
}

- (CGFloat)halfArrowBase
{
    return [CustomPopoverBg arrowBase] / 2;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.layer.opacity = 0;
        
    }
    return self;
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOfset = arrowOffset;
    [self setNeedsLayout];
}


- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
}

+ (BOOL)wantsDefaultContentAppearance{
    return NO;
}





@end
