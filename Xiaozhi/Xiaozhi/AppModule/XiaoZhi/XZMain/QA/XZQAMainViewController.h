//
//  XZQAMainViewController.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/9.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <CMPLib/CMPBannerViewController.h>
#import "XZWebViewModel.h"
#import "SPConstant.h"
#import "XZQABottomBar.h"

#define kXZQACommonTag_StartAsk 11
#define kXZQACommonTag_View30History 12

typedef void(^VoiceStateChangeBlock)(BOOL state);
typedef void(^ViewControllerShouldDismissBlock)(void);
typedef void(^CommonActBlock)(NSInteger act, id _Nullable obj);


NS_ASSUME_NONNULL_BEGIN

@interface XZQAMainViewController : CMPBannerViewController
@property (nonatomic, assign)SpeechRecognizeType recognizeType;//现在没有自动识别了，标记当前的状态。  弱化语音，引导用户使用键盘 和手动点击。

@property(nonatomic, copy)StartRecordingBlock startRecordingBlock;
@property(nonatomic, copy)StopRecordingBlock stopRecordingBlock;
@property(nonatomic, copy)InputContentBlock inputContentBlock;
@property(nonatomic, copy)VoiceStateChangeBlock voiceStateChangeBlock;
@property(nonatomic, copy)ViewControllerShouldDismissBlock shouldDismissBlock;
@property(nonatomic, copy)CommonActBlock commonActBlk;

@property(nonatomic, strong)NSArray *keywordArray;
@property(nonatomic, assign)BOOL formMsg;//来自消息界面


//+ (void)lockRotation:(BOOL)lock;
- (void)showCloseAlert:(void(^)(void))complete;
- (void)showWaveView;
- (void)showWaveViewAnalysis;
- (void)hideWaveView;
- (void)waveVolumeChanged:(NSInteger)volume;
- (void)showToast:(NSString*)toast;
//清空记录，并回到提示页面
- (void)clearMessage;
//机器人说话
- (void)robotSpeakWithText:(NSString *)text;
- (void)robotSpeakWithModels:(NSArray *)models;
- (void)robotSpeakWithWebModel:(XZWebViewModel *)model;
- (void)showCreateAppCardWithAppName:(NSString *)name infoList:(NSArray *)infoList;
- (void)hideCreateAppCard;
- (void)showCreateAppCardButtons:(NSArray *)buttons;
//人类说话
- (void)humenSpeakNothing;
- (void)humenSpeakText:(NSString *)text;
- (void)showOptionIntents:(NSArray *)array;
- (void)showModelsInHistory:(NSArray *)models;
- (void)hideSpeechLoadingView;
//multi 是否多选人员
- (void)recognizeMemberWithMulti:(BOOL)multi;
- (void)hideMemberView;
//还原界面
- (void)restoreView;
//用于选人是否可以下一步
- (void)memberNodeWillNextStep:(BOOL)will;
- (BOOL)isInSpeechView;
- (void)enbaleSpeakButton:(BOOL)enable;
- (void)showKeyboard;
- (void)hideKeyboard;
- (void)showChooseMemberViewController:(NSArray *)selectedMembers isMultiSelect:(BOOL)isMultiSelect;
@end

NS_ASSUME_NONNULL_END
