//
//  CMPSkinPlugin.m
//  M3
//
//  Created by 程昆 on 2019/12/12.
//

#import "CMPSkinPlugin.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPThemeManager.h>
#import "AppDelegate.h"

@implementation CMPSkinPlugin

- (void)setTheme:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *theme = param[@"theme"];
    if ([NSString isNull:theme]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    CMPThemeManager *themeManager = [CMPThemeManager sharedManager];
    
    if ([theme isEqualToString:@"sys"]) {
        themeManager.currentThemeInterfaceStyle = CMPThemeInterfaceStyleFillowSystem;
    }
    else if ([theme isEqualToString:@"white"]){
        themeManager.currentThemeInterfaceStyle = CMPThemeInterfaceStyleLight;
    }
    else if ([theme isEqualToString:@"black"]){
        themeManager.currentThemeInterfaceStyle = CMPThemeInterfaceStyleDark;
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    [[AppDelegate shareAppDelegate] reloadApp];
}

- (void)getTheme:(CDVInvokedUrlCommand *)command {
    NSString *currentTheme = [CMPThemeManager sharedManager].currentThemeInterfaceStyleMapValue;
    NSDictionary *dic = @{
        @"theme" : [currentTheme copy]
    };
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// 是否支持主题设置
- (void)isSupportThemeSetting:(CDVInvokedUrlCommand *)command
{
    BOOL aValue = CMPThemeManager.sharedManager.isSupportUserInterfaceStyleDark;
    // 0 无权限 1有权限
    NSDictionary *dic = @{
        @"value" : @(aValue)
    };
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
