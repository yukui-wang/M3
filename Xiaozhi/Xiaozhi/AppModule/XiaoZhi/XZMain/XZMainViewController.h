//
//  XZMainViewController.h
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import <CMPLib/CMPBannerViewController.h>
#import <CMPLib/CMPOfflineContactMember.h>
#import "SPConstant.h"
#import "XZRecorderWave.h"
#import "XZCellModel.h"
#import "XZTextModel.h"
#import "XZPromptModel.h"
#import "XZLeaveModel.h"
#import "XZMemberModel.h"
#import "XZLeaveTypesModel.h"
#import "XZQAGuideInfo.h"
#import "XZWebViewModel.h"

@interface XZMainViewController : CMPBannerViewController

@property (nonatomic, assign) id<XZMainViewControllerDelegate> delegate;
@property (nonatomic, assign)SpeechRecognizeType recognizeType;//现在没有自动识别了，标记当前的状态。  弱化语音，引导用户使用键盘 和手动点击。
@property (nonatomic, retain) XZQAGuideInfo *guideInfo;

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
- (void)showSpeechLoadingView;
- (void)hideSpeechLoadingView;
//提示消息
- (void)addPromptMessage:(NSString *)string;
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
