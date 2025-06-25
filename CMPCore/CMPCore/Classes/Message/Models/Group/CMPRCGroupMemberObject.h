//
//  CMPRCGroupMemberObject.h
//  CMPCore
//
//  Created by CRMO on 2017/9/15.
//
//

#import <CMPLib/CMPObject.h>

typedef NS_ENUM(NSInteger, CMPGroupType) {
    CMPGroupTypeOrdinary,
    CMPGroupTypeDepartment
};

@class RCUserInfo;

@interface CMPRCGroupMemberObject : CMPObject

/** 群名 **/
@property (nonatomic, strong) NSString *name;
/** 群ID **/
@property (nonatomic, strong) NSString *groupID;
/** 群主名称 **/
@property (nonatomic, strong) NSString *ownerName;
/** 创建时间 **/
@property (nonatomic, strong) NSString *createDate;
/** 群成员列表 **/
@property (nonatomic, strong) NSArray *members;
/** 群成员人数 **/
@property (nonatomic, assign) NSUInteger membersCount;
/** 群类型 **/
@property (nonatomic, copy) NSString *groupType;

/** 群类型 **/
@property (nonatomic, assign ,readonly) CMPGroupType enumGroupType;

/** 是否允许@所有人 **/
@property (nonatomic, assign, readonly) BOOL hasPermissionAtAll;

/** 群主ID **/
@property (nonatomic, strong) NSString *ownerId;

/** 管理员ID **/
@property (nonatomic, strong) NSString *adminIds;

/** 是否显示群主岗 **/
//@property (nonatomic, assign) BOOL isShowMemberPost;

/** 群成员信息。key是uid ，value是map（{"sortId":"29","postName":"高级开发工程师","name":"郭金龙","id":"-6650499944156018294"}） **/
@property (nonatomic, strong) NSDictionary *membersDic;

/**
 获取所有群成员的信息
 */
- (NSArray<RCUserInfo *> *)allUserInfo;

@end
