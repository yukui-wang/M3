//
//  CMPRCChatViewModel.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/13.
//

#import <CMPLib/CMPBaseViewModel.h>
#import "CMPRCGroupPrivilegeModel.h"
@class CMPRCGroupMemberObject;

NS_ASSUME_NONNULL_BEGIN

@interface CMPRCChatViewModel : CMPBaseViewModel

-(void)fetchMemberOnlineStatus:(NSString *)mid
                        result:(void(^)(NSDictionary *desDic,NSError *error, id ext))result;

-(void)fetchChatFileOperationPrivilegeByParams:(NSDictionary *)params
                                    completion:(void(^)(CMPRCGroupPrivilegeModel *privilege, NSError *error, id ext))completion;

-(void)checkChatFileIfExistById:(NSString *)fid
                        groupId:(NSString *)gid
                     completion:(void(^)(BOOL ifExsit,NSError *error, id ext))completion;

-(void)fetchGroupUserListByGroupId:(NSString *)groupId
                        completion:(void(^)(CMPRCGroupMemberObject *memberObj,NSError *error, id ext))completion;

@end

NS_ASSUME_NONNULL_END
