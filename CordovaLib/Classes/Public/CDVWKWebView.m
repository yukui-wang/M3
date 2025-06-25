//
//  CDVWKWebView.m
//  CordovaLib
//
//  Created by youlin on 2018/10/25.
//

#import "CDVWKWebView.h"
#import "sys/utsname.h"
#import "KKWebViewCookieManager.h"
#import "WKWebConstant.h"
@implementation CDVWKWebView

static NSMutableDictionary *_webViewMap;
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupWebviewId];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if (self = [super initWithFrame:frame configuration:configuration]) {
        //解决webView下方出现黑条的问题
        [self setupWebviewId];
    }
    return self;
}
- (void)setupWebviewId {
    self.opaque = NO;
    //edited by He Zhonglin
    //解决webView下方出现黑条的问题
    self.opaque = NO;
    _webViewID = [[CDVWKWebView uuidString] copy];
    if (!_webViewMap) {
        _webViewMap = [[NSMutableDictionary alloc] init];
    }
    [_webViewMap setObject:self forKey:_webViewID];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hTTPCookieManagerCookiesChanged:) name:knativeCookiesChangesNotification object:nil];//暂时这样，以后改成常量
}

+ (NSString *)uuidString
{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidStrRef= CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    NSString * retStr = [NSString stringWithString:(__bridge NSString *)uuidStrRef];
    CFRelease(uuidStrRef);
    return retStr;
}

+ (CDVWKWebView *)webViewWithID:(NSString *)aWebViewID
{
    return [_webViewMap objectForKey:aWebViewID];
}

+ (void)remove:(NSString *)aWebViewID
{
    WKWebView *webView = [_webViewMap objectForKey:aWebViewID];
    [webView.configuration.userContentController removeAllUserScripts];
    [webView.configuration.userContentController removeScriptMessageHandlerForName:kWKWebViewMessageHandlerName];
    [webView.configuration.userContentController removeScriptMessageHandlerForName:CDV_BRIDGE_NAME];
    [webView.configuration.userContentController removeScriptMessageHandlerForName:kCMPBridgeName];
    [_webViewMap removeObjectForKey:aWebViewID];
    [[NSNotificationCenter defaultCenter]removeObserver:webView];
    
}

- (nullable WKNavigation *)loadRequest:(NSURLRequest *)request
{
    //BUG_紧急_OS_湖北日报传媒集团（湖北日报社）_V8.0sp1_移动端门户空间、配置第三方链接之后、如果一个链接访问之后为空白页、之后的所有链接访问都为空白页_BUG2021020132413
    //会导致有过期时间的cookie丢失
    //[KKWebViewCookieManager clearWKHTTPCookieStore:self];
    NSURLRequest *mRequest = request;
    NSString *aUrl = mRequest.URL.absoluteString;
    if ([aUrl containsString:@"formtalk.net/pub.do"]) { //拦截formtalk-意见反馈链接-替换企业版的url;直接替换是为了兼容老版本
        aUrl = @"https://pro.formtalk.net/form/bizFormData.do?method=index&formId=F16509525326760000720000&rightId=6267898f6964727df941a14a&ours_as=c8f4296d0cb32cc40b8b814986185a639abd3d0e&viewType=NEW&ours_params=F0A4E31B34439EF36C9670AC944227148053882FC3955B1B32E0CA89018732864E56CB9B96B41D354ED334414DA64237F072795F9FCC40C7549232EC62B5FB2F7771823921405E50B677A22F1AE5443C9ADAA38E2E9A57DF403F49302C19C2DFEDC5609E259C26E3";
    }
    if ([aUrl rangeOfString:@"webviewId"].length > 0) {
    }
    else {
        aUrl = [CDVWKWebView appendWebviewId:_webViewID url:aUrl];
        NSLog(@"ks log --- result url : %@",aUrl);
        mRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:aUrl]];
    }
    // 同步cookie
    //[self syncAjaxCookie];
    NSMutableURLRequest *requestWithCookie = mRequest.mutableCopy;
    //[KKWebViewCookieManager syncRequestCookie:requestWithCookie];
    mRequest = requestWithCookie;
    return [super loadRequest:mRequest];
}

- (WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL
{
    NSString *aUrl = URL.absoluteString;
    if ([aUrl rangeOfString:@"webviewId"].length > 0) {
        NSLog(@"ks log --- CDVWKWebview loadFileURL : %@",aUrl);
        return [super loadFileURL:URL allowingReadAccessToURL:readAccessURL];
    }
    if (!_webViewID) {
        _webViewID = [[CDVWKWebView uuidString] copy];
        if (!_webViewMap) {
            _webViewMap = [[NSMutableDictionary alloc] init];
        }
        [_webViewMap setObject:self forKey:_webViewID];
    }
    aUrl = [CDVWKWebView appendWebviewId:_webViewID url:aUrl];
    NSLog(@"ks log --- result url : %@",aUrl);
    URL = [NSURL URLWithString:aUrl];
    
    NSURL *bundleURL = [NSBundle mainBundle].bundleURL;
    if ([aUrl hasPrefix:bundleURL.absoluteString]) {
        readAccessURL = bundleURL;
    } else {
        NSURL *accessURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
//        NSString *readAccessPath = NSHomeDirectory();
        readAccessURL = accessURL;//[NSURL fileURLWithPath:readAccessPath];
//        readAccessURL = [NSURL fileURLWithPath:@"/Users"]; // 开启本地代码调试
    }
    NSLog(@"ks log --- CDVWKWebview loadFileURL : %@",aUrl);
    return [super loadFileURL:URL allowingReadAccessToURL:readAccessURL];
}

+ (NSString *)appendWebviewId:(NSString *)aWebViewId  url:(NSString *)aUrl
{
    NSLog(@"ks log --- %s -- awebid:%@ \n ori url :%@",__func__,aWebViewId,aUrl);
    if (!aUrl || aUrl.length == 0) {
        return @"";
    }
    if ([aUrl rangeOfString:@"webviewId"].length > 0) {
        return aUrl;
    }
    //ks fix -- 20220830 解决前端框架不规则的#路由和#锚导致的参数拼接错误解析失败问题
    //先判断有无#
    //无#，正常拼接
    //有#，一种是路由。 一种是猫，怎么截取需要拼参数的baseurl
    //判断有无？
    //有则以？截取baseurl，判断后半段首位是否
    //无？，判断#位置， #前一位是/为路由，不是/为锚
    //如果有锚，则截取锚点前面的为baseurl
    //无锚，则正常拼接
    
    NSString *aBaseUrl;
    NSRange jinghaoRange = [aUrl rangeOfString:@"#"];
    if (jinghaoRange.location == NSNotFound) {
        aBaseUrl = aUrl;
        NSMutableString *mUrl = [NSMutableString stringWithString:aBaseUrl];
        mUrl = [NSMutableString stringWithString:[CDVWKWebView urlAddCompnentForValue:aWebViewId key:@"webviewId" url:mUrl]];
        return mUrl;
    }
    NSRange wenhaoRange = [aUrl rangeOfString:@"?"];
    if (wenhaoRange.location != NSNotFound) {
        aBaseUrl = [aUrl substringToIndex:wenhaoRange.location+1];//加上?
        NSMutableString *mUrl = [NSMutableString stringWithString:aBaseUrl];
        mUrl = [NSMutableString stringWithString:[CDVWKWebView urlAddCompnentForValue:aWebViewId key:@"webviewId" url:mUrl]];
        NSString *lastStr = [aUrl substringFromIndex:wenhaoRange.location+1];//?后
        if (lastStr && lastStr.length) {//有无query和fragment
            NSString *str1 = lastStr, *str2 = @"";
            NSRange ran1 = [lastStr rangeOfString:@"#"];
            if (ran1.location != NSNotFound) {
                str1 = [lastStr substringToIndex:ran1.location];
                str2 = [lastStr substringFromIndex:ran1.location];
            }
            if (str1.length && [str1 containsString:@"="]) {
                str1 = [str1 hasPrefix:@"&"] ? str1 : [@"&" stringByAppendingString:str1];
            }
            [mUrl appendFormat:@"%@%@",str1,str2];
        }
        return mUrl;
    }
    if (![aUrl containsString:@"/#"]) {
        NSArray *paramList = [aUrl componentsSeparatedByString:@"#"];
        aBaseUrl = paramList.firstObject;
        NSMutableString *mUrl = [NSMutableString stringWithString:aBaseUrl];
        mUrl = [NSMutableString stringWithString:[CDVWKWebView urlAddCompnentForValue:aWebViewId key:@"webviewId" url:mUrl]];
        // add for #
        if (paramList.count == 2) {
            [mUrl appendString:@"#"];
            [mUrl appendString:[paramList lastObject]];
        }
        return mUrl;
    }
    
    //有路由。有或无锚点。无？ xxxx/#/xxx/#/xxx#xxxx
    NSInteger tempLength = 0;
    NSString *sss = aUrl;
    BOOL _goon = YES;
    while (_goon && sss && [sss containsString:@"#"]) {
        NSRange r = [sss rangeOfString:@"#"];
        NSString *str1 = [sss substringToIndex:r.location];
        NSString *str2 = [sss substringFromIndex:r.location+1];
        if (str1 && ![str1 hasSuffix:@"/"]) {
            _goon = NO;
            tempLength += str1.length;
        }else{
            _goon = YES;
            tempLength += str1.length + 1;
        }
        sss = str2;
    }
    NSInteger desIndex = _goon ? aUrl.length+1 : tempLength;
    if (aUrl.length-1>=desIndex) {
        aBaseUrl = [aUrl substringToIndex:desIndex];
        NSMutableString *mUrl = [NSMutableString stringWithString:aBaseUrl];
        mUrl = [NSMutableString stringWithString:[CDVWKWebView urlAddCompnentForValue:aWebViewId key:@"webviewId" url:mUrl]];
        NSString *lastStr = [aUrl substringFromIndex:desIndex];
        if (lastStr) {
            [mUrl appendString:lastStr];
        }
        return mUrl;
    }
    
    aBaseUrl = aUrl;
    NSMutableString *mUrl = [NSMutableString stringWithString:aBaseUrl];
    mUrl = [NSMutableString stringWithString:[CDVWKWebView urlAddCompnentForValue:aWebViewId key:@"webviewId" url:mUrl]];
    return mUrl;
    //ks end
    
    //底下的为原有方法
    
//    if ([aUrl rangeOfString:@"webviewId"].length > 0) {
//        return aUrl;
//    }
//    NSArray *paramList = [aUrl componentsSeparatedByString:@"#"];
//    NSString *aBaseUrl = [paramList objectAtIndex:0];
//    NSMutableString *mUrl = [NSMutableString stringWithString:aBaseUrl];
//    if ([mUrl rangeOfString:@"?"].length > 0) {
//        [mUrl appendFormat:@"&webviewId=%@", aWebViewId];
//    }
//    else {
//        [mUrl appendFormat:@"?webviewId=%@", aWebViewId];
//    }
//    // add for #
//    if (paramList.count == 2) {
//        [mUrl appendString:@"#"];
//        [mUrl appendString:[paramList lastObject]];
//    }
//    return mUrl;
}

+(NSString *)urlAddCompnentForValue:(NSString *)value key:(NSString *)key   url:(NSString *)aUrl{
    
    NSMutableString *string = [[NSMutableString alloc]initWithString:aUrl];
    @try {
        NSRange range = [string rangeOfString:@"?"];
        if (range.location != NSNotFound) {//找到了
            //如果?是最后一个直接拼接参数
            if (string.length == (range.location + range.length)) {
                NSLog(@"最后一个是?");
                string = (NSMutableString *)[string stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,value]];
            }else{//如果不是最后一个需要加&
                if([string hasSuffix:@"&"]){//如果最后一个是&,直接拼接
                    string = (NSMutableString *)[string stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,value]];
                }else{//如果最后不是&,需要加&后拼接
                    string = (NSMutableString *)[string stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",key,value]];
                }
            }
        }else{//没找到
            if([string hasSuffix:@"&"]){//如果最后一个是&,去掉&后拼接
                string = (NSMutableString *)[string substringToIndex:string.length-1];
            }
            string = (NSMutableString *)[string stringByAppendingString:[NSString stringWithFormat:@"?%@=%@",key,value]];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    
    return string.copy;
}

/**
 【COOKIE 2】为异步 ajax 请求同步 cookie
 */
- (void)syncAjaxCookie {
    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:[KKWebViewCookieManager ajaxCookieScripts] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.configuration.userContentController addUserScript:cookieScript];
}

- (void)hTTPCookieManagerCookiesChanged:(NSNotification *)notif {
//    NSString *webviewId = notif.object;
//    if ([webviewId isEqualToString:self.webViewID]) {
//        __weak typeof(self) weakSelf = self;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf syncAjaxCookie];
//        });
//    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 11.0, *)) {
            [KKWebViewCookieManager copyNSHTTPCookieStorageToWKHTTPCookieStoreForWebViewOniOS11:weakSelf withCompletion:^{
                
            }];
        }else{
            [weakSelf syncAjaxCookie];
        }
    });
}

@end
