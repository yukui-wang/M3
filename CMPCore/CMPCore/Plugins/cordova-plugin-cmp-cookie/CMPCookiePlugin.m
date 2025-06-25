//
//  CMPCookiePlugin.m
//  CMPCore
//
//  Created by youlin on 2016/8/22.
//
//

#import "CMPCookiePlugin.h"
#import <CMPLib/CMPCore.h>
#import <CordovaLib/KKWebViewCookieManager.h>

@implementation CMPCookiePlugin

- (void)setCookie:(CDVInvokedUrlCommand *)command
{
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *jsessionId =  [paramDict objectForKey:@"jsession"];
    if (![NSString isNull:jsessionId]) {
        [CMPCore sharedInstance].jsessionId = jsessionId;
    }
    else {
         [CMPCore sharedInstance].jsessionId = nil;
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)syncJsCookieToWebview:(CDVInvokedUrlCommand *)command
{
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *jsessionId =  [paramDict objectForKey:@"cookies"];
    [KKWebViewCookieManager syncJsCookie:jsessionId toWkWebview:(WKWebView *)self.webView result:^(BOOL success, NSError * _Nonnull err) {
        if (success) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:err?err.domain:@"unknown err"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

@end
