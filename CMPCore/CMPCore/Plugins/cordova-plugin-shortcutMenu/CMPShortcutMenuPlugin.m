//
//  CMPShortcutMenuPlugin.m
//  CMPCore
//
//  Created by CRMO on 2017/8/24.
//
//

#import "CMPShortcutMenuPlugin.h"
#import "CMPMessageManager.h"
#import "CMPChatManager.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPMediator/CMPMediator+ShortcutActions.h>
#import "CMPShortcutHelper.h"

@implementation CMPShortcutMenuPlugin

- (void)show:(CDVInvokedUrlCommand *)command {
    CMPBannerWebViewController *vc = (CMPBannerWebViewController *)self.viewController;
    vc.allowRotation = NO;
    UIViewController *parentVc = vc;
    if (self.viewController.navigationController.viewControllers.lastObject == vc) {
        parentVc = [vc rdv_tabBarController];
    }
    [CMPShortcutHelper showInViewController:parentVc];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)hide:(CDVInvokedUrlCommand *)command {
    [CMPShortcutHelper hide];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
