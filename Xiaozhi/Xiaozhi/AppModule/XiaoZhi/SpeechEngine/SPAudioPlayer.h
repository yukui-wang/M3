//
//  SPAudioPlayer.h
//  CMPCore
//
//  Created by CRMO on 2017/2/24.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SPConstant.h"
#define START_AUDIO @"start.wav"
#define END_AUDIO   @"end.wav"

@interface SPAudioPlayer : NSObject

+ (instancetype)sharedInstance;
@property (nonatomic) BOOL canPlay;//静音状态下不能播放

- (void)playStartAudio;

- (void)playEndAudio;

- (void)stopPlayAudio;
@end
