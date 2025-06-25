//
//  RCMessageModel+type.h
//  CMPCore
//
//  Created by CRMO on 2017/8/1.
//
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
#import "CMPQuoteMessage.h"

@interface RCMessageModel(Type)

/**
 判断是否是图片类型消息
 */
- (BOOL)isImageMessage;

/**
 判断是否是文件类型消息
 */
- (BOOL)isFileMessage;

- (BOOL)isVideoMessage;
/**
 判断是否是转发的系统类型消息
 */
- (BOOL)isRCForwardMessage;

/**
 判断是否是文字转任务类型消息
 */
- (BOOL)isRCConvertMissionMessage;

/**
 判断是否是窗口抖动类型消息
 */
- (BOOL)isRCShakeWinMessage;
/**
 判断是否是催办类型消息
 */
- (BOOL)isRCUrgeMessage;

/**
 判断是否是引用类型消息
 */
-(BOOL)isQuoteMessage;

///判断是否机器人消息
- (BOOL)isRobotMessage;
- (BOOL)isRobotAtMessage;

@end
