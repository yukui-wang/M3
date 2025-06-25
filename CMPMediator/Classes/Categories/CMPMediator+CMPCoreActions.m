//
//  CMPMediator+CMPCoreActions.m
//  CMPMediator
//
//  Created by wujiansheng on 2019/4/3.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPMediator+CMPCoreActions.h"
NSString * const kCMPMediatorTargetCMPCore = @"CMPCore";

@implementation CMPMediator (CMPCoreActions)

- (NSArray *)CMPMediator_tabbarIdList {
    return [self performTarget:kCMPMediatorTargetCMPCore action:@"tabbarIdList" params:nil shouldCacheTarget:NO];
}

- (NSArray *)CMPMediator_m3AppIdList {
    return [self performTarget:kCMPMediatorTargetCMPCore action:@"m3AppIdList" params:nil shouldCacheTarget:NO];
}

- (NSDictionary *)CMPMediator_userPrivilegeDictionary {
    return [self performTarget:kCMPMediatorTargetCMPCore action:@"userPrivilegeDictionary" params:nil shouldCacheTarget:NO];
}

- (BOOL)CMPMediator_reachableNetwork {
    id result = [self performTarget:kCMPMediatorTargetCMPCore action:@"reachableNetwork" params:nil shouldCacheTarget:NO];
    return [result boolValue];
}

- (BOOL)CMPMediator_reachableServer {
    id result = [self performTarget:kCMPMediatorTargetCMPCore action:@"reachableServer" params:nil shouldCacheTarget:NO];
    return [result boolValue];
}

- (void)CMPMediator_updateReachableServer:(NSError *)aError {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:aError,@"error", nil];
    [self performTarget:kCMPMediatorTargetCMPCore action:@"updateReachableServer" params:params shouldCacheTarget:NO];
}

- (void)CMPMediator_showLoginViewController {
    [self performTarget:kCMPMediatorTargetCMPCore action:@"showLoginViewController" params:nil shouldCacheTarget:NO];
}

- (void)CMPMediator_showChatWithMember:(id)member {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:member,@"member", nil];
    [self performTarget:kCMPMediatorTargetCMPCore action:@"showChatWithMember" params:params shouldCacheTarget:NO];
}

- (BOOL)CMPMediator_unavailableCMPChatType {
    id result = [self performTarget:kCMPMediatorTargetCMPCore action:@"unavailableCMPChatType" params:nil shouldCacheTarget:NO];
    return [result boolValue];
}

#pragma mark contacts Start

- (BOOL)CMPMediator_contactsIsUpdating{
    id result = [self performTarget:kCMPMediatorTargetCMPCore action:@"contactsIsUpdating" params:nil shouldCacheTarget:NO];
    return [result boolValue];
}

- (void)CMPMediator_memberListForNameArray:(NSArray *)nameArray isFlow:(BOOL)isFlow completion:(void (^)(NSArray *))completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:nameArray forKey:@"nameArray"];
    [params setObject:[NSNumber numberWithBool:isFlow] forKey:@"isFlow"];
    [params setObject:completion forKey:@"completion"];
    [self performTarget:kCMPMediatorTargetCMPCore action:@"memberListForNameArray" params:params shouldCacheTarget:YES];
}

- (void)CMPMediator_memberListForName:(NSString *)name completion:(void (^)(NSArray *))completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:name forKey:@"name"];
    [params setObject:completion forKey:@"completion"];
    [self performTarget:kCMPMediatorTargetCMPCore action:@"memberListForName" params:params shouldCacheTarget:YES];
}

- (void)CMPMediator_memberListForPinYin:(NSString *)name completion:(void (^)(NSArray *))completion{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:name forKey:@"name"];
    [params setObject:completion forKey:@"completion"];
    [self performTarget:kCMPMediatorTargetCMPCore action:@"memberListForPinYin" params:params shouldCacheTarget:YES];
}

- (void)CMPMediator_searchMemberWithKey:(NSString *)key isFlow:(BOOL)isFlow completion:(void (^)(NSArray *))completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:key forKey:@"key"];
    [params setObject:[NSNumber numberWithBool:isFlow] forKey:@"isFlow"];
    [params setObject:completion forKey:@"completion"];
    [self performTarget:kCMPMediatorTargetCMPCore action:@"searchMemberWithKey" params:params shouldCacheTarget:YES];
}

- (void)CMPMediator_topTenFrequentContact:(void (^)(NSArray *))block addressbook:(BOOL)adressbook {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithBool:adressbook] forKey:@"adressbook"];
    [params setObject:block forKey:@"completion"];
    [self performTarget:kCMPMediatorTargetCMPCore action:@"topTenFrequentContact" params:params shouldCacheTarget:YES];
}

- (void)CMPMediator_clearMediatorCache {
    [self releaseCachedTargetWithTargetName:kCMPMediatorTargetCMPCore];
}
#pragma mark contacts end

#pragma mark CMPHomeAlertManager start

- (void)CMPMediator_homeAlertManagerPushTask:(void(^)(void))showBlock priority:(NSInteger)priority {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:showBlock forKey:@"showBlock"];
    [params setObject:[NSNumber numberWithInteger:priority] forKey:@"priority"];
    [self performTarget:kCMPMediatorTargetCMPCore action:@"homeAlertManagerPushTask" params:params shouldCacheTarget:YES];
}

- (void)CMPMediator_homeAlertManagerTaskDone {
    [self performTarget:kCMPMediatorTargetCMPCore action:@"homeAlertManagerTaskDone" params:nil shouldCacheTarget:NO];
}
#pragma mark CMPHomeAlertManager end


//小致发融云消息
- (void)CMPMediator_chatToMember:(id)member content:(NSString *)content completion:(void (^)(NSError *))completion {    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:member forKey:@"member"];
    [params setObject:content forKey:@"content"];
    [params setObject:completion forKey:@"block"];

    [self performTarget:kCMPMediatorTargetCMPCore action:@"chatToMember" params:params shouldCacheTarget:NO];
}

- (UIViewController *)CMPMediator_offlineContactViewController {
    return  [self performTarget:kCMPMediatorTargetCMPCore action:@"offlineContactViewController" params:nil shouldCacheTarget:NO];
}

- (UITabBarController *)CMPMediator_tabBarViewController {
    return  [self performTarget:kCMPMediatorTargetCMPCore action:@"tabBarViewController" params:nil shouldCacheTarget:NO];
}

- (BOOL)CMPMediator_tabbarCanExpand
{
    return  [self performTarget:kCMPMediatorTargetCMPCore action:@"tabbarCanExpand" params:nil shouldCacheTarget:NO];
}

@end

