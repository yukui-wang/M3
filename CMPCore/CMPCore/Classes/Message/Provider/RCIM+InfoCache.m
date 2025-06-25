//
//  RCIM+InfoCache.m
//  M3
//
//  Created by 程昆 on 2020/5/7.
//

#import "RCIM+InfoCache.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPDateHelper.h>

@implementation RCIM (InfoCache)

- (RCUserInfo *)refreshUserNameCache:(NSString *)name withUserId:(NSString *)userId {
    NSString *portrait = [CMPCore memberIconUrlWithId:userId];
    RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:userId];
    if (userInfo) {
//        if ([NSString isNull:userInfo.portraitUri] || [userId isEqualToString:CMP_USERID]) {
            userInfo.portraitUri = portrait;
//        }
        userInfo.name = name;
    } else {
        userInfo = [[RCUserInfo alloc] initWithUserId:userId name:name portrait:portrait];
    }
    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userId];
    return userInfo;
}

- (void)refreshUserPortraitUriCacheWithUserId:(NSString *)userId {
    NSString *imageUrl = [NSString stringWithFormat:kMemberIconUrl_M3_Param,userId];
    imageUrl = [CMPCore fullUrlForPath:imageUrl];
    NSString *portrait = [NSString stringWithFormat:@"%@&time=%@", imageUrl, [[CMPDateHelper currentNumberDate] stringValue]];
    RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:userId];
    if (userInfo) {
        userInfo.portraitUri = portrait;
        [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userId];
    }
}

- (RCGroup *)refreshGroupNameCache:(NSString *)groupName withGroupId:(NSString *)groupId {
    NSString *portrait = [CMPCore memberIconUrlWithId:groupId];
    RCGroup *groupInfo = [[RCIM sharedRCIM] getGroupInfoCache:groupId];
    if (groupInfo) {
//        if ([NSString isNull:groupInfo.portraitUri]) {
            groupInfo.portraitUri = portrait;
//        }
        groupInfo.groupName = groupName;
    } else {
        groupInfo = [[RCGroup alloc] initWithGroupId:groupId groupName:groupName portraitUri:portrait];
    }
    [[RCIM sharedRCIM] refreshGroupInfoCache:groupInfo withGroupId:groupId];
    return groupInfo;
}

@end
