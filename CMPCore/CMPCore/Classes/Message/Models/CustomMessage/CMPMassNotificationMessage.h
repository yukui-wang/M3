//
//  CMPMassNotificationMessage.h
//  M3
//
//  Created by 程昆 on 2019/1/14.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPMassNotificationMessage : RCMessageContent

/**业务消息类型**/
@property (nonatomic, copy) NSString *type;

/** 小广播id **/
@property (nonatomic, copy) NSString *broadcastId;

/*! 消息内容 */
@property(nonatomic, copy) NSString *content;

/** 发送人id **/
@property (nonatomic, copy) NSString *sendMemberId;

/** 发送人姓名 **/
@property (nonatomic, copy) NSString *sendMemberName;

/** 发送时间 **/
@property (nonatomic, copy) NSString *sendTime;

/**
 * 小广播的类型
 * 0:有新广播通知 (发送给接收人)
 * 1:已读确认通知 (例如pc端查看了,会给其他端发送已读确认信息,告诉他们可以把红点清除了)
 * 2:撤销广播通知 (当发送者撤销了广播,会给q接收人发送一条撤销消息)
 */
@property (nonatomic, copy) NSString *broadcastType;

@end

NS_ASSUME_NONNULL_END
