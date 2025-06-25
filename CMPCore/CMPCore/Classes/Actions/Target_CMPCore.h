//
//  Target_CMPCore.h
//  M3
//
//  Created by wujiansheng on 2019/4/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Target_CMPCore : NSObject


- (NSArray *)Action_tabbarIdList:(NSDictionary *)params;
- (NSArray *)Action_m3AppIdList:(NSDictionary *)params;
- (NSDictionary *)Action_userPrivilegeDictionary:(NSDictionary *)params;
- (BOOL)Action_reachableNetwork:(NSDictionary *)params;
- (BOOL)Action_reachableServer:(NSDictionary *)params;
- (void)Action_updateReachableServer:(NSDictionary *)params;
- (void)Action_showLoginViewController:(NSDictionary *)params;
- (void)Action_showChatWithMember:(NSDictionary *)params;
- (BOOL)Action_unavailableCMPChatType:(NSDictionary *)params;

#pragma mark - contacts Start
- (BOOL)Action_contactsIsUpdating:(NSDictionary *)params;
- (void)Action_memberListForNameArray:(NSDictionary *)params;
- (void)Action_memberListForName:(NSDictionary *)params;
- (void)Action_memberListForPinYin:(NSDictionary *)params;
- (void)Action_searchMemberWithKey:(NSDictionary *)params;
- (void)Action_topTenFrequentContact:(NSDictionary *)params;

#pragma mark - contacts end

#pragma mark CMPHomeAlertManager start
- (void)Action_homeAlertManagerPushTask:(NSDictionary *)params;
- (void)Action_homeAlertManagerTaskDone:(NSDictionary *)params;
#pragma mark - CMPHomeAlertManager end
//小致发融云消息
- (void)Action_chatToMember:(NSDictionary *)params;

- (UIViewController *)Action_offlineContactViewController:(NSDictionary *)params;
- (UITabBarController *)Action_tabBarViewController:(NSDictionary *)params;
- (BOOL)Action_tabbarCanExpand:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
