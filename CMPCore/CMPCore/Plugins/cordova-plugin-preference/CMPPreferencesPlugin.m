//
//  CMPPreferencesPlugin.m
//  M3
//
//  Created by Kaku Songu on 5/27/21.
//

#import "CMPPreferencesPlugin.h"
#import <CMPLib/CMPCore.h>
#import "CMPPreferenceManager.h"

@implementation CMPPreferencesPlugin

- (void)put:(CDVInvokedUrlCommand *)command {

    NSDictionary *param = command.arguments.lastObject;//{name value valueType}
    if (param && [param isKindOfClass:[NSDictionary class]]) {
        
        NSString *name = param[@"name"]?:@"";
        if ([name isEqualToString:@"openGoogleMap"]) {
            NSString *value = [NSString stringWithFormat:@"%@",param[@"value"]];
            BOOL success;
            if ([value isEqualToString:@"1"]) {//open
                success = [CMPPreferenceManager setMapTypeInUse:MapTypeInUse_Google];
            }else{
                success =[CMPPreferenceManager setMapTypeInUse:MapTypeInUse_Gaode];
            }
            if (success) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }else{
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"params error"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"params error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}


- (void)get:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *param = command.arguments.lastObject;//{name value valueType}
    if (param && [param isKindOfClass:[NSDictionary class]]) {
        
        NSString *name = param[@"name"]?:@"";
        if ([name isEqualToString:@"openGoogleMap"]) {
            NSString *val;
            MapTypeInUse mapType = [CMPPreferenceManager getMapTypeInUse];
            if (mapType == MapTypeInUse_Google) {
                val = @"1";
            }else{
                val = @"0";
            }
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"value":val}];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"params error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}


@end
