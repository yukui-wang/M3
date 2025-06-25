//
//  TouchIDPlugin.m
//  CMPCore
//
//  Created by youlin on 16/7/14.
//
//

#import "CMPLocalAuthenticationPlugin.h"
#import "CMPLocalAuthenticationTools.h"
#import "CMPLocalAuthenticationState.h"

@implementation CMPLocalAuthenticationPlugin

- (void)verify:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [[command arguments] lastObject];
    NSString *fallbackTitle = parameter[@"callbackTitle"];
    if ([NSString isNull:fallbackTitle]) {
        fallbackTitle = @"";
    }
    [CMPLocalAuthenticationTools verifyWithFallbackTitle:fallbackTitle usePassCode:YES fallbackAction:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"code":[NSNumber numberWithInteger:CMPLocalAuthenticationErrorFallback]}];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } completion:^(BOOL result, CMPLocalAuthenticationType type, NSError * _Nullable error) {
        if (result) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"code":[NSNumber numberWithInteger:error.code]}];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)supportType:(CDVInvokedUrlCommand *)command {
    CMPLocalAuthenticationType type = [CMPLocalAuthenticationTools supportType];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:type];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setLocalAuthenticationState:(CDVInvokedUrlCommand *)command {
    NSString *parameter = [[command arguments] lastObject];
    if ([NSString isNull:parameter]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    [CMPLocalAuthenticationState updateWithJson:parameter];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getLocalAuthenticationState:(CDVInvokedUrlCommand *)command {
    NSString *state = [CMPLocalAuthenticationState stateJson];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getEnrolledState:(CDVInvokedUrlCommand *)command {
    BOOL isEnrolled = [CMPLocalAuthenticationTools isEnrolled];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:isEnrolled ? 1:0];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
