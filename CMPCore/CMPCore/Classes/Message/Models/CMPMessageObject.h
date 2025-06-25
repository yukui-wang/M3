//
//  CMPMessageObject.h
//  CMPCore
//
//  Created by wujiansheng on 2017/6/27.
//
//

typedef NS_ENUM(NSInteger, CMPMessageType) {
    CMPMessageTypeApp = 0, // V5消息
    CMPMessageTypeRC = 1, // 融云
    CMPMessageTypeUC = 2, // 致信2.0
    CMPMessageTypeRCCustom = 3, // 融云自定义消息
    CMPMessageTypeRCGroupNotification = 4, // 融云群系统消息
    CMPMessageTypeAssociate = 5, // 关联账号消息
    CMPMessageTypeAggregationApp = 100, // 聚合应用消息
    CMPMessageTypeMassNotification  = 101, // 群发通知消息(小广播)
    CMPMessageTypeFileAssistant  = 102, // 文件助手
//    CMPMessageTypeMention = 101, // @我
//    CMPMessageTypeTrack = 102, // 跟踪
//    CMPmessageTypeLeadership = 103, // 领导
};

//融云会话类型
typedef NS_ENUM(NSInteger, CMPRCConversationType) {
    
    /*!
     单聊
     */
    CMPRCConversationType_PRIVATE = 1,
    /*!
     群组
     */
    CMPRCConversationType_GROUP = 3,
   
};

// 聚合消息
#define kMessageType_AppMessage @"AppMessage" // 应用消息
#define kMessageType_V5Message @"application" // V5消息
#define kMessageType_MentionMessage @"at_me" // @我
#define kMessageType_TrackMessage @"track" // 跟踪消息
#define kMessageType_LeadershipMessage @"leadership" // 领导消息
#define kMessageType_SmartMessage @"intelligent" // 智能消息
#define kMessageType_AssociateMessage @"associate" // 关联消息
#define kMessageType_MassNotificationMessage @"massNotification" // 小广播消息

#define kTopSort_Default 1
//#define kTopSort_AssociateMessage -9529638608
#define kTopSort_AssociateMessage LONG_MIN
#define kMsg_NoMessage @""  // @"msg_noMsg"
#define kMsg_NoAssMessage @"msg_noAssMsg"

#import <CMPLib/CMPObject.h>
#import <RongIMKit/RongIMKit.h>


@interface CMPPGroupTypeInfoModel : CMPObject

/* 是否已请求过 */
@property (nonatomic,assign)BOOL isMarked;
/** 群类型 **/
@property (nonatomic, assign ,readonly) NSInteger groupType;
/* 群组信息 */
@property (nonatomic,strong) NSDictionary *val;

@end


@class CMPPMessageObjectExtradDataModel,CMPRCGroupMemberObject;

@interface CMPMessageObject : CMPObject

@property(nonatomic,copy)NSString *cId;//  聊天--- targetId  业务-- appId xmpp固定为UC
@property(nonatomic,assign)NSInteger topSort;//置顶计数
@property(nonatomic,assign)CMPMessageType type;//业务 ---0  rong cloud --1  xmpp -- 2
@property(nonatomic,assign)NSInteger unreadCount;//未读数
@property(nonatomic,copy)NSString *timeStamp;//最新会话时间戳
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *appName;
@property(nonatomic,copy)NSString *iconUrl;
@property(nonatomic,copy)NSString *createTime;
@property(nonatomic,copy)NSString *senderName;
@property(nonatomic,copy)NSString *sId;//serverId
@property(nonatomic,copy)NSString *senderFaceUrl;
@property(nonatomic,copy)NSString *msgId;//消息ID   服务器id
@property(nonatomic,assign)BOOL isTop;//置顶
@property(nonatomic,assign)BOOL hasUnreadMentioned;//是否有未读@

@property(nonatomic,copy)NSString *latestMessage;//json string

@property(nonatomic,copy)NSString *receiveTime;
@property(nonatomic,assign)CMPRCConversationType subtype;// 融云会话类型

@property(nonatomic,copy)NSString *gotoParams;

@property (nonatomic, copy) NSString *extra1; // aggregationType 聚合到指定Type
@property (nonatomic, copy) NSString *extra2; // 消息是否提醒 0-不提醒 1-提醒
@property (nonatomic, copy) NSString *extra3; // 智能消息，已经弹出过的msgID
@property (nonatomic, copy) NSString *extra4; // 最后一条消息的发送状态  RCSentStatus 对应的类型 字符串
@property (nonatomic, copy) NSString *extra5;
@property (nonatomic, copy) NSString *extra6;
@property (nonatomic, copy) NSString *extra7;
@property (nonatomic, copy) NSString *extra8;
@property (nonatomic, copy) NSString *extra9;
@property (nonatomic, copy) NSString *extra10;
@property (nonatomic, copy) NSString *extra11;
@property (nonatomic, copy) NSString *extra12;
@property (nonatomic, copy) NSString *extra13;
@property (nonatomic, copy) NSString *extra14;//ks add -- 存储部门群flag，{'tag':'0未获取/1已获取','val':{'groupType':'DEPARTMENT'}}
@property (nonatomic, copy) NSString *extra15; //储存附加信息

@property(nonatomic, assign) NSInteger popType; // 弹出窗口类型，不入库，仅智能消息使用

//储存在extend15中
@property (strong, nonatomic ,readonly) CMPPMessageObjectExtradDataModel *extradDataModel;
//储存在extend14中
@property (strong, nonatomic ,readonly) CMPPGroupTypeInfoModel *groupTypeInfo;

//v5消息
- (id)initWithV5Message:(NSDictionary *)message localModuleConfig:(NSDictionary *)localModuleConfig;
//融云消息
- (id)initWithRCConversation:(RCConversation *)conversation;
- (id)initWithGroup:(RCGroup *)groupInfo istop:(BOOL)istop;
- (id)initWithUserInfo:(RCUserInfo *)targetId istop:(BOOL)istop;
// 初始化一条“暂无消息”
- (id)initNoMessageWithRCConversation:(RCConversation *)conversation;
- (void)handleForSql;
//初始化一条小广播消息
- (id)initMassNotificationMessageeWithMessage:(RCMessageContent *)message;
//初始化一条空小广播消息
- (id)initNoneMassNotificationMessage;
//初始化一条空文件助手消息
- (id)initFileAssistantMessageWithAppID:(NSString *)appID;

/**
 获取type对应的字符串ID
 本地type与服务器端的映射

 @param type 类型
 */
+ (NSString *)cIDWithMessageType:(CMPMessageType)type;
//+ (NSInteger)typeWithCID:(NSString *)cID;

//标记消息是否未读
- (void)markUnread:(BOOL)isMarkUnread;
//设置群组类型
- (void)setGroupInfo:(CMPRCGroupMemberObject *)groupInfo;
//该条消息是否免打扰
- (BOOL)isNoDisturb;
/**
 更新群组类型信息，部门群标识
 ks add -- 8.2 330
 */
-(void)updateGroupTypeInfo:(NSDictionary *)val;

@end

@interface CMPPMessageObjectExtradDataModel : CMPObject

/* 是否标记为未读 */
@property (nonatomic,assign)BOOL isMarkUnread;
/* 群组信息 */
@property (nonatomic,strong)CMPRCGroupMemberObject *groupInfo;

@end

