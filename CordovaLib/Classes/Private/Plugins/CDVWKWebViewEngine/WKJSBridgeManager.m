//
//  JSBridgeManager.m
//  CMPLib
//
//  Created by CRMO on 2018/10/22.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "WKJSBridgeManager.h"
#import "CDVJSON_private.h"

#import "KKJSBridgeURLRequestSerialization.h"
#import "KKWebViewCookieManager.h"

static NSString * const kJSBridgeHost = @"__jsbridge__";

@implementation WKJSBridgeManager

#pragma mark-
#pragma mark 同步调用

+ (BOOL)isSyncCommand:(NSURL *)url {
    if (!url) {
        return NO;
    }
    NSRange ns = [url.absoluteString rangeOfString:kJSBridgeHost];
    if (ns.location != NSNotFound) {
        return YES;
    }
    NSRange nn = [url.absoluteString rangeOfString:@"?bridgeid="];
    if (nn.location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (NSString *)excuteSyncCommandWithRequestBody:(id)body {
    NSDictionary *bodyDic = [body isKindOfClass:[NSString class]] ? [body cdv_JSONObject]:body;
    NSString *plugin = bodyDic[@"plugin"];
    NSString *action = bodyDic[@"action"];
    NSDictionary *param = [bodyDic[@"param"] cdv_JSONObject];
    action = [action stringByAppendingString:@":"];
    
    Class pluginClass = NSClassFromString(plugin);
    SEL sel = NSSelectorFromString(action);
    NSString *result;
    
    if ([pluginClass respondsToSelector:sel]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        result = [pluginClass performSelector:sel withObject:param];
        #pragma clang diagnostic pop
    }
    if (!result) {
        result = @"";
    }
    NSDictionary *responseDic = @{@"code" : @"200",
                                  @"data" : result};
    return [responseDic cdv_JSONString];
}

+ (BOOL)isAsyncCommand:(NSURL *)url {
    BOOL result = [[url scheme] isEqualToString:@"jsbridge"];
    return result;
}

@end
