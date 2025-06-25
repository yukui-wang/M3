//
//  CMPPlugin.m
//  CMPCore
//
//  Created by youlin on 2016/9/13.
//
//

#import "CMPShellPlugin.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import "AppDelegate.h"
#import <CMPLib/DES3Util.h>
#import "CMPCommonManager.h"
#import "CMPCustomManager.h"

@interface CMPShellPlugin() <CMPDataProviderDelegate> {
    
}

@end

@implementation CMPShellPlugin

//  获取cmp的version
- (void)version:(CDVInvokedUrlCommand*)command
{
    NSString *aClinetVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
#if CUSTOM
    NSString *str = self.webViewEngine.URL.absoluteString;
    if ([str containsString:@"/my-about.html"]) {
        aClinetVersion = [[CMPCustomManager sharedInstance].cusModel.bundleVersion stringByAppendingString:@" (定制版)"];
    }
#endif
    NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:aClinetVersion, @"value", buildVersion, @"build", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// 检查版本
- (void)checkVersion:(CDVInvokedUrlCommand*)command
{
#if CUSTOM
    [[CMPCustomManager sharedInstance] checkVersionFrom:2];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
#else
//    NSDictionary *argumentsMap = [command.arguments firstObject];
//    NSString *aUrl = [argumentsMap objectForKey:@"checkUpdateUrl"];
//    if ([NSString isNull:aUrl]) {
//        NSDictionary *error= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:4001],@"code",SY_STRING(@"url_empty"),@"message",@"",@"detail", nil];
//        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error];
//        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//        return;
//    }
//    NSString *urlStr = [CMPCommonManager checkCMPShellUpdateUrl:aUrl];
//    CMPDataRequest *aRequest = [[[CMPDataRequest alloc] init] autorelease];
//    aRequest.requestMethod = @"get";
//    aRequest.requestUrl = urlStr;
//    aRequest.delegate = self;
//    aRequest.timeout = 10;
//    aRequest.userInfo  = [NSDictionary dictionaryWithObjectsAndKeys:command.callbackId, @"callbackId", nil];
//    [[CMPDataProvider sharedInstance] addRequest:aRequest];
    // 打开App Store应用
    NSString *appstore = @"https://apps.apple.com/zm/app/m3-%E7%A7%BB%E5%8A%A8%E5%8A%9E%E5%85%AC%E5%B9%B3%E5%8F%B0/id1236176492";
    NSURL *appStoreURL = [NSURL URLWithString:appstore];
    if ([[UIApplication sharedApplication] canOpenURL:appStoreURL]) {
        [[UIApplication sharedApplication] openURL:appStoreURL options:@{} completionHandler:^(BOOL success) {
            
        }];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        NSDictionary *error= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:4001],@"code",@"请到苹果应用商店检查更新",@"message",@"",@"detail", nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
#endif
}

- (void)openDownloadUrl:(CDVInvokedUrlCommand*)command
{
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *aStr = [argumentsMap objectForKey:@"url"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:aStr]];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma -mark CMPDataProviderDelegate
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    NSString *callbackId = [aRequest.userInfo objectForKey:@"callbackId"];
    NSDictionary *aDict = [aResponse.responseStr JSONValue];
    if (!aDict) {
        NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:55], @"code", SY_STRING(@"updates_check_failed"), @"message", nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:aDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        return;
    }
    NSMutableDictionary *result = [[[NSMutableDictionary alloc] initWithDictionary:aDict] autorelease];
    NSString *downloadurl = [aDict objectForKey:@"downloadurl"];
    NSString *aStr = [DES3Util decryptDataAES128:downloadurl passwordKey:[CMPCore appDownloadUrlPwd]];
    [result setObject:aStr forKey:@"downloadurl"];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

/**
 * 2. 当请求数据出现错误时调用
 *
 * aProvider: 数据访问类
 * anError: 错误信息
 * aRequest: 请求对象
 */
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    NSString *callbackId = [aRequest.userInfo objectForKey:@"callbackId"];
    NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:error.code], @"code", SY_STRING(@"updates_check_failed"), @"message", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:aDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

/**
 * 3. 开始请求时调用
 *
 * aProvider: 数据访问类
 * aRequest: 请求对象
 */
- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest
{
    
}

@end
