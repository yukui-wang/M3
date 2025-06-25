//
//  RemoteNotificationPlugin.m
//  CMPCore
//
//  Created by lin on 15/10/9.
//
//

#import "RemoteNotificationPlugin.h"

@implementation RemoteNotificationPlugin

-(void)getRemoteNotificationType:(CDVInvokedUrlCommand*)command{
    BOOL  isEnable = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationSettings *notiSetting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (notiSetting.types != UIUserNotificationTypeNone) {
            isEnable = YES;
        }
    }else{
        UIRemoteNotificationType type = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
        if (type != UIRemoteNotificationTypeNone) {
            isEnable = YES;
        }
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isEnable];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
