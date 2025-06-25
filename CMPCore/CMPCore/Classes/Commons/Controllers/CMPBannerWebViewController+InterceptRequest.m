//
//  CMPBannerWebViewController+InterceptRequest.m
//  M3
//
//  Created by 程昆 on 2020/4/9.
//

#import "CMPBannerWebViewController+InterceptRequest.h"

@implementation CMPBannerWebViewController (InterceptRequest)

- (BOOL)customShouldOverrideLoadWithRequest:(NSURLRequest*)request navigationType:(WKNavigationType)navigationType
{
    if ([self hanndelPayRequest:request]) {
        return NO;
    } else if ([self hanndelWeixinRequest:request]) {
        return NO;
    } else if ([self hanndelYunShanFuRequest:request]) {
        return NO;
    }
    return YES;
}

- (BOOL)hanndelPayRequest:(NSURLRequest*)request {
    NSURL *url = request.URL;
    NSArray *aStrArray = @[@"ay", @"p", @"li",@"a"];
    NSString *vaule =  [[[aStrArray reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
    NSString *vaule2 =  [vaule stringByAppendingString:@"s"];
    NSString *hostStr = [@"mclient.alip" stringByAppendingString:@"ay.com"];
    if([url.scheme isEqualToString:vaule] || [url.scheme isEqualToString:vaule2] || ([url.host.lowercaseString isEqualToString:hostStr] && [url.absoluteString containsString:@"_invoke_"])) {
        // NOTE: 跳转支付宝App
        BOOL bSucc = [[UIApplication sharedApplication] openURL:request.URL];
        if (!bSucc) {
            // 提示未安装支付宝
        }
        return YES;
    }
    return NO;
}

- (BOOL)hanndelWeixinRequest:(NSURLRequest*)request {
    NSURL *url = request.URL;
    if([url.scheme isEqualToString:@"weixin"]) {
        BOOL bSucc = [[UIApplication sharedApplication] openURL:url];
        if (!bSucc) {
            // 提示未安装微信
        }
        return YES;
    }
    return NO;
}


- (BOOL)hanndelYunShanFuRequest:(NSURLRequest*)request {
    NSURL *url = request.URL;
    if([url.scheme isEqualToString:@"uppaywallet"]) {
        BOOL bSucc = [[UIApplication sharedApplication] openURL:url];
        if (!bSucc) {
            // 提示未安装微信
        }
        return YES;
    }
    return NO;
}

@end
