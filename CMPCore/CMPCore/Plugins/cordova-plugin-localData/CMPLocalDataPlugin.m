//
//  CMPLocalDataPlugin.m
//  CMPCore
//
//  Created by yang on 2017/2/21.
//
//

#import "CMPLocalDataPlugin.h"
#import <CMPLib/CMPObject.h>
#import <CMPLib/NSObject+Thread.h>

@implementation CMPLocalDataPlugin

- (void)write:(CDVInvokedUrlCommand*)command {
    __weak typeof(self) weakself = self;
    [self dispatchAsyncToChild:^{
        NSString *identifier = (command.arguments[0])[@"identifier"];
        id data = (command.arguments[0])[@"data"];
        BOOL isGlobal = (command.arguments[0])[@"isGlobal"];
        
        CDVPluginResult *pluginResult = nil;
        
        if ([NSString isNull:identifier] ||
            !data) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"data_fail_local")];
            [weakself.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        [CMPLocalDataPlugin writeDataWithIdentifier:identifier data:data isGlobal:isGlobal];
        pluginResult  = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [weakself.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)read:(CDVInvokedUrlCommand*)command {
    __weak typeof(self) weakself = self;
    [self dispatchAsyncToChild:^{
        NSString *identifier = (command.arguments[0])[@"identifier"];
        BOOL isGlobal = (command.arguments[0])[@"isGlobal"];
        CDVPluginResult *pluginResult = nil;
        
        if ([NSString isNull:identifier]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"data_fail_local")];
            [weakself.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        id data = [CMPLocalDataPlugin readDataWithIdentifier:identifier isGlobal:isGlobal];
        
        if([data isKindOfClass:[NSDictionary class]]){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
        }else if([data isKindOfClass:[NSArray class]]){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:data];
        }else if([data isKindOfClass:[NSString class]]){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:data];
        }else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [weakself.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)remove:(CDVInvokedUrlCommand*)command {
    __weak typeof(self) weakself = self;
    [self dispatchAsyncToChild:^{
        CDVPluginResult *pluginResult = nil;
        NSArray *identifierList = (command.arguments[0])[@"identifier"];
        BOOL isGlobal = (command.arguments[0])[@"isGlobal"];
        
        if (!identifierList ||
            ![identifierList isKindOfClass:[NSArray class]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"data_fail_local")];
            [weakself.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        for (NSString *indentifier in identifierList) {
            [CMPLocalDataPlugin removeDataWithIdentifier:indentifier isGlobal:isGlobal];
        }
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [weakself.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

+ (id)readDataWithIdentifier:(NSString *)identifier isGlobal:(BOOL)isGlobal {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[CMPLocalDataPlugin userDefaultsKeyWithIdentifier:identifier isGlobal:isGlobal]];
}

+ (void)writeDataWithIdentifier:(NSString *)identifier data:(id)data isGlobal:(BOOL)isGlobal {
    if(!data) {
        return;
    }
    
    NSString *key  = [CMPLocalDataPlugin userDefaultsKeyWithIdentifier:identifier isGlobal:isGlobal];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeDataWithIdentifier:(NSString *)identifier isGlobal:(BOOL)isGlobal {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[CMPLocalDataPlugin userDefaultsKeyWithIdentifier:identifier isGlobal:isGlobal]];
}

+ (NSString *)userDefaultsKeyWithIdentifier:(NSString *)identifier isGlobal:(BOOL)isGlobal {
    CMPCore *cmpCore = [CMPCore sharedInstance];
    NSString *userID = [cmpCore userID];
    NSString *serverID = [cmpCore serverID];
    NSString *key  = nil;
    if (isGlobal) {
        key = [NSString stringWithFormat:@"serverID_%@_cmp_localDataPlugin_%@",serverID,identifier];
    } else {
        key = [NSString stringWithFormat:@"serverID_%@_userID_%@_cmp_localDataPlugin_%@",serverID,userID,identifier];
    }
    return key;
}

@end
