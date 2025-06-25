//
//  RemoteNotificationPlugin.h
//  CMPCore
//
//  Created by lin on 15/10/9.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface PushPlugin : CDVPlugin

/**
 设置消息开关状态

 @param command soundRemind、vibrationRemind、useReceive、startReceiveTime、endReceiveTime
 */
- (void)setPushConfig:(CDVInvokedUrlCommand*)command;

/**
 获取消息开关状态

 @param command soundRemind、vibrationRemind、useReceive、startReceiveTime、endReceiveTime
 */
- (void)getPushConfig:(CDVInvokedUrlCommand*)command;

@end
