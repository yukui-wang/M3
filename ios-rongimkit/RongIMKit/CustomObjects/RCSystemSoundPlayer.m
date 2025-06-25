//
//  RCSystemSoundPlayer.m
//  RongIMKit
//
//  Created by xugang on 15/1/22.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCSystemSoundPlayer.h"
#import "RCIM.h"
#import "RCKitCommonDefine.h"
#import "RCVoicePlayer.h"
#import "RongExtensionKit.h"
#import <AVFoundation/AVFoundation.h>

#define kPlayDuration 0.9

static RCSystemSoundPlayer *rcSystemSoundPlayerHandler = nil;

@interface RCSystemSoundPlayer ()

@property (nonatomic, assign) SystemSoundID soundId;
@property (nonatomic, copy) NSString *soundFilePath;

@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, assign) RCConversationType conversationType;
@property (atomic) BOOL isPlaying;

@property (nonatomic, copy) RCSystemSoundPlayerCompletion completion;

@end

static void playSoundEnd(SystemSoundID mySSID, void *myself) {
    AudioServicesRemoveSystemSoundCompletion(mySSID);
    AudioServicesDisposeSystemSoundID(mySSID);

    //    CFRelease(myself);
    [RCSystemSoundPlayer defaultPlayer].isPlaying = NO;
}

@implementation RCSystemSoundPlayer

+ (RCSystemSoundPlayer *)defaultPlayer {

    @synchronized(self) {
        if (nil == rcSystemSoundPlayerHandler) {
            rcSystemSoundPlayerHandler = [[[self class] alloc] init];
            rcSystemSoundPlayerHandler.isPlaying = NO;
        }
    }

    return rcSystemSoundPlayerHandler;
}

- (void)setIgnoreConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId {
    self.conversationType = conversationType;
    self.targetId = targetId;
}
- (void)resetIgnoreConversation {
    self.targetId = nil;
}

- (void)setSystemSoundPath:(NSString *)path {
    if (nil == path) {
        return;
    }

    _soundFilePath = path;
}
- (void)playSoundByMessage:(RCMessage *)rcMessage completeBlock:(RCSystemSoundPlayerCompletion)completion {
    if (rcMessage.conversationType == self.conversationType && [rcMessage.targetId isEqualToString:self.targetId]) {
        completion(NO);
    } else {
        self.completion = completion;
        [self needPlaySoundByMessage:rcMessage];
    }
}
- (void)needPlaySoundByMessage:(RCMessage *)rcMessage {
    //add by chengkun
    //OA-213775 M3-iOS端：新消息通知设置无声音+无震动，有致信新消息进入时，正在播放的音乐声音会变小2s
    if ([RCIM sharedRCIM].pushVibrationRemind  == NO && [RCIM sharedRCIM].pushSoundRemind == NO) {
        [[AVAudioSession sharedInstance] setActive:NO
        withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
              error:nil];
        return;
    }
    //add by chengkun end
    
    if (RCSDKRunningMode_Background == [RCIMClient sharedRCIMClient].sdkRunningMode) {
        return;
    }
    //如果来信消息时正在播放或录制语音消息
    if ([RCVoicePlayer defaultPlayer].isPlaying || [RCVoiceRecorder defaultVoiceRecorder].isRecording ||
        [RCVoiceRecorder hqVoiceRecorder].isRecording) {
        self.completion(NO);
        return;
    }

    if (self.isPlaying) {
        self.completion(NO);
        return;
    }

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    NSError *err = nil;

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_7_0
    //是否扬声器播放
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
#else
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
#endif
    
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    [audioSession setActive:YES error:&err];

    if (nil != err) {
        DebugLog(@"[RongIMKit]: Exception is thrown when setting audio session");
        self.completion(NO);
        return;
    }
    if (nil == _soundFilePath) {
        // no redefined path, use the default
        _soundFilePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"RongCloud.bundle"]
            stringByAppendingPathComponent:@"sms-received.caf"];
    }

    if (nil != _soundFilePath) {
        OSStatus error =
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:_soundFilePath], &_soundId);
        if (error != kAudioServicesNoError) { //获取的声音的时候，出现错误
            DebugLog(@"[RongIMKit]: Exception is thrown when creating system sound ID");
            self.completion(NO);
            return;
        }

        // edit by zl 增加震动提醒、根据配置控制是否提醒
//        self.isPlaying = YES;
//        if (RC_IOS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
//            AudioServicesPlaySystemSoundWithCompletion(_soundId, ^{
//                self.isPlaying = NO;
//                self.completion(YES);
//                return;
//            });
//        } else {
//            AudioServicesPlaySystemSound(_soundId);
//            AudioServicesAddSystemSoundCompletion(_soundId, NULL, NULL, playSoundEnd, NULL);
//            self.completion(YES);
//            return;
//        }

       if ([RCIM sharedRCIM].pushSoundRemind) {
           self.isPlaying = YES;
       }
       if (RC_IOS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
           if ([RCIM sharedRCIM].pushVibrationRemind) {
               AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil);
           }
           if ([RCIM sharedRCIM].pushSoundRemind) {
               AudioServicesPlaySystemSoundWithCompletion(_soundId, ^{
                   self.isPlaying = NO;
               });
           }
       } else {
           if ([RCIM sharedRCIM].pushVibrationRemind) {
               AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
           }
           if ([RCIM sharedRCIM].pushSoundRemind) {
               AudioServicesAddSystemSoundCompletion (_soundId, NULL, NULL, playSoundEnd, NULL);
               AudioServicesPlaySystemSound(_soundId);
           }
       }
       // edit by zl 增加震动提醒、根据配置控制是否提醒 end
        
    } else {
        DebugLog(@"[RongIMKit]: Not found the related sound resource file in RongCloud.bundle");
        self.completion(NO);
        return;
    }
}

@end
