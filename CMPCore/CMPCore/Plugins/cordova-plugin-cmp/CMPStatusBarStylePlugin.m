//
//  CMPStatusBarStylePlugin.m
//  CMPCore
//
//  Created by youlin on 2016/10/9.
//
//

#import "CMPStatusBarStylePlugin.h"
#import <CMPLib/CMPBannerWebViewController.h>

@implementation CMPStatusBarStylePlugin

- (void)setStatusBarStyle:(CDVInvokedUrlCommand *)command
{
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSInteger aStyle = [[argumentsMap objectForKey:@"statusBarStyle"] integerValue];
    UIViewController *aViewController = self.viewController;
    CDVPluginResult *pluginResult = nil;
    if ([aViewController isKindOfClass:[CMPBannerWebViewController class]]) {
        CMPBannerWebViewController *webViewController = (CMPBannerWebViewController *)aViewController;
        webViewController.statusBarStyle = aStyle;
        [webViewController setNeedsStatusBarAppearanceUpdate];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    else {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:55001], @"code",SY_STRING(@"viewController_unsupported"), @"message",@"",@"detail", nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
