//
//  XZMainProjectBridge.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/3.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZMainProjectBridge.h"
#import <CMPMediator/CMPMediator+CMPCoreActions.h>

@implementation XZMainProjectBridge

+ (NSArray *)tabbarIdList {
    return [[CMPMediator sharedInstance] CMPMediator_tabbarIdList];
}

+ (NSArray *)m3AppIdList {
    return [[CMPMediator sharedInstance] CMPMediator_m3AppIdList];
}

+ (NSDictionary *)userPrivilegeDictionary {
    return [[CMPMediator sharedInstance] CMPMediator_userPrivilegeDictionary];
}

+ (BOOL)reachableNetwork {
    return [[CMPMediator sharedInstance] CMPMediator_reachableNetwork];
}

+ (BOOL)reachableServer {
    return [[CMPMediator sharedInstance] CMPMediator_reachableServer];
}

+ (void)updateReachableServer:(NSError *)aError {
    [[CMPMediator sharedInstance] CMPMediator_updateReachableServer:aError];
}

+ (void)showLoginViewControllerWithMessage:(NSString *)message {
    [[CMPMediator sharedInstance] CMPMediator_showLoginViewController];
}

+ (void)showChatWithMember:(id)member {
    [[CMPMediator sharedInstance] CMPMediator_showChatWithMember:member];
}

+ (BOOL)unavailableCMPChatType {
    return [[CMPMediator sharedInstance] CMPMediator_unavailableCMPChatType];
}

#pragma mark contacts Start
+ (BOOL)contactsIsUpdating {
    return [[CMPMediator sharedInstance] CMPMediator_contactsIsUpdating];
}

+ (void)memberListForNameArray:(NSArray *)nameArray isFlow:(BOOL)isFlow completion:(void (^)(NSArray *))completion {
    [[CMPMediator sharedInstance] CMPMediator_memberListForNameArray:nameArray isFlow:isFlow completion:completion];
}

+ (void)memberListForName:(NSString *)name completion:(void (^)(NSArray *))completion {
    [[CMPMediator sharedInstance] CMPMediator_memberListForName:name completion:completion];
}

+ (void)memberListForPinYin:(NSString *)name completion:(void (^)(NSArray *))completion {
    [[CMPMediator sharedInstance] CMPMediator_memberListForPinYin:name completion:completion];
}

+ (void)searchMemberWithKey:(NSString *)key isFlow:(BOOL)isFlow completion:(void (^)(NSArray *))completion {
    [[CMPMediator sharedInstance] CMPMediator_searchMemberWithKey:key isFlow:isFlow completion:completion];
}

+ (void)topTenFrequentContact:(void (^)(NSArray *))block addressbook:(BOOL)adressbook {
    [[CMPMediator sharedInstance] CMPMediator_topTenFrequentContact:block addressbook:adressbook];
}
#pragma mark contacts end

+ (void)clearMediatorCache {
    [[CMPMediator sharedInstance] CMPMediator_clearMediatorCache];
}

#pragma mark CMPHomeAlertManager start

+ (void)homeAlertManagerPushTask:(void(^)(void))showBlock priority:(NSInteger)priority {
    [[CMPMediator sharedInstance] CMPMediator_homeAlertManagerPushTask:showBlock priority:priority];
}

+ (void)homeAlertManagerTaskDone {
    [[CMPMediator sharedInstance] CMPMediator_homeAlertManagerTaskDone];
}
#pragma mark CMPHomeAlertManager end


//发融云消息
+ (void)chatToMember:(id)member content:(NSString *)content completion:(void (^)(NSError *))completion{
    [[CMPMediator sharedInstance] CMPMediator_chatToMember:member content:content completion:completion];
}

+ (UIViewController *)offlineContactViewController  {
    return [[CMPMediator sharedInstance] CMPMediator_offlineContactViewController];
}

+ (UITabBarController *)tabBarViewController {
    return [[CMPMediator sharedInstance] CMPMediator_tabBarViewController];

}

+ (BOOL)tabbarCanExpand {
    return [[CMPMediator sharedInstance] CMPMediator_tabbarCanExpand];
}

@end
