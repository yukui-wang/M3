//
//  JSBridgeCommandDelegateImpl.m
//  CordovaLib
//
//  Created by CRMO on 2018/10/23.
//

#import "JSBridgeCommandDelegateImpl.h"
#import "CDVJSON_private.h"
#import "CDVCommandQueue.h"
#import "CDVPluginResult.h"
#import "CDVViewController.h"

@implementation JSBridgeCommandDelegateImpl

- (void)sendPluginResult:(CDVPluginResult*)result callbackId:(NSString*)callbackId {
    if ([@"INVALID" isEqualToString:callbackId]) {
        return;
    }

    int status = [result.status intValue];
    NSString* argumentsAsJSON = [result argumentsAsJSON];
    
    NSString *responseCode;
    if (status == 1) {
        responseCode = @"200";
    } else {
        responseCode = @"500";
    }
    
    NSDictionary *responseDic = @{@"code" : responseCode,
                                  @"data" : argumentsAsJSON};
    
    NSString *response = [responseDic cdv_JSONString];
    
    NSMutableString *mutStr = [NSMutableString stringWithString:response];
    NSRange range = {0, response.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    NSString* js = [NSString stringWithFormat:@"__CMPBridgeNativeToJS__('%@', '%@')",callbackId, mutStr];
    [super evalJsHelper:js];
}

@end
