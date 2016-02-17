//
//  soundManager.m
//  Colorer
//
//  Created by illa on 8/8/14.
//  Copyright (c) 2014 Illya Kyznetsov. All rights reserved.
//

#import "SoundManager.h"

@implementation SoundManager

// instance
static SoundManager* __instance;

// singleton
+ (SoundManager*) shared {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // init instance
        __instance = [[self alloc] init];
        
        // init sounds
        [__instance initSoundManager];
        
    });
    
    return __instance;
}

- (void) initSoundManager {
    
    // background music
    NSURL *musicURL = [[NSBundle mainBundle] URLForResource:@"bg"
                                              withExtension:@"mp3"];
    
    bgMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    bgMusic.volume = 0.5;
    
    // play infinitely
    bgMusic.numberOfLoops = -1;
    [bgMusic play];
    
}

- (void) playSound:(SoundFileID) soundId {
    NSString *fileName;
    
    switch (soundId) {
        case buttonHitSound:
            fileName = @"buttonHit";
            break;
            
        case boardHitSound:
            fileName = @"boardHit";
            break;
            
        case savedSound:
            fileName = @"save";
            break;
            
        case clearSound:
            fileName = @"clear";
            break;            
            
        default:
            break;
    }
    NSString *soundPath =[[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    
    NSError *error = nil;
    hitSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    [hitSound play];
}

- (void) soundForBrush:(SoundFileID) soundId{
    NSString *fileName;

    switch (soundId) {
        case drawSound:
            fileName = @"draw";
            break;
            
        case eraseSound:
            fileName = @"erase";
            break;
            
               default:
            break;
    }
    NSString *soundPath =[[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    
    NSError *error = nil;
    brushSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    
}

- (void) playBrush{
    [brushSound play];
}

- (void) stopPlayBrush{
    [brushSound stop];
}

@end
