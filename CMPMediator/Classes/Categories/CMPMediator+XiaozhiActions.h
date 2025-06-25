//
//  CMPMediator+XiaozhiActions.h
//  CMPMediator
//
//  Created by wujiansheng on 2019/4/3.
//  Copyright © 2019 crmo. All rights reserved.
//



#import <CMPMediator/CMPMediator.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^CMPMediatorSpeechViewFinishBlock)(NSString *result, BOOL finish, UIView *speechView);
typedef void(^CMPMediatorFaceDetectionsuccessBlock)(NSDictionary *result,NSError *error);
typedef void(^CMPMediatorXiaozhiCancelBlock)(void);

@interface CMPMediator (XiaozhiActions)

- (void)CMPMediator_openSpeechRobot;
- (void)CMPMediator_reloadSpeechRobot;
- (void)CMPMediator_updateSpeechRobotConfig:(NSDictionary *)params;
- (NSDictionary *)CMPMediator_obtainSpeechRobotConfig:(NSArray *)keys;
- (NSDictionary *)CMPMediator_obtainXiaozhiSettings;
- (NSDictionary *)CMPMediator_obtainSpeechInput:(UIViewController *)controller;
//语音播报（小致平台中H5卡片语音播报）
- (void)CMPMediator_broadcast:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail;
//语音播报文本
- (void)CMPMediator_broadcastText:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail;
//停止语音播报文本
- (void)CMPMediator_stopBroadcastText;
//清空语音合成block
- (void)CMPMediator_clearBroadcastTextBlock;
- (void)CMPMediator_updateMsgSwitchInfo:(NSDictionary *)params;
- (void)CMPMediator_showQAWithIntentId:(NSString *)intentId;
- (void)CMPMediator_showWebViewWithParam:(NSDictionary *)param;

- (void)CMPMediator_clearMediatorXZCache;


#pragma mark Speech Plugin  start
- (void)CMPMediator_showSpeechViewInView:(UIView *)view
                                    Type:(NSInteger)type
                                endBlock:(CMPMediatorSpeechViewFinishBlock)endBlock
                             cancelBlock:(CMPMediatorXiaozhiCancelBlock)cancelBlock;
- (void)CMPMediator_removeSpeechView;

#pragma mark Speech Plugin  end


#pragma mark Face Detection  start
- (void)CMPMediator_showFaceDetectionView:(NSString *)groupId
                                    useId:(NSString *)useId
                                       vc:(UIViewController *)viewController
                               handleType:(NSInteger)handleType
                                   params:(NSDictionary *)faceParams
                               completion:(CMPMediatorFaceDetectionsuccessBlock)completion
                                   cancel:(CMPMediatorXiaozhiCancelBlock)cancelBlock;

- (void)CMPMediator_removeFace:(NSString *)groupId
                         useId:(NSString *)useId
                    completion:(CMPMediatorFaceDetectionsuccessBlock)completion;

- (void)CMPMediator_isRegisteredFace:(NSString *)groupId
                               useId:(NSString *)useId
                          completion:(CMPMediatorFaceDetectionsuccessBlock)completion;

- (BOOL)CMPMediator_hasFacePermission;
- (void)CMPMediator_cleanFaceData;
#pragma mark Face Detection  end

#pragma mark 语音回复 start

- (void)CMPMediator_speechReplyWithFilePath:(NSString *)filePath
                              flushStrBlock:(void(^)(NSString *flushStr))flushStrBlock
                              completeBlock:(void(^)(NSString *filePath,NSString *resultStr))completeBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock;
- (void)CMPMediator_stopSpeechReply;
- (void)CMPMediator_cancelSpeechReply;

#pragma mark 语音回复 end

#pragma mark 会议室申请 start

- (void)CMPMediator_setOptionValue:(NSDictionary *)params controller:(UIViewController *)controller;
//可选项卡片：设置选中的选项对下一个意图
- (void)CMPMediator_nextIntent:(NSDictionary *)params controller:(UIViewController *)controller;
//可选项卡片：设置选择命令词
- (void)CMPMediator_setOptionCommands:(NSDictionary *)params
                           controller:(UIViewController *)controller
                                block:(void(^)(NSString *key,NSString *word))block ;

- (void)CMPMediator_webviewChangeHeight:(NSString *)height controller:(UIViewController *)controller;
- (void)CMPMediator_passOperationText:(NSString *)text controller:(UIViewController *)controller;
#pragma mark 会议室申请 end
- (void)CMPMediator_openQAPage:(NSDictionary *)params;
- (void)CMPMediator_openXiaoz:(NSDictionary *)params;
- (void)CMPMediator_openAllSearchPage:(NSDictionary *)params;
#pragma mark 智能助手
- (UIViewController *)CMPMediator_showIntelligentPage;
- (void)CMPMediator_callXiaozMethod:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
