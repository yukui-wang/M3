//
//  XZPrivilege.h
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//
//小致权限统一管理

#import <CMPLib/CMPObject.h>


@interface XZPrivilege : CMPObject

@property(nonatomic, assign)BOOL hasColNewAuth;
@property(nonatomic, assign)BOOL hasAddressBookAuth;
@property(nonatomic, assign)BOOL hasCalEventAuth;
@property(nonatomic, assign)BOOL hasTaskAuth;
@property(nonatomic, assign)BOOL hasMeetingAuth;
@property(nonatomic, assign)BOOL hasZhixinAuth;
@property(nonatomic, assign)BOOL hasIndexPlugin;

@end

