//
//  CMPServerPlugin.m
//  CMPCore
//
//  Created by youlin on 2016/8/3.
//
//

#import "CMPServerPlugin.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPAppManager.h>
#import "CMPBackgroundRequestsManager.h"
#import "CMPContactsManager.h"
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDateHelper.h>
#import "CMPChatManager.h"
#import <CMPLib/CMPScheduleManager.h>
#import "CMPCommonManager.h"
#import "CMPMessageManager.h"
#import "AppDelegate.h"
#import "M3LoginManager.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPCookieTool.h"
#import "CMPCheckUpdateManager.h"

@interface CMPServerPlugin() <CMPDataProviderDelegate>

@property (nonatomic, copy)NSString *callbackId;
@property (nonatomic, assign) BOOL isSessionInvalid;

@end

@implementation CMPServerPlugin

// 存储server信息 for cmp 1.0.0
- (void)saveServerInfo:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//退出登录时的清空操作
- (void)clearLoginResult:(CDVInvokedUrlCommand *)command {
    
    [[M3LoginManager sharedInstance] logout];
    self.callbackId = command.callbackId;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    if (!_isSessionInvalid) {
        [[CMPCore sharedInstance].loginDBProvider clearLoginPasswordWithServerId:[CMPCore sharedInstance].serverID];
    }
    _isSessionInvalid = NO;
    [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
}

//登录失效时弹框
- (void)showSessionInvalidAlert:(CDVInvokedUrlCommand *)command {
    NSLog(@"%s",__func__);
    if (!CMPCore.isLoginState) {
        NSLog(@"已经没有session不是登录状态了，不弹");
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
        return;
    }
    
    if (![CMPCore sharedInstance].loginSuccessTime) {
        NSLog(@"当前没有登录成功时间，不弹");
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
        return;
    }
    NSTimeInterval sp = [[NSDate date] timeIntervalSinceDate:[CMPCore sharedInstance].loginSuccessTime];
    NSLog(@"请求间隔：%f",sp);
    if (sp < 2) {
        NSLog(@"当前登录成功时间间隔小于2s，不弹");
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
        return;
    }
    NSString *newssessionid = [CMPCore sharedInstance].anewSessionAfterLogin;
    NSString *cursessionid = [CMPCore sharedInstance].jsessionId;
    NSLog(@"new:%@__cur:%@",newssessionid,cursessionid);
    if ([NSString isNull:newssessionid]
        || [NSString isNull:cursessionid]
        || ![cursessionid isEqualToString:newssessionid]) {
        NSLog(@"当前session有问题，不弹");
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
        return;
    }
    
    [[M3LoginManager sharedInstance] logout];
    _isSessionInvalid = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_SessionInvalid object:nil];
    self.callbackId = command.callbackId;
    NSDictionary *aDict = [command.arguments lastObject];
    NSString *title = SY_STRING(@"common_prompt"),*message = @"",*cancelBtnTitle = SY_STRING(@"common_ok");
    if (aDict) {
        title = [aDict objectForKey:@"title"];
        message = [aDict objectForKey:@"content"];
        cancelBtnTitle = [aDict objectForKey:@"buttonTitle"];
    }
    if (![CMPCore sharedInstance].isAlertOnShowSessionInvalid) {
        NSLog(@"showing session invalid alert");
        [CMPCore sharedInstance].isAlertOnShowSessionInvalid = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_UserWillLogout object:nil];
        CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:title
                                                           message:message
                                                 cancelButtonTitle:cancelBtnTitle
                                                 otherButtonTitles:nil
                                                         callback:^(NSInteger buttonIndex)
        {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
            [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
        }];
        
        [alert show];
        return;
    }
    NSLog(@"not show session invalid alert");
}

- (void)isAssociatedServer:(CDVInvokedUrlCommand *)command {
    BOOL isAssociatedServer =  ![[CMPCore sharedInstance].currentServer isMainAssAccount];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isAssociatedServer];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)isLoginByMokey:(CDVInvokedUrlCommand *)command {
    BOOL isLoginByMokey = NO;
    CMPLoginAccountModelLoginType loginType = [CMPCore sharedInstance].currentUser.loginType;
    if (loginType == CMPLoginAccountModelLoginTypeMokey) {
        isLoginByMokey = YES;
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:isLoginByMokey ? 1 : 0];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
//获取多租户登陆的组织码
- (void)getOrgCode:(CDVInvokedUrlCommand *)command {
    NSString *orgCode = CMPCore.sharedInstance.currentServer.orgCode;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:orgCode?orgCode:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}



@end
