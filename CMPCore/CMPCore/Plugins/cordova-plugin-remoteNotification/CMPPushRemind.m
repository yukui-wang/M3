//
//  CMPPushRemind.m
//  CMPCore
//
//  Created by wujiansheng on 2016/11/7.
//
//

#import "CMPPushRemind.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CMPLib/CMPCore.h>

@interface CMPPushRemind () {
    float _soundDuration;
    NSTimer *_playbackTimer;

}

@end
//static CMPPushRemind *_sharedInstance;

@implementation CMPPushRemind
//声音提醒及震动提醒
+ (void)reminderAction
{
    //声音
    if ([CMPCore sharedInstance].pushSoundRemind){
        AudioServicesPlayAlertSound(1300);//声音提示 ios10 1007 不得行
    }
    //震动
    if ([CMPCore sharedInstance].pushVibrationRemind) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    //ps  AudioServicesPlaySystemSound  强制调用声音等  AudioServicesPlayAlertSound 根据系统设置

}
@end
