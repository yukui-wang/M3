//
//  CMPLoginUpdateConfigHelper.m
//  M3
//  1130移动专版token登录，更新配置信息
//
//  Created by CRMO on 2018/9/27.
//

#import "CMPLoginUpdateConfigHelper.h"
#import "CMPLoginUpdateConfigProvider.h"
#import "CMPLoginUpdateManager.h"
#import "CMPPrivilegeManager.h"
#import "CMPMigrateWebDataViewController.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "AppDelegate.h"
#import "CMPLoginResponse.h"
#import <CMPLib/CMPAlertView.h>
#import "CMPHomeAlertManager.h"
#import <CoreLocation/CoreLocation.h>
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "CMPCommonManager.h"
#import "CMPLocationManager.h"
#import "CMPGestureHelper.h"

//导航变化
typedef NS_ENUM(NSUInteger, CMPTabbarChangeType) {
    CMPTabbarChangeType_Null  = 0,//没变化
    CMPTabbarChangeType_ChangeAll,//需要全部重新加载
    CMPTabbarChangeType_OnlyTabBar//仅重新更新底导航
};


@interface CMPLoginUpdateConfigHelper()<CLLocationManagerDelegate, AMapSearchDelegate>

@property (strong, nonatomic) CMPLoginUpdateConfigProvider *provider;
@property (assign, nonatomic) BOOL appListSyncDone;
@property (assign, nonatomic) BOOL configInfoSyncDone;
@property (assign, nonatomic) BOOL userInfoSyncDone;

@end

@implementation CMPLoginUpdateConfigHelper

- (instancetype)init {
    if (self = [super init]) {
        [[CMPMigrateWebDataViewController shareInstance] initSeverVersion:[CMPCore sharedInstance].currentServer.serverVersion companyID:[CMPCore sharedInstance].currentUser.accountID];
    }
    return self;
}

- (void)updateConfigInfo:(CMPLoginUpdateDoneBlock)doneBlock {
    _configInfoSyncDone = NO;
    __weak __typeof(self)weakSelf = self;
    [self.provider requestConfigInfoSuccess:^(id  _Nonnull response,NSString *responseStr) {
        DDLogDebug(@"zl---[%s]，更新成功", __FUNCTION__);
        weakSelf.configInfoSyncDone = YES;
        [weakSelf _handleConfigInfo:response responseStr:responseStr];
        if (doneBlock) {
            doneBlock(YES);
        }
    } fail:^(NSError * _Nonnull error) {
        DDLogError(@"zl---[%s]，更新失败：%@", __FUNCTION__, error);
        weakSelf.configInfoSyncDone = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ConfigInfoDidUpdate object:nil userInfo:@{@"result" : @NO}];
        if (doneBlock) {
            doneBlock(NO);
        }
    }];
}

- (void)updateAppList:(CMPLoginUpdateDoneBlock)doneBlock {
    _appListSyncDone = NO;
    __weak __typeof(self)weakSelf = self;
    [self.provider requestAppListSuccess:^(id  _Nonnull response, NSString *responseStr) {
        DDLogDebug(@"zl---[%s]，更新成功", __FUNCTION__);
        weakSelf.appListSyncDone = YES;
        [weakSelf _handleAppList:response responseStr:responseStr];
        if (doneBlock) {
            doneBlock(YES);
        }
    } fail:^(NSError * _Nonnull error) {
        DDLogError(@"zl---[%s]，更新失败：%@", __FUNCTION__, error);
        weakSelf.appListSyncDone = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AppListDidUpdate object:nil userInfo:@{@"result" : @NO}];
        if (doneBlock) {
            doneBlock(NO);
        }
    }];
}

- (void)updateUserInfo:(CMPLoginUpdateDoneBlock)doneBlock {
    _userInfoSyncDone = NO;
    __weak __typeof(self)weakSelf = self;
    [self.provider requestUserInfoSuccess:^(NSString *response) {
        DDLogDebug(@"zl---[%s]，更新成功", __FUNCTION__);
        [weakSelf _handleUserInfo:response];
        weakSelf.userInfoSyncDone = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_UserInfoDidUpdate object:nil userInfo:@{@"result" : @YES}];
        if (doneBlock) {
            doneBlock(YES);
        }
    } fail:^(NSError * _Nonnull error) {
        DDLogError(@"zl---[%s]，更新失败：%@", __FUNCTION__, error);
        weakSelf.userInfoSyncDone = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_UserInfoDidUpdate object:nil userInfo:@{@"result" : @NO}];
        if (doneBlock) {
            doneBlock(NO);
        }
    }];
}

- (void)allUpdateDone {
    self.appListSyncDone = YES;
    self.configInfoSyncDone = YES;
    self.userInfoSyncDone = YES;
}

- (void)allUpdateReLoad {
    self.appListSyncDone = NO;
    self.configInfoSyncDone = NO;
    self.userInfoSyncDone = NO;
}

- (BOOL)needAlertUpdate:(CMPLoginAccountModel *)oldUser newUser:(CMPLoginAccountModel *)newUser {
    CMPLoginConfigInfoModel_2 *oldConfig = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:oldUser.configInfo];
    CMPLoginConfigInfoModel_2 *newConfig = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:newUser.configInfo];
    
    if ([oldUser.serverID isEqualToString:newUser.serverID] && [oldUser.userID isEqualToString:newUser.userID]
        && ![oldConfig.portal.indexAppKey isEqualToString:newConfig.portal.indexAppKey] ) {
        return NO;//如果同一用户单位切换了，则不提示改变
    }
    return YES;
}

- (void)_handleConfigInfo:(id)response responseStr:(NSString *)responseStr {
    if (!response) {
        DDLogError(@"zl---_handleConfigInfo失败,response为空");
        return;
    }
    CMPLoginAccountModel *oldUser = [CMPCore sharedInstance].currentUser;
    CMPPrivilege *oldPrivilege = [CMPPrivilegeManager getCurrentUserPrivilege];

    [self _updateAdressBookAndIndexPrivilege:response];
    CMPCore *core = [CMPCore sharedInstance];
    [core.loginDBProvider updateAccount:core.currentUser ConfigInfo:responseStr];
    [[CMPMigrateWebDataViewController shareInstance] saveConfigInfo:[response getH5CacheStr]];
    [core setup];
    
    if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
        CMPLoginConfigInfoModel_2 *model = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:responseStr];
        core.printIsOpen = model.config.printIsOpen;
        core.screenMirrorIsOpen = [model.config.allow_ScreenCast isEqualToString:@"enable"];
        //设置地图key
        CMPLocationManager.shareLocationManager.mapKey = model.config.mapKey;
    } else {
        CMPLoginConfigInfoModel *model = [CMPLoginConfigInfoModel yy_modelWithJSON:responseStr];
        core.printIsOpen = model.data.printIsOpen;
        core.screenMirrorIsOpen = [model.data.allow_ScreenCast isEqualToString:@"enable"];
    }
    
    // 判断底导航数据是否有变化，如果有刷新底导航
    CMPLoginAccountModel *currentUser = [CMPCore sharedInstance].currentUser;
    CMPPrivilege *newPrivilege = [CMPPrivilegeManager getCurrentUserPrivilege];
    
    // 更新服务器首页
    if ([CMPCore sharedInstance].serverIsLaterV7_1) {
        CMPLoginConfigInfoModel_2 *newConfig = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:currentUser.configInfo];
        NSString *defaultAppKey = newConfig.portal.indexAppKey;
        [CMPTabBarViewController setHomeTabBar:defaultAppKey];
        if (newConfig.config.canLocation) {
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (status == kCLAuthorizationStatusAuthorizedAlways||
                status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                [AppDelegate shareAppDelegate].hasCalledUpdateOnlineLngLat = YES;//标记位置已上报
                [self reportLoginLocation];//如果已同意则直接调用
            }
        }
    }
    CMPTabbarChangeType type = [self isTabBarChangeWithOldUser:oldUser newUser:currentUser];
    if (type == CMPTabbarChangeType_ChangeAll||
        (oldPrivilege.hasAddressBook != newPrivilege.hasAddressBook && !core.serverIsLaterV1_8_0)) {
        
        //V5-56775 ios端登录后切兼职单位，再杀进程登录，都会提示底导航被修改
        if ([self needAlertUpdate:oldUser newUser:currentUser]) {
            [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
                DDLogError(@"zl---[%s]，底导航数据变化", __FUNCTION__);
                UIAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:nil message:SY_STRING(@"common_reload_tabbar") cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
                    [[AppDelegate shareAppDelegate] reloadTabBar];
                    [[CMPHomeAlertManager sharedInstance] taskDone];
                }];
                [aAlertView show];
            } priority:CMPHomeAlertPriorityTabBar];
        }else{
            [[AppDelegate shareAppDelegate] reloadTabBar];
        }
    }
    else if(type == CMPTabbarChangeType_OnlyTabBar) {
        [[AppDelegate shareAppDelegate].tabBarViewController reloadTabBarIfNeed];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ConfigInfoDidUpdate object:response userInfo:@{@"result" : @YES}];
}

- (void)_handleUserInfo:(NSString *)userInfo {
    CMPLoginResponse *aLoginResponse = [CMPLoginResponse yy_modelWithJSON:userInfo];
    NSString *loginName = [CMPCore sharedInstance].currentUser.loginName;
    NSString *password = [CMPCore sharedInstance].currentUser.loginPassword;
    
    CMPLoginResponse *oldLoginResponse = [CMPLoginResponse yy_modelWithJSON:[CMPCore sharedInstance].currentUser.loginResult];
    oldLoginResponse.data.config = aLoginResponse.data.config;
    oldLoginResponse.data.currentMember = aLoginResponse.data.currentMember;
    
    [[CMPMigrateWebDataViewController shareInstance] saveLoginCache:[oldLoginResponse yy_modelToJSONString] loginName:loginName password:password serverVersion:[CMPCore sharedInstance].currentServer.serverVersion];
    
    CMPLoginResponseCurrentMember *model = oldLoginResponse.data.currentMember;
    NSString *aServerId = [CMPCore sharedInstance].serverID;
    CMPLoginAccountModel *aAccount = [[CMPCore sharedInstance].loginDBProvider accountWithServerID:aServerId userID:model.userId];
    if (!aAccount) {
        DDLogError(@"zl---[%s]:account为空，serverID:%@,userID:%@", __FUNCTION__, aServerId, model.userId);
        return;
    }
    
    // 取不到config相关信息，取之前的值
//    CMPLoginResponse *oldLoginResponse = [CMPLoginResponse yy_modelWithJSON:aAccount.loginResult];
//    aLoginResponse.data.config.allowUpdateAvatar = oldLoginResponse.data.config.allowUpdateAvatar;
//    aLoginResponse.data.config.passwordOvertime = oldLoginResponse.data.config.passwordOvertime;
//    aLoginResponse.data.config.passwordStrong = oldLoginResponse.data.config.passwordStrong;
//    aAccount.loginResult = [oldLoginResponse yy_modelToJSONString];
    
    aAccount.accountID = model.accountId;
    aAccount.departmentID = model.departmentId;
    aAccount.levelID = model.levelId;
    aAccount.postID = model.postId;
    aAccount.iconUrl = model.iconUrl;
    aAccount.extend1 = model.accShortName;
    aAccount.extend3 = model.accName;
    aAccount.departmentName = model.departmentName;
    aAccount.postName = model.postName;
    aAccount.loginResult = [oldLoginResponse yy_modelToJSONString];
    [[CMPCore sharedInstance].loginDBProvider addAccount:aAccount inUsed:YES];
    [[CMPCore sharedInstance] setup];
    [CMPCore sharedInstance].passwordChangeForce = aLoginResponse.data.config.passwordChangeForce;
    [CMPCore sharedInstance].devBindingForce = aLoginResponse.data.config.devBindingForce;
    [CMPCore sharedInstance].csrfToken = aLoginResponse.data.config.csrfToken;
}

/**
 判断底导航是否改变
 */
- (CMPTabbarChangeType)isTabBarChangeWithOldUser:(CMPLoginAccountModel *)oldUser newUser:(CMPLoginAccountModel *)newUser {
    
    CMPLoginConfigInfoModel_2 *oldConfig = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:oldUser.configInfo];
    CMPLoginConfigInfoModel_2 *newConfig = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:newUser.configInfo];
    
    BOOL result = ![oldConfig.tabBar isEqual:newConfig.tabBar];
    
    if (!result) {//如果tabbar没变，则判断expandTabbar
        if (oldConfig.portal.expandNavBar && newConfig.portal.expandNavBar) {
            result = ![oldConfig.portal.expandNavBar isEqual:newConfig.portal.expandNavBar];
        }
    }
    
    if ([CMPCore sharedInstance].serverIsLaterV7_1) {
        result = result || ![oldConfig.portal.indexAppKey isEqualToString:newConfig.portal.indexAppKey];
    }
    if (result) {
        return CMPTabbarChangeType_ChangeAll;
    }
    if ([oldConfig.tabBar needOnlyReloadTabbarItem:newConfig.tabBar]) {
        return CMPTabbarChangeType_OnlyTabBar;
    }
    return CMPTabbarChangeType_Null;
}

- (void)_handleAppList:(id)response responseStr:(NSString *)responseStr {
    if (!response) {
        DDLogError(@"zl---_handleAppList失败,response为空");
        return;
    }
    
    [UserDefaults setObject:responseStr forKey:[NSString stringWithFormat:@"CMPAppList_%@_%@", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID]];
    
    [self _updateNewColPrivilege:response];
    
    // H5用待办数据库
    CMPLoginUpdateManager *upadateManager = [[CMPLoginUpdateManager alloc] init];
    [upadateManager createTables];
    if ([response isKindOfClass:[CMPAppListModel class]]) {
        [upadateManager insertApps:response];
    }
    
    CMPCore *core = [CMPCore sharedInstance];
    [core.loginDBProvider updateAccount:core.currentUser AppList:responseStr];
    [core setup];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AppListDidUpdate object:response userInfo:@{@"result" : @YES}];
}

#pragma mark-
#pragma mark 权限更新

/**
 更新新建协同权限
 */
- (void)_updateNewColPrivilege:(id)model {
    CMPPrivilege *pr = [CMPPrivilegeManager getCurrentUserPrivilege];
    BOOL hasNewColPrivilege = [self _hasNewColPrivilege:model];
    pr.hasColNew = hasNewColPrivilege;
    [CMPPrivilegeManager setCurrentUserPrivilegeWithConfig:pr];
}

/**
 更新通讯录、全文检索权限
 */
- (void)_updateAdressBookAndIndexPrivilege:(id)model {
    BOOL hasAdressBookPrivilege;
    BOOL hasIndexPrivilege;
    
    if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
        CMPLoginConfigInfoModel_2 *aModel = (CMPLoginConfigInfoModel_2 *)model;
        hasAdressBookPrivilege = aModel.config.hasAddressBook;
        hasIndexPrivilege = aModel.config.hasIndexPlugin;
    } else {
        CMPLoginConfigInfoModel *aModel = (CMPLoginConfigInfoModel *)model;
        hasAdressBookPrivilege = aModel.data.hasAddressBook;
        hasIndexPrivilege = aModel.data.hasIndexPlugin;
    }

    CMPPrivilege *pr = [CMPPrivilegeManager getCurrentUserPrivilege];
    pr.hasAddressBook = hasAdressBookPrivilege;
    pr.hasIndexPlugin = hasIndexPrivilege;
    [CMPPrivilegeManager setCurrentUserPrivilegeWithConfig:pr];
}

/**
 判断是否有新建协同权限
 */
- (BOOL)_hasNewColPrivilege:(id)model {
    if ([model isKindOfClass:[CMPAppListModel class]]) {
        CMPAppListModel *aModel = (CMPAppListModel *)model;
        for (CMPAppListData *obj in aModel.data) {
            if ([obj.bundleName isEqualToString:@"newcoll"] &&
                [obj.isShow isEqualToString:@"1"]) {
                return YES;
            }
        }
    } else if ([model isKindOfClass:[CMPAppListModel_2 class]]) {
        CMPAppListModel_2 *aModel = (CMPAppListModel_2 *)model;
        for (CMPAppListData_2 *appListData in aModel.data) {
            for (CMPAppList_2 *appList in appListData.appList) {
                if ([appList.bundleName isEqualToString:@"newcoll"] &&
                    [appList.isShow isEqualToString:@"1"]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

#pragma mark-
#pragma mark 上报登录位置信息

- (void)reportLoginLocation {
    if (![CMPDevicePermissionHelper isHasLocationPermission]) {
        DDLogInfo(@"[%s]定位没有权限或者没有开启", __FUNCTION__);
        return;
    }
    NSLog(@"高德回调reportLoginLocation");
    //AMapLocationErrorLocateFailed
    [[CMPLocationManager shareLocationManager] getSingleLocationWithCompletionBlock:^(NSString *  _Nullable provider,AMapGeoPoint * _Nullable location, AMapReGeocode * _Nullable regeocode, NSError * _Nullable locationError, NSError * _Nullable searchError, NSError * _Nullable locationResultError) {
        if (locationError) {
            DDLogInfo(@"[%s]定位失败：%@", __FUNCTION__, locationError);
            return;
        }
        
        if (locationResultError) {
            DDLogInfo(@"[%s]定位失败：%@", __FUNCTION__, locationResultError);
            return;
        }
        
        if (searchError) {
            DDLogError(@"[%s]逆地理解析失败: %@", __FUNCTION__, searchError);
            [self reportWithReGeocode:nil location:location];
            return;
        }
        NSLog(@"高德回调");
        [self reportWithReGeocode:regeocode location:location];
    }];
}

/**
 上报位置信息
 */
- (void)reportWithReGeocode:(AMapReGeocode *)reGeocode location:(AMapGeoPoint *)location{
    if (![CMPCore isLoginState]) {
        //OA-222299 切换账号太快，前一个账号的地址还没获取到就切换了新账号，新账号还没发登陆就发请求，报错
        return;
    }
    CLLocationDegrees latitude = location.latitude;
    CLLocationDegrees longitude = location.longitude;
    NSString *rectangle = [NSString stringWithFormat:@"%f,%f;%f,%f", longitude, latitude, longitude, latitude];
    NSString *province = @"";
    NSString *city = @"";
    
    if (reGeocode) {
        AMapAddressComponent *addressComponent = reGeocode.addressComponent;
        province = addressComponent.province;
        city = addressComponent.city;
    }
    
    [self.provider reportLoginLocationWithProvice:province city:city rectangle:rectangle];
}

#pragma mark-
#pragma mark Getter

- (CMPLoginUpdateConfigProvider *)provider {
    if (!_provider) {
        _provider = [[CMPLoginUpdateConfigProvider alloc] init];
    }
    return _provider;
}

@end
