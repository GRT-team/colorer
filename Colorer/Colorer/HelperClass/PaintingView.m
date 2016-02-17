//
//  DrawingView.m
//  Colorer
//
//  Created by illa on 7/10/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import "PaintingView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/glext.h>
#import <GLKit/GLKit.h>
#import "shaderUtil.h"
#import "fileUtil.h"
#import "debug.h"

#define kBrushOpacity		(1)
#define kBrushStep			2
#define kPencilStep		    3
#define kHardPencilStep		8
#define kMarkerStep			1



// Shaders
enum {
    PROGRAM_POINT,
    NUM_PROGRAMS
};

enum {
	UNIFORM_MVP,
    UNIFORM_POINT_SIZE,
    UNIFORM_VERTEX_COLOR,
    UNIFORM_TEXTURE,
	NUM_UNIFORMS
};

enum {
	ATTRIB_VERTEX,
	NUM_ATTRIBS
};

typedef struct {
	char *vert, *frag;
	GLint uniform[NUM_UNIFORMS];
	GLuint id;
} programInfo_t;

programInfo_t program[NUM_PROGRAMS] = {
    { "point.vsh",   "point.fsh" },     // PROGRAM_POINT
};


// Texture
typedef struct {
    GLuint id;
    GLsizei width, height;
} textureInfo_t;


@interface PaintingView()
{
	// The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext *context;
	
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    GLuint depthRenderbuffer;
	
	GLuint brushTexture;     // brush texture
    GLfloat brushColor[4];          // brush color
    
	Boolean	firstTouch;
	Boolean needsErase;
    
    // Shader objects
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint shaderProgram;
    
    // Buffer Objects
    GLuint vboId;
    
    BOOL initialized;
    BOOL erased;
    
    float brushOpacity;
    float redColor;
    float greenColor;
    float blueColor;
    float brushScale;
    
    float kBrushPixelStep;
    
    GLuint	stampTexture;
    size_t brushWidth;
    NSString *currentTextureName;
}

@end

@implementation PaintingView

@synthesize  location;
@synthesize  previousLocation;

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

// The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		eaglLayer.opaque = NO;
		// In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if (!context || ![EAGLContext setCurrentContext:context]) {
            
			return nil;
		}
		
		// Create a texture from an image
		// First create a UIImage object from the data in a image file, and then extract the Core Graphics image
        brushScale = 0.6;
        [self textureFromName:@"Pencil"];
        kBrushPixelStep = 3;
		// Texture dimensions must be a power of 2. If you write an application that allows users to supply an image,
		// you'll want to add code that checks the dimensions and takes appropriate action if they are not a power of 2.
		
		
		// Set the view's scale factor
		self.contentScaleFactor = 1.0;
        
		// Setup OpenGL states
		glMatrixMode(GL_PROJECTION);
		CGRect frame = self.bounds;
		CGFloat scale = self.contentScaleFactor;
		// Setup the view port in Pixels
		glOrthof(0, frame.size.width * scale, 0, frame.size.height * scale, -1, 1);
		glViewport(0, 0, frame.size.width * scale, frame.size.height * scale);
		glMatrixMode(GL_MODELVIEW);
		
		glDisable(GL_DITHER);
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		
	    glEnable(GL_BLEND);
		// Set a blending function appropriate for premultiplied alpha pixel data
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		
		glEnable(GL_POINT_SPRITE_OES);
		glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
        
    	
		// Make sure to start with a cleared buffer
		needsErase = YES;
		
	}
	
	return self;
}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews
{
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	
	// Clear the framebuffer the first time it is allocated
	if (needsErase) {
		[self erase];
		needsErase = NO;
	}
}

- (BOOL)createFramebuffer
{
	// Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	// For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

// Releases resources when they are not longer needed.
- (void) dealloc
{
	if (brushTexture)
	{
		glDeleteTextures(1, &brushTexture);
		brushTexture = 0;
	}
	
	if([EAGLContext currentContext] == context)
	{
		[EAGLContext setCurrentContext:nil];
	}
	
}

// Erases the screen
- (void) erase
{
	[EAGLContext setCurrentContext:context];
	
	// Clear the buffer
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
}

// Drawings a line onscreen based on where the user touches
- (void) renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
    _lineDrawn = YES;
	static GLfloat*		vertexBuffer = NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0,
    count,
    i;
	
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	// Convert locations from Points to Pixels
	CGFloat scale = self.contentScaleFactor;
	start.x *= scale;
	start.y *= scale;
	end.x *= scale;
	end.y *= scale;
	
	// Allocate vertex array buffer
	if(vertexBuffer == NULL)
		vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
	
	// Add points to the buffer so there are drawing points every X pixels
	count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
	for(i = 0; i < count; ++i) {
		if(vertexCount == vertexMax) {
			vertexMax = 2 * vertexMax;
			vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
		}
		
		vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
		vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
		vertexCount += 1;
	}
    
	// Render the vertex array
	glVertexPointer(2, GL_FLOAT, 0, vertexBuffer);
	glDrawArrays(GL_POINTS, 0, vertexCount);
	
	// Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGRect				bounds = [self bounds];
    UITouch*	touch = [[event touchesForView:self] anyObject];
	firstTouch = YES;
	// Convert touch point from UIView referential to OpenGL one (upside-down flip)
	location = [touch locationInView:self];
	location.y = bounds.size.height - location.y;
    if (_paletteShown) {
        [self.delegate hidePalette];
        _paletteShown = NO;
    }
    if (_optionsShown) {
        [self.delegate hideOptions];
    }
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
	CGRect				bounds = [self bounds];
	UITouch*			touch = [[event touchesForView:self] anyObject];
    
	// Convert touch point from UIView referential to OpenGL one (upside-down flip)
	if (firstTouch) {
		firstTouch = NO;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
	} else {
		location = [touch locationInView:self];
	    location.y = bounds.size.height - location.y;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
	}
    [[SoundManager shared] playBrush];
	// Render the stroke
	[self renderLineFromPoint:previousLocation toPoint:location];
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGRect				bounds = [self bounds];
    UITouch*	touch = [[event touchesForView:self] anyObject];
	if (firstTouch) {
		firstTouch = NO;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
		[self renderLineFromPoint:previousLocation toPoint:location];
	}
       [[SoundManager shared] stopPlayBrush];
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	// If appropriate, add code necessary to save the state of the application.
	// This application is not saving state.
}

- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue opacity:(CGFloat)opacity
{
    float colorAlphaRatio = 2;
    
    if (kBrushPixelStep == kMarkerStep|| kBrushPixelStep == kHardPencilStep) {
        colorAlphaRatio = 1;
    }
    
    glColor4f(red	* opacity/colorAlphaRatio,
			  green * opacity/colorAlphaRatio,
			  blue	* opacity/colorAlphaRatio,
			  opacity/colorAlphaRatio);
    
    redColor = red;
	blueColor = blue;
	greenColor = green;
    brushOpacity = opacity;
}

-(void)changeWidth:(float)width{
    brushScale = width;
    glPointSize(brushWidth*width);
    
}

-(void)eraseMode{
         erased = YES;
        [self textureFromName:@"Pencil"];
        glBlendFunc( GL_ZERO, GL_ONE_MINUS_SRC_COLOR);
        glBlendFunc( GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);
}

-(void)eraseModeOff{
        erased = NO;
        [self textureFromName:currentTextureName];
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);   
}
// Erases the screen

-(IBAction)selectTool:(id)sender{
    UIButton *tool = (UIButton*)sender;
    NSString *cId = tool.restorationIdentifier;
    switch (cId.intValue) {
        case pencil:
            [self textureFromName:@"Pencil"];
            kBrushPixelStep = kPencilStep;
            [self setBrushColorWithRed:redColor green:greenColor blue:blueColor opacity:brushOpacity];
            [self.delegate selectedTool:@"Pencil"];
            break;
        case brush:
            [self textureFromName:@"Brush"];
            kBrushPixelStep = kBrushStep;
            [self setBrushColorWithRed:redColor green:greenColor blue:blueColor opacity:brushOpacity];
            [self.delegate selectedTool:@"Brush"];
            break;
        case hardPencil:
            [self textureFromName:@"HardPencil"];
            kBrushPixelStep = kHardPencilStep;
            [self setBrushColorWithRed:redColor green:greenColor blue:blueColor opacity:brushOpacity];
            [self.delegate selectedTool:@"HardPencil"];
            break;
        case marker:
            [self textureFromName:@"Marker"];
            kBrushPixelStep = kMarkerStep;
            [self setBrushColorWithRed:redColor green:greenColor blue:blueColor opacity:brushOpacity];
            [self.delegate selectedTool:@"Marker"];
            break;
            
        default:
            break;
    }
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
}

// Create a texture from an image
- (void)textureFromName:(NSString *)name
{
    CGImageRef		brushImage;
	CGContextRef	brushContext;
	GLubyte			*brushData;
	size_t			 height;
    
    if (!erased) {
        currentTextureName = name;
    }
    
    // First create a UIImage object from the data in a image file, and then extract the Core Graphics image
    brushImage = [UIImage imageNamed:name].CGImage;
    
    // Get the width and height of the image
    brushWidth = CGImageGetWidth(brushImage);
    height = CGImageGetHeight(brushImage);
    
    // Make sure the image exists
    
    // Allocate  memory needed for the bitmap context
    brushData = (GLubyte *) calloc(brushWidth * height * 4, sizeof(GLubyte));
    // Use  the bitmatp creation function provided by the Core Graphics framework.
    brushContext = CGBitmapContextCreate(brushData, brushWidth, height, 8, brushWidth * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
    // After you create the context, you can draw the  image to the context.
    CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)brushWidth, (CGFloat)height), brushImage);
    // You don't need the context at this point, so you need to release it to avoid memory leaks.
    CGContextRelease(brushContext);
    // Use OpenGL ES to generate a name for the texture.
    glGenTextures(1, &brushTexture);
    // Bind the texture name.
    glBindTexture(GL_TEXTURE_2D, brushTexture);
    // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    // Specify a 2D texture image, providing the a pointer to the image data in memory
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)brushWidth, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
    // Release  the image data; it's no longer needed
    free(brushData);
    [self changeWidth:brushScale];
    
}

void ProviderReleaseData ( void *info, const void *data, size_t size ) {
    
	free((void*)data);
}

-(UIImage*) upsideDownImageRepresenation{
	
	int imageWidth = CGRectGetWidth([self bounds]);
	int imageHeight = CGRectGetHeight([self bounds]);
	
	//image buffer for export
	NSInteger myDataLength = imageWidth* imageHeight * 4;
	
	// allocate array and read pixels into it.
	GLubyte *tempImagebuffer = (GLubyte *) malloc(myDataLength);
    
    glReadPixels(0, 0, imageWidth, imageHeight, GL_RGBA, GL_UNSIGNED_BYTE, tempImagebuffer);
	
	// make data provider with data.
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, tempImagebuffer, myDataLength, ProviderReleaseData);
	
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * imageWidth;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
	
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
	// then make the uiimage from that
	
	UIImage *myImage =  [UIImage imageWithCGImage:imageRef] ;
	
	CGDataProviderRelease(provider);
	CGImageRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
    
    
    return myImage;
}



-(UIImage*) imageRepresentation{
	
	UIImageView* upsideDownImageView=[[UIImageView alloc] initWithImage: [self upsideDownImageRepresenation]];
    
	upsideDownImageView.transform=CGAffineTransformScale(upsideDownImageView.transform, 1, -1);
	
	UIView* container=[[UIView alloc] initWithFrame:upsideDownImageView.frame];
	[container addSubview:upsideDownImageView];
	UIImage* toReturn=nil;
    
	UIGraphicsBeginImageContext(container.frame.size);
	
	[container.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	toReturn = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return toReturn;
}



-(void) mergeWithImage:(UIImage*) image{
	if(image==nil){
		return;
	}
	
	glPushMatrix();
	glColor4f(256,
			  256,
			  256,
			  1.0);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glGenTextures(1, &stampTexture);
	glBindTexture(GL_TEXTURE_2D, stampTexture);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
	GLuint imgwidth = CGImageGetWidth(image.CGImage);
	GLuint imgheight = CGImageGetHeight(image.CGImage);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	void *imageData = malloc( imgheight * imgwidth * 4 );
	CGContextRef context2 = CGBitmapContextCreate( imageData, imgwidth, imgheight, 8, 4 * imgwidth, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
	CGContextTranslateCTM (context2, 0, imgheight);
	CGContextScaleCTM (context2, 1.0, -1.0);
	CGColorSpaceRelease( colorSpace );
	CGContextClearRect( context2, CGRectMake( 0, 0, imgwidth, imgheight ) );
	CGContextTranslateCTM( context2, 0, imgheight - imgheight );
	CGContextDrawImage( context2, CGRectMake( 0, 0, imgwidth, imgheight ), image.CGImage );
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imgwidth, imgheight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	
	CGContextRelease(context2);
    
	free(imageData);
	
	static const GLfloat texCoords[] = {
		0.0, 1.0,
		1.0, 1.0,
		0.0, 0.0,
		1.0, 0.0
	};
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    static const GLfloat vertices[] = {
		0.0,  607, 0.0,
		1024,  607, 0.0,
		0.0, 607-1024, 0.0,
		1024, 607-1024, 0.0
	};
    
	static const GLfloat normals[] = {
		0.0, 0.0, 1024,
		0.0, 0.0, 1024,
		0.0, 0.0, 1024,
		0.0, 0.0, 1024
	};
    
	glBindTexture(GL_TEXTURE_2D, stampTexture);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glNormalPointer(GL_FLOAT, 0, normals);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glPopMatrix();
    
	glDeleteTextures( 1, &stampTexture );
	//set back the brush
	glBindTexture(GL_TEXTURE_2D, brushTexture);
    
	glColor4f(redColor,
			  greenColor,
			  blueColor,
			  brushOpacity);
	
	// Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
}

-(void) setImage:(UIImage*)newImage{
    
    UIView* imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,1024, 1024)];
	UIImageView* subView   = [[UIImageView alloc] initWithImage:newImage];
    
    [imageView addSubview:subView];
	UIImage* blendedImage =nil;
	UIGraphicsBeginImageContext(imageView.frame.size);
	
	[imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	blendedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	[self mergeWithImage: blendedImage ];
   }




@end
