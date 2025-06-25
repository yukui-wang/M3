//
//  CMPTabBarViewController.m
//  CMPCore
//
//  Created by yang on 2017/2/13.
//
//


#import "CMPTabBarPlugin.h"
#import "CMPTabBarViewController.h"
#import "CMPTabBarItemAttribute.h"
#import "CMPTabBarViewController.h"
#import <CMPLib/NSObject+AutoMagicCoding.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPDBAppInfo.h>
#import "UITabBar+badge.h"
#import <CMPLib/NSString+CMPString.h>

#import "AppDelegate.h"
#import "CMPLoginConfigInfoModel.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPTabBarWebViewController.h"
#import <CMPLib/UIColor+Hex.h>

static NSString * const kCommonAppTypeDefault = @"default";
static NSString * const kCommonAppTypeWhite = @"white";

@interface CMPTabBarPlugin()
@property (nonatomic,assign) NSUInteger defaultSelectIndex;
@end

@implementation CMPTabBarPlugin
//根据菜单权限创建TaBar并显示
- (void)show:(CDVInvokedUrlCommand*)command {
    NSString *appIDs = command.arguments[0][@"appIDs"];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [self dispatchAsyncToMain:^{
        [appDelegate showTabBarWithHideAppIds:appIDs didFinished:nil];
    }];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//设置红点
- (void)setBadge:(CDVInvokedUrlCommand*)command {
    NSString *appID = command.arguments[0][@"appID"];
    BOOL show = [(command.arguments[0][@"show"]) boolValue];
    if (![appID isEqualToString:kM3AppID_Message]) {
        //消息的原生界面设置
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [self dispatchAsyncToMain:^{
            [appDelegate.tabBarViewController setTabBarBadge:appID show:show];
        }];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//设置默认首页
- (void)setDefaultIndex:(CDVInvokedUrlCommand*)command {
    NSString *appID = command.arguments[0][@"appID"];
    NSString *appKey = command.arguments[0][@"appKey"];
    [self dispatchAsyncToMain:^{
        if (appKey) {
            [CMPTabBarViewController setHomeTabBar:appKey];
        } else if (appID) {
            [CMPTabBarViewController setHomeTabBar:appID];
        }
    }];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getDefaultIndex:(CDVInvokedUrlCommand*)command {
    NSString *appID = [CMPTabBarViewController tabBarHomeKey];
    
    if ([NSString isNull:appID]) {
        appID = [[AppDelegate shareAppDelegate].tabBarViewController defaultHomeAppID];
    }
    
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];//@{@"appKey" : appID};
    resultDic[@"appKey"] = appID;
    NSString *resultStr = [resultDic yy_modelToJSONString];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:resultStr];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getPortalConfig:(CDVInvokedUrlCommand*)command {
    CMPLoginConfigInfoModel_2 *configInfo = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:[CMPCore sharedInstance].currentUser.configInfo];
    CMPLoginConfigPortalModel *portal = configInfo.portal;
    
    if (!portal) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"portal为空"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSString *portals = [@[portal] yy_modelToJSONString];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:portals];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)updatePortalConfig:(CDVInvokedUrlCommand*)command {
    NSString *portalConfig = command.arguments[0];
    if ([NSString isNull:portalConfig]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"portalConfig为空"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSArray *portals = [portalConfig JSONValue];
    if (!portals || ![portals isKindOfClass:[NSArray class]]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"portalConfig参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    CMPLoginConfigPortalModel *portal = [CMPLoginConfigPortalModel yy_modelWithDictionary:portals[0]];
    
    if (!portal) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"portal参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    // 更新底导航数据
    CMPLoginConfigInfoModel_2 *configInfo = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:[CMPCore sharedInstance].currentUser.configInfo];
    configInfo.portals = @[portal];
    configInfo.tabBar = portal.navBar;
    CMPCore *core = [CMPCore sharedInstance];
    [core.loginDBProvider updateAccount:core.currentUser ConfigInfo:[configInfo yy_modelToJSONString]];
    [core setup];
    
    // 重新加载底导航
    [[AppDelegate shareAppDelegate] reloadTabBar];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)isShowCommonAPP:(CDVInvokedUrlCommand*)command {
    CMPLoginConfigInfoModel_2 *configInfo = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:[CMPCore sharedInstance].currentUser.configInfo];
    BOOL show = configInfo.portal.isShowCommonApp;
    NSString *showStr = [NSString stringWithFormat:@"%d", show];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:showStr];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setCommonAPPColor:(CDVInvokedUrlCommand*)command {
    NSDictionary *config = [command.arguments lastObject];
    NSString *colorHex = config[@"color"];
    CDVPluginResult *pluginResult = nil;
    
    if (![self.viewController isKindOfClass:[CMPTabBarWebViewController class]]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"当前类不是CMPTabBarWebViewController"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    CMPTabBarWebViewController *tabbar = (CMPTabBarWebViewController *)self.viewController;
    UIColor *color = [UIColor colorWithHexString:colorHex];
    
    if (!color) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
    } else {
        [tabbar updateCommonAppButtonColor:color];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)hideCommonAPPBtn:(CDVInvokedUrlCommand*)command {
    NSDictionary *config = [command.arguments lastObject];
    BOOL hide = [config[@"hide"] boolValue];
    CMPTabBarWebViewController *tabbar = (CMPTabBarWebViewController *)self.viewController;
    [tabbar hideCommonAppButton:hide];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)hideBannerBackPageBtn:(CDVInvokedUrlCommand*)command {
    NSDictionary *config = [command.arguments lastObject];
    BOOL hide = [config[@"hide"] boolValue];
    CMPTabBarWebViewController *tabbar = (CMPTabBarWebViewController *)self.viewController;
    [tabbar hideBannerBackPageButton:hide];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)hideBannerFarwardPageBtn:(CDVInvokedUrlCommand*)command {
    NSDictionary *config = [command.arguments lastObject];
    BOOL hide = [config[@"hide"] boolValue];
    CMPTabBarWebViewController *tabbar = (CMPTabBarWebViewController *)self.viewController;
    [tabbar hideBannerFarwardPageButton:hide];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
