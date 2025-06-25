//
//  CMPRCGroupPrivilegeProvider.h
//  M3
//
//  Created by CRMO on 2018/7/4.
//

#import <CMPLib/CMPObject.h>
#import "CMPRCGroupPrivilegeModel.h"

typedef void(^RequestRCGroupPrivilegeDidFinish)(CMPRCGroupPrivilegeModel *privilege, NSError *error);

@interface CMPRCGroupPrivilegeProvider : CMPObject

/**
 获取致信群相关权限
 现在只有文件收/发控制

 @param groupID 群ID
 @param memberID 人员ID
 @param block 成功回调
 */
- (void)rcGroupPrivilegeWithGroupID:(NSString *)groupID
                           memberID:(NSString *)memberID
                         completion:(RequestRCGroupPrivilegeDidFinish)block;

@end
