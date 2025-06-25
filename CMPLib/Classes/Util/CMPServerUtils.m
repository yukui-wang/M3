//
//  CMPServerUtils.m
//  CMPLib
//
//  Created by youlin on 2019/8/2.
//  Copyright © 2019年 crmo. All rights reserved.
//

#import "CMPServerUtils.h"
#import "CMPCore.h"

@implementation CMPServerUtils

/**
 判断传入URL是否是当前设置服务器的请求
 */
+ (BOOL)isCurrentServer:(NSURL *)url
{
    if (!url) {
        DDLogError(@"zl---[%s]:url is nil", __FUNCTION__);
        return NO;
    }
    
    NSURLComponents *compareUrlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSString *currentServer = [CMPCore sharedInstance].serverurl;
    
    if ([NSString isNull:currentServer]) {
        DDLogError(@"zl---[%s]:currentServer is nil", __FUNCTION__);
        return NO;
    }
    
    NSURLComponents *currentServerUrlComponents = [NSURLComponents componentsWithString:currentServer];
    if (!compareUrlComponents ||
        !currentServerUrlComponents) {
        DDLogError(@"zl---[%s]:compareUrlComponents or currentServerUrlComponents is nil", __FUNCTION__);
        return NO;
    }
    
    // 兼容端口为80、443的情况
    if (!compareUrlComponents.port) {
        if ([compareUrlComponents.scheme isEqualToString:@"http"]) {
            compareUrlComponents.port = @80;
        } else if ([compareUrlComponents.scheme isEqualToString:@"https"]) {
            compareUrlComponents.port = @443;
        }
    }
    
    if ([compareUrlComponents.host.lowercaseString isEqualToString:currentServerUrlComponents.host.lowercaseString] &&
        [compareUrlComponents.port isEqual:currentServerUrlComponents.port]) {
        NSLog(@"%s:same",__func__);
        return YES;
    } else {
        NSLog(@"%s:not same",__func__);
        return NO;
    }
}

@end
