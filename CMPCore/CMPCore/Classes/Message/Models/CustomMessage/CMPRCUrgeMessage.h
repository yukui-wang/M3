//
//  CMPRCUrgeMessage.h
//  M3
//
//  Created by 曾祥洁 on 2018/10/9.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPRCUrgeMessage : RCMessageContent
/*! 文本消息的内容 */
@property(nonatomic, copy) NSString *content;

/** 标题 **/
@property (nonatomic, copy) NSString *title;
/**业务消息类型**/
@property (nonatomic, copy) NSString *type;
/** 消息类型图标地址 **/
@property (nonatomic, copy) NSString *imgURL;
/** 业务消息发送人 **/
@property (nonatomic, copy) NSString *sendName;
/** 业务消息发送时间 **/
@property (nonatomic, copy) NSString *sendTime;
/** 移动消息穿透链接 **/
@property (nonatomic, copy) NSString *mobilePassURL;
/** PC穿透地址 **/
@property (nonatomic, copy) NSString *PCPassURL;
@property (nonatomic, copy) NSString *appId;
//0：只读   1：可穿透
@property (nonatomic, copy) NSString *actionType;

/*文本消息的附加信息 */
@property(nonatomic, copy) NSString *extra;


/*!
 初始化文本消息
 
 @param content 文本消息的内容
 @return        文本消息对象
 */
+ (instancetype)messageWithContent:(NSString *)content;

/*
 {
 title:”消息标题”,
 content:”业务消息展示内容”,
 type:”业务消息类型”,
 imgURL:”消息类型图标地址”,
 sendName:”业务消息发送人”,
 sendTime:”业务消息发送时间”,
 mobilePassURL:”移动消息穿透链接”,
 PCPassURL：“PC穿透地址”，
 extra:”扩展字段”
 }
 1、mobilePassURL格式：http://messge.m3.cmp/layout/handleRemoteNotification.html?params="{\"affairId\":\"419337353905062151\",\"messageCategory\":\"1\",\"messageType\":\"0\",\"linkParam0\":\"419337353905062151\",\"linkParam1\":\"3974055521912966751\",\"linkUrl\":\"/collaboration/collaboration.do?method=summary&openFrom=listPending&affairId={0}&contentAnchor={1}\",\"linkType\":\"message.link.col.pending\"}"
 
 2、PCPassURL格式：
 http://172.20.2.20/seeyon/uc/rest.do?method=pierce&enc=Tj4uNzkyOTg5NzY1NDk2NDE1Mjg5J00%2BbmZ0dGJoZi9tam9sL2RwbS94YmpUZm9lJ1U%2BMjY0MTY5NDkzNjk3Nw%3D%3D&P=-5885091646874170501&P=4192465969427466102&from=ucpc&uckey=775477e3-8844-40df-945e-c046e83f5f32_1530584058784
 
 
 */

@end

NS_ASSUME_NONNULL_END
