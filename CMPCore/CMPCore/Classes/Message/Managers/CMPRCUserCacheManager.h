//
//  CMPRCUserCacheManager.h
//  CMPCore
//
//  Created by CRMO on 2017/8/22.
//
//

#import <Foundation/Foundation.h>
#import "CMPRCUserCacheObject.h"
#import "CMPRCBlockObject.h"

@interface CMPRCUserCacheManager : NSObject

/**
 根据UserId查询userName，该方法会首先从缓存里面取，没有从网络获取

 @param block 查询完成回调，如果失败返回空字符串
 */
- (void)getUserName:(NSString *)userId groupId:(NSString *)groupId done:(UserNameDoneBlock)block;


/**
 根据UserId查询userName,该方法只从缓存里面取
 */
- (void)getUserName:(NSString *)userId done:(UserNameDoneBlock)block;

/**
根据groupid查询群名,该方法从网络取
*/
- (void)refreshCache:(NSString *)groupId  done:(GroupNameDoneBlock)block;

/**
 强制从网络更新指定群组的缓存

 @param groupId
 */
- (void)refreshCache:(NSString *)groupId;

/**
 手动设置缓存

 @param name
 @param userId
 @param type
 */
- (void)setCache:(NSArray<CMPRCUserCacheObject *> *)users;

/**
 清除所有缓存
 */
- (void)clearAllCache;

@end
