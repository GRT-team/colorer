//
//  DrawingView.h
//  Colorer
//
//  Created by illa on 7/10/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//


#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@protocol PaintingViewDelegate <NSObject>

-(void)hidePalette;
-(void)hideOptions;
-(void)selectedTool:(NSString*)name;

@end
//CLASS INTERFACES:
typedef enum {
    
    pencil=10,
    brush,
    hardPencil,
    marker,
} tools;

@interface PaintingView : UIView

@property (assign, nonatomic) id<PaintingViewDelegate> delegate;
@property(nonatomic, readwrite) CGPoint location;
@property(nonatomic, readwrite) CGPoint previousLocation;
@property BOOL paletteShown;
@property BOOL optionsShown;
@property BOOL lineDrawn;

- (void)erase;
- (void)changeWidth:(float)width;
- (void)eraseMode;
- (void)eraseModeOff;
- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue opacity:(CGFloat)opacity;
-(UIImage*) imageRepresentation;
-(void) setImage:(UIImage*)newImage;
    
@end

