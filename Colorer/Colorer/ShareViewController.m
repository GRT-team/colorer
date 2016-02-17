//
//  ShareViewController.m
//  Colorer
//
//  Created by Kyznetsov Illya on 7/25/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import "ShareViewController.h"
#import <Social/Social.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "GAI.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    signIn = [GPPSignIn sharedInstance];
    signIn.scopes = [NSArray arrayWithObjects:
                     kGTLAuthScopePlusLogin,
                     nil];
    signIn.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma SHARING
////FB/////
-(IBAction)facebook{
         
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText:[self sharedText]];
        
        [mySLComposerSheet addImage:_sharedImage];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                     [self sendGA];
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    
}

///////////////

///INSTAGRAM////

-(IBAction)instagram{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"ShareImage.igo"];
        
        NSData *imageData = UIImagePNGRepresentation(_sharedImage);
		[imageData writeToFile:savedImagePath atomically:YES];
		
        NSURL *imageUrl = [NSURL fileURLWithPath:savedImagePath];
        docController = [[UIDocumentInteractionController alloc] init];
        docController.delegate = self;
        docController.UTI = @"com.instagram.exclusivegram";
        [docController setURL:imageUrl];
        [docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
    else {
        NSString *message = @"The application cannot send a tweet at the moment. This is because it cannot reach Twitter or you don't have a Twitter account associated with this device.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        
    }
    
}
- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

-(BOOL)documentInteractionController:(UIDocumentInteractionController *)controller canPerformAction:(SEL)action{
    NSLog(@"%@",NSStringFromSelector(action));
      return YES;
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
    NSString* path = [NSHomeDirectory() stringByAppendingString:@"/Documents/ShareImage.igo"];
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath: path error: &error];

    NSLog(@"%@",application);
}
//////

////TWITTER////

-(IBAction)twitter{
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText:[self sharedText]];
        
        [mySLComposerSheet addImage:_sharedImage];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                     [self sendGA];
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    
}


//////

///GOOGLE+///

-(IBAction)google{
    [signIn authenticate];
    }

- (void)finishedSharing: (BOOL)shared {
    if (shared) {
        NSLog(@"User successfully shared!");
        [self sendGA];
    } else {
        NSLog(@"User didn't share.");
    }
}

- (void)finishedSharingWithError:(NSError *)error {
    NSString *text;
    
    if (!error) {
        text = @"Success";
    } else if (error.code == kGPPErrorShareboxCanceled) {
        text = @"Canceled";
    } else {
        text = [NSString stringWithFormat:@"Error (%@)", [error localizedDescription]];
    }
    
    NSLog(@"Status: %@", text);
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (!error) {
		id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
		[shareBuilder attachImage:_sharedImage];
		[shareBuilder setPrefillText:[self sharedText]];
		[shareBuilder open];

    }
}

-(void)sendGA{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"image_shared"     // Event category (required)
                                                          action:_imageName         // Event action (required)
                                                           label:nil          // Event label
                                                           value:nil] build]];    // Event value
}

-(NSString*)sharedText{
    NSArray *sharingTextList = [NSArray arrayWithContentsOfFile: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                                                                  @"SharingText.plist"]];
    NSString *shareText = [sharingTextList objectAtIndex:arc4random_uniform((int)[sharingTextList count])];
    return shareText;
}

@end
