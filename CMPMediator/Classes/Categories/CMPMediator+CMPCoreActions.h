//
//  CMPMediator+CMPCoreActions.h
//  CMPMediator
//
//  Created by wujiansheng on 2019/4/3.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <CMPMediator/CMPMediator.h>
NS_ASSUME_NONNULL_BEGIN

@interface CMPMediator (CMPCoreActions)

- (NSArray *)CMPMediator_tabbarIdList;
- (NSArray *)CMPMediator_m3AppIdList;
- (NSDictionary *)CMPMediator_userPrivilegeDictionary;
- (BOOL)CMPMediator_reachableNetwork;
- (BOOL)CMPMediator_reachableServer;
- (void)CMPMediator_updateReachableServer:(NSError *)aError;
- (void)CMPMediator_showLoginViewController;
- (void)CMPMediator_showChatWithMember:(id)member;
- (BOOL)CMPMediator_unavailableCMPChatType;

#pragma mark contacts Start
- (BOOL)CMPMediator_contactsIsUpdating;
- (void)CMPMediator_memberListForNameArray:(NSArray *)nameArray isFlow:(BOOL)isFlow completion:(void (^)(NSArray *))completion;
- (void)CMPMediator_memberListForName:(NSString *)name completion:(void (^)(NSArray *))completion;
- (void)CMPMediator_memberListForPinYin:(NSString *)name completion:(void (^)(NSArray *))completion;
- (void)CMPMediator_searchMemberWithKey:(NSString *)key isFlow:(BOOL)isFlow completion:(void (^)(NSArray *))completion;
- (void)CMPMediator_topTenFrequentContact:(void (^)(NSArray *))block addressbook:(BOOL)adressbook;
#pragma mark contacts end
- (void)CMPMediator_clearMediatorCache;

#pragma mark CMPHomeAlertManager start
- (void)CMPMediator_homeAlertManagerPushTask:(void(^)(void))showBlock priority:(NSInteger)priority;
- (void)CMPMediator_homeAlertManagerTaskDone;
#pragma mark CMPHomeAlertManager end
//小致发融云消息
- (void)CMPMediator_chatToMember:(id)member content:(NSString *)content completion:(void (^)(NSError *))completion;

- (UIViewController *)CMPMediator_offlineContactViewController;
- (UITabBarController *)CMPMediator_tabBarViewController;
- (BOOL)CMPMediator_tabbarCanExpand;

@end

NS_ASSUME_NONNULL_END
