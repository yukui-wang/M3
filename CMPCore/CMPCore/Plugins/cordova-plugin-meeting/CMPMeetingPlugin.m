//
//  CMPMeetingPlugin.m
//  M3
//
//  Created by Kaku Songu on 11/28/22.
//

#import "CMPMeetingPlugin.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import "CMPMeetingManager.h"
#import <CMPLib/NSObject+CMPHUDView.h>

@implementation CMPMeetingPlugin

- (void)instantPersonalConfigSave:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"save success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    UIViewController *vc = self.viewController;
    if ([vc isKindOfClass:CMPBannerWebViewController.class]) {
        if (((CMPBannerWebViewController *)vc).actionBlk){
            ((CMPBannerWebViewController *)vc).actionBlk([param copy],nil,1);
        }
    }
}

- (void)instantPersonalConfigCancel:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"cancel success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    UIViewController *vc = self.viewController;
    if ([vc isKindOfClass:CMPBannerWebViewController.class]) {
        if (((CMPBannerWebViewController *)vc).actionBlk){
            ((CMPBannerWebViewController *)vc).actionBlk([param copy],nil,2);
        }
    }
}

- (void)openInstantPersonalMeeting:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *meetingNum = param[@"meetingNum"];
    NSString *meetingPassword = param[@"meetingPassword"];
    NSString *meetingUrl = param[@"meetingUrl"];
    [CMPMeetingManager otmOpenWithNumb:meetingNum pwd:meetingPassword link:meetingUrl result:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"open success"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            if (error && error.code == -104) {
                [CMPObject cmp_showHUDWithText:@"会议链接格式有误，无法打开"];
                return;
            }
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"open fail"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

@end
