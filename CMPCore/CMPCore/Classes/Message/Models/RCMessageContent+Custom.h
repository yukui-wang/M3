//
//  RCMessageContent+Custom.h
//  CMPCore
//
//  Created by CRMO on 2017/9/14.
//
//

#import <RongIMKit/RongIMKit.h>

@interface RCMessageContent(Custom)


/**
 特殊类型的消息，移动端不使用，只在PC端使用需要屏蔽
 */
- (BOOL)isSpecialMessage;


/**
 是否要在聊天页面展示
 */
- (BOOL)isDisplayInChatView;

@end
