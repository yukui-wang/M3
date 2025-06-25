//
//  CMPTransferDataPlugin.m
//  M3
//
//  Created by CRMO on 2018/10/17.
//

#import "CMPTransferDataPlugin.h"
#import <CMPLib/CMPThreadSafeMutableDictionary.h>
#import <CMPLib/NSString+CMPString.h>

/** 存放临时数据 **/
static CMPThreadSafeMutableDictionary *transferData;
static dispatch_once_t onceToken;

@implementation CMPTransferDataPlugin

- (void)pluginInitialize {
    _initTransferData();
}

- (void)getData:(CDVInvokedUrlCommand*)command {
    NSString *key = (command.arguments[0])[@"key"];
    if ([NSString isNull:key]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"key为空"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSString *data = [transferData objectForKey:key];
    if ([NSString isNull:data]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"data为空"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    [transferData removeObjectForKey:key];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:data];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

NSString* saveData(NSString *data) {
    if ([NSString isNull:data]) {
        return nil;
    }
    _initTransferData();
    NSString *key = _generateKey();
    [transferData setObject:data forKey:key];
    return key;
}

#pragma mark-
#pragma mark 私有方法

NSString* _generateKey() {
    NSInteger time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *key = [NSString stringWithInt:time];
    return key;
}

void _initTransferData() {
    dispatch_once(&onceToken, ^{
        if (!transferData) {
            transferData = [[CMPThreadSafeMutableDictionary alloc] init];
        }
    });
}

@end
