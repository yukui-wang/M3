//
//  RemoteNotificationPlugin.m
//  CMPCore
//
//  Created by lin on 15/10/9.
//
//

#import "PushPlugin.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/JSON.h>
#import <CMPLib/CMPCore.h>
#import "CMPCommonManager.h"
#import "CMPMessageManager.h"
#import "CMPPushConfigResponse.h"

@implementation PushPlugin

- (void)setPushConfig:(CDVInvokedUrlCommand*)command
{
    NSDictionary *paramDict = [[command arguments] lastObject];
    NSArray *keys = [paramDict allKeys];
    
    BOOL pushSoundRemind = YES;
    BOOL pushVibrationRemind = YES;
    BOOL pushAcceptInformation = YES;
    NSString *startReceiveTime = @"00:00:00";
    NSString *endReceiveTime = @"23:59:00";
    
    if ([keys containsObject:@"soundRemind"]) {
        pushSoundRemind = [[paramDict objectForKey:@"soundRemind"] boolValue];
    }
    if ([keys containsObject:@"vibrationRemind"]) {
        pushVibrationRemind = [[paramDict objectForKey:@"vibrationRemind"] boolValue];
    }
    if ([keys containsObject:@"useReceive"]) {
        pushAcceptInformation = [[paramDict objectForKey:@"useReceive"] boolValue];
    }
    if ([keys containsObject:@"startReceiveTime"]) {
        startReceiveTime = [self formatDate:[paramDict objectForKey:@"startReceiveTime"]];
    }
    if ([keys containsObject:@"endReceiveTime"]) {
        endReceiveTime = [self formatDate:[paramDict objectForKey:@"endReceiveTime"]];
    }
    
    CMPCore *core = [CMPCore sharedInstance];
    core.pushSoundRemind = pushSoundRemind;
    core.pushVibrationRemind = pushVibrationRemind;
    core.pushAcceptInformation = pushAcceptInformation;
    core.startReceiveTime = startReceiveTime;
    core.endReceiveTime = endReceiveTime;
    
    CMPPushConfigResponse *pushConfigResponse = [[CMPPushConfigResponse alloc] init];
    pushConfigResponse.ring = pushSoundRemind ? @"1" : @"0";
    pushConfigResponse.shake = pushVibrationRemind ? @"1" : @"0";
    pushConfigResponse.main = pushAcceptInformation ? @"1" : @"0";
    pushConfigResponse.startDate = startReceiveTime;
    pushConfigResponse.endDate = endReceiveTime;
    core.pushConfig = [pushConfigResponse yy_modelToJSONString];
    [pushConfigResponse release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AcceptInformationChange object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_MessageUpdate object:nil];
    
    // 低版本特殊逻辑，处理bug OA-173642
    if (![CMPCore sharedInstance].serverIsLaterV1_8_0) {
        [[CMPMessageManager sharedManager] updatePushConfig];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getPushConfig:(CDVInvokedUrlCommand *)command {
    NSString *useReceive = [CMPCore sharedInstance].pushAcceptInformation ? @"1" : @"0";
    NSString *soundRemind = [CMPCore sharedInstance].pushSoundRemind ? @"1" : @"0";
    NSString *vibrationRemind = [CMPCore sharedInstance].pushVibrationRemind ? @"1" : @"0";
    NSString *startReceiveTime = [CMPCore sharedInstance].startReceiveTime;
    NSString *endReceiveTime = [CMPCore sharedInstance].endReceiveTime;
    NSDictionary *dic = @{@"useReceive" : useReceive ,
                          @"soundRemind" : soundRemind ,
                          @"vibrationRemind" : vibrationRemind ,
                          @"startReceiveTime" : startReceiveTime ,
                          @"endReceiveTime" : endReceiveTime};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[dic yy_modelToJSONString]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 HH:mm 转 HH:mm:ss
 */
- (NSString *)formatDate:(NSString *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    NSDate *aDate = [formatter dateFromString:date];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *result = [formatter stringFromDate:aDate];
    [formatter release];
    formatter = nil;
    if ([NSString isNull:result]) {
        return date;
    }
    return result;
}

- (void)getRemoteNotificationType:(CDVInvokedUrlCommand*)command
{
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

- (void)getRemoteNotificationToken:(CDVInvokedUrlCommand *)command
{
    NSDictionary *paramDict = [[command arguments] lastObject];
    NSArray *keys = [paramDict allKeys];
    if ([keys containsObject:@"soundRemind"]) {
        [CMPCore sharedInstance].pushSoundRemind = [[paramDict objectForKey:@"soundRemind"] boolValue];
    }
    if ([keys containsObject:@"vibrationRemind"]) {
        [CMPCore sharedInstance].pushVibrationRemind = [[paramDict objectForKey:@"vibrationRemind"] boolValue];
    }
    
    NSDictionary *registInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"RemoteNotificationsDeviceToken"];
    NSString *clientProtocolType = [CMPCommonManager pushMsgClientProtocolType];
    NSArray *platforms = [NSArray arrayWithObjects:@"baidu", nil];
    NSString *aTokenId = [registInfo objectForKey:@"channel_id"];
    if (!aTokenId) {
        aTokenId = @"";
    }
    NSDictionary *tokenDict = [NSDictionary dictionaryWithObjectsAndKeys:aTokenId, @"baidu", nil];
    NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:clientProtocolType, @"clientProtocolType", platforms, @"platforms", tokenDict, @"tokens", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// 获取远程消息始终返回最新一条消息
- (void)getRemoteNotification:(CDVInvokedUrlCommand *)command
{
    NSDictionary *aDict = [[CMPCore sharedInstance].remoteNotifiData objectForKey:@"options"];
    CDVPluginResult *pluginResult = nil;
    if (aDict) {
        NSDictionary *result = aDict;
        if ([aDict isKindOfClass:[NSString class]]) {
            result = [(NSString *)aDict JSONValue];
        }
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    }
    else {
          NSDictionary *errorDict= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:32003],@"code",SY_STRING(@"parameters_error"),@"message",@"",@"detail", nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    [CMPCore sharedInstance].remoteNotifiData = nil;
}

@end
