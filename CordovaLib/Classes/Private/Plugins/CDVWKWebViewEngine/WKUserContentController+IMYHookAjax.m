//
//  WKUserContentController+IMYHookAjax.m
//  IMYViewKit
//
//  Created by ljh on 2017/3/24.
//  Copyright © 2017年 IMY. All rights reserved.
//

#import "WKUserContentController+IMYHookAjax.h"
#import <objc/runtime.h>
#import "WKWebRequestManager.h"

@interface _IMYWKHookAjaxHandler : NSObject <WKScriptMessageHandler>
@property (nonatomic, weak) WKWebView *webView;
@end


@implementation _IMYWKHookAjaxHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    self.webView = message.webView;
    NSLog(@"_IMYWKHookAjaxHandler : %@",message.body);
    [WKWebRequestManager wkWebRequestWithBody:message.body webview:self.webView completedBlock:nil];
}


@end

@implementation WKUserContentController (IMYHookAjax)

static const void *IMYHookAjaxKey = &IMYHookAjaxKey;
- (void)imy_uninstallHookAjax
{
    BOOL installed = [objc_getAssociatedObject(self, IMYHookAjaxKey) boolValue];
    if (!installed) {
        return;
    }
    [self removeScriptMessageHandlerForName:kWKWebViewMessageHandlerName];
    objc_setAssociatedObject(self, IMYHookAjaxKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static NSString * const cmpProxyJS = @"cmp-proxy-419.js";
static NSString *_proxyJSScript = nil;
static NSString *_bundelProxyJSScript = nil;

static NSString * const cmpJs_fileName_localStorage = @"localStorage-proxy.js";
static NSString *_jsSourceForLocalStorage = nil;
static NSString *_bundelJsSourceForLocalStorage = nil;

- (void)imy_installHookAjax
{
    BOOL installed = [objc_getAssociatedObject(self, IMYHookAjaxKey) boolValue];
    if (installed) {
        return;
    }
    objc_setAssociatedObject(self, IMYHookAjaxKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    _IMYWKHookAjaxHandler *handler = [_IMYWKHookAjaxHandler new];
    [self addScriptMessageHandler:handler name:kWKWebViewMessageHandlerName];
//    [self imy_injectProxy];
//    [self imy_injectJsSourceForLocalStorage];
}

-(void)imy_injectProxy
{
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:self.proxyJSScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self addUserScript:userScript];
}

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wint-conversion"

- (NSString *)proxyJSScript {
    if (!_proxyJSScript) {
        BOOL isCanShowApp = NO;
        Class CMPCheckUpdateManager = NSClassFromString(@"CMPCheckUpdateManager");
        SEL sharedManager = NSSelectorFromString(@"sharedManager");
        SEL canShowApp = NSSelectorFromString(@"canShowApp");
        isCanShowApp  = [[CMPCheckUpdateManager performSelector:sharedManager] performSelector:canShowApp];

        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cmp/v/js/%@",cmpProxyJS]];
        Class CMPCachedUrlParser = NSClassFromString(@"CMPCachedUrlParser");
        SEL cachedPathWithUrl = NSSelectorFromString(@"cachedPathWithUrl:");
        NSString *cachedPath =  [CMPCachedUrlParser performSelector:cachedPathWithUrl withObject:url];
        cachedPath = [cachedPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        if (isCanShowApp &&cachedPath && [[NSFileManager defaultManager] fileExistsAtPath:cachedPath]) {
            NSString *jsScript = [NSString stringWithContentsOfFile:cachedPath encoding:NSUTF8StringEncoding error:nil];
            _proxyJSScript = [jsScript copy];
        }
    }
    //本地调试 注释上面的，打开下面的两种方式：
    // 部署路径：/ApacheJetspeed/webapps/seeyon/m3files/m3/cmp.zip/js    ----cmp-proxy-419.js
    //一、mac(模拟器可用)
//    NSString *cachedPath = @"/Users/shoujian/Desktop/cmp-proxy-419.js";
//    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedPath]) {
//        NSString *jsScript = [NSString stringWithContentsOfFile:cachedPath encoding:NSUTF8StringEncoding error:nil];
//        _proxyJSScript = [jsScript copy];
//    }
    
    //二、iphone真机可用（项目中的js文件）
//    NSString *cachedPath = [[NSBundle mainBundle] pathForResource:@"cmp-proxy-419" ofType:@"js"];
//    NSString *jsScript = [NSString stringWithContentsOfFile:cachedPath encoding:NSUTF8StringEncoding error:nil];
//    _proxyJSScript = [jsScript copy];
    
    if (_proxyJSScript) {
        return _proxyJSScript;
    }
    return self.bundelProxyJSScript;
}

- (NSArray *)getWhiteHost{
    
    NSString *string = self.proxyJSScript;
    NSString *startString = @"[host-begin]";
    NSString *endString = @"[host-end]";

    NSRange startRange = [string rangeOfString:startString];
    NSRange endRange = [string rangeOfString:endString];

    if (startRange.location != NSNotFound && endRange.location != NSNotFound) {
        NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
        NSString *result = [string substringWithRange:range];
        NSLog(@"%@", result);
        if(result.length){
            NSArray *arr =[result componentsSeparatedByString:@","];
            if(arr.count){
                return arr;
            }
        }
    }
    return nil;
}

//解析代理js文件中的字符串
- (NSArray *)getSubmitJumpUrl{
    
    NSString *string = self.proxyJSScript;
    NSString *startString = @"[jumpUrl-begin]";
    NSString *endString = @"[jumpUrl-end]";

    NSRange startRange = [string rangeOfString:startString];
    NSRange endRange = [string rangeOfString:endString];

    if (startRange.location != NSNotFound && endRange.location != NSNotFound) {
        NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
        NSString *result = [string substringWithRange:range];
        if(result.length){
            NSArray *arr =[result componentsSeparatedByString:@","];
            if(arr.count){
                return arr;
            }
        }
    }
    return nil;
}

#pragma clang diagnostic pop

- (NSString *)bundelProxyJSScript {
    if (!_bundelProxyJSScript) {
        NSString *path = [[NSBundle mainBundle] pathForResource:cmpProxyJS ofType:nil];
        NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        _bundelProxyJSScript = [jsScript copy];
    }
    return _bundelProxyJSScript;
}

+  (void)clearProxyJSScript {
    _proxyJSScript = nil;
}


-(void)imy_injectJsSource:(NSString *)js
{
    if (!js || !js.length) {
        return;
    }
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self addUserScript:userScript];
}


-(void)imy_injectJsSourceForLocalStorage
{
    [self imy_injectJsSource:[self jsSourceForLocalStorage]];
}


#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wint-conversion"

- (NSString *)jsSourceForLocalStorage {
    if (!_jsSourceForLocalStorage) {
        BOOL isCanShowApp = NO;
        Class CMPCheckUpdateManager = NSClassFromString(@"CMPCheckUpdateManager");
        SEL sharedManager = NSSelectorFromString(@"sharedManager");
        SEL canShowApp = NSSelectorFromString(@"canShowApp");
        isCanShowApp  = [[CMPCheckUpdateManager performSelector:sharedManager] performSelector:canShowApp];

        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cmp/v/js/%@",cmpJs_fileName_localStorage]];
        Class CMPCachedUrlParser = NSClassFromString(@"CMPCachedUrlParser");
        SEL cachedPathWithUrl = NSSelectorFromString(@"cachedPathWithUrl:");
        NSString *cachedPath =  [CMPCachedUrlParser performSelector:cachedPathWithUrl withObject:url];
        cachedPath = [cachedPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        if (isCanShowApp &&cachedPath && [[NSFileManager defaultManager] fileExistsAtPath:cachedPath]) {
            NSString *jsScript = [NSString stringWithContentsOfFile:cachedPath encoding:NSUTF8StringEncoding error:nil];
            _jsSourceForLocalStorage = [jsScript copy];
        }
        //本地调试 注释上面的，打开下面的
//        NSString *cachedPath = @"/Users/songu/Desktop/cmp-proxy-419xx.js";
//        if ([[NSFileManager defaultManager] fileExistsAtPath:cachedPath]) {
//            NSString *jsScript = [NSString stringWithContentsOfFile:cachedPath encoding:NSUTF8StringEncoding error:nil];
//            _proxyJSScript = [jsScript copy];
//        }
    }
    if (_jsSourceForLocalStorage) {
        return _jsSourceForLocalStorage;
    }
    return self.bundelJSSourceForLocalStorage;
}

#pragma clang diagnostic pop

- (NSString *)bundelJSSourceForLocalStorage {
    if (!_bundelJsSourceForLocalStorage) {
        NSString *path = [[NSBundle mainBundle] pathForResource:cmpJs_fileName_localStorage ofType:nil];
        NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        _bundelJsSourceForLocalStorage = [jsScript copy];
    }
    return _bundelJsSourceForLocalStorage;
}

+  (void)clearJSSourceForLocalStorage {
    _jsSourceForLocalStorage = nil;
}



@end
