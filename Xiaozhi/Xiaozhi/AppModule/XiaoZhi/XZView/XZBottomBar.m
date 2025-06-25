//
//  XZBottomBar.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/9.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#define kSpeakButtomAnimationKey @"xiaozhispeakbutton"

#import "XZBottomBar.h"
#import "SPTools.h"

@implementation XZBottomBar

- (void)setup {
    [super setup];
    if (!self.keyboardButton) {
        self.keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.keyboardButton setImage:XZ_IMAGE(@"xz_keyboard_1.png") forState:UIControlStateNormal];
        [self addSubview:self.keyboardButton];
    }
    if (!self.helpButton) {
        self.helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.helpButton setImage:XZ_IMAGE(@"xz_guide_1.png") forState:UIControlStateNormal];
        [self addSubview:self.helpButton];
    }
    if (!_speakBtnBk) {
        _speakBtnBk = [[UIImageView alloc] initWithImage:XZ_IMAGE(@"xz_bar_speak_bk.png")];
        _speakBtnBk.frame = CGRectMake(0, 0, 70, 70);
        [self addSubview:_speakBtnBk];
    }
    
    if (!self.speakButton) {
        self.speakButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.speakButton setImage:XZ_IMAGE(@"xz_bar_speak.png") forState:UIControlStateNormal];
        [self addSubview:self.speakButton];
    }
    if (!self.cancelButton) {
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.hidden = YES;
        [self addSubview:self.cancelButton];
    }
    self.backgroundColor = [UIColor clearColor];
}

- (void)customLayoutSubviews {
    [super customLayoutSubviews];
    UIEdgeInsets  edgeInsets = [SPTools xzSafeAreaInsets];
    [_keyboardButton setFrame:CGRectMake(9+edgeInsets.left, self.height-35-10, 32, 35)];
    [_helpButton setFrame:CGRectMake(self.width-9-32-edgeInsets.right, self.height-35-10, 32, 35)];//2020
    [_speakButton setFrame:CGRectMake(self.width/2-33, 14, 66, 66)];
    if (_waveView) {
        _waveView.frame = CGRectMake(0, kXZBottomBarHeight/2-30, self.width, 60);
    }
    [_speakBtnBk setCenter:_speakButton.center];
}

//显示语音监听动画
- (void)showWaveView {
    if (!_waveView) {
        _waveView = [[XZSpeechWave alloc] initWithFrame:CGRectMake(0, kXZBottomBarHeight/2-30, self.width, 60)];
        [self addSubview:_waveView];
        [self bringSubviewToFront:_keyboardButton];
        [self bringSubviewToFront:_helpButton];
    }
    [self hideSpeakButton];
    [_waveView show];
}
//关闭语音监听动画
- (void)hideWaveView {
    [self showSpeakButton];
    [_waveView stop];
    [_waveView removeFromSuperview];
    _waveView = nil;
}

- (void)waveVolumeChanged:(NSInteger)volume {
    [_waveView showWaveWithVolume:volume];
}

- (void)hideSpeakButton {
    _speakButton.hidden = YES;
    _speakBtnBk.hidden = YES;
    [self stopButtonAnimation];
}

- (void)showSpeakButton {
    _speakButton.hidden = NO;
    _speakBtnBk.hidden = NO;
    [self showButtonAnimation];
}

- (void)showButtonAnimation {
    if ([_speakBtnBk.layer animationForKey:kSpeakButtomAnimationKey]) {
        return;
    }
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue = [NSNumber numberWithFloat: M_PI *2];
    animation.duration = 3.6;
    animation.autoreverses = NO;
    animation.removedOnCompletion = NO;//默认YES，会在退到后台停止动画
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    [_speakBtnBk.layer addAnimation:animation forKey:kSpeakButtomAnimationKey];
}

- (void)stopButtonAnimation {
    [_speakBtnBk.layer removeAnimationForKey:kSpeakButtomAnimationKey];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        [self stopButtonAnimation];
    }
}

@end
