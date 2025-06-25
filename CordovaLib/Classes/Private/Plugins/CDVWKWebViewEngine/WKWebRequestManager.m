//
//  WKAjaxRequestManager.m
//  CordovaLib
//
//  Created by wujiansheng on 2020/7/1.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "WKWebRequestManager.h"
#import "KKWebViewCookieManager.h"
#import <objc/message.h>
#import "WKWebThreadSafeMutableDictionary.h"
#import "WKJSBridgeManager.h"
#import "WKUserContentController+IMYHookAjax.h"
#import "WKWebRequestCacheManager.h"
#import "CDVJSON_private.h"

#define kCMPWebRequestHandleFrom_Request @"request"
#define kCMPWebRequestHandleFrom_Cache @"cache"

@interface WKWebRequestManager ()<WKWebRequestDelegate>
@property(nonatomic,strong)WKWebThreadSafeMutableDictionary *requestMap;
@property(nonatomic,strong)WKWebThreadSafeMutableDictionary *cacheResponseMap;

@end

@implementation WKWebRequestManager

static WKWebRequestManager *_requestManager;
+ (WKWebRequestManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_requestManager) {
            _requestManager = [[WKWebRequestManager alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:_requestManager selector:@selector(clearProxyJSScript) name:@"kNotificationName_UserLogout" object:nil];
        }
    });
    return _requestManager;
}

- (WKWebThreadSafeMutableDictionary *)requestMap {
    if (!_requestMap) {
        _requestMap = [[WKWebThreadSafeMutableDictionary alloc] init];
    }
    return _requestMap;
}

+ (BOOL)isWKWebSyncRequestWithBody:(NSDictionary *)body {
    if (!body) {
        return NO;
    }
    if (![body isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    if (![WKWebRequest isNullString:body[@"method"]]) {
        return YES;
    }
    return NO;
}

+ (void)wkWebRequestWithBody:(NSDictionary *)body
                     webview:(nullable WKWebView *)webview
              completedBlock:(nullable WKWebRequestCallback) completedBlock{
    NSString *method = [body[@"method"] lowercaseString];
    if ([WKWebRequest isNullString:method]) {
        if (completedBlock) {
            completedBlock(@"");
        }
        return;
    }
    WKWebRequestManager *manager = [WKWebRequestManager sharedInstance];
    NSString *action = @"requestWithBody:webview:completedBlock:";
    if ([method isEqualToString:@"cookie"] ||
        [method isEqualToString:@"abort"] ||
        [method isEqualToString:@"localstorage"]||
        [method isEqualToString:@"cookiepolicy"]||
        [method isEqualToString:@"verify"]||
        [method isEqualToString:@"conndidresp"]) {//connection:didReceiveResponse:
        action = [method stringByAppendingString:@"RequestWithBody:webview:completedBlock:"];
    }else if([method isEqualToString:@"cmpjsconsole"]){
//        NSLog(@"cmpJsConsole---%@",body);
        if (completedBlock) {
            completedBlock(@"");
        }
        return;
    }
    SEL sel = NSSelectorFromString(action);
    if (sel && [manager respondsToSelector:sel]) {
        ((void (*)(id, SEL, NSDictionary *, WKWebView *, WKWebRequestCallback))objc_msgSend)(manager,sel,body,webview,completedBlock);
    }
    else {
        NSLog(@"not found %@",method);
        if (completedBlock) {
            completedBlock(@"");
        }
    }
}

- (void)cookieRequestWithBody:(NSDictionary *)body
                      webview:(nullable WKWebView *)webview
               completedBlock:(nullable WKWebRequestCallback)completedBlock {
    NSString *requestId = body[@"id"];
    [KKWebViewCookieManager copyCookiebviewFromWkWebview:body[@"contentBody"]];
    NSString *result = [WKWebRequest callbackStringWithId:requestId httpCode:200 headers:[NSDictionary dictionary] data:@"" responseURL:@"" base64Data:nil];
    if (completedBlock) {
        completedBlock(result);
    }
}

- (void)requestWithBody:(NSDictionary *)body
                    webview:(nullable WKWebView *)webview
             completedBlock:(nullable WKWebRequestCallback)completedBlock {
    NSLog(@"postRequestWithBody :\n%@",body);
    if ([WKWebRequest isNullString:body[@"url"]]) {
        if (completedBlock) {
            completedBlock(@"");
        }
        return;
    }
    
    //ks add
    BOOL needCache = [WKWebRequestCacheManager needCache:body];
    if (needCache) {
        [[WKWebRequestCacheManager shareInstance] cacheBody:body result:^(BOOL success, NSString * _Nonnull cacheId, WKWebRequestCache * _Nonnull curCacheObj) {
            
            NSDictionary *result = @{@"cmpReqFrom":kCMPWebRequestHandleFrom_Cache,
                                     @"result":@(success)
            };
            NSString *resultStr = [result cdv_JSONString];
            
            if (completedBlock) {
                completedBlock(resultStr);
            }else{
                [WKWebRequestManager evaluateJSwithResponse:resultStr callbackID:cacheId inWebView:webview];
            }
        }];
        return;
    }
    WKWebRequest *request = [[WKWebRequest alloc] initWithBody:body webView:webview];
    request.delegate = self;
    request.completedBlock = completedBlock;
    [self.requestMap setObject:request forKey:request.callbackID];
    [request send];
}

- (void)abortRequestWithBody:(NSDictionary *)body
                     webview:(nullable WKWebView *)webview
              completedBlock:(nullable WKWebRequestCallback)completedBlock {
    //abort不回调
    NSString *requestId = body[@"id"];
    WKWebRequest *request = self.requestMap[requestId];
    [request abort];
    [self.requestMap removeObjectForKey:requestId];
    if (completedBlock) {
        completedBlock(@"");
    }
}

#pragma mark WKWebRequestDelegate

- (void)wkWebRequest:(WKWebRequest *)webRequest didCompletedWithResponse:(NSString *)response {
    NSString *callbackID = webRequest.callbackID;
    NSLog(@"ks log --- wkwebrequestmanager didCompletedWithResponse:%@,%@",webRequest.url,response);
    if (webRequest.completedBlock) {
        webRequest.completedBlock(response);
    }
    else {
        [WKWebRequestManager evaluateJSwithResponse:response callbackID:callbackID inWebView:webRequest.webView];
    }
    if (webRequest.needCacheResponse && webRequest.responseUrl) {
        if (!_cacheResponseMap) {
            self.cacheResponseMap = [[WKWebThreadSafeMutableDictionary alloc] init];
        }
        [self.cacheResponseMap setObject:webRequest.responseRecord forKey:webRequest.responseUrl];
    }
    [self.requestMap removeObjectForKey:callbackID];
}

- (void)wkWebRequest:(WKWebRequest *)webRequest uploadProgressWithResponse:(NSString *)response {
    NSString *callbackID = webRequest.callbackID;
    [WKWebRequestManager evaluateJSwithResponse:response callbackID:callbackID inWebView:webRequest.webView];
}
+ (void)evaluateJSwithResponse:(NSString *)response callbackID:(NSString *)callbackID inWebView:(WKWebView *)webView {
    if ([WKWebRequest isNullString:callbackID] || !webView) {
        return;
    }
    NSString *jsScript = [NSString stringWithFormat:@"window.%@('%@',%@);",kWKWebViewEvaluateJSMethod, callbackID, response?:@"{}"];
    NSLog(@"%s__response :\n%@",__FUNCTION__,jsScript);
    if ([[NSThread currentThread] isMainThread]) {
        [webView evaluateJavaScript:jsScript completionHandler:^(id result, NSError *error) {
        }];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [webView evaluateJavaScript:jsScript completionHandler:^(id result, NSError *error) {
            }];
        });
    }
}
+ (id)cacheResponseForUrl:(NSString *)url {
    WKWebResponseRecord *record = [[[WKWebRequestManager sharedInstance] cacheResponseMap] objectForKey:url];
    if (record) {
        [[[WKWebRequestManager sharedInstance] cacheResponseMap] removeObjectForKey:url];
        return record;
    }
    return nil;
}

-  (void)clearProxyJSScript {
    [WKUserContentController clearProxyJSScript];
}

@end

