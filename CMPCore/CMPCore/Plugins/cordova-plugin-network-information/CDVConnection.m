/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVConnection.h"
#import "CMPCommonManager.h"
#import <CMPLib/CMPWiFiUtil.h>

static NSString * const kSSIDKey = @"ssid";
static NSString * const kMacKey = @"mac";
static NSString * const kIsConnectKey = @"isConnected";

@interface CDVConnection ()

@property (nonatomic, copy)NSString *getWifiInfoCallbackId;

@end

@implementation CDVConnection

static NSString *lastNetworkType;

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getConnectionInfo:(CDVInvokedUrlCommand *)command
{
    NSString *networkType = [CMPCommonManager networkType];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:networkType];
    
//    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)getNetworkStatusInfo:(CDVInvokedUrlCommand *)command
{
    NSDictionary *aValue = [CMPCommonManager networkStatusInfo];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aValue];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)getWifiInfo:(CDVInvokedUrlCommand *)command {
    // mode : 2-连续监测，1-单次监测
    NSDictionary *dictionary = [command.arguments lastObject];
    NSString *aMode = dictionary[@"mode"];
    if ([NSString isNull:aMode]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数异常"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    if ([aMode isEqualToString:@"1"]) {
        NSString *infoStr = [self getWifiInfo];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:infoStr];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    if ([aMode isEqualToString:@"2"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kNotificationName_NetworkStatusChange object:nil];
        self.getWifiInfoCallbackId = command.callbackId;
        NSString *infoStr = [self getWifiInfo];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:infoStr];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.getWifiInfoCallbackId];
    }
}

- (void)networkChanged:(NSNotification *)notification{
    NSString *aOldNetworkType = nil;
    NSDictionary *aValue = [CMPCommonManager networkStatusInfo];
    NSString *aNetworkType = aValue[@"networkType"];
    if (lastNetworkType) {
        aOldNetworkType = lastNetworkType;
    }
    if ([aNetworkType isEqualToString:aOldNetworkType]) {
        return;
    }
    NSString *infoStr = [self getWifiInfo];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:infoStr];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.getWifiInfoCallbackId];
    lastNetworkType = notification.userInfo[@"networkType"];
    
}

- (NSString *)getWifiInfo {
    NSDictionary *dic = [CMPWiFiUtil connectedWifiInfo];
    NSString *ssid = dic[CMPWiFiInfoKeySSID];
    NSString *bssid = dic[CMPWiFiInfoKeyBSSID];
    NSDictionary *infoDic = nil;
    if (ssid && bssid) {
        //22:bc:5a:9:e1:38
        infoDic = @{
                    kSSIDKey:ssid,
                    kMacKey:bssid
                    };
    } else {
        infoDic = [NSDictionary dictionary];
    }
    NSString *infoStr = [infoDic JSONRepresentation];
    return infoStr;
}

- (void)getWifiScanList:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = [CMPWiFiUtil connectedWifiInfo];
    NSString *infoStr = @"";
    if (dic) {
        NSString *ssid = dic[CMPWiFiInfoKeySSID] ?: @"";
        NSString *bssid = dic[CMPWiFiInfoKeyBSSID] ?: @"";
        NSDictionary *infoDic = @{
            kSSIDKey:ssid,
            kMacKey:bssid,
            kIsConnectKey:@(YES)
           };
        NSArray *listArr = @[infoDic];
        infoStr = [listArr JSONRepresentation];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:infoStr];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

@end
