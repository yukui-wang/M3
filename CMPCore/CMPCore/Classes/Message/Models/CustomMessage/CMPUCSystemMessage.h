//
//  融云自定义消息类型
//  CMPUCSystemMessage.h
//  CMPCore
//
//  Created by CRMO on 2017/8/2.
//
//

#import <RongIMKit/RongIMKit.h>

@interface CMPUCSystemMessage : RCMessageContent


/**
 消息内容
 */
@property (nonatomic, strong) NSString *content;


/**
 额外信息
 */
@property (nonatomic, strong) NSDictionary *extra;


/**
 消息类型：RC:OaMsg
 */
@property (nonatomic, strong) NSString *type;

@end
