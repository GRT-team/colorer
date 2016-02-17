//
//  ShareViewController.h
//  Colorer
//
//  Created by Kyznetsov Illya on 7/25/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@interface ShareViewController : UIViewController<UIDocumentInteractionControllerDelegate,GPPShareDelegate,GPPSignInDelegate>{
        UIDocumentInteractionController *docController;
    GPPSignIn *signIn;
}

@property (nonatomic,retain) UIImage *sharedImage;
@property (nonatomic,retain) NSString *imageName;
@end
