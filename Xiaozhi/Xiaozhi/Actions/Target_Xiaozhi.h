//
//  Target_Xiaozhi.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/2.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface Target_Xiaozhi : NSObject

- (void)Action_openSpeechRobot:(NSDictionary *)params;
- (void)Action_reloadSpeechRobot:(NSDictionary *)params;
- (void)Action_updateSpeechRobotConfig:(NSDictionary *)params;
- (NSDictionary *)Action_obtainSpeechRobotConfig:(NSDictionary *)params;
- (NSDictionary *)Action_obtainXiaozhiSettings:(NSDictionary *)params;
- (NSDictionary *)Action_obtainSpeechInput:(NSDictionary *)params;
//语音播报（小致平台中H5卡片语音播报）
- (void)Action_broadcast:(NSDictionary *)params;
//语音播报文本
- (void)Action_broadcastText:(NSDictionary *)params;
//停止语音播报文本
- (void)Action_stopBroadcastText:(NSDictionary *)params;
//清空语音合成block
- (void)Action_clearBroadcastTextBlock:(NSDictionary *)params;

- (void)Action_updateMsgSwitchInfo:(NSDictionary *)params;
- (void)Action_showQAWithIntentId:(NSDictionary *)params;
- (void)Action_showWebViewWithParam:(NSDictionary *)params;


@end

NS_ASSUME_NONNULL_END
