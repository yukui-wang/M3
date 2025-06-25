//
//  CMPMediator+XiaozhiActions.m
//  CMPMediator
//
//  Created by wujiansheng on 2019/4/3.
//  Copyright © 2019 crmo. All rights reserved.
//


#import "CMPMediator+XiaozhiActions.h"

NSString * const kCMPMediatorTargetXiaozhi = @"Xiaozhi";
NSString * const kCMPMediatorTargetFaceDetection = @"FaceDetection";
NSString * const kCMPMediatorTargetSpeechView = @"SpeechView";
NSString * const kCMPMediatorTargetSpeechReply = @"SpeechReply";
NSString * const kCMPMediatorTargetXiaozhiIntent =@"XiaozhiIntent";

@implementation CMPMediator (XiaozhiActions)
- (void)CMPMediator_openSpeechRobot {
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"openSpeechRobot" params:nil shouldCacheTarget:NO];
}

- (void)CMPMediator_reloadSpeechRobot {
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"reloadSpeechRobot" params:nil shouldCacheTarget:NO];
}

- (void)CMPMediator_updateSpeechRobotConfig:(NSDictionary *)params {
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"updateSpeechRobotConfig" params:params shouldCacheTarget:NO];
}

- (NSDictionary *)CMPMediator_obtainSpeechRobotConfig:(NSArray *)keys {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:keys,@"keys", nil];
    return [self performTarget:kCMPMediatorTargetXiaozhi action:@"obtainSpeechRobotConfig" params:params shouldCacheTarget:NO];
}

- (NSDictionary *)CMPMediator_obtainXiaozhiSettings {
    return [self performTarget:kCMPMediatorTargetXiaozhi action:@"obtainXiaozhiSettings" params:nil shouldCacheTarget:NO];
}

- (NSDictionary *)CMPMediator_obtainSpeechInput:(UIViewController *)controller {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:controller,@"viewController", nil];
    return [self performTarget:kCMPMediatorTargetXiaozhi action:@"obtainSpeechInput" params:params shouldCacheTarget:NO];
}

//语音播报（小致平台中H5卡片语音播报）
- (void)CMPMediator_broadcast:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail {
    NSDictionary *params = @{@"text":text,
                             @"success":success,
                             @"fail":fail};
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"broadcast" params:params shouldCacheTarget:NO];
}
//语音播报文本
- (void)CMPMediator_broadcastText:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail {
    
    NSDictionary *params = @{@"text":text,
                             @"success":success,
                             @"fail":fail};
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"broadcastText" params:params shouldCacheTarget:NO];
}
//停止语音播报文本
- (void)CMPMediator_stopBroadcastText {
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"stopBroadcastText" params:nil shouldCacheTarget:NO];
}
//清空语音合成block
- (void)CMPMediator_clearBroadcastTextBlock {
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"clearBroadcastTextBlock" params:nil shouldCacheTarget:NO];
}


- (void)CMPMediator_updateMsgSwitchInfo:(NSDictionary *)params {
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"updateMsgSwitchInfo" params:params shouldCacheTarget:NO];
}

- (void)CMPMediator_showQAWithIntentId:(NSString *)intentId {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:intentId,@"intentId", nil];
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"showQAWithIntentId" params:params shouldCacheTarget:NO];
}

- (void)CMPMediator_showWebViewWithParam:(NSDictionary *)param {
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"showWebViewWithParam" params:param shouldCacheTarget:NO];
}

- (void)CMPMediator_clearMediatorXZCache {
    [self releaseCachedTargetWithTargetName:kCMPMediatorTargetXiaozhi];
}

#pragma mark Speech Plugin  start
- (void)CMPMediator_showSpeechViewInView:(UIView *)view
                                    Type:(NSInteger)type
                                endBlock:(CMPMediatorSpeechViewFinishBlock)endBlock
                             cancelBlock:(CMPMediatorXiaozhiCancelBlock)cancelBlock {
   
    CMPMediatorSpeechViewFinishBlock aFinishiBlock = ^(NSString *result, BOOL finish, UIView *speechView) {
        [self releaseCachedTargetWithTargetName:kCMPMediatorTargetXiaozhi];
        endBlock(result,finish,speechView);
    };
    CMPMediatorXiaozhiCancelBlock aCancelBlock = ^(void) {
        [self releaseCachedTargetWithTargetName:kCMPMediatorTargetXiaozhi];
        cancelBlock();
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:view forKey:@"view"];
    [params setObject:[NSNumber numberWithInteger:type] forKey:@"type"];
    [params setObject:aFinishiBlock forKey:@"endBlock"];
    [params setObject:aCancelBlock forKey:@"cancelBlock"];
    [self performTarget:kCMPMediatorTargetSpeechView action:@"showSpeechViewInView" params:params shouldCacheTarget:YES];
}

- (void)CMPMediator_removeSpeechView {
    [self performTarget:kCMPMediatorTargetSpeechView action:@"removeSpeechView" params:nil shouldCacheTarget:NO];
}
#pragma mark Speech Plugin  end

#pragma mark Face Detection  start
- (void)CMPMediator_showFaceDetectionView:(NSString *)groupId
                        useId:(NSString *)useId
                           vc:(UIViewController *)viewController
                   handleType:(NSInteger)handleType
                       params:(NSDictionary *)faceParams
                   completion:(CMPMediatorFaceDetectionsuccessBlock)completion
                       cancel:(CMPMediatorXiaozhiCancelBlock)cancelBlock {
    
    CMPMediatorFaceDetectionsuccessBlock asuccessBlock = ^(NSDictionary *result,NSError *error) {
        [self releaseCachedTargetWithTargetName:kCMPMediatorTargetFaceDetection];
        completion(result,error);
    };
    CMPMediatorXiaozhiCancelBlock aCancelBlock = ^(void)  {
        [self releaseCachedTargetWithTargetName:kCMPMediatorTargetFaceDetection];
        cancelBlock();
    };
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupId forKey:@"groupId"];
    [params setObject:useId forKey:@"useId"];
    [params setObject:viewController forKey:@"viewController"];
    [params setObject:[NSNumber numberWithInteger:handleType] forKey:@"handleType"];
    [params setObject:faceParams forKey:@"faceParams"];
    [params setObject:asuccessBlock forKey:@"completion"];
    [params setObject:aCancelBlock forKey:@"cancelBlock"];
    [self performTarget:kCMPMediatorTargetFaceDetection action:@"showFaceDetectionView" params:params shouldCacheTarget:YES];
}

- (void)CMPMediator_removeFace:(NSString *)groupId
             useId:(NSString *)useId
        completion:(CMPMediatorFaceDetectionsuccessBlock)completion {
    
    CMPMediatorFaceDetectionsuccessBlock asuccessBlock = ^(NSDictionary *result,NSError *error) {
        [self releaseCachedTargetWithTargetName:kCMPMediatorTargetFaceDetection];
        completion(result,error);
    };
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupId forKey:@"groupId"];
    [params setObject:useId forKey:@"useId"];
    [params setObject:asuccessBlock forKey:@"completion"];
    [self performTarget:kCMPMediatorTargetFaceDetection action:@"removeFace" params:params shouldCacheTarget:YES];
}

- (void)CMPMediator_isRegisteredFace:(NSString *)groupId
                   useId:(NSString *)useId
              completion:(CMPMediatorFaceDetectionsuccessBlock)completion {
    
    CMPMediatorFaceDetectionsuccessBlock asuccessBlock = ^(NSDictionary *result,NSError *error) {
        [self releaseCachedTargetWithTargetName:kCMPMediatorTargetFaceDetection];
        completion(result,error);
    };
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupId forKey:@"groupId"];
    [params setObject:useId forKey:@"useId"];
    [params setObject:asuccessBlock forKey:@"completion"];
    [self performTarget:kCMPMediatorTargetFaceDetection action:@"isRegisteredFace" params:params shouldCacheTarget:YES];
}

- (BOOL)CMPMediator_hasFacePermission {
    id result = [self performTarget:kCMPMediatorTargetFaceDetection action:@"hasFacePermission" params:nil shouldCacheTarget:NO];
    return [result boolValue];
}

- (void)CMPMediator_cleanFaceData {
    [self performTarget:kCMPMediatorTargetFaceDetection action:@"cleanFaceData" params:nil shouldCacheTarget:NO];
}

#pragma mark Face Detection  end

#pragma mark 语音回复 start

- (void)CMPMediator_speechReplyWithFilePath:(NSString *)filePath
                              flushStrBlock:(void(^)(NSString *flushStr))flushStrBlock
                              completeBlock:(void(^)(NSString *filePath,NSString *resultStr))completeBlock
                                 errorBlock:(void(^)(NSError *error))errorBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (filePath) {
        [params setObject:filePath forKey:@"path"];
    }
    if (flushStrBlock) {
        [params setObject:flushStrBlock forKey:@"flushStr"];
    }
    if (completeBlock) {
        [params setObject:completeBlock forKey:@"complete"];
    }
    if (errorBlock) {
        [params setObject:errorBlock forKey:@"error"];
    }
    [self performTarget:kCMPMediatorTargetSpeechReply action:@"obtainSpeechReply" params:params shouldCacheTarget:NO];
}

- (void)CMPMediator_stopSpeechReply {
    [self performTarget:kCMPMediatorTargetSpeechReply action:@"stopSpeechReply" params:nil shouldCacheTarget:NO];
}
- (void)CMPMediator_cancelSpeechReply {
    [self performTarget:kCMPMediatorTargetSpeechReply action:@"cancelSpeechReply" params:nil shouldCacheTarget:NO];
}

#pragma mark 语音回复 end

#pragma mark 会议室申请 start

- (void)CMPMediator_setOptionValue:(NSDictionary *)params controller:(UIViewController *)controller{
    NSMutableDictionary *params1 = [NSMutableDictionary dictionary];
    if (params) {
        [params1 setObject:params forKey:@"params"];
    }
    if (controller) {
        [params1 setObject:controller forKey:@"viewController"];
    }
    [self performTarget:kCMPMediatorTargetXiaozhiIntent action:@"setOptionValue" params:params1 shouldCacheTarget:NO];
}
//可选项卡片：设置选中的选项对下一个意图
- (void)CMPMediator_nextIntent:(NSDictionary *)params controller:(UIViewController *)controller {
    NSMutableDictionary *params1 = [NSMutableDictionary dictionary];
    if (params) {
        [params1 setObject:params forKey:@"params"];
    }
    if (controller) {
        [params1 setObject:controller forKey:@"viewController"];
    }
    [self performTarget:kCMPMediatorTargetXiaozhiIntent action:@"nextIntent" params:params1 shouldCacheTarget:NO];
}
//可选项卡片：设置选择命令词
- (void)CMPMediator_setOptionCommands:(NSDictionary *)params
                           controller:(UIViewController *)controller
                                block:(void(^)(NSString *key,NSString *word))block {
    NSMutableDictionary *params1 = [NSMutableDictionary dictionary];
    if (params) {
        [params1 setObject:params forKey:@"params"];
    }
    if (controller) {
        [params1 setObject:controller forKey:@"viewController"];
    }
    if (block) {
        [params1 setObject:block forKey:@"block"];
    }
    [self performTarget:kCMPMediatorTargetXiaozhiIntent action:@"setOptionCommands" params:params1 shouldCacheTarget:NO];
}

- (void)CMPMediator_webviewChangeHeight:(NSString *)height controller:(UIViewController *)controller {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (height) {
        [param setObject:height forKey:@"height"];
    }
    if (controller) {
        [param setObject:controller forKey:@"viewController"];
    }
    [self performTarget:kCMPMediatorTargetXiaozhiIntent action:@"webviewChangeHeight" params:param shouldCacheTarget:NO];
}
- (void)CMPMediator_passOperationText:(NSString *)text controller:(UIViewController *)controller {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (text) {
        [param setObject:text forKey:@"text"];
    }
    if (controller) {
        [param setObject:controller forKey:@"viewController"];
    }
    [self performTarget:kCMPMediatorTargetXiaozhiIntent action:@"passOperationText" params:param shouldCacheTarget:NO];
}
#pragma mark 会议室申请 end
- (void)CMPMediator_openQAPage:(NSDictionary *)params{
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"openQAPage" params:params shouldCacheTarget:NO];
}
- (void)CMPMediator_openXiaoz:(NSDictionary *)params {
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"openXiaoz" params:params shouldCacheTarget:NO];
}
- (void)CMPMediator_openAllSearchPage:(NSDictionary *)params {
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"openAllSearchPage" params:params shouldCacheTarget:NO];
}

#pragma mark 智能助手
- (UIViewController *)CMPMediator_showIntelligentPage {
  return [self performTarget:kCMPMediatorTargetXiaozhi action:@"showIntelligentPage" params:nil shouldCacheTarget:NO];
}

- (void)CMPMediator_callXiaozMethod:(NSDictionary *)params {
    [self performTarget:kCMPMediatorTargetXiaozhi action:@"callXiaozMethod" params:params shouldCacheTarget:NO];
}
@end
