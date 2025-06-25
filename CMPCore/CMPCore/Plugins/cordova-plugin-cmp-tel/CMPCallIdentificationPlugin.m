//
//  CMPCallIdentificationPlugin.m
//  M3
//
//  Created by CRMO on 2017/11/29.
//

#import "CMPCallIdentificationPlugin.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPAlertView.h>
#import "CMPCallIdentificationHelper.h"
#import "CMPCallIdentificationGuideViewController.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/NSObject+Thread.h>

NSString * const CMPCallIdentificationPluginStateKey = @"state";

@interface CMPCallIdentificationPlugin()

@property (strong, nonatomic) CMPCallIdentificationHelper *callHelper;

@end

@implementation CMPCallIdentificationPlugin

- (void)isSupportCallIdentification:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = @{CMPCallIdentificationPluginStateKey : [NSNumber numberWithInteger:1]};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getCallIdentificationState:(CDVInvokedUrlCommand *)command {
    [self dispatchAsyncToChild:^{
        BOOL state = self.callHelper.switchState;
        NSDictionary *dic = @{CMPCallIdentificationPluginStateKey : [NSNumber numberWithBool:state]};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setCallIdentificationState:(CDVInvokedUrlCommand *)command {
    [self dispatchAsyncToChild:^{
        if (!IOS10_Later) {
            [self showAlertWithMessage:SY_STRING(@"call_identification_low_system")];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        NSDictionary *parameter = [command.arguments lastObject];
        NSNumber *state = [parameter objectForKey:CMPCallIdentificationPluginStateKey];
        
        if (!state || ![state isKindOfClass:[NSNumber class]]) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        
        __weak typeof(self) weakself = self;
        [self dispatchAsyncToMain:^{
            [weakself cmp_showProgressHUD];
        }];
        
        BOOL switchState = [state boolValue];
        [self.callHelper switchCallIdentification:switchState completion:^(BOOL result, NSError *error) {
            [self dispatchAsyncToMain:^{
                [weakself cmp_hideProgressHUD];
            }];
            
            if (result) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                if (error.code == CMPCallIdentificationPluginErrorDisabled) {
                    if (!switchState) { // 关闭时，不判断权限
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                        return;
                    } else {
                        [weakself showDisabledAlert];
                    }
                } else {
                    [weakself showAlertWithMessage:error.domain];
                }
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }];
}

#pragma mark-
#pragma mark-Private Method

- (void)showDisabledAlert {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:nil
//                                                          message:SY_STRING(@"call_identification_setting_alert")
//                                                cancelButtonTitle:SY_STRING(@"common_cancel")
//                                                otherButtonTitles:@[SY_STRING(@"call_identification_to_setting")]
//                                                         callback:^(NSInteger buttonIndex) {
//                                                             if (buttonIndex == 1) {
//                                                                 [weakself openCallSetting];
//                                                             }
//                                                         }];
//        [alert show];
//    });
    [self dispatchAsyncToMain:^{
        CMPCallIdentificationGuideViewController *vc = [[CMPCallIdentificationGuideViewController alloc] init];
        [self.viewController presentViewController:vc animated:YES completion:nil];
    }];
}

- (void)showAlertWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:nil
                                                          message:message
                                                cancelButtonTitle:SY_STRING(@"common_ok")
                                                otherButtonTitles:nil
                                                         callback:nil];
        [alert show];
    });
}

/**
 打开设置-电话
 */
- (void)openCallSetting {
    // "prefs:root="已经被列为私有API
//    NSURL *url = [NSURL URLWithString:@"App-prefs:root=Phone"];
//    if ([[UIApplication sharedApplication] canOpenURL:url]) {
//        [[UIApplication sharedApplication] openURL:url];
//    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark-
#pragma mark-Getter & Setter

- (CMPCallIdentificationHelper *)callHelper {
    if (!_callHelper) {
        _callHelper = [[CMPCallIdentificationHelper alloc] init];
    }
    return _callHelper;
}

@end
