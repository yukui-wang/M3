//
//  CMPHandleThirdApp.m
//  M3
//
//  Created by Shoujian Rao on 2022/10/21.
//

#import "CMPHandleThirdApp.h"

@implementation CMPHandleThirdApp
- (void)openThirdApp:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *url = param[@"urlScheme"];
    NSURL *thirdAppURL = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:thirdAppURL]) {
//        [[UIApplication sharedApplication] openURL:thirdAppURL];
        [[UIApplication sharedApplication] openURL:thirdAppURL options:@{} completionHandler:^(BOOL success) {
            
        }];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"code":@200}];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
//        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@",@"找不到App"]];//14001
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"code":@14001,@"message":@"找不到App"}];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}
@end
