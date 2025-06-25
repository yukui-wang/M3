//
//  CMPAlbumPlugin.m
//  M3
//
//  Created by 程昆 on 2019/12/19.
//

#import "CMPUserInfoPlugin.h"
#import <CMPLib/NSString+CMPString.h>
#import "RCIM+InfoCache.h"
#import "CMPCommonManager.h"

@implementation CMPUserInfoPlugin

- (void)userInfoUpdate:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *userId = param[@"userId"];
    if ([NSString isNull:userId]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    [CMPCommonManager updateMemberIconInfoWithUserId:userId];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
