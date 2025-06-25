//
//  XZMainProjectBridge.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/3.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZMainProjectBridge : NSObject

+ (NSArray *)tabbarIdList;
+ (NSArray *)m3AppIdList;
+ (NSDictionary *)userPrivilegeDictionary;
+ (BOOL)reachableNetwork;
+ (BOOL)reachableServer;
+ (void)updateReachableServer:(NSError *)aError;
+ (void)showLoginViewControllerWithMessage:(NSString * _Nullable )message;
+ (void)showChatWithMember:(id)member;
+ (BOOL)unavailableCMPChatType;//致信使用融云

#pragma mark contacts Start
+ (void)memberListForNameArray:(NSArray *)nameArray isFlow:(BOOL)isFlow completion:(void (^)(NSArray *))completion;
+ (void)memberListForName:(NSString *)name completion:(void (^)(NSArray *))completion;
+ (void)memberListForPinYin:(NSString *)name completion:(void (^)(NSArray *))completion;
+ (BOOL)contactsIsUpdating;
+ (void)searchMemberWithKey:(NSString *)key isFlow:(BOOL)isFlow completion:(void (^)(NSArray *))completion;
+ (void)topTenFrequentContact:(void (^)(NSArray *))block addressbook:(BOOL)adressbook;
#pragma mark contacts end

+ (void)clearMediatorCache;

#pragma mark CMPHomeAlertManager start
+ (void)homeAlertManagerPushTask:(void(^)(void))showBlock priority:(NSInteger)priority;
+ (void)homeAlertManagerTaskDone;
#pragma mark CMPHomeAlertManager end
//发融云消息
+ (void)chatToMember:(id)member content:(NSString *)content completion:(void (^)(NSError *))completion;

+ (UIViewController *)offlineContactViewController;
+ (UITabBarController *)tabBarViewController;
+ (BOOL)tabbarCanExpand;

@end

NS_ASSUME_NONNULL_END
