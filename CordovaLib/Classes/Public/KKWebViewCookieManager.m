//
//  KKWebViewCookieManager.m
//  KKJSBridge
//
//  Created by karos li on 2019/7/29.
//  Copyright © 2019 karosli. All rights reserved.
//

#import "KKWebViewCookieManager.h"
#import <WebKit/WebKit.h>

@implementation KKWebViewCookieManager

+ (void)syncRequestCookie:(NSMutableURLRequest *)request {
    if (!request.URL) {
        return;
    }
    
    NSArray *availableCookie = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL];
    if (availableCookie.count > 0) {
        NSDictionary *reqHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookie];
        NSString *cookieStr = [reqHeader objectForKey:@"Cookie"];
        [request setValue:cookieStr forHTTPHeaderField:@"Cookie"];
    }
}

+ (void)clearWKHTTPCookieStore:(WKWebView *)WebView {
    if (@available(iOS 9.0, *)) {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeCookies]];
        [WebView.configuration.websiteDataStore removeDataOfTypes:websiteDataTypes modifiedSince:[NSDate distantPast] completionHandler:^{
            
        }];
    }
}

+ (NSString *)ajaxCookieScripts {
    NSMutableString *cookieScript = [[NSMutableString alloc] init];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        // Skip cookies that will break our script
        if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
            continue;
        }
        // Create a line that appends this cookie to the web view's document's cookies
        [cookieScript appendFormat:@"document.cookie='%@=%@;", cookie.name, cookie.value];
        if (cookie.domain || cookie.domain.length > 0) {
            [cookieScript appendFormat:@"domain=%@;", cookie.domain];
        }
        if (cookie.path || cookie.path.length > 0) {
            [cookieScript appendFormat:@"path=%@;", cookie.path];
        }
        if (cookie.expiresDate) {
            [cookieScript appendFormat:@"expires=%@;", [[self cookieDateFormatter] stringFromDate:cookie.expiresDate]];
        }
        if (cookie.secure) {
            // 只有 https 请求才能携带该 cookie
            [cookieScript appendString:@"Secure;"];
        }
        if (cookie.HTTPOnly) {
            // 保持 native 的 cookie 完整性，当 HTTPOnly 时，不能通过 document.cookie 来读取该 cookie。
            [cookieScript appendString:@"HTTPOnly;"];
        }
        [cookieScript appendFormat:@"'\n"];
    }
    
    return cookieScript;
}

+ (NSMutableURLRequest *)fixRequest:(NSURLRequest *)request {
    NSMutableURLRequest *fixedRequest;
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        fixedRequest = (NSMutableURLRequest *)request;
    } else {
        fixedRequest = request.mutableCopy;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL]) {
        NSString *value = [NSString stringWithFormat:@"%@=%@", cookie.name, cookie.value];
        [array addObject:value];
    }

    NSString *cookie = [array componentsJoinedByString:@";"];
    [fixedRequest setValue:cookie forHTTPHeaderField:@"Cookie"];
    return fixedRequest;
}

+ (void)copyNSHTTPCookieStorageToWKHTTPCookieStoreForWebViewOniOS11:(WKWebView *)webView withCompletion:(nullable void (^)(void))completion {
    if (@available(iOS 11.0, *)) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        WKHTTPCookieStore *cookieStroe = webView.configuration.websiteDataStore.httpCookieStore;
        if (cookies.count == 0) {
            completion ? completion() : nil;
            return;
        }
        for (NSHTTPCookie *cookie in cookies) {
            [cookieStroe setCookie:cookie completionHandler:^{
                if ([[cookies lastObject] isEqual:cookie]) {
                    completion ? completion() : nil;
                    return;
                }
            }];
        }
    }
}

+ (void)copyWKHTTPCookieStoreToNSHTTPCookieStorageForWebViewOniOS11:(WKWebView *)webView withCompletion:(nullable void (^)(void))completion {
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookieStroe = webView.configuration.websiteDataStore.httpCookieStore;
        [cookieStroe getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
            if (cookies.count == 0) {
                completion ? completion() : nil;
                return;
            }
            for (NSHTTPCookie *cookie in cookies) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                if ([[cookies lastObject] isEqual:cookie]) {
                    completion ? completion() : nil;
                    return;
                }
            }
        }];
    }
}

// Expires格式错误导致请求cookie重复
//+ (NSDateFormatter *)cookieDateFormatter {
//    static NSDateFormatter *formatter;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        // expires=Mon, 01 Aug 2050 06:44:35 GMT
//        formatter = [NSDateFormatter new];
//        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
//        formatter.dateFormat = @"EEE, d MMM yyyy HH:mm:ss zzz";
//    });
//
//    return formatter;
//}

+ (NSDateFormatter *)cookieDateFormatter {

    static NSDateFormatter *formatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // expires=Mon, 01 Aug 2050 06:44:35 GMT
            formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
            formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
            formatter.dateFormat = @"EEE, dd-MMM-yyyy HH:mm:ss zzz";
        });

        return formatter;
}

/**
Hook cookie 修改操作，把 WKWebView cookie 同步给 NSHTTPCookieStorage

比如：
H5 控制台执行如下语句
document.cookie='qq=55x; domain=172.16.12.72; path=/; expires=Mon, 01 Aug 2050 06:44:35 GMT; Secure'

就会触发下方方法的调用。执行完方法后，可以去查看 cookie 同步的结果：
> Python BinaryCookieReader.py ./Cookies.binarycookies
Cookie : qq=55 x; domain=172.16.12.72; path=/; expires=Mon, 01 Aug 2050; Secure

> Python BinaryCookieReader.py ./com.xxx.KKWebview.binarycookies
Cookie : qq=55 x; domain=172.16.12.72; path=/; expires=Mon, 01 Aug 2050; Secure

*/
+ (void)copyCookiebviewFromWkWebview:(NSString *)cookieString {
    if (![cookieString isKindOfClass:NSString.class] || cookieString.length == 0) {
        return;
    }
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:6];
    NSArray<NSString *> *segements = [cookieString componentsSeparatedByString:@";"];
    for (NSInteger i = 0; i < segements.count; i++) {
        NSString *seg = segements[i];
        NSString *trimSeg = [seg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        BOOL isSingleKey = NO;
        NSString *key = nil;
        NSString *value = nil;
        NSRange range = [trimSeg rangeOfString:@"="];
        if (range.location != NSNotFound) {
            key = [trimSeg substringWithRange:NSMakeRange(0, range.location)];
            value = [trimSeg substringFromIndex:range.location + 1];
        } else {
            key = trimSeg;
            isSingleKey = YES;
        }
        //NSArray<NSString *> *keyWithValues = [trimSeg componentsSeparatedByString:@"="];
        if (key.length > 0 && !isSingleKey) {
            NSString *trimKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *trimValue = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (i == 0) {
                properties[NSHTTPCookieName] = trimKey;
                properties[NSHTTPCookieValue] = trimValue;
                if ( trimValue.length == 0) {
                    //value 为空，去掉，fix学习平台
                    continue;
                }
            } else if ([trimKey isEqualToString:@"domain"]) {
                properties[NSHTTPCookieDomain] = trimValue;
            } else if ([trimKey isEqualToString:@"path"]) {
                properties[NSHTTPCookiePath] = trimValue;
            } else if ([trimKey isEqualToString:@"expires"] && trimValue.length > 0) {
                properties[NSHTTPCookieExpires] = [[KKWebViewCookieManager cookieDateFormatter] dateFromString:trimValue];;
            } else {
                // 虽然设置可能也不会生效，但是在这里做个兜底。因为必须设置 NSHTTPCookieName 这样的常量作为键，NSHTTPCookie 才能识别。
                properties[trimKey] = trimValue;
            }
        } else if (key.length > 0 && isSingleKey) {// 说明是单个 key 的属性
            NSString *trimKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([trimKey isEqualToString:@"Secure"]) {
                properties[NSHTTPCookieSecure] = @(YES);
            } else {
                // 虽然 NSHTTPCookie 不支持 HTTPOnly 属性设置，还是做个兜底设置，虽然可能也不会生效。
                properties[trimKey] = @(YES);
            }
        }
    }
    
    if (properties.count > 0) {
        NSHTTPCookie *cookieObject = [NSHTTPCookie cookieWithProperties:properties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookieObject];
    }
}


+ (void)syncJsCookie:(NSString *)cookieString toWkWebview:(WKWebView *)webView result:(void(^)(BOOL success,NSError *err))resultBlk {
    
    if (!webView) {
        if (resultBlk) {
            resultBlk(NO,[NSError errorWithDomain:@"webview nil" code:-1001 userInfo:nil]);
        }
        return;
    }
    if (@available(iOS 11.0, *)) {
        if (![cookieString isKindOfClass:NSString.class] || cookieString.length == 0) {
            if (resultBlk) {
                resultBlk(NO,[NSError errorWithDomain:@"cookie null" code:-1001 userInfo:nil]);
            }
            return;
        }
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:6];
        NSArray<NSString *> *segements = [cookieString componentsSeparatedByString:@";"];
        for (NSInteger i = 0; i < segements.count; i++) {
            NSString *seg = segements[i];
            NSString *trimSeg = [seg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            BOOL isSingleKey = NO;
            NSString *key = nil;
            NSString *value = nil;
            NSRange range = [trimSeg rangeOfString:@"="];
            if (range.location != NSNotFound) {
                key = [trimSeg substringWithRange:NSMakeRange(0, range.location)];
                value = [trimSeg substringFromIndex:range.location + 1];
            } else {
                key = trimSeg;
                isSingleKey = YES;
            }
            //NSArray<NSString *> *keyWithValues = [trimSeg componentsSeparatedByString:@"="];
            if (key.length > 0 && !isSingleKey) {
                NSString *trimKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *trimValue = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if (i == 0) {
                    properties[NSHTTPCookieName] = trimKey;
                    properties[NSHTTPCookieValue] = trimValue;
                    if ( trimValue.length == 0) {
                        //value 为空，去掉，fix学习平台
                        continue;
                    }
                } else if ([trimKey isEqualToString:@"domain"]) {
                    properties[NSHTTPCookieDomain] = trimValue;
                } else if ([trimKey isEqualToString:@"path"]) {
                    properties[NSHTTPCookiePath] = trimValue;
                } else if ([trimKey isEqualToString:@"expires"] && trimValue.length > 0) {
                    properties[NSHTTPCookieExpires] = [[KKWebViewCookieManager cookieDateFormatter] dateFromString:trimValue];;
                } else {
                    // 虽然设置可能也不会生效，但是在这里做个兜底。因为必须设置 NSHTTPCookieName 这样的常量作为键，NSHTTPCookie 才能识别。
                    properties[trimKey] = trimValue;
                }
            } else if (key.length > 0 && isSingleKey) {// 说明是单个 key 的属性
                NSString *trimKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([trimKey isEqualToString:@"Secure"]) {
                    properties[NSHTTPCookieSecure] = @(YES);
                } else {
                    // 虽然 NSHTTPCookie 不支持 HTTPOnly 属性设置，还是做个兜底设置，虽然可能也不会生效。
                    properties[trimKey] = @(YES);
                }
            }
        }
        
        if (properties.count > 0) {
            NSHTTPCookie *cookieObject = [NSHTTPCookie cookieWithProperties:properties];
            WKHTTPCookieStore *cookieStroe = webView.configuration.websiteDataStore.httpCookieStore;
            [cookieStroe setCookie:cookieObject completionHandler:^{
                if (resultBlk) {
                    resultBlk(YES,nil);
                }
            }];
        }else{
            if (resultBlk) {
                resultBlk(NO,[NSError errorWithDomain:@"cookie params count is 0" code:-1001 userInfo:nil]);
            }
        }
        
    }else{
        if (resultBlk) {
            resultBlk(NO,[NSError errorWithDomain:@"os version below 11.0" code:-1001 userInfo:nil]);
        }
    }
}

@end
