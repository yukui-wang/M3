//
//  CMPReminderMessage.h
//  M3
//
//  Created by zengbixing on 2018/1/15.
//

#import <RongIMKit/RongIMKit.h>

@interface CMPRCV5Message : RCTextMessage

/** 0-普通V5消息 1-关联文档消息 **/
@property (strong, nonatomic) NSString *messageType;
/** 消息类型 **/
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *appName;
/** 内容 **/
//@property (nonatomic, strong) NSString *content;
/** 发起人姓名 **/
@property (strong, nonatomic) NSString *senderName;
/** 发起时间 **/
@property (strong, nonatomic) NSString *sendDate;
/** 穿透参数 **/
@property (strong, nonatomic) NSString *gotoParam;
/** 扩展字段 **/
//@property (nonatomic, strong) NSString *extra;

@end
