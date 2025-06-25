//
//  CMPCore_XiaozhiBridge.m
//  M3
//
//  Created by wujiansheng on 2019/4/3.
//

#import "CMPCore_XiaozhiBridge.h"
#import <CMPMediator/CMPMediator+XiaozhiActions.h>

@implementation CMPCore_XiaozhiBridge
+ (void)openSpeechRobot {
    [[CMPMediator sharedInstance] CMPMediator_openSpeechRobot];
}

+ (void)reloadSpeechRobot {
    [[CMPMediator sharedInstance] CMPMediator_reloadSpeechRobot];
}

+ (void)updateSpeechRobotConfig:(NSDictionary *)params {
    [[CMPMediator sharedInstance] CMPMediator_updateSpeechRobotConfig:params];
}

+ (NSDictionary *)obtainSpeechRobotConfig:(NSArray *)keys {
    NSDictionary *result = [[CMPMediator sharedInstance] CMPMediator_obtainSpeechRobotConfig:keys];
    return result;
}

+ (NSDictionary *)obtainXiaozhiSettings {
    NSDictionary *result = [[CMPMediator sharedInstance] CMPMediator_obtainXiaozhiSettings];
    return result;
}

+ (NSDictionary *)obtainSpeechInput:(UIViewController *)controller {
    NSDictionary *result = [[CMPMediator sharedInstance] CMPMediator_obtainSpeechInput:controller];
    return result;
}
//语音播报（小致平台中H5卡片语音播报）
+ (void)broadcast:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail {
    [[CMPMediator sharedInstance] CMPMediator_broadcast:text success:success fail:fail];
}
//语音播报文本
+ (void)broadcastText:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail {
     [[CMPMediator sharedInstance] CMPMediator_broadcastText:text success:success fail:fail];
}
//停止语音播报文本
+ (void)stopBroadcastText {
    [[CMPMediator sharedInstance] CMPMediator_stopBroadcastText];
}
//清空语音合成block
+ (void)clearBroadcastTextBlock {
    [[CMPMediator sharedInstance] CMPMediator_clearBroadcastTextBlock];
}

+ (void)updateMsgSwitchInfo:(NSDictionary *)params {
    [[CMPMediator sharedInstance] CMPMediator_updateMsgSwitchInfo:params];
}

+ (void)showQAWithIntentId:(NSString *)intentId {
    [[CMPMediator sharedInstance] CMPMediator_showQAWithIntentId:intentId];
}

+ (void)showWebViewWithParam:(NSDictionary *)param {
    [[CMPMediator sharedInstance] CMPMediator_showWebViewWithParam:param];
}

+ (void)clearMediatorCache {
    [[CMPMediator sharedInstance] CMPMediator_clearMediatorXZCache];
}


#pragma mark Speech Plugin  start
+ (void)showSpeechViewInView:(UIView *)view
                        Type:(NSInteger) type
                    endBlock:(void (^)(NSString *result, BOOL finish, UIView *speechView))endBlock
                 cancelBlock:(void(^)(void))cancelBlock {
    [[CMPMediator sharedInstance] CMPMediator_showSpeechViewInView:view Type:type endBlock:endBlock cancelBlock:cancelBlock];
}

+ (void)removeSpeechView {
    [[CMPMediator sharedInstance] CMPMediator_removeSpeechView];
}
#pragma mark Speech Plugin  end


#pragma mark Face Detection  start

+ (void)showFaceDetectionView:(NSString *)groupId
                        useId:(NSString *)useId
                           vc:(UIViewController *)viewController
                   handleType:(NSInteger)handleType
                       params:(NSDictionary *)faceParams
                   completion:(void(^)(NSDictionary *result,NSError *error))completion
                       cancel:(void(^)(void))cancelBlock {
    [[CMPMediator sharedInstance] CMPMediator_showFaceDetectionView:groupId
                                                              useId:useId
                                                                 vc:viewController
                                                         handleType:handleType
                                                             params:faceParams
                                                         completion:completion
                                                             cancel:cancelBlock];
}

+ (void)removeFace:(NSString *)groupId
             useId:(NSString *)useId
        completion:(void(^)(NSDictionary *result,NSError *error))completion {
    [[CMPMediator sharedInstance] CMPMediator_removeFace:groupId
                                                   useId:useId
                                              completion:completion];
}

+ (void)isRegisteredFace:(NSString *)groupId
                   useId:(NSString *)useId
              completion:(void(^)(NSDictionary *result,NSError *error))completion {
    [[CMPMediator sharedInstance] CMPMediator_isRegisteredFace:groupId
                                                         useId:useId
                                                    completion:completion];
}

+ (BOOL)hasFacePermission {
    return [[CMPMediator sharedInstance] CMPMediator_hasFacePermission];
}

+ (void)cleanFaceData {
    [[CMPMediator sharedInstance] CMPMediator_cleanFaceData];
}

#pragma mark Face Detection  end

#pragma mark 语音回复 start

+ (void)speechReplyWithFilePath:(NSString *)filePath
                  flushStrBlock:(void(^)(NSString *flushStr))flushStrBlock
                  completeBlock:(void(^)(NSString *filePath,NSString *resultStr))completeBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    [[CMPMediator sharedInstance] CMPMediator_speechReplyWithFilePath:filePath flushStrBlock:flushStrBlock completeBlock:completeBlock errorBlock:errorBlock];
}

+ (void)stopSpeechReply {
    [[CMPMediator sharedInstance] CMPMediator_stopSpeechReply];
}

+ (void)cancelSpeechReply {
    [[CMPMediator sharedInstance] CMPMediator_cancelSpeechReply];
}
#pragma mark 语音回复 end

#pragma mark 会议室申请 start

+ (void)setOptionValue:(NSDictionary *)params controller:(UIViewController *)controller{
    [[CMPMediator sharedInstance] CMPMediator_setOptionValue:params controller:controller];
}
//可选项卡片：设置选中的选项对下一个意图
+ (void)nextIntent:(NSDictionary *)params controller:(UIViewController *)controller {
    [[CMPMediator sharedInstance] CMPMediator_nextIntent:params controller:controller];
}
//可选项卡片：设置选择命令词
+ (void)setOptionCommands:(NSDictionary *)params
               controller:(UIViewController *)controller
                    block:(void(^)(NSString *key,NSString *word))block {
    [[CMPMediator sharedInstance] CMPMediator_setOptionCommands:params controller:controller block:block];
}

+ (void)webviewChangeHeight:(NSString *)height controller:(UIViewController *)controller {
    [[CMPMediator sharedInstance] CMPMediator_webviewChangeHeight:height controller:controller];
}

+ (void)passOperationText:(NSString *)text controller:(UIViewController *)controller {
    [[CMPMediator sharedInstance] CMPMediator_passOperationText:text controller:controller];
}

#pragma mark 会议室申请 end

+ (void)openQAPage:(NSDictionary *)params{
    [[CMPMediator sharedInstance] CMPMediator_openQAPage:params];
}
+ (void)openXiaoz:(NSDictionary *)params {
    [[CMPMediator sharedInstance] CMPMediator_openXiaoz:params];
}
+ (void)openAllSearchPage:(NSDictionary *)params {
    [[CMPMediator sharedInstance] CMPMediator_openAllSearchPage:params];
}
#pragma mark 智能助手
+ (UIViewController *)showIntelligentPage {
    return [[CMPMediator sharedInstance] CMPMediator_showIntelligentPage];
}

+ (void)callXiaozMethod:(NSString *)method params:(NSDictionary *)params{
    NSMutableDictionary *xzParams = [[NSMutableDictionary alloc] init];
    [xzParams setObject:method forKey:@"method"];
    if (params) {
        [xzParams setObject:params forKey:@"params"];
    }
    [[CMPMediator sharedInstance] CMPMediator_callXiaozMethod:xzParams];
}

@end
