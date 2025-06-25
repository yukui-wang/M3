//
//  Target_CMPCore.m
//  M3
//
//  Created by wujiansheng on 2019/4/3.
//

#import "Target_CMPCore.h"
#import "AppDelegate.h"
#import "CMPTabBarItemAttribute.h"
#import <CMPLib/CMPAppListModel.h>
#import "CMPPrivilege.h"
#import "CMPPrivilegeManager.h"

#import "CMPRCTargetObject.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/CMPOfflineContactMember.h>
#import "CMPChatManager.h"
#import "CMPCommonManager.h"
#import "CMPContactsManager.h"
#import "CMPHomeAlertManager.h"
#import "M3LoginManager.h"
#import "CMPOfflineContactViewController.h"

@implementation Target_CMPCore

- (NSArray *)Action_tabbarIdList:(NSDictionary *)params {
    AppDelegate *delegate = [AppDelegate shareAppDelegate];
    CMPTabBarViewController *tabBarViewController = delegate.tabBarViewController;
    NSMutableArray *array = [NSMutableArray array];
    for (CMPTabBarItemAttribute *obj in tabBarViewController.itemAttrs) {
        if (![NSString isNull:obj.appID]) {
            [array addObject:obj.appID];
        }
    }
    return array;
}

- (NSArray *)Action_m3AppIdList:(NSDictionary *)params {
    NSString *appListStr = [CMPCore sharedInstance].currentUser.appList;
    CMPObject *appListMode = nil;
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        appListMode = [CMPAppListModel_2 yy_modelWithJSON:appListStr];
    } else {
        appListMode = [CMPAppListModel yy_modelWithJSON:appListStr];
    }
    NSMutableArray *array = [NSMutableArray array];
    if ([appListMode isKindOfClass:[CMPAppListModel_2 class]]) {
        CMPAppListModel_2 *mode = (CMPAppListModel_2 *)appListMode;
        NSArray *data = mode.data;
        NSArray *tabbarIds = [NSArray arrayWithObjects:kM3AppID_My,kM3AppID_Todo,kM3AppID_Contacts, nil];//这三个的appId 不是default
        for (CMPAppListData_2 *listData_2 in data) {
            NSArray *appList = listData_2.appList;
            for (CMPAppList_2 *appListObj in appList) {
                NSString *appType = appListObj.appType;
                NSString *appId = appListObj.appId;
                //7.0不过滤isShow 服务器已经过滤过了
                if ([appType isEqualToString:@"default"] || [tabbarIds containsObject:appId]) {
                    CMPAppListM3AppType_2 *m3AppType = appListObj.m3AppType;
                    NSInteger edit = m3AppType.edit;
                    if (edit != -1) {
                        [array addObject:appId];
                    }
                }
            }
        }
    }
    else if ([appListMode isKindOfClass:[CMPAppListModel class]]) {
        CMPAppListModel *mode = (CMPAppListModel *)appListMode;
        NSArray *data = mode.data;
        for (CMPAppListData *listData in data) {
            if ([listData.isShow boolValue] &&  [listData.appType isEqualToString:@"default"] && ![NSString isNull:listData.appId]) {
                [array addObject:listData.appId];
            }
        }
    }
    return array;
}

- (NSDictionary *)Action_userPrivilegeDictionary:(NSDictionary *)params {
    CMPPrivilege *privilege = [CMPPrivilegeManager getCurrentUserPrivilege];
    BOOL hasAddressBook = privilege.hasAddressBook;
    BOOL hasColNew = privilege.hasColNew;
    BOOL hasIndexPlugin = privilege.hasIndexPlugin;

    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:hasAddressBook],@"hasAddressBook",[NSNumber numberWithBool:hasColNew],@"hasColNew",[NSNumber numberWithBool:hasIndexPlugin],@"hasIndexPlugin", nil];
    return dic;
}

- (BOOL)Action_reachableNetwork:(NSDictionary *)params {
    return [CMPCommonManager reachableNetwork];
}

- (BOOL)Action_reachableServer:(NSDictionary *)params {
    return [CMPCommonManager reachableServer];
}

- (void)Action_updateReachableServer:(NSDictionary *)params {
    NSError *error = params[@"error"];
    [CMPCommonManager updateReachableServer:error];
}

- (void)Action_showLoginViewController:(NSDictionary *)params {
    [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
}

- (void)Action_showChatWithMember:(NSDictionary *)params {
    CMPOfflineContactMember *member = params[@"member"];
    CMPTabBarViewController *tabbar =  [AppDelegate shareAppDelegate].tabBarViewController;
    CMPRCTargetObject *targetObjec =  [[CMPRCTargetObject alloc] init];
    targetObjec.targetId = member.orgID;
    targetObjec.type = 1;
    targetObjec.title = member.name;
    tabbar.tabBar.hidden = NO;
    targetObjec.tabbar = tabbar;
    targetObjec.navigationController = [UIViewController currentViewController].navigationController;
    [[CMPChatManager sharedManager] showChatView:targetObjec];
}

- (BOOL)Action_unavailableCMPChatType:(NSDictionary *)params {
    BOOL result = [[CMPChatManager sharedManager] chatType] != CMPChatType_Rong;
    return result;
}

#pragma mark contacts Start

- (BOOL)Action_contactsIsUpdating:(NSDictionary *)params {
    BOOL result = [[CMPContactsManager defaultManager] offlineStatus] == OfflineStatusUpating;
    return result;
}

- (void)Action_memberListForNameArray:(NSDictionary *)params {
    NSArray *nameArray = params[@"nameArray"];
    BOOL isFlow = [params[@"isFlow"] boolValue];
    NSString *tbName = isFlow?kFlowTempTable:kContactsTempTable;
    [[CMPContactsManager defaultManager] memberListForNameArray:nameArray tbName:tbName completion:params[@"completion"]];
}

- (void)Action_memberListForName:(NSDictionary *)params {
    NSString *name = params[@"name"];
    [[CMPContactsManager defaultManager] memberListForName:name completion:params[@"completion"]];
}

- (void)Action_memberListForPinYin:(NSDictionary *)params {
    [[CMPContactsManager defaultManager] memberListForPinYin:params[@"name"] completion:params[@"completion"]];
}

- (void)Action_searchMemberWithKey:(NSDictionary *)params {
    NSString *key = params[@"key"];
    BOOL isFlow = [params[@"isFlow"] boolValue];
    NSString *tbName = isFlow?kFlowTempTable:kContactsTempTable;
    [[CMPContactsManager defaultManager] searchMemberWithKey:key tbName:tbName completion:params[@"completion"]];
}

- (void)Action_topTenFrequentContact:(NSDictionary *)params {
    BOOL adressbook = [params[@"adressbook"] boolValue];
    [[CMPContactsManager defaultManager] topTenFrequentContact:params[@"completion"] addressbook:adressbook];
}
#pragma mark contacts end

#pragma mark CMPHomeAlertManager start

- (void)Action_homeAlertManagerPushTask:(NSDictionary *)params {
    NSInteger priority = [params[@"priority"] integerValue] == 1 ? CMPHomeAlertPrioritySmartMsg:CMPHomeAlertPriorityXZ;
    [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:params[@"showBlock"] priority:priority];
}

- (void)Action_homeAlertManagerTaskDone:(NSDictionary *)params {
    [[CMPHomeAlertManager sharedInstance] taskDone];
}

#pragma mark CMPHomeAlertManager end

//小致发融云消息
- (void)Action_chatToMember:(NSDictionary *)params {
    [[CMPChatManager sharedManager] chatToMember:params[@"member"] content:params[@"content"] completion:params[@"block"]];
}

- (UIViewController *)Action_offlineContactViewController:(NSDictionary *)params  {
    CMPOfflineContactViewController *aCMPBannerViewController = [[CMPOfflineContactViewController alloc] init];
    aCMPBannerViewController.isShowBackButton = YES;
    aCMPBannerViewController.hidesBottomBarWhenPushed = YES;
    return aCMPBannerViewController;
}

- (UITabBarController *)Action_tabBarViewController:(NSDictionary *)params {
    AppDelegate *delegate = [AppDelegate shareAppDelegate];
    CMPTabBarViewController *tabBarViewController = delegate.tabBarViewController;
    return (UITabBarController *)tabBarViewController;
}

- (BOOL)Action_tabbarCanExpand:(NSDictionary *)params
{
    AppDelegate *delegate = [AppDelegate shareAppDelegate];
    CMPTabBarViewController *tabBarViewController = delegate.tabBarViewController;
    return tabBarViewController.canPanExpandNavi;
}

@end
