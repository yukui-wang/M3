//
//  CDVWKWebView+CMP.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/7/8.
//

#import "CDVWKWebView+CMP.h"
#import <CordovaLib/KKWebViewCookieManager.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/SOSwizzle.h>

@implementation CDVWKWebView (CMP)

+ (void)load {
    SOSwizzleClassMethod([CDVWKWebView class], @selector(appendWebviewId:url:), @selector(cmpAppendWebviewId:url:));
}

+ (NSString *)cmpAppendWebviewId:(NSString *)aWebViewId  url:(NSString *)aUrl{
    NSString *aul_ = [CDVWKWebView cmpAppendWebviewId:aWebViewId url:aUrl];
    NSLog(@"ks log --- %s -- awebid:%@ \n ori url :%@",__func__,aWebViewId,aUrl);
    if (!aul_ || aul_.length == 0) {
        return @"";
    }
    if (![aul_ hasPrefix:@"file://"]) return aul_;
    NSString *tag = [CMPCore sharedInstance].localstorageTag;
    if (!tag) return aul_;
    aul_ = [CDVWKWebView urlAddCompnentForValue:tag key:@"lsn" url:aul_];
    NSLog(@"CDVWKWebView append lsn result:%@",aul_);
    return aul_;
}

- (void)hTTPCookieManagerCookiesChanged:(NSNotification *)notif {

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //ks add -- 此处为了兼容客户第三方待办问题
        NSInteger act = 0;
        if ([CMPCore sharedInstance].serverID) {
            NSString *key = [@"cmp_cookiepolicy_" stringByAppendingString:[CMPCore sharedInstance].serverID];
            NSString *val = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            if (val && val.length && [val isEqualToString:@"2"]) {
                act = 2;
            }
        }
        
        if ([[CMPCore sharedInstance].serverurl containsString:@".guorui."] || act ==2) {
            SEL selctor = NSSelectorFromString(@"syncAjaxCookie");
            if([weakSelf respondsToSelector:selctor]){
                [weakSelf performSelector:selctor];
            }
        }else{
            if (@available(iOS 11.0, *)) {
                [KKWebViewCookieManager copyNSHTTPCookieStorageToWKHTTPCookieStoreForWebViewOniOS11:weakSelf withCompletion:^{
                    
                }];
            }else{
                SEL selctor = NSSelectorFromString(@"syncAjaxCookie");
                if([weakSelf respondsToSelector:selctor]){
                    [weakSelf performSelector:selctor];
                }
            }
        }
    });
}

@end
