//
//  RCKitUtility+CMP.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/1/21.
//

#import "RCKitUtility+CMP.h"
#import <SafariServices/SafariServices.h>
#import <CMPLib/CMPCommonWebViewController.h>
#import <CMPLib/CMPIntercepter.h>

@implementation RCKitUtility (CMP)

+ (void)openURLInSafariViewOrWebView:(NSString *)url base:(UIViewController *)viewController {
    if (!url || url.length == 0) {
        NSLog(@"[RongIMKit] : Push to web Page url is nil");
        return;
    }
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    url = [self checkOrAppendHttpForUrl:url];
    if (![RCIM sharedRCIM].embeddedWebViewPreferred && RC_IOS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        NSURL *targetUrl = [NSURL URLWithString:url];
        if (targetUrl) {
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:targetUrl];
            safari.modalPresentationStyle = UIModalPresentationFullScreen;
            [viewController presentViewController:safari animated:YES completion:nil];
        } else {
            RCLogI(@"Push to web Page url is Invalid");
        }
    } else {
//        BOOL noIntercept = ![[CMPIntercepter sharedInstance] needIntercept:url];
        if(YES){
            [[NSNotificationCenter defaultCenter]postNotificationName:kNoInterceptJumpNotification object:viewController userInfo:@{@"url":url}];
            return;
        }

        NSInteger openact = [RCKitUtility actTypeWithUrl:url];
        if (openact == 1) {//兼容一下致信聊天中发的url因为拦截打不开的问题
            NSURL *targetUrl = [NSURL URLWithString:url];
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:targetUrl];
            safari.modalPresentationStyle = UIModalPresentationFullScreen;
            [viewController presentViewController:safari animated:YES completion:nil];
        }else{
            CMPCommonWebViewController *webview = [[CMPCommonWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
            [viewController.navigationController pushViewController:webview animated:YES];

        }
    }
}

+(NSInteger)actTypeWithUrl:(NSString *)url
{
    NSInteger act = 0;
    if (url && url.length) {
        if ([url containsString:@"cmpopac=1"] && ![url hasPrefix:@"file://"]) {
            act=1;
        }else if ([url containsString:@"cmpopac=2"]){
            act=2;
        }else if ([url containsString:@"cmpopac=3"]){
            act=3;
        }
    }
    return act;
}

@end
