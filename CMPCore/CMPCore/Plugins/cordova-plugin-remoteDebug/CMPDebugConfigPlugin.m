//
//  CMPDebugConfigPlugin.m
//  M3
//
//  Created by CRMO on 2018/5/30.
//

#import "CMPDebugConfigPlugin.h"

static NSString * const kConfigStatuskey = @"CMPRemoteDebugConfigStatuskey";
static NSString * const kConfigMapkey = @"CMPRemoteDebugConfigMapkey";

@implementation CMPDebugConfigPlugin

- (void)debugSwitch:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = command.arguments[0];
    NSNumber *appID = dic[@"status"];
    [[NSUserDefaults standardUserDefaults] setObject:appID forKey:kConfigStatuskey];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getDebugConfig:(CDVInvokedUrlCommand *)command {
    NSNumber *debugStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kConfigStatuskey];
    NSDictionary *debugMap = [[NSUserDefaults standardUserDefaults] objectForKey:kConfigMapkey];
    NSNumber *mapStatus = @0;
    if (debugMap && [debugMap isKindOfClass:[NSDictionary class]]) {
        mapStatus = @1;
    }
    NSDictionary *result = @{@"isDebug" : debugStatus ?: @0,
                             @"isMapping" : mapStatus ?: @0};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)pathMapping:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = command.arguments[0];
    NSNumber *status = dic[@"status"];
    NSDictionary *config = dic[@"config"];
    
    if ([status boolValue] && config && [config isKindOfClass:[NSDictionary class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:config forKey:kConfigMapkey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kConfigMapkey];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
