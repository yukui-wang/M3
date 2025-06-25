//
//  CMPMessageManager.h
//  CMPCore
//
//  Created by wujiansheng on 2017/6/28.
//
//
#define kRequestTag_ReadMessage @"2"
#define kRequestTag_DeleteMessage @"3"

#define kMessageDidFinishRequest @"kMessageDidFinishRequest"


#import <CMPLib/CMPObject.h>
#import "CMPMessageObject.h"

@class FMDatabaseQueue;

@interface CMPMessageManager : CMPObject
+ (CMPMessageManager *)sharedManager;
- (void)begin;
- (void)stop;

#pragma mark-
#pragma mark V5消息

/**
 开始V5消息轮询
 */
- (void)startV5MessagePolling;

/**
 停止V5消息轮询
 */
- (void)stopV5MessagePolling;

/**
 删除所有V5消息（Delete操作）
 */
- (void)clearV5Message;

/**
 保存V5消息

 @param messages CMPMessageObject数组
 */
- (void)saveMessages:(NSArray *)messages;

/**
 保存小广播消息
 
 @param messages CMPMessageObject数组
 @param isChat no
 */
- (void)saveMessages:(NSArray<CMPMessageObject *> *)messages isChat:(BOOL)isChat;

/**
 刷新消息列表，仅刷新V5消息
 */
- (void)refreshMessage;

#pragma mark-
#pragma mark 消息操作

/**
 获取消息列表
 */
- (void)messageList:(void (^)(NSArray *))completion;
/**
 ks add 包含移除的
 */
- (void)allMessageList:(void (^)(NSArray *))completion;

/**
 根据消息类型获取二级消息列表
 用于消息聚合功能（应用消息分类）

 @param type 消息聚合分类
 @param completion
 */
- (void)messageListWithType:(NSInteger)type completion:(void (^)(NSArray *))completion;

/**
 置顶消息
 */
- (void)topMessage:(CMPMessageObject *)obj;

/**
置顶消息,仅同步本地数据库
*/
- (void)onlyLocalTopMessage:(CMPMessageObject *)obj;

/**
 设置消息提醒
 */
- (void)remindMessage:(CMPMessageObject *)obj completion:(void(^)(NSError *error))completion;

/**
批量同步消息设置到服务器

@param settingArray中的元素为 @{@"appId" : appID,@"type" : key,@"value" : value};
@param completion 完成回调，error为nil成功
*/
- (void)batchUploadSettingWithSettingArray:(NSArray *)settingArray completion:(void (^)(NSError *))completion;

/**
设置消息提醒,只同步本地数据库
*/
- (void)onlyLocalRemindMessage:(CMPMessageObject *)obj;

/**
 设置 RC 消息提醒
 */
- (void)remindRCMessage:(CMPMessageObject *)obj;

/**
 删除消息
 */
- (void)deleteMessageWithAppId:(CMPMessageObject *)obj;

/**
 批量删除消息
 */
- (void)deleteMessagesWithObjs:(NSArray<CMPMessageObject *> *)objs;

/**
 删除应用消息分类下的所有消息
 */
- (void)deleteAppMessage;

/**
 标记消息为已读

 @param obj
 @param isClear 是否需要清空融云消息记录
 */
- (void)readMessageWithAppId:(CMPMessageObject *)obj clearMessage:(BOOL)isClear;

/**
标记消息消息类型为appID为已读

@param appID
*/
- (void)readMessageWithAppID:(NSString *)appID;

/**
 将应用消息分类下的所有消息标记为已读
 */
- (void)readAppMessage;

/**
将消息是否标记为未读
*/
- (void)markUnreadWithMessage:(CMPMessageObject *)obj isMarkUnread:(BOOL)isMarkUnread;

/**
设置消息群组信息
*/
- (void)setGroupInfoWithMessage:(CMPMessageObject *)obj groupInfo:(CMPRCGroupMemberObject*)groupInfo;


-(void)updateGroupConversationTypeInfo:(NSDictionary *)val;

/**
发送业务卡片消息
*/
- (void)sendBusinessMessageWithParam:(NSDictionary * _Nonnull)param receiverIds:(NSString * _Nonnull)receiverIds success:(void (^ _Nonnull)(NSString * _Nonnull messageId,id _Nonnull data))success fail:(void (^ _Nonnull)(NSError * _Nonnull error, NSString * _Nonnull messageId))fail;

/**
获取 业务卡片消息各个应用快速审批
*/
- (void)getQuickProcessWithId:(NSString * _Nonnull)messageId messageCategory:(NSString * _Nonnull)messageCategory success:(void (^ _Nonnull)(NSString * _Nonnull messageId,id _Nonnull data))success fail:(void (^ _Nonnull)(NSError * _Nonnull error, NSString * _Nonnull messageId))fail;

/**
 业务卡片消息 进行快速审批
*/
- (void)quickProcessWithParam:(NSDictionary * _Nonnull)param success:(void (^ _Nonnull)(NSString * _Nonnull messageId, id _Nonnull data))success fail:(void (^ _Nonnull)(NSError * _Nonnull error, NSString * _Nonnull messageId))fail;

#pragma mark-
#pragma mark 消息设置

/**
 更新消息设置
 */
- (void)updateMessageSetting;

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
 更新消息推送设置
 */
- (void)updatePushConfig;

#pragma mark-
#pragma mark 消息聚合

/**
 聚合消息

 @param type 需要聚合消息到的目标消息
 @param appID 待聚合消息的应用ID
 */
- (void)aggregationMessageWithType:(CMPMessageType)type appID:(NSString *)appID completion:(void(^)(NSError *error))completion;

/**
 取消聚合消息

 @param appID 待取消聚合消息的应用ID
 */
- (void)cancelAggregationMessageWithAppID:(NSString *)appID completion:(void(^)(NSError *error))completion;

#pragma mark-
#pragma mark 新建一个聊天会话
- (void)showChatViewAfterShare:(CMPMessageObject *)obj vc:(UIViewController *)viewController filePaths:(NSArray *)filePaths;
- (void)showChatView:(CMPMessageObject *)obj viewController:(UIViewController *)viewController;
- (void)showChatView:(CMPMessageObject *)obj viewController:(UIViewController *)viewController filePaths:(NSArray *)filePaths;
- (void)showWebviewWithUrl:(NSString *)url viewController:(UIViewController *)viewController;
- (void)showScanViewWithUrl:(NSString *)url viewController:(UIViewController *)viewController;
- (void)showScanViewWithUrl:(NSString *)url viewController:(UIViewController *)viewController scanImage:(nullable UIImage *)scanImage;
- (void)showWebviewWithUrl:(NSString *)url viewController:(UIViewController *)viewController params:(id)tParams actionBlk:(void(^)(id params, NSError *error, NSInteger act))actBlk;

#pragma mark-
#pragma mark 致信

// 是否有致信
- (BOOL)hasZhiXin;
//是否有致信插件且可用
- (BOOL)hasZhiXinPermissionAndServerAvailable ;
//融云群设置
- (void)setRCChatTopStatus:(CMPMessageObject *)obj type:(RCConversationType)type ext:(NSDictionary *)ext;
- (void)getRCChatTopStatusWithTargetId:(NSString *)targetId type:(RCConversationType)type completion:(void (^)(BOOL))completion;
- (void)clearRCChatMsgWithTargetId:(NSString *)targetId type:(RCConversationType)type;
- (void)clearRCGroupChatMsgWithGroupId:(NSString *)groupId;
// 将群系统消息设置为“暂无消息”
- (void)clearRCGroupNotification;
/**
 更新群名称
 */
- (void)updateGroupName:(CMPMessageObject *)obj;
// 是否有任务插件
- (BOOL)hasTask;

#pragma mark-
#pragma mark 消息更新

// 设置底导航未读提醒
- (void)setupTabBarMsgBadge;
// 快捷菜单列表
- (NSArray *)shortcutItemList;
//融云快捷新建入口数据
- (NSArray *)RCQuickNewEntryItemList;

#pragma mark-
#pragma mark 关联消息

/**
 开始关联账号消息轮询
 */
- (void)startAssociateMessagePolling;

/**
 停止关联账号消息轮询
 */
- (void)stopAssociateMessagePolling;

/**
 刷新关联账号消息，仅刷新该条目
 */
- (void)refreshAssociateMessage;

/**
 移除关联消息
 */
- (void)deleteAssociateMessage;

/**
 插入空的关联消息
 */
- (void)insetEmptyAssociateMessage;

#pragma mark-
#pragma mark 消息查询

/**
 用appID查询消息
 */
- (CMPMessageObject *)messageWithAppID:(NSString *)appID;

#pragma mark-
#pragma mark 水印

/**
 向指定View添加水印
 */
- (void)addWaterMarkToView:(UIView *)view;

#pragma mark-
#pragma mark 多端在线

/**
 下线其它端
 1 - PC
 4 - UC
 */
- (void)logoutDeviceType:(NSInteger)type completion:(void(^)(NSError *error))completion;

/**
 获取消息未读数
 */
- (void)totalUnreadCount:(void (^)(NSInteger count))completion;

@end
