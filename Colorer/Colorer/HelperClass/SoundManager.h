//
//  soundManager.h
//  Colorer
//
//  Created by illa on 8/8/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    
    buttonHitSound=0,
    boardHitSound,
    savedSound,
    clearSound,
    drawSound,
    eraseSound,
    } SoundFileID;

@interface SoundManager : NSObject
{
    AVAudioPlayer *bgMusic, *hitSound, *brushSound;
}

+ (SoundManager*) shared;

- (void) playSound:(SoundFileID) soundId;
- (void) soundForBrush:(SoundFileID) soundId;
- (void) playBrush;
- (void) stopPlayBrush;

@end
