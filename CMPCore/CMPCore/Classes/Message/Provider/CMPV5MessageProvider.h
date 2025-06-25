//
//  CMPMessageNetProvider.h
//  M3
//
//  Created by CRMO on 2018/1/4.
//

#import <CMPLib/CMPObject.h>
#import "CMPV5MessageSetting.h"

typedef void(^CMPRequestAssociateUnreadComletion)(NSInteger unreadCount, NSError *error);
typedef void(^CMPLogoutOtherDeviceComletion)(NSError *error);

@class CMPMessageObject;

@interface CMPV5MessageProvider : CMPObject

/**
 获取消息列表
 */
- (void)requestMessageCompletion:(void(^)(NSArray *messageList, NSError *error))completion;

// 更新在线状态
- (void)requestUpdateOnlineState;

/**
 删除消息
 */
- (void)deleteMessageWithAppID:(NSString *)appID completion:(void(^)(NSError *error))completion;

/**
 批量删除消息
 注：1.8.0以后版本服务器才支持
 */
- (void)deleteMessageWithAppIDs:(NSArray *)appIDs completion:(void(^)(NSError *error))completion;

/**
 标记消息已读
 */
- (void)readMessageWithAppID:(NSString *)appID completion:(void(^)(NSError *error))completion;

/**
 批量删除消息
 注：1.8.0以后版本服务器才支持
 */
- (void)readMessageWithAppIDs:(NSArray *)appIDs completion:(void(^)(NSError *error))completion;

/**
 同步智能消息已读状态到服务器
 */
- (void)readSmartPushMessageWithID:(NSString *)messageID;

/**
 同步未读条数到服务器
 */
- (void)updateUnreadCountToServer;

#pragma mark-
#pragma mark 消息设置

/**
 消息置顶状态同步到服务器
 注：1.8.0以后版本服务器才支持
 @param isTop 是否置顶
 @param appID App ID、Target ID、自定义Type
 @param completion error为nil成功
 */
- (void)setTopStatus:(BOOL)isTop appID:(NSString *)appID completion:(void(^)(NSError *error))completion;

/**
 设置消息的聚合类

 @param appID App ID
 @param parent 聚合类ID-应用消息：AppMessage，设置为nil代表无聚合/取消聚合
 @param completion 完成回调，error为nil成功
 */
- (void)setParent:(NSString *)parent appID:(NSString *)appID completion:(void(^)(NSError *error))completion;

/**
 同步排序号到服务器

 @param sort 排序号
 @param appID App ID、Target ID、自定义Type
 @param completion 完成回调，error为nil成功
 */
- (void)setSort:(NSString *)sort appID:(NSString *)appID completion:(void(^)(NSError *error))completion;

/**
 设置消息提醒状态
 仅同步V5消息提醒状态

 @param remind 1-提醒 0-免打扰
 @param appID App ID
 @param completion 完成回调
 */
- (void)setRemind:(BOOL)remind appID:(NSString *)appID completion:(void(^)(NSError *error))completion;

/**
 从服务器获取消息设置列表

 @param completion 获取消息设置成功回调
 */
- (void)getMessagesSetting:(void(^)(NSArray *settingList))completion;

/**
批量同步消息设置到服务器

@param settingArray中的元素为 @{@"appId" : appID,@"type" : key,@"value" : value};
@param completion 完成回调，error为nil成功
*/
- (void)batchUploadSettingWithSettingArray:(NSArray *)settingArray
                                completion:(void (^)(NSError *error))completion;

#pragma mark-
#pragma mark 关联账号

/**
 获取关联账号的消息未读数

 @param url 关联账号的服务器地址
 @param userID 关联账号的id
 @param timestamp 单位毫秒，消息取timestamp后的
 @param completion 成功回调
 */
- (void)requestAssociateUnreadWithUrl:(NSString *)url
                               userID:(NSString *)userID
                            timestamp:(NSString *)timestamp
                           completion:(CMPRequestAssociateUnreadComletion)completion;

/**
 取消所有获取关联账号消息未读数请求
 所有调用都会回调CMPRequestAssociateUnreadComletion
 unreadcount为0，error code -1
 */
- (void)cancelAllAssociateUnreadRequest;

#pragma mark-
#pragma mark 多端在线

/**
 下线其它端
 1 - PC
 4 - UC
 */
- (void)logoutDeviceType:(NSInteger)type completion:(CMPLogoutOtherDeviceComletion)completion;

@end

@interface CMPV5MessageProviderBlock : NSObject
@property (copy, nonatomic) void(^messageListBlock)(NSArray *messageList, NSError *error);
@property (copy, nonatomic) void(^uploadDoneBlock)(NSError *error);
@property (copy, nonatomic) void(^getSettingBlock)(NSArray *settingList);
@end

