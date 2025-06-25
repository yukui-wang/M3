//
//  SPAudioPlayer.m
//  CMPCore
//
//  Created by CRMO on 2017/2/24.
//
//

#import "SPAudioPlayer.h"

@interface SPAudioPlayer()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *startPlayer;
@property (nonatomic, strong) AVAudioPlayer *endPlayer;

@end

@implementation SPAudioPlayer

#pragma mark - Init

static SPAudioPlayer *shareInstance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [super allocWithZone:zone];
            }
        }
    }
    return shareInstance;
}

+ (instancetype)sharedInstance {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [[self alloc] init];
                shareInstance.canPlay = YES;
            }
        }
    }
    return shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return shareInstance;
}


- (void)playStartAudio {
    if (!self.canPlay) {
        return;
    }
    _startPlayer = nil;
    NSString *startPath = [[NSBundle mainBundle] pathForResource:XZ_NAME(START_AUDIO) ofType:nil];
    NSURL *startUrl = [NSURL fileURLWithPath:startPath];
    _startPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:startUrl error:nil];
    [_startPlayer setVolume:0.5];
    _startPlayer.delegate = self;
    [_startPlayer play];
}

- (void)playEndAudio {
    if (!self.canPlay) {
        return;
    }
    _endPlayer = nil;
    NSString *endPath = [[NSBundle mainBundle] pathForResource:XZ_NAME(END_AUDIO) ofType:nil];
    NSURL *endUrl = [NSURL fileURLWithPath:endPath];
    _endPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:endUrl error:nil];
    [_endPlayer setVolume:0.5];
    _endPlayer.delegate = self;
    [_endPlayer play];
}

- (void)stopPlayAudio {
    [_startPlayer stop];
    _startPlayer = nil;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    _startPlayer = nil;
    _endPlayer = nil;
}

@end
