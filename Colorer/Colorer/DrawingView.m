//
//  DrawingView.m
//  Colorer
//
//  Created by illa on 7/10/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import "DrawingView.h"

@implementation DrawingView


- (void)commonInit
{
    tempPath = CGPathCreateMutable();
    changeColor = NO;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (void)drawRect:(CGRect)rect{
    
     [image drawInRect:self.bounds];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextAddPath(context, tempPath);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, _currentColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetAlpha(context, self.lineAlpha);
    CGContextStrokePath(context);

}

- (void)updateCacheImage:(BOOL)redraw
{
    // init a context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    

        // set the draw point
        [image drawAtPoint:CGPointZero];
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextAddPath(context, tempPath);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextSetStrokeColorWithColor(context, _currentColor.CGColor);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextSetAlpha(context, _lineAlpha);
        CGContextStrokePath(context);
    // store the image
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)finishDrawing
{
    // update the image
    [self updateCacheImage:NO];

}
 


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // add the first touch
    UITouch *touch = [touches anyObject];
    previousPoint = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // save all the touches in the path
    UITouch *touch = [touches anyObject];
    
    previousPreviousPoint = previousPoint;
    previousPoint = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
    CGRect bounds = [self addPathPreviousPreviousPoint:previousPreviousPoint withPreviousPoint:previousPoint withCurrentPoint:currentPoint];
    
        CGRect drawBox = bounds;
        drawBox.origin.x -= self.lineWidth * 2.0;
        drawBox.origin.y -= self.lineWidth * 2.0;
        drawBox.size.width += self.lineWidth * 4.0;
        drawBox.size.height += self.lineWidth * 4.0;
        
        [self setNeedsDisplayInRect:drawBox];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // make sure a point is recorded
    [self touchesMoved:touches withEvent:event];
   
        [self finishDrawing];
   
}

- (CGRect)addPathPreviousPreviousPoint:(CGPoint)p2Point withPreviousPoint:(CGPoint)p1Point withCurrentPoint:(CGPoint)cpoint {
    
    CGPoint mid1 = midPoint(p1Point, p2Point);
    CGPoint mid2 = midPoint(cpoint, p1Point);
    CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL, p1Point.x, p1Point.y, mid2.x, mid2.y);
    CGRect bounds = CGPathGetBoundingBox(subpath);
    
    CGPathAddPath(tempPath, NULL, subpath);
    CGPathRelease(subpath);
    
    return bounds;
}

-(void)changedColor{
    changeColor = YES;
    [self setNeedsDisplay];
    CGPathRelease(tempPath);
    tempPath = CGPathCreateMutable();
}

@end
