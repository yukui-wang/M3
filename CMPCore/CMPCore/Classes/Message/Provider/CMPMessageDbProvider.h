//
//  CMPMessageDbProvider.h
//  M3
//
//  Created by CRMO on 2018/1/4.
//

#import <CMPLib/CMPObject.h>
#import "CMPMessageObject.h"
#import <CMPLib/FMDB.h>

typedef void(^MessageListCompletion)(NSArray<CMPMessageObject *> * messages);
typedef void(^SaveMessagesCompletion)(BOOL isUpdate);
typedef void(^DeleteMessagesCompletion)(void);

@class CMPV5MessageSetting;

@interface CMPMessageDbFilterCondition : CMPObject

- (void)containKey:(NSString *)key values:(NSArray *)values;
- (void)exceptKey:(NSString *)key values:(NSArray *)values;
- (NSString *)conditionStr;

@end


@interface CMPMessageDbProvider : CMPObject

@property (nonatomic, strong) FMDatabaseQueue *dataQueue;

#pragma mark-
#pragma mark 消息列表

/**
 获取消息列表
 */
- (void)messageList:(MessageListCompletion)completion;
/**
 ks add 包含移除的
 */
-(void)allMessageList:(MessageListCompletion)completion;

/**
 获取聚合消息列表

 @param type 聚合消息的type
 */
- (void)messageListWithAggregationType:(CMPMessageType)type completion:(MessageListCompletion)completion;

/**
 获取聚合消息的所有APP ID

 @param completion APP ID数组
 */
- (void)appIDsOfAppMessage:(void(^)(NSArray *IDs))completion;

/**
 根据过滤条件获取消息

 @param condition 过滤条件
 @param completion 成功回调
 */
- (void)messageListWithCondition:(CMPMessageDbFilterCondition *)condition cmpletion:(MessageListCompletion)completion;

/**
 获取消息列表，屏蔽聚合消息
 */
- (void)messageListWithoutAggregationCompletion:(MessageListCompletion)completion;

/**
 根据消息ID，获取消息

 @param messageID 消息ID
 @param completion 成功回调
 */
- (void)messageWithMsgID:(NSString *)messageID completion:(void(^)(CMPMessageObject *message))completion;

/**
 根据AppID，获取消息
 */
- (CMPMessageObject *)messageWithAppID:(NSString *)appID;

/**
 标记智能消息为已读
 */
- (void)readSmartMessageWithMsgID:(NSString *)msgID;

#pragma mark-
#pragma mark 消息操作

/**
 存储消息
 
 @param messages 消息数组
 */
- (void)saveMessages:(NSArray<CMPMessageObject *> *)messages isChat:(BOOL)isChat;

/**
 根据过滤条件条件删除消息
 
 @param condition 过滤条件
 @param completion 成功回调
 */
- (void)deleteMessageWithCondition:(CMPMessageDbFilterCondition *)condition completion:(DeleteMessagesCompletion)completion;

- (void)deleteV5MessageOnly;

/**
 删除消息
 */
- (void)deleteMessageWithAppID:(NSString *)appID;

/**
 删除应用消息分类
 */
- (void)deleteAppMessage;

/**
 消息标记为暂无消息
 */
- (void)clearMessageWithAppID:(NSString *)appID;

/**
 消息标记为已读
 */
- (void)readMessageWithAppID:(NSString *)appID;

/**
 获取消息的未读条数
 */
- (void)totalUnreadCount:(void (^)(NSInteger))completion;

/**
 置顶/取消置顶消息
 */
- (void)topMessage:(CMPMessageObject *)obj;

/**
 设置消息提醒
 */
- (void)remindMessage:(CMPMessageObject *)obj;

/**
 更新消息设置

 @param settingList 设置列表
 */
- (void)updateWithMessageSettings:(NSArray<CMPV5MessageSetting *> *)settingList;

/**
 获取消息的置顶状态
 */
- (void)getTopStatusWithAppID:(NSString *)appID completion:(void(^)(BOOL isTop))completion;

/**
 获取消息的聚合信息
 */
- (void)getParentWithAppID:(NSString *)appID completion:(void(^)(NSString *parent))completion;

/**
 获取排序号
 */
- (void)getSortWithAppID:(NSString *)appID completion:(void(^)(NSString *sort))completion;

/**
 获取消息提醒状态
 */
- (BOOL)getRemindWithAppID:(NSString *)appID;

/**
更新消息附加信息
*/
- (void)updateMessageExtraDataString:(CMPMessageObject *)obj;

/**
 更新群组类型扩展信息
 */
- (void)updateMessageExtraDataString14:(NSDictionary *)val;

#pragma mark-
#pragma mark 消息聚合

/**
 聚合消息到指定分类

 @param type 聚合的消息类型
 @param appID 待聚合消息ID
 */
- (void)aggregationMessageWithType:(CMPMessageType)type appID:(NSString *)appID;

/**
 取消聚合

 @param appID 待取消聚合消息ID
 */
- (void)cancelAggregationMessageWithAppID:(NSString *)appID;

/**
 将应用消息分类下的所有消息标记为已读
 */
- (void)readAppMessage;

#pragma mark-
#pragma mark 致信

/**
 更新群名
 */
- (void)updateGroupName:(CMPMessageObject *)obj;

/**
 设置置顶状态
 */
- (void)setRCChatTopStatus:(CMPMessageObject *)obj type:(RCConversationType)type ext:(NSDictionary *)ext;

/**
 获取置顶状态
 */
- (void)getRCChatTopStatusWithTargetId:(NSString *)targetId type:(RCConversationType)type completion:(void (^)(BOOL))completion;

/**
 清空聊天记录
 */
- (void)clearRCChatMsgWithTargetId:(NSString *)targetId type:(RCConversationType)type;

/**
 清空群系统消息
 */
- (void)clearRCGroupNotification;

#pragma mark-
#pragma mark 关联账号

- (void)saveAssociateMessage:(CMPMessageObject *)message;

- (void)deleteAssociateMessage;

@end
