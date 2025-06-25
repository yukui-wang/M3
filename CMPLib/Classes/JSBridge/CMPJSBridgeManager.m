//
//  JSBridgeManager.m
//  CMPLib
//
//  Created by CRMO on 2018/10/22.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "CMPJSBridgeManager.h"

static NSString * const kJSBridgeHost = @"__jsbridge__";

@implementation CMPJSBridgeManager

#pragma mark-
#pragma mark 同步调用

+ (BOOL)isSyncCommand:(NSURL *)url {
    NSRange ns = [url.absoluteString rangeOfString:kJSBridgeHost];
    if (ns.location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (NSData *)excuteSyncCommand:(NSURLRequest *)request {
    NSString *body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    NSDictionary *bodyDic = [body JSONValue];
    NSString *plugin = bodyDic[@"plugin"];
    NSString *action = bodyDic[@"action"];
    NSDictionary *param = [bodyDic[@"param"] JSONValue];
    action = [action stringByAppendingString:@":"];
    
    Class pluginClass = NSClassFromString(plugin);
    SEL sel = NSSelectorFromString(action);
    NSString *result;
    
    if ([pluginClass respondsToSelector:sel]) {
        result = [pluginClass performSelector:sel withObject:param];
    }
    if (!result) {
        result = @"";
    }
    NSDictionary *responseDic = @{@"code" : @"200",
                                  @"data" : result};
    NSData *responseData = [[responseDic yy_modelToJSONString] dataUsingEncoding:NSUTF8StringEncoding];
    return responseData;
}

+ (BOOL)isAsyncCommand:(NSURL *)url {
    BOOL result = [[url scheme] isEqualToString:@"jsbridge"];
    return result;
}


@end
