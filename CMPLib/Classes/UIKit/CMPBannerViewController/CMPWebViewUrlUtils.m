//
//  CMPWebViewUrlUtils.m
//  CMPLib
//
//  Created by CRMO on 2018/7/17.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import "CMPWebViewUrlUtils.h"

@implementation CMPWebViewUrlUtils

+ (NSString *)handleUrl:(NSString *)url {
    if (![CMPCore sharedInstance].serverIsLaterV7_0_SP1) {
        return url;
    }
    
    NSDictionary *urlDict = [url urlPropertyValue];
    NSString *useNativeBanner = urlDict[@"useNativebanner"];
    NSString *result = url;
    
    if (!useNativeBanner) {
        result = [self _handleNativeTabbar:result];
    }
    
    return result;
}

/**
 增加原生导航栏参数
 */
+ (NSString *)_handleNativeTabbar:(NSString *)url {
    if (![CMPCore sharedInstance].serverIsLaterV7_0_SP1) {
        return url;
    }
    
    NSURL *aUrl = [NSURL URLWithString:url];
    NSString *urlPath = aUrl.host;
    NSArray *urlPathArr = [urlPath componentsSeparatedByString:@"."];
    BOOL isV5 = NO;
    BOOL isUC = NO;
    for (NSString *str in urlPathArr) {
        if ([str isEqualToString:@"v5"]) {
            isV5 = YES;
        }
        if ([str isEqualToString:@"uc"]) {
            isUC = YES;
        }
    }
    
    if (isV5 && !isUC) {
        url = [url appendHtmlUrlParam:@"useNativebanner" value:@"1"];
    }
    
    return url;
}

/**
 增加横竖屏参数
 */
+ (NSString *)_handleRotation:(NSString *)url {
    if (![CMPCore sharedInstance].serverIsLaterV7_0_SP1) {
        return url;
    }
    
    NSString *urlPath = [url urlPath];
    NSArray *urlPathArr = [urlPath componentsSeparatedByString:@"."];
    for (NSString *str in urlPathArr) {
        if ([str isEqualToString:@"m3"]) {
            url = [url appendHtmlUrlParam:@"cmp_orientation" value:@"auto"];
        }
    }
    
    return url;
}


@end
