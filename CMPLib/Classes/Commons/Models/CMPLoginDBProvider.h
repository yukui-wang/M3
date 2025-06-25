//
//  CMPLoginDBProvider.h
//  M3
//
//  Created by CRMO on 2017/12/5.
//

#import "CMPObject.h"
#import "CMPServerModel.h"
#import "CMPLoginAccountModel.h"
#import "CMPAssociateAccountModel.h"
#import "CMPPartTimeModel.h"

@interface CMPLoginDBProvider : CMPObject

#pragma mark-
#pragma mark-服务器API

/**
 获取服务器列表

 @return CMPServerModel数组
 */
- (NSArray<CMPServerModel *>*)listOfServer;

/**
 获取服务器总数
 */
- (NSInteger)countOfServer;

/**
 插入一条新的服务器记录
 */
- (BOOL)addServerWithModel:(CMPServerModel *)model;
//OA-209897 M3-iOS端：关联的账号数据存在一定逻辑问题，具体见描述
- (void)addServerIfServerIdChangeWithModel:(CMPServerModel *)model;

- (BOOL)updateServerWithUniqueID:(NSString *)aUniqueID
                        serverID:(NSString *)aServerID
                   serverVersion:(NSString *)aServerVersion
                    updateServer:(NSString *)updateServer
                   allowRotation:(BOOL)allowRotation
                         appList:(NSString *)appList
                 extraDataString:(NSString *)extraDataString;

/**
 更新服务器备注信息

 @param aUniqueID 需要更新的服务器uniqueID
 @param note 需要更新的备注信息
 */
- (void)updateServerWithUniqueID:(NSString *)aUniqueID note:(NSString *)note;

/**
 更新服务器储存附加信息
 
 @param aUniqueID 需要更新的服务器uniqueID
 @param extraDataString 需要更新的备注信息
 */
- (void)updateServerWithUniqueID:(NSString *)aUniqueID extraDataString:(NSString *)extraDataString;

/**
 根据服务器uniqueID查询服务器信息
 */
- (CMPServerModel *)findServerWithUniqueID:(NSString *)uniqueID;

/**
 根据ServerID查询服务器信息，返回一个列表，可能出现两个服务器，普通与安全
 */
- (NSArray<CMPServerModel *> *)findServersWithServerID:(NSString *)serverID;

/**
 当前正在使用的Server
 */
- (CMPServerModel *)inUsedServer;

/**
 删除服务器
 */
- (BOOL)deleteServerWithUniqueID:(NSString *)uniqueID;
- (void)deleteServerWithServerID:(NSString *)serverID;

/**
 切换正在使用的服务器
 */
- (BOOL)switchUsedServerWithUniqueID:(NSString *)uniqueID;

#pragma mark-
#pragma mark-账号API

/**
 获取服务器的自动登陆账号
 */
- (CMPLoginAccountModel *)inUsedAccountWithServerID:(NSString *)serverID;

/**
 根据服务器和用户名获取账号信息
 */
- (CMPLoginAccountModel *)accountWithServerID:(NSString *)serverID userID:(NSString *)userID;

/**
 获取所有获取账号信息
 */
- (NSArray<CMPLoginAccountModel *> *)allAccount;

/**
 将所有老用户标记为已经弹出过隐私协议框
 */
- (void)updateDatabaseOldAccountAlreadyPopuUppPrivacypPage;

- (void)updateAccount:(CMPLoginAccountModel *)account
             extend10:(NSString *)extend10;

- (void)updateAccount:(CMPLoginAccountModel *)account
              AppList:(NSString *)appList;

- (void)updateAccount:(CMPLoginAccountModel *)account
           ConfigInfo:(NSString *)configInfo;

- (void)updateAccount:(CMPLoginAccountModel *)account
                token:(NSString *)token
           expireTime:(NSString *)expireTime;

- (void)clearAccountToken:(CMPLoginAccountModel *)account;

/**
 清空所有账号的token
 */
- (void)clearAllTokens;

/**
 添加一个使用的账号
 */
- (BOOL)addAccount:(CMPLoginAccountModel *)account inUsed:(BOOL)inUsed;

/**
 移除账号的信息
 */
- (BOOL)deleteAccount:(CMPLoginAccountModel *)account;
/**
 设置手势密码
 */
- (BOOL)updateGesturePassword:(NSString *)password
                     serverID:(NSString *)serverID
                       userID:(NSString *)userID
                  gestureMode:(NSInteger)aMode;

// 将所有用户设置为不在使用中
- (BOOL)updateAllAccountsUnUsedWithServerId:(NSString *)aServerId;

- (void)clearLoginPasswordWithServerId:(NSString *)aServerId;
/**
 清空某个账号的密码包括备用密码
 @param serverID 服务器ID
 @param userID 用户ID
*/
- (void)clearLoginAllPasswordWithServerID:(NSString *)serverID userId:(NSString *)userID;
/**
 只清空手动登录密码，不包含关联账号的extend2字段密码
 */
- (void)clearLoginPasswordWithServerID:(NSString *)serverID userId:(NSString *)userID;

// 清空所有用户密码
- (BOOL)clearAllLoginPassword;

/**
 更新pushConfig缓存
 */
- (BOOL)updatePushConfig:(NSString *)pushConfig serverID:(NSString *)serverID userID:(NSString *)userID;

/**
 获取pushConfig缓存
 */
- (NSString *)pushConfigWithServerID:(NSString *)serverID userID:(NSString *)userID;

/**
 更新ucConfig缓存
 */
- (BOOL)updateUcConfig:(NSString *)pushConfig serverID:(NSString *)serverID userID:(NSString *)userID;

/**
 获取ucConfig缓存
 */
- (NSString *)ucConfigWithServerID:(NSString *)serverID userID:(NSString *)userID;

/**
 通过手机号获取密码
 */
- (NSString *)passwordWithPhone:(NSString *)phone;

#pragma mark-
#pragma mark 关联账号

/**
 查询关联账号表
 只能查到serverID、userID、groupID

 @param serverUniqueID 服务器唯一ID
 @return 关联账号
 */
- (CMPAssociateAccountModel *)assAcountWithServerID:(NSString *)serverUniqueID userID:(NSString *)userID;

/**
 添加关联账号

 @param assAccount 关联账号
 */
- (void)addAssAccount:(CMPAssociateAccountModel *)assAccount;

/**
 获取关联账号列表（不包含当前服务器）

 @param serverID 服务器ID
  @param userID 用户ID
 @return 关联账号列表（包含所有信息）
 */
- (NSArray<CMPAssociateAccountModel *> *)assAcountListWithServerID:(NSString *)serverID userID:(NSString *)userID;
/**
 删除主服务器关联的服务器，同时删除关联关系

 @param serverID 主服务器的ID
 */
- (void)deleteAssAccountAndServerForServerID:(NSString *)serverID;

/**
 获取关联账号列表（不包含当前服务器）
 
 @param serverID 服务器唯一ID
 @return 关联账号列表（包含所有信息）
 */
- (NSArray<CMPAssociateAccountModel *> *)assAcountListWithServerID:(NSString *)serverID;

/**
 删除关联账号

 @param assAccount 关联账号
 */
- (void)deleteAssAccount:(CMPAssociateAccountModel *)assAccount;

/**
 更新关联账号的未读消息数

 @param assAccount 需要更新的关联账号,取其中的unreadCount来更新关联消息的未读条数
 */
- (void)updateUnreadWithAssAccount:(CMPAssociateAccountModel *)assAccount;

/**
 更新关联账号的切换时间
 
 @param assAccount 需要更新的关联账号,取其中的switchTime来更新关联消息的切换时间
 */
- (void)updateSwitchTimeWithAssAccount:(CMPAssociateAccountModel *)assAccount;

/**
 查询指定serverUniqueID对应服务器所在Group的关联账号数量

 @param serverID 服务器的ID
 @return 关联账号数量
 */
- (NSInteger)countOfAssAcountWithServerID:(NSString *)serverID;

/**
 主服务器数量
 extend1 的 值不是"1"
 */
- (NSInteger)countOfMainServer;

#pragma mark-
#pragma mark 兼职单位

/**
 获取兼职单位列表，去掉本单位
 */
- (NSArray<CMPPartTimeModel *> *)partTimeListWithServerID:(NSString *)serverID
                                                   userID:(NSString *)userID;

- (CMPPartTimeModel *)partTimeWithServerID:(NSString *)serverID
                                    userID:(NSString *)userID
                                 accountID:(NSString *)accountID;

- (void)clearPartTimesWithServerID:(NSString *)serverID
                            userID:(NSString *)userID;

- (void)addPartTimes:(NSArray<CMPPartTimeModel *> *)partTimes;


#pragma mark 组织码
- (BOOL)addOrgLoginInfoWithOrgCode:(NSString *)orgCode loginName:(NSString*)loginName;
- (NSDictionary *)findOrgLoginInfo;

#pragma mark - vpn
- (BOOL)addVpnInfoWith:(CMPServerVpnModel *)vpnModel;
- (CMPServerVpnModel *)getVpnInfoByServerID:(NSString *)serverID;
- (BOOL)deleteServerVpnWithServerID:(NSString *)serverID;

@end
