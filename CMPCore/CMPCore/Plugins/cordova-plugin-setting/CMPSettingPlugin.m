//
//  CMPSettingPlugin.m
//  CMPCore
//
//  Created by wujiansheng on 2016/12/30.
//
//

#import "CMPSettingPlugin.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPConstant.h>
#import "CMPPadTabBarViewController.h"

@implementation CMPSettingPlugin

- (void)padGotoPrevious:(CDVInvokedUrlCommand*)command
{
    if (CMP_IPAD_MODE) {
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([vc isKindOfClass:CMPPadTabBarViewController.class]) {
            CMPPadTabBarViewController *tabVC = (CMPPadTabBarViewController *)vc;
            [tabVC setSelectedIndex:tabVC.lastSelectIndex];
        }
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)enterSetting:(CDVInvokedUrlCommand*)command
{
    [self openSettings];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)enterSettingDetail:(CDVInvokedUrlCommand*)command
{
    [self openSettings];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openSettings{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
