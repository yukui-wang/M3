//
//  CMPOAMessage.h
//  CMPCore
//
//  Created by CRMO on 2017/9/8.
//
//

#import <RongIMKit/RongIMKit.h>

@interface CMPOAMessage : RCMessageContent

/**
 消息内容
 */
@property (nonatomic, strong) NSString *content;


/**
 额外信息
 */
@property (nonatomic, strong) NSString *extra;


/**
 消息类型：RC:MOaMsg
 */
@property (nonatomic, strong) NSString *type;

@end
