//
//  CMPThirdAppInvoicePlugin.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/1/13.
//

#import "CMPThirdAppInvoicePlugin.h"
#import "CMPInvoiceWechatHelper.h"
#import "CMPInvoiceHelper.h"

@implementation CMPThirdAppInvoicePlugin

- (void)createCmpAccessToken:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSDictionary *result = [CMPInvoiceHelper fetchCmpNewAccessTokenByParams:param];
    if (result) {
        NSString *code = [NSString stringWithFormat:@"%@",result[@"code"]];
        if ([@"200" isEqualToString:code]) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@",result[@"message"]]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"all nil"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)getInvoiceList:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:param];
    [dic setObject:@"weixin" forKey:@"plat"];
    [CMPInvoiceHelper fetchOtherPlatformInvoiceList:dic result:^(id  _Nonnull data, NSError * _Nonnull error) {
        if (!error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"code":@(200),@"invoiceData":data?:@""}];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@",error.domain]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)decodeInvoiceData:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *acc = param[@"accessToken"];
    if (!acc || acc.length == 0) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"accessToken is null"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    NSString *invoiceData = param[@"invoiceData"];
    if (!invoiceData || invoiceData.length == 0) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invoiceData is null"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    [CMPInvoiceHelper decodeCmpInvoiceDataByParams:param result:^(id  _Nonnull data, NSError * _Nonnull error) {
        if (!error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"code":@(200),@"wxData":data}];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@",error.domain]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}


/**
 

- (void)fetchThirdAppInvoice:(CDVInvokedUrlCommand *)command {

    NSDictionary *param = command.arguments.lastObject;
    if (param) {
        NSString *platform = param[@"platform"];
        if (platform && [platform isKindOfClass:[NSString class]]) {
            if ([[platform lowercaseString] isEqualToString:@"wechat"]) {
                [[CMPInvoiceWechatHelper shareInstance] getWXInvoiceWithCompletion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                    if (!error) {
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:respData];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }else{
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                }];
            }else if ([[platform lowercaseString] isEqualToString:@"alipay"]){
                
            }
        }
    }
}

- (void)updateThirdAppInvoiceState:(CDVInvokedUrlCommand *)command {

    NSDictionary *param = command.arguments.lastObject;
    if (param) {
        NSString *platform = param[@"platform"];
        if ([platform isEqualToString:@"wechat"]) {
            [[CMPInvoiceWechatHelper shareInstance] updateWXInvoiceStateWithParams:@{} completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                if (!error) {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:respData];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }else{
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            }];
        }else if ([platform isEqualToString:@"alipay"]){
            
        }
    }
}

 */

@end
