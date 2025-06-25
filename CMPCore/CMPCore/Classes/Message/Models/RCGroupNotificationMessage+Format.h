//
//  RCGroupNotificationMessage+Format.h
//  CMPCore
//
//  Created by CRMO on 2017/8/4.
//
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

@interface RCGroupNotificationMessage(Format)

/**
 将融云的通知类消息解析为群系统消息格式
 */
- (NSString *)groupNotification;


/**
 将融云的通知类消息解析为聊天详情界面提示格式
 */
- (NSString *)messageList;

/**
 群主转移提示语
 */
- (NSString *)replacementMessage;

@end
