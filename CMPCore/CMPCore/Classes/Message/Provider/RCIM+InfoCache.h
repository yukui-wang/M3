//
//  RCIM+InfoCache.h
//  M3
//
//  Created by 程昆 on 2020/5/7.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCIM (InfoCache)

- (RCUserInfo *)refreshUserNameCache:(NSString *)name withUserId:(NSString *)userId;
- (void)refreshUserPortraitUriCacheWithUserId:(NSString *)userId;
- (RCGroup *)refreshGroupNameCache:(NSString *)groupName withGroupId:(NSString *)groupId;

@end

NS_ASSUME_NONNULL_END
