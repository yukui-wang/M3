//
//  CMPLanguageHelper.m
//  M3
//
//  Created by 程昆 on 2019/7/2.
//

#import "CMPLanguageHelper.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPDataProvider.h>
#import "M3LoginManager.h"
#import "AppDelegate.h"
#import "CMPHomeAlertManager.h"
#import "CMPLauguageProvider.h"
#import <CMPLib/SOLocalization.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPAlertView.h>
#import "CMPHomeAlertManager.h"

@implementation CMPLanguageHelper

+ (void)refreshDataAndInterfaceDidSuccess:(void(^)(void))success fail:(void(^)(NSError *error))fail {
    AppDelegate *appdelegate = [AppDelegate shareAppDelegate];
    M3LoginManager *aLoginManager = [M3LoginManager sharedInstance];
    
    [[CMPDataProvider sharedInstance] cancelAllRequestsWithCompleteBlock:^{
        appdelegate.alertGroup = nil;
    }];
    [CMPCore sharedInstance].messageIdentifier = nil;
    [aLoginManager clearRetryAppAndConfig];
    [[CMPHomeAlertManager sharedInstance] removeAllTask];
    
    [aLoginManager retryAppAndConfig:^(NSDictionary *dic) {
        if (![dic[@"appList"] boolValue] | ![dic[@"configInfo"] boolValue] | ![dic[@"userInfo"] boolValue]) {
            if (fail) {
                NSError *error = [NSError errorWithDomain:@"数据更新失败" code:5008 userInfo:nil];
                fail(error);
            }
            return;
        }
        
        if (success) {
            success();
        }
        [appdelegate reloadTabBar];
        [[CMPHomeAlertManager sharedInstance] removeAllTask];
        [[CMPHomeAlertManager sharedInstance] ready];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
    }];
}

+ (NSArray *)availableLanguageList {
    NSArray *availableLanguageList = [CMPCore sharedInstance].availableLanguageList;
    return availableLanguageList;
}

+ (void)checkAndSwichAvailableLanguage {
    if (![CMPCore sharedInstance].isSupportSwitchLanguage) {
        return;
    }
    
    AppDelegate *appdelegate = [AppDelegate shareAppDelegate];
    SOLocalization *localization = [SOLocalization sharedLocalization];
    CMPCore *core = [CMPCore sharedInstance];
    
    dispatch_group_enter(appdelegate.alertGroup);
    dispatch_group_t oldAlertGroup = appdelegate.alertGroup;
    NSLog(@"enter alertGroup 3 %p",appdelegate.alertGroup);
    
    [[[CMPLauguageProvider alloc] init] getLanguageListSuccess:^(NSArray *languageList, NSString *seccessMesssage) {
        NSArray *supportRegions = localization.supportRegions;
        NSMutableArray *availableLanguageList = [NSMutableArray array];
        __block BOOL isSupportCurrentLanguage = NO;
        NSString *serverIdRegion = [localization getRegionWithServerId:core.serverID inSupportRegions:[SOLocalization loacalSupportRegions]];
        
        [languageList enumerateObjectsUsingBlock:^(NSDictionary *languageDic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *language = languageDic[@"lang"];
            NSString *serverRegion = [localization getRegionWithServerLanguageKey:language];
            [supportRegions enumerateObjectsUsingBlock:^(NSString *region, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([serverRegion isEqualToString:region]) {
                    [availableLanguageList addObject:languageDic];
                    if ([serverRegion isEqualToString:serverIdRegion]) {
                        isSupportCurrentLanguage = YES;
                    }
                }
            }];
        }];
        
        core.availableLanguageList = [availableLanguageList copy];
        core.isSupportCurrentLanguage = isSupportCurrentLanguage;
        if (oldAlertGroup == appdelegate.alertGroup) {
            dispatch_group_leave(appdelegate.alertGroup);
            NSLog(@"leave alertGroup 3-1 %p-%p",oldAlertGroup,appdelegate.alertGroup);
        }
        
    } fail:^(NSError *failError) {
        core.isSupportCurrentLanguage = YES;
//        core.availableLanguageList = nil;
        if (oldAlertGroup == appdelegate.alertGroup) {
            dispatch_group_leave(appdelegate.alertGroup);
            NSLog(@"leave alertGroup 3-2 %p-%p",oldAlertGroup,appdelegate.alertGroup);
        }
    }];
    
    [self autoSwitchToSupportedLanguage];

}

+ (void)autoSwitchToSupportedLanguage {
    CMPCore *core = [CMPCore sharedInstance];
    SOLocalization *localization = [SOLocalization sharedLocalization];
    [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
        if (core.isSupportCurrentLanguage) {
            core.isSupportCurrentLanguage =  NO;
            [[CMPHomeAlertManager sharedInstance] taskDone];
            return;
        }
        if (core.availableLanguageList.count > 0) {
            UIAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:nil message:SY_STRING(@"common_reload_language") cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
                [self cmp_showProgressHUD];
                NSString *region = [localization getRegionWithServerLanguageKey:[[core.availableLanguageList firstObject] objectForKey:@"lang"]];
                [localization setRegion:region serverId:core.serverID];
                [self refreshDataAndInterfaceDidSuccess:^{
                    [self cmp_hideProgressHUD];
                    [[CMPHomeAlertManager sharedInstance] taskDone];
                } fail:^(NSError *error) {
                    [self cmp_hideProgressHUD];
                    [[CMPHomeAlertManager sharedInstance] taskDone];
                }];
            }];
            [aAlertView show];
        } else {
            [[CMPHomeAlertManager sharedInstance] taskDone];
        }
    } priority:CMPHomeAlertPriorityNotHaveAvailableLanguage];
}

@end
