//
//  CMPRCGetUserNameBlockObj.h
//  CMPCore
//
//  Created by CRMO on 2017/8/22.
//
//

#import <Foundation/Foundation.h>

@class RCUserInfo,CMPRCGroupMemberObject;
@interface CMPRCBlockObject : NSObject

/** 获取用户名字回调 **/
typedef void(^UserNameDoneBlock)(NSString *name);
/** 获取群名回调 **/
typedef void(^GroupNameDoneBlock)(NSString *groupName);
/** 融云获取群成员列表回调 **/
typedef void (^AllMembersOfGroupResultBlock)(CMPRCGroupMemberObject *groupInfo,NSArray<RCUserInfo *> *userList);

@property (nonatomic, strong) UserNameDoneBlock userNameDoneBlock;
@property (nonatomic, strong) AllMembersOfGroupResultBlock allMemberOfGroupResultBlock;

@end
