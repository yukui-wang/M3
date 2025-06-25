//
//  CMPCore_XiaozhiBridge.h
//  M3
//
//  Created by wujiansheng on 2019/4/3.
//

#import <Foundation/Foundation.h>


@interface CMPCore_XiaozhiBridge : NSObject
+ (void)openSpeechRobot;
+ (void)reloadSpeechRobot;
+ (void)updateSpeechRobotConfig:(NSDictionary *)params;
+ (NSDictionary *)obtainSpeechRobotConfig:(NSArray *)keys;
+ (NSDictionary *)obtainXiaozhiSettings;
+ (NSDictionary *)obtainSpeechInput:(UIViewController *)controller;


//语音播报（小致平台中H5卡片语音播报）
+ (void)broadcast:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail;
//语音播报文本
+ (void)broadcastText:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail;
//停止语音播报文本
+ (void)stopBroadcastText;
//清空语音合成block
+ (void)clearBroadcastTextBlock;

+ (void)updateMsgSwitchInfo:(NSDictionary *)params;
+ (void)showQAWithIntentId:(NSString *)intentId;
+ (void)showWebViewWithParam:(NSDictionary *)param;
+ (void)clearMediatorCache;


#pragma mark Speech Plugin  start
+ (void)showSpeechViewInView:(UIView *)view
                        Type:(NSInteger) type
                    endBlock:(void (^)(NSString *result, BOOL finish, UIView *speechView))endBlock
                 cancelBlock:(void(^)(void))cancelBlock;
+ (void)removeSpeechView;

#pragma mark Speech Plugin  end


#pragma mark Face Detection  start
+ (void)showFaceDetectionView:(NSString *)groupId
                        useId:(NSString *)useId
                           vc:(UIViewController *)viewController
                   handleType:(NSInteger)handleType
                       params:(NSDictionary *)faceParams
                   completion:(void(^)(NSDictionary *result,NSError *error))completion
                       cancel:(void(^)(void))cancelBlock;

+ (void)removeFace:(NSString *)groupId
             useId:(NSString *)useId
        completion:(void(^)(NSDictionary *result,NSError *error))completion;

+ (void)isRegisteredFace:(NSString *)groupId
                   useId:(NSString *)useId
              completion:(void(^)(NSDictionary *result,NSError *error))completion;
+ (BOOL)hasFacePermission;
+ (void)cleanFaceData;
#pragma mark Face Detection  end

#pragma mark 语音回复 start

+ (void)speechReplyWithFilePath:(NSString *)filePath
                  flushStrBlock:(void(^)(NSString *flushStr))flushStrBlock
                  completeBlock:(void(^)(NSString *filePath,NSString *resultStr))completeBlock
                     errorBlock:(void(^)(NSError *error))errorBlock ;
+ (void)stopSpeechReply;
+ (void)cancelSpeechReply;

#pragma mark 会议室申请 start

+ (void)setOptionValue:(NSDictionary *)params controller:(UIViewController *)controller;
+ (void)nextIntent:(NSDictionary *)params controller:(UIViewController *)controller;
+ (void)setOptionCommands:(NSDictionary *)params
               controller:(UIViewController *)controller
                    block:(void(^)(NSString *key,NSString *word))block;
+ (void)webviewChangeHeight:(NSString *)height controller:(UIViewController *)controller;
+ (void)passOperationText:(NSString *)text controller:(UIViewController *)controller;

#pragma mark 会议室申请 end
+ (void)openQAPage:(NSDictionary *)params;
+ (void)openXiaoz:(NSDictionary *)params;
+ (void)openAllSearchPage:(NSDictionary *)params;
#pragma mark 智能助手
+ (UIViewController *)showIntelligentPage;
+ (void)callXiaozMethod:(NSString *)method params:(NSDictionary *)params;

@end

