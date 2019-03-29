//
//  Music.m
//  OpenFire_OC
//
//  Created by guxiangyun on 2019/3/28.
//  Copyright © 2019 chenran. All rights reserved.
//

#import "Music.h"
#import <AVFoundation/AVFoundation.h>

@interface Music ()
/** bgm player */
@property (nonatomic, strong) AVAudioPlayer *bgmPlayer;
/** bulletShoot */
@property (nonatomic, strong) AVAudioPlayer *bulletShoot;
/** explodedSound */
@property (nonatomic, strong) AVAudioPlayer *explodedSound;

@end

@implementation Music


+ (Music *)shareInstance {
    static Music *music = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        music = [[Music alloc] init];
    });
    return music;
}
- (void)playBGM {
    self.bgmPlayer.numberOfLoops = (int)INT_MAX;
    [self.bgmPlayer play];
    self.bgmPlayer.volume = 0.2;
}
- (void)bulletShootSound {
    [self.bulletShoot play];
}
- (void)bomb {
    [self.explodedSound play];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bgmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self urlWithMP3Path:@"bgm"] error:nil];
        self.bulletShoot =  [[AVAudioPlayer alloc] initWithContentsOfURL:[self urlWithMP3Path:@"direction"] error:nil];
        self.explodedSound =[[AVAudioPlayer alloc] initWithContentsOfURL:[self urlWithMP3Path:@"bomb"] error:nil];
    }
    return self;
}

- (NSURL *)urlWithMP3Path:(NSString *)path {
    NSString *mp3Path = [NSBundle.mainBundle pathForResource:path ofType:@"mp3"];
    NSURL *pathUrl = [NSURL fileURLWithPath:mp3Path];
    return pathUrl;
}


@end
