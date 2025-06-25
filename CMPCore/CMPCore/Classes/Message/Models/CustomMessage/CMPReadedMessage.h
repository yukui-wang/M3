//
//  CMPReadedMessage.h
//  CMPCore
//
//  Created by CRMO on 2017/8/31.
//
//

#import <RongIMKit/RongIMKit.h>

@interface CMPReadedMessage : RCMessageContent

/**
 消息内容
 */
@property (nonatomic, strong) NSString *extra;

@property (nonatomic, strong) NSDictionary *extraDic;

@property (nonatomic, assign) NSInteger conversationType;
/** 会话的TargetId **/
@property (nonatomic, strong) NSString *itemId;
/** 被阅读的最后一条消息的senttime **/
@property (nonatomic, assign) long long timestamp;

@end
