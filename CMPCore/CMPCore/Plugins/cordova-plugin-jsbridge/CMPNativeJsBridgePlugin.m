//
//  CMPNativeJsBridgePlugin.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2021/10/19.
//

#import "CMPNativeJsBridgePlugin.h"
#import "CMPNativeToJsModelManager.h"

@implementation CMPNativeJsBridgePlugin

- (void)syncInfoToJs:(CDVInvokedUrlCommand *)command {

    NSLog(@"ks log --- syncInfoToJs begin");
    NSDictionary *param = command.arguments.lastObject;//url:string isForce:int
    NSLog(@"ks log --- syncInfoToJs param: %@",param);
    if (param && [param isKindOfClass:[NSDictionary class]]) {
        NSString *url = param[@"url"];
        NSString *isForceStr = [NSString stringWithFormat:@"%@",param[@"isForce"]];
        BOOL isForce = [isForceStr isEqualToString:@"1"];
        [[CMPNativeToJsModelManager shareManager] syncInfoToJsWithUrl:url isForce:isForce webview:nil result:^(CMPSyncDataToJsResult state, NSError * _Nonnull err) {
            NSLog(@"ks log --- syncInfoToJs 回调失败");
            if (state == CMPSyncDataToJsResultError) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:err.localizedDescription];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }else{
                NSLog(@"ks log --- syncInfoToJs 回调成功");
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:state];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }else{
        NSLog(@"ks log --- syncInfoToJs 参数错误");
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"param err"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

@end
