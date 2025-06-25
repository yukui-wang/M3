//
//  CMPRCGroupNotificationObject.h
//  CMPCore
//
//  Created by CRMO on 2017/8/3.
//
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
#import <CMPLib/CMPObject.h>

#pragma mark - 群通知操作名

/** 有成员加入群组的通知 **/
extern NSString *const CMPRCGroupNotificationOperationAdd;
/** 创建群组的通知 **/
extern NSString *const CMPRCGroupNotificationOperationCreate;
/** 解散群组的通知 **/
extern NSString *const CMPRCGroupNotificationOperationDismiss;
/** 有成员退出群组的通知 **/
extern NSString *const CMPRCGroupNotificationOperationQuit;
/** 有成员被踢出群组的通知 **/
extern NSString *const CMPRCGroupNotificationOperationKicked;
/** 群组名称发生变更的通知 **/
extern NSString *const CMPRCGroupNotificationOperationRename;
/** 群组公告发生变更的通知 **/
extern NSString *const CMPRCGroupNotificationOperationBulletin;
/** 群主转移通知 **/
extern NSString *const CMPRCGroupNotificationOperationReplacement;
/** 被设置为群管理员通知 **/
extern NSString *const CMPRCGroupNotificationOperationSetAdmin;
/** 被取消群管理员通知 **/
extern NSString *const CMPRCGroupNotificationOperationUnSetAdmin;

#pragma mark - 群通知通知名
/** 群人员变动通知 **/
extern NSString *const CMPRCGroupNotificationNameMembersChanged;

@interface CMPRCGroupNotificationObject : CMPObject

/** ServerId **/
@property (nonatomic, copy) NSString *sId;
/** UserId **/
@property (nonatomic, copy) NSString *mId;
/** 群聊的TargetId **/
@property (nonatomic, copy) NSString *targetId;
/** 消息Id **/
@property (nonatomic, copy) NSString *msgId;
/** 接收时间 **/
@property (nonatomic, copy) NSString *receiveTime;
/** 消息内容 **/
@property (nonatomic, copy) NSString *content;
/** 头像Url **/
@property (nonatomic, copy) NSString *iconUrl;
/** 操作人Id **/
@property (nonatomic, copy) NSString *operatorUserId;
/** 原始数据，JSON格式 **/
@property (nonatomic, copy) NSString *data;
/** 操作类型，参照RCGroupNotificationMessage中定义 **/
@property (nonatomic, copy) NSString *operation;

@property (nonatomic, copy) NSString *extra1;
@property (nonatomic, copy) NSString *extra2;
@property (nonatomic, copy) NSString *extra3;
@property (nonatomic, copy) NSString *extra4;
@property (nonatomic, copy) NSString *extra5;
@property (nonatomic, copy) NSString *extra6;
@property (nonatomic, copy) NSString *extra7;
@property (nonatomic, copy) NSString *extra8;
@property (nonatomic, copy) NSString *extra9;
@property (nonatomic, copy) NSString *extra10;
@property (nonatomic, copy) NSString *extra11;
@property (nonatomic, copy) NSString *extra12;
@property (nonatomic, copy) NSString *extra13;
@property (nonatomic, copy) NSString *extra14;
@property (nonatomic, copy) NSString *extra15;

- (id)initWithRCConversation:(RCConversation *)conversation;
- (id)initWithRCMessage:(RCMessage *)message;
- (void)handleForSql;

@end
