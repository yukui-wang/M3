//
//  XZBottomBar.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/9.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#define kXZBottomBarHeight 94

#import "XZBaseView.h"
#import "XZRippleView.h"
#import "XZSpeechWave.h"

@interface XZBottomBar : XZBaseView

@property(nonatomic, strong)UIButton *keyboardButton;//底部键盘按钮
@property(nonatomic, strong)UIButton *helpButton;//底部语音按钮
@property(nonatomic, strong)UIImageView *speakBtnBk;
@property(nonatomic, strong)UIButton *speakButton;
@property(nonatomic, strong)UIButton *cancelButton;//波纹
@property(nonatomic, strong)XZSpeechWave *waveView;

//显示语音监听动画
- (void)showWaveView;
//关闭语音监听动画
- (void)hideWaveView;
- (void)waveVolumeChanged:(NSInteger)volume;
- (void)showButtonAnimation;

@end

