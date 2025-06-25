//
//  CMPGreetingPlugin.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/9/5.
//

#import "CMPGreetingPlugin.h"
#import "CMPImpAlertManager.h"

@implementation CMPGreetingPlugin

- (void)showGreeting:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSDictionary *data = param[@"greeting"];
    if (data && [data isKindOfClass:NSDictionary.class]) {
        NSArray *datas = [NSArray arrayWithObject:data];
        [CMPImpAlertManager showMsgWithDatas:datas];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"code":@200}];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"code":@-1,@"message":@"no data"}];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

@end
