//
//  RCUserListViewController.h
//  RongExtensionKit
//
//  Created by 杜立召 on 16/7/14.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <CMPLib/CMPBaseViewController.h>
#import <RongIMKit/RongIMKit.h>
#import "CMPRCBlockObject.h"

@protocol RCSelectingUserDataSource;

@interface CMPRCUserListViewController : CMPBaseViewController

@property(nonatomic, copy) void (^selectedBlock)(RCUserInfo *selectedUserInfo);
@property(nonatomic, copy) void (^cancelBlock)();

@property(nonatomic, weak) id<RCSelectingUserDataSource> dataSource;
@property(nonatomic, assign) int maxSelectedUserNumber;
@property(nonatomic,assign) BOOL hasPermissionAtAll;

@end

@protocol RCSelectingUserDataSource <NSObject>

- (void)getSelectingUserList:(AllMembersOfGroupResultBlock)completion;

@end
