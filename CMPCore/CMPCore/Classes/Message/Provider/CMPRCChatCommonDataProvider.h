//
//  CMPRCChatCommonDataProvider.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/13.
//

#import <CMPLib/CMPBaseDataProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPRCChatCommonDataProvider : CMPBaseDataProvider

/**
 v8.2 330 sprint0
 获取人员在线状态
 */
-(void)fetchMemberOnlineStatus:(NSString *)mid
                        result:(CommonResultBlk)result;

/**
 批量获取群信息
 v8.2 330 sprint0
 */
-(void)fetchGroupsInfoByParams:(NSDictionary *)params
                        result:(CommonResultBlk)result;


/**
 获取致信文件操作权限
 v8.2 330 sprint2
 */
-(void)fetchChatFileOperationPrivilegeByParams:(NSDictionary *)params
                                        result:(CommonResultBlk)result;


/**
 非后台新增
 查询致信文件是否存在
 v8.2 330 解决jira bug V5-34763 移动端M3-已经删除的群文件，还能通过收藏查看该文件
 */
-(void)checkChatFileIfExistById:(NSString *)fid
                        groupId:(NSString *)gid
                         result:(CommonResultBlk)result;

/**
 8.2为了解决文件权限不安全问题
 */
- (void)fetchGroupUserListByGroupId:(NSString *)groupId
                         completion:(CommonResultBlk)result;


/**
 8.2_810
 获取所有置顶会话
 */
- (void)fetchAllTopChatListWithCompletion:(CommonResultBlk)result;

/**
 8.2_810
 保存置顶状态
 */
- (void)saveChatTopStateByCid:(NSString *)cid
                        state:(NSInteger)state
                   completion:(CommonResultBlk)result;

/**
 8.2_810
 批量保存本地置顶状态
 */
- (void)saveLocalChatsTopStatesByValues:(NSArray *)values
                             completion:(CommonResultBlk)result;

/**
 8.2_810
 标记会话为未读
 */
- (void)signChatToUnreadByCid:(NSString *)cid
                     isUnread:(BOOL)isUnread
                   completion:(CommonResultBlk)result;
/**
 8.2_810
 删除会话
 */
- (void)deleteChatByCid:(NSString *)cid
             completion:(CommonResultBlk)result;

@end

NS_ASSUME_NONNULL_END
