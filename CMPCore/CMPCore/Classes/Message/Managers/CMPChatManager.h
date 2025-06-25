//
//  CMPChatManager.h
//  CMPCore
//
//  Created by wujiansheng on 2016/12/12.
//
//

#import <Foundation/Foundation.h>
#import "CMPRCBlockObject.h"

@class CMPRCGroupNotificationManager;
@class CMPRCUserCacheManager;
@class XMPSendAbstractMsg;

#define kRLMXMPUCReciveChatMessage         @"kRLMXMPUCReciveChatMessage"
#define kNotification2H5_UC_DidRecvieMess  @"com.seeyon.m3.uc.didReciveLatestMess"
#define kRLMXMPUCReciveIQ                  @"kRLMXMPUCReciveIQ"
#define kNotification_UC_Login_Success     @"kNotification_UC_Login_Success"
#define kChatDidConnected                  @"kChatDidConnected"


#define kXmppDidConnected @"kXmppDidConnected"
#define kXmppDidDisConnected @"kXmppDidDisConnected"
#define kXmppDidReceiveIQ @"kXmppDidReceiveIQ"
#define kXmppDidReceiveErrorIQ @"kXmppDidReceiveErrorIQ"
#define kXmppDidReceiveMessage @"kXmppDidReceiveMessage"
#define kXmppDidReceiveErrorMessage @"kXmppDidReceiveErrorMessage"

#define kXmppDidReceiveMessageToMsg @"kXmppDidReceiveMessageToMsg"

#define kChatManagerRCChatTypeGroup @"group"
#define kChatManagerRCChatTypePrivate @"private"
#define kRCGroupNotificationTargetID @"GroupSystemMessage"


typedef NS_ENUM(NSInteger, CMPChatType){
    CMPChatType_null, //没有致信
    CMPChatType_Xmpp, // 致信 xmpp
    CMPChatType_Rong // 融云
    
};


#import <RongIMKit/RongIMKit.h>
#import "CMPRCTargetObject.h"
#import <CMPLib/CMPOfflineContactMember.h>
@interface CMPChatManager : NSObject
{
}
@property(nonatomic,strong) NSString *ucFilePort;
@property(nonatomic,strong) NSString *ucServerStyle;
@property(nonatomic,assign) CMPChatType chatType;
@property(nonatomic,strong) CMPRCGroupNotificationManager *groupNotificationManager;
@property(nonatomic,strong) CMPRCUserCacheManager *userCacheManager;
@property(nonatomic,strong) NSString *currentGroupId;
@property(nonatomic,strong) NSDictionary *rongConfig;
@property(nonatomic,strong) NSString *groupUsers;
@property(nonatomic,assign,readonly)BOOL isShowlittleBroad;
//是否有音视频插件,音视频服务是否开通 默认no
@property(nonatomic,assign,readonly)BOOL isVideoEnable;
//音视频服饰是否可用 默认no
@property(nonatomic,assign,readonly)BOOL videoStatus;

@property(nonatomic,assign)BOOL fileUploadEnable;//是否可以上传附件与图片，默认YES，

@property(nonatomic,assign)BOOL isRemindVideoExpire;
@property(nonatomic,assign)NSInteger videoExpirationDays;
@property(nonatomic,copy)NSString *videoExpirationRemindMsg;

@property(nonatomic, copy, readonly)NSString *token;

+ (CMPChatManager*)sharedManager;

+(BOOL)canRemoveRemoteMsg;
- (void)begin;
- (void)logout;
- (void)reconnectWhenApplicationDidBecomeActive;
- (BOOL)sendMsg:(NSString *)msg;
- (NSArray *)getLocalMessage;
- (void)deleteMsgWithID:(NSString *)msgId;
- (NSString *)ip;
- (NSString *)port;
- (BOOL)checkAndReconnect;

#pragma mark 融云

//新建一个聊天会话
- (void)showChatView:(CMPRCTargetObject *)obj;
- (void)showChatView:(CMPRCTargetObject *)obj isShowShareTips:(BOOL)isShowShareTips;
- (void)showChatView:(CMPRCTargetObject *)obj isShowShareTips:(BOOL)isShowShareTips filePaths:(NSArray *)filePaths;

//删除对应的消息
- (BOOL)removeConversation:(NSInteger)conversationType targetId:(NSString *)targetId;
//对应的消息未读为0
- (BOOL)clearMessagesUnreadStatus:(NSInteger)conversationType targetId:(NSString *)targetId;
//所有的未读数
- (NSInteger)totalRongUnreadCount;
- (void)getRCMessageList:(void (^)(NSArray *))completion;
//是否使用融云
- (BOOL)useRongCloud;

//获取融云群设置
- (void)rcGroupChatSettingWithGroupId:(NSString *)groupId completion:(void (^)(NSDictionary *))completion;

//设置融云群置顶状态
- (void)setGroupChatTopStatus:(NSString *)topStatus groupId:(NSString *)groupId;
//设置融云群消息提醒状态
- (void)setGroupChatAlertStatus:(NSString *)topStatus groupId:(NSString *)groupId;


//获取融云聊天设置
- (void)rcChatSettingWithType:(NSString *)type targetId:(NSString *)targetId completion:(void (^)(NSDictionary *))completion;

//设置融云群置顶状态
- (void)setChatTopStatus:(NSString *)topStatus targetId:(NSString *)targetId type:(NSString *)type ext:(NSDictionary *)ext;
//设置融云群消息提醒状态
- (void)setChatAlertStatus:(NSString *)topStatus targetId:(NSString *)targetId type:(NSString *)type;
// 获取聊天消息是否屏蔽
- (BOOL)getChatAlertStatus:(NSString *)targetId;

//清空融云群消息
- (void)clearRCGroupMsgWithGroupId:(NSString *)groupId;

- (void)clearRCMsgWithTargetId:(NSString *)targetId type:(NSString *)type;

// 清空群系统消息
- (void)clearRCGroupNotification;
// 群系统消息全部设置为已读
- (void)readRCGroupNotification;
// 刷新群组人员信息（获取跨单位人员名字）
- (void)refreshGroupUserInfo:(NSString *)groupId;
// 发送多端未读消息同步消息
- (void)sendReadedMessageWithType:(RCConversationType)conversationType targetId:(NSString *)targetId;

- (void)openAccDoc:(NSString*)param;
- (void)requestAddGroup:(NSString*)groupId start:(void(^)(void))start success:(void(^)(id info))success fail:(void(^)(id error))fail;

/*!
 设置消息的附加信息
 
 @param messageId   消息ID
 @param value       附加信息
 @return            是否设置成功
 */
- (BOOL)setMessageExtra:(long)messageId value:(NSString *)value;
/*!
 同步获取一个RCGroup(为解决融云多线程获取RCGroup崩溃的问题)
 
 @return RCGroup
 */
- (RCGroup *)syncCreateRCGroupObject:(NSString *)groupId;
/*!
 发送已读群消息
 
 @return
 */
- (void)sendGroupNotificationReadedMessage;
/* 给memberId 发消息，内容：content*/
- (void)chatToMember:(CMPOfflineContactMember *)member content:(NSString *)content completion:(void (^)(NSError *))completion;

/**
  根据groupId获取群成员列表
 */
- (void)getGroupUserListByGroupId:(NSString *)groupId completion:(AllMembersOfGroupResultBlock)completion fail:(void(^)(NSError *error,id ext))failBlk;

/**
 设置某个人/群的消息免打扰,0:开启消息免打扰 1：关闭
*/
- (void)uploadRCMessageSettingRemindType:(NSString *)remindType targetId:(NSString *)targetId completion:(void (^)(BOOL isSeccess,NSError *error))completion;

/**
 转化融云推送消息为可穿透格式
 */
- (NSDictionary *)handleUserInfo:(NSDictionary *)userInfo;

/**
 获取是否显示主岗信息
 */
- (void)getPostShowStatusByTalkId:(NSString *)talkId
                       completion:(void (^)(BOOL isShow,NSError *error))completion;


/**
 获取人员状态（离职还是其他 2是离职,其他都是退群）
 */
- (void)getMemberOrgStatusByMid:(NSString *)mid
                     completion:(void (^)(id result,NSError *error))completion;


/**
 转发文件到会话
 */
-(void)forwardFile:(NSString *)fileId
              type:(int)type
            target:(NSString *)targetId
        completion:(void (^)(id result,NSError *error))completion;

/**
 从消息列表中删除多条记录
 */
-(void)deleteMessageObjects:(NSArray<CMPMessageObject *> *)objs;

@end



