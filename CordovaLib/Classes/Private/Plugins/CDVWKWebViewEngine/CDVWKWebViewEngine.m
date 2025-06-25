/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVWKWebViewEngine.h"
#import "CDVWKWebViewUIDelegate.h"
#import "CDVWKProcessPoolFactory.h"
#import <CordovaLib/NSDictionary+CordovaPreferences.h>

#import <objc/message.h>
#import "WKUserContentController+IMYHookAjax.h"
#import "CDVWKWebView.h"
#import "KKWebViewCookieManager.h"
#import "WKWebConstant.h"
#define CDV_WKWEBVIEW_FILE_URL_LOAD_SELECTOR @"loadFileURL:allowingReadAccessToURL:"


@interface CDVWKWebViewEngine ()<UIDocumentInteractionControllerDelegate>


@property (nonatomic, strong, readwrite) id <WKUIDelegate,WKNavigationDelegate> uiDelegate;
@property (nonatomic, weak) id <WKScriptMessageHandler> weakScriptMessageHandler;

@property (nonatomic, strong) NSArray *jumpUrlInterceptArr;//拦截跳转的url

@property (nonatomic,strong) UIDocumentInteractionController *documentInteractionController;

@end

// see forwardingTargetForSelector: selector comment for the reason for this pragma
#pragma clang diagnostic ignored "-Wprotocol"

@implementation CDVWKWebViewEngine

@synthesize engineWebView = _engineWebView;

- (void)dealloc
{
    // add by guoyl
    if ([_engineWebView isKindOfClass:[CDVWKWebView class]]) {
        CDVWKWebView *aWebView = (CDVWKWebView *)_engineWebView;
        if (aWebView.webViewID) {
            [CDVWKWebView remove:aWebView.webViewID];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        if (NSClassFromString(@"WKWebView") == nil) {
            return nil;
        }
        NSDictionary* settings = self.commandDelegate.settings;
        self.uiDelegate = [[CDVWKWebViewUIDelegate alloc] initWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];

        CDVWKWeakScriptMessageHandler *weakScriptMessageHandler = [[CDVWKWeakScriptMessageHandler alloc] initWithScriptMessageHandler:self];

        WKUserContentController* userContentController = [[WKUserContentController alloc] init];
        [userContentController addScriptMessageHandler:weakScriptMessageHandler name:CDV_BRIDGE_NAME];
        [userContentController addScriptMessageHandler:weakScriptMessageHandler name:kCMPBridgeName];
        [userContentController imy_installHookAjax];
        [userContentController imy_injectProxy];
        [userContentController imy_injectJsSourceForLocalStorage];
        
        WKWebViewConfiguration* configuration = [self createConfigurationFromSettings:settings];
        configuration.userContentController = userContentController;

        // re-create WKWebView, since we need to update configuration
        WKWebView* wkWebView = [[CDVWKWebView alloc] initWithFrame:frame configuration:configuration];
        wkWebView.UIDelegate = self.uiDelegate;
        wkWebView.navigationDelegate = self.uiDelegate;
        wkWebView.scrollView.showsVerticalScrollIndicator = NO;
        
        self.engineWebView = wkWebView;
        if (@available(iOS 16.4, *)) {
            wkWebView.inspectable = YES;
        } else {
            // Fallback on earlier versions
        }
    }

    return self;
}

- (WKWebViewConfiguration*) createConfigurationFromSettings:(NSDictionary*)settings
{
    WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
    configuration.processPool = [[CDVWKProcessPoolFactory sharedFactory] sharedProcessPool];
//    [configuration.preferences setValue:@"TRUE" forKey:@"allowFileAccessFromFileURLs"];
//    configuration.preferences.javaScriptEnabled = YES;
//    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
//    configuration.suppressesIncrementalRendering = YES; // 是否支持记忆读取
    [configuration.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
    if (@available(iOS 10.0,*) ) {
        //ios9。3.5 crash; ios10.3.1模拟器测试正常
        [configuration setValue:@YES forKey:@"_allowUniversalAccessFromFileURLs"];
    }
    configuration.allowsInlineMediaPlayback = YES;//默认视频在线播放
//    [configuration setValue:@YES forKey:@"_allowUniversalAccessFromFileURLs"];
    
    //ks log --- !!! 此处是将浏览器的默认模式设置为移动端，不然高版本的ipad默认是桌面模式会导致h5页面os.platform判断错误而加载报错
    if (@available(iOS 13.0, *)) {
       configuration.defaultWebpagePreferences.preferredContentMode = WKContentModeMobile;
    }
    
    if (settings == nil) {
        return configuration;
    }

    configuration.allowsInlineMediaPlayback = [settings cordovaBoolSettingForKey:@"AllowInlineMediaPlayback" defaultValue:YES];
    configuration.mediaPlaybackRequiresUserAction = [settings cordovaBoolSettingForKey:@"MediaPlaybackRequiresUserAction" defaultValue:YES];
    configuration.suppressesIncrementalRendering = [settings cordovaBoolSettingForKey:@"SuppressesIncrementalRendering" defaultValue:NO];
    configuration.mediaPlaybackAllowsAirPlay = [settings cordovaBoolSettingForKey:@"MediaPlaybackAllowsAirPlay" defaultValue:YES];
    return configuration;
}

- (void)pluginInitialize
{
    // viewController would be available now. we attempt to set all possible delegates to it, by default
    NSDictionary* settings = self.commandDelegate.settings;
/*
    self.uiDelegate = [[CDVWKWebViewUIDelegate alloc] initWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];

    CDVWKWeakScriptMessageHandler *weakScriptMessageHandler = [[CDVWKWeakScriptMessageHandler alloc] initWithScriptMessageHandler:self];

    WKUserContentController* userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:weakScriptMessageHandler name:CDV_BRIDGE_NAME];
    [userContentController addScriptMessageHandler:weakScriptMessageHandler name:kCMPBridgeName];
    [userContentController imy_installHookAjax];

    WKWebViewConfiguration* configuration = [self createConfigurationFromSettings:settings];
    configuration.userContentController = userContentController;

    // re-create WKWebView, since we need to update configuration
    WKWebView* wkWebView = [[CDVWKWebView alloc] initWithFrame:self.engineWebView.frame configuration:configuration];
    wkWebView.UIDelegate = self.uiDelegate;
    wkWebView.navigationDelegate = self.uiDelegate;
    self.engineWebView = wkWebView;
*/
    WKWebView* wkWebView = self.engineWebView;
    
    if (IsAtLeastiOSVersion(@"9.0") && [self.viewController isKindOfClass:[CDVViewController class]]) {
        wkWebView.customUserAgent = ((CDVViewController*) self.viewController).userAgent;
    }

    if ([self.viewController conformsToProtocol:@protocol(WKUIDelegate)]) {
        wkWebView.UIDelegate = (id <WKUIDelegate>)self.viewController;
    }

    if ([self.viewController conformsToProtocol:@protocol(WKNavigationDelegate)]) {
        wkWebView.navigationDelegate = (id <WKNavigationDelegate>)self.viewController;
    } else {
        wkWebView.navigationDelegate = (id <WKNavigationDelegate>)self;
    }

    if ([self.viewController conformsToProtocol:@protocol(WKScriptMessageHandler)]) {
        [wkWebView.configuration.userContentController addScriptMessageHandler:(id < WKScriptMessageHandler >)self.viewController name:CDV_BRIDGE_NAME];
    }

    [self updateSettings:settings];

    // check if content thread has died on resume
    NSLog(@"%@", @"CDVWKWebViewEngine will reload WKWebView if required on resume");
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(onAppWillEnterForeground:)
               name:UIApplicationWillEnterForegroundNotification object:nil];

    NSLog(@"Using WKWebView");

    [self addURLObserver];
}

//此方法在iOS8上面不执行，也就是iOS8目前不能加载不受信任的HTTPS（我目前知道的）
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

- (void)evaluateJavaScript:(NSString*)javaScriptString completionHandler:(void (^)(id, NSError*))completionHandler
{
    // 修复行分隔符、段落分隔符导致的JS语法错误SyntaxError: Unexpected EOF
    javaScriptString = [javaScriptString stringByReplacingOccurrencesOfString:@"\u2028" withString:@""];
    javaScriptString = [javaScriptString stringByReplacingOccurrencesOfString:@"\u2029" withString:@""];
    
    [(WKWebView *)_engineWebView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(ret, error);
        }
    }];

    
}

- (void)onReset {
    [self addURLObserver];
}

static void * KVOContext = &KVOContext;

- (void)addURLObserver {
    if(!IsAtLeastiOSVersion(@"9.0")){
        [self.webView addObserver:self forKeyPath:@"URL" options:0 context:KVOContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == KVOContext) {
        if (object == [self webView] && [keyPath isEqualToString: @"URL"] && [object valueForKeyPath:keyPath] == nil){
            NSLog(@"URL is nil. Reloading WKWebView");
            [(WKWebView*)_engineWebView reload];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void) onAppWillEnterForeground:(NSNotification*)notification {
    if ([self shouldReloadWebView]) {
        NSLog(@"%@", @"CDVWKWebViewEngine reloading!");
        [(WKWebView*)_engineWebView reload];
    }
}

- (BOOL)shouldReloadWebView
{
    WKWebView* wkWebView = (WKWebView*)_engineWebView;
    return [self shouldReloadWebView:wkWebView.URL title:wkWebView.title];
}

- (BOOL)shouldReloadWebView:(NSURL*)location title:(NSString*)title
{
    BOOL title_is_nil = (title == nil);
    BOOL location_is_blank = [[location absoluteString] isEqualToString:@"about:blank"];

    BOOL reload = (title_is_nil || location_is_blank);

#ifdef DEBUG
    NSLog(@"%@", @"CDVWKWebViewEngine shouldReloadWebView::");
    NSLog(@"CDVWKWebViewEngine shouldReloadWebView title: %@", title);
    NSLog(@"CDVWKWebViewEngine shouldReloadWebView location: %@", [location absoluteString]);
    NSLog(@"CDVWKWebViewEngine shouldReloadWebView reload: %u", reload);
#endif

    return reload;
}

- (id)loadRequest:(NSURLRequest*)request
{
    if ([self canLoadRequest:request]) { // can load, differentiate between file urls and other schemes
        if (request.URL.fileURL) {
            SEL wk_sel = NSSelectorFromString(CDV_WKWEBVIEW_FILE_URL_LOAD_SELECTOR);
            NSURL* readAccessUrl = [request.URL URLByDeletingLastPathComponent];
            return ((id (*)(id, SEL, id, id))objc_msgSend)(_engineWebView, wk_sel, request.URL, readAccessUrl);
        } else {
            return [(WKWebView*)_engineWebView loadRequest:request];
        }
    } else { // can't load, print out error
        NSString* errorHtml = [NSString stringWithFormat:
                               @"<!doctype html>"
                               @"<title>Error</title>"
                               @"<div style='font-size:2em'>"
                               @"   <p>The WebView engine '%@' is unable to load the request: %@</p>"
                               @"   <p>Most likely the cause of the error is that the loading of file urls is not supported in iOS %@.</p>"
                               @"</div>",
                               NSStringFromClass([self class]),
                               [request.URL description],
                               [[UIDevice currentDevice] systemVersion]
                               ];
        return [self loadHTMLString:errorHtml baseURL:nil];
    }
    
    
    
}

- (id)loadHTMLString:(NSString*)string baseURL:(NSURL*)baseURL
{
    return [(WKWebView*)_engineWebView loadHTMLString:string baseURL:baseURL];
}

- (NSURL*) URL
{
    return [(WKWebView*)_engineWebView URL];
}

- (BOOL) canLoadRequest:(NSURLRequest*)request
{
    // See: https://issues.apache.org/jira/browse/CB-9636
    SEL wk_sel = NSSelectorFromString(CDV_WKWEBVIEW_FILE_URL_LOAD_SELECTOR);

    // if it's a file URL, check whether WKWebView has the selector (which is in iOS 9 and up only)
    if (request.URL.fileURL) {
        return [_engineWebView respondsToSelector:wk_sel];
    } else {
        return YES;
    }
}

- (void)updateSettings:(NSDictionary*)settings
{
    WKWebView* wkWebView = (WKWebView*)_engineWebView;

    wkWebView.configuration.preferences.minimumFontSize = [settings cordovaFloatSettingForKey:@"MinimumFontSize" defaultValue:0.0];

    /*
     wkWebView.configuration.preferences.javaScriptEnabled = [settings cordovaBoolSettingForKey:@"JavaScriptEnabled" default:YES];
     wkWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = [settings cordovaBoolSettingForKey:@"JavaScriptCanOpenWindowsAutomatically" default:NO];
     */

    // By default, DisallowOverscroll is false (thus bounce is allowed)
    BOOL bounceAllowed = !([settings cordovaBoolSettingForKey:@"DisallowOverscroll" defaultValue:NO]);

    // prevent webView from bouncing
    if (!bounceAllowed) {
        if ([wkWebView respondsToSelector:@selector(scrollView)]) {
            ((UIScrollView*)[wkWebView scrollView]).bounces = NO;
        } else {
            for (id subview in wkWebView.subviews) {
                if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
                    ((UIScrollView*)subview).bounces = NO;
                }
            }
        }
    }

    NSString* decelerationSetting = [settings cordovaSettingForKey:@"WKWebViewDecelerationSpeed"];
    if (![@"fast" isEqualToString:decelerationSetting]) {
        [wkWebView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    } else {
        [wkWebView.scrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
    }

    wkWebView.allowsBackForwardNavigationGestures = [settings cordovaBoolSettingForKey:@"AllowBackForwardNavigationGestures" defaultValue:NO];
    wkWebView.allowsLinkPreview = [settings cordovaBoolSettingForKey:@"Allow3DTouchLinkPreview" defaultValue:YES];
}

- (void)updateWithInfo:(NSDictionary*)info
{
    NSDictionary* scriptMessageHandlers = [info objectForKey:kCDVWebViewEngineScriptMessageHandlers];
    NSDictionary* settings = [info objectForKey:kCDVWebViewEngineWebViewPreferences];
    id navigationDelegate = [info objectForKey:kCDVWebViewEngineWKNavigationDelegate];
    id uiDelegate = [info objectForKey:kCDVWebViewEngineWKUIDelegate];

    WKWebView* wkWebView = (WKWebView*)_engineWebView;

    if (scriptMessageHandlers && [scriptMessageHandlers isKindOfClass:[NSDictionary class]]) {
        NSArray* allKeys = [scriptMessageHandlers allKeys];

        for (NSString* key in allKeys) {
            id object = [scriptMessageHandlers objectForKey:key];
            if ([object conformsToProtocol:@protocol(WKScriptMessageHandler)]) {
                [wkWebView.configuration.userContentController addScriptMessageHandler:object name:key];
            }
        }
    }

    if (navigationDelegate && [navigationDelegate conformsToProtocol:@protocol(WKNavigationDelegate)]) {
        wkWebView.navigationDelegate = navigationDelegate;
    }

    if (uiDelegate && [uiDelegate conformsToProtocol:@protocol(WKUIDelegate)]) {
        wkWebView.UIDelegate = uiDelegate;
    }

    if (settings && [settings isKindOfClass:[NSDictionary class]]) {
        [self updateSettings:settings];
    }
}

// This forwards the methods that are in the header that are not implemented here.
// Both WKWebView and WKWebView implement the below:
//     loadHTMLString:baseURL:
//     loadRequest:
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _engineWebView;
}

- (UIView*)webView
{
    return self.engineWebView;
}

#pragma mark WKScriptMessageHandler implementation

- (void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message
{
    
    if (![message.name isEqualToString:CDV_BRIDGE_NAME] && ![message.name isEqualToString:kCMPBridgeName]) {
        return;
    }

    CDVViewController* vc = (CDVViewController*)self.viewController;

    NSArray* jsonEntry = message.body; // NSString:callbackId, NSString:service, NSString:action, NSArray:args
    CDVInvokedUrlCommand* command = [CDVInvokedUrlCommand commandFromJson:jsonEntry];
    CDV_EXEC_LOG(@"Exec(%@): Calling %@.%@", command.callbackId, command.className, command.methodName);

    if (![vc.commandQueue execute:command]) {
#ifdef DEBUG
        NSError* error = nil;
        NSString* commandJson = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonEntry
                                                           options:0
                                                             error:&error];

        if (error == nil) {
            commandJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

            static NSUInteger maxLogLength = 1024;
            NSString* commandString = ([commandJson length] > maxLogLength) ?
                [NSString stringWithFormat : @"%@[...]", [commandJson substringToIndex:maxLogLength]] :
                commandJson;

            NSLog(@"FAILED pluginJSON = %@", commandString);
#endif
    }
}

#pragma mark WKNavigationDelegate implementation

//获取一次需要不拦截的url
- (NSArray *)jumpUrlInterceptArr{
    if (!_jumpUrlInterceptArr) {
        _jumpUrlInterceptArr = [[[WKUserContentController alloc]init] getSubmitJumpUrl];
    }
    return _jumpUrlInterceptArr;
}

- (void)webView:(WKWebView*)webView didStartProvisionalNavigation:(WKNavigation*)navigation
{
    NSLog(@"%s__%@",__FUNCTION__,webView.URL.absoluteString);
    
    //这里检测一下是否需要根据url中的字符串判断跳转不拦截容器
    // /*[jumpUrl-begin]ct.ctrip.com/webapp/home[jumpUrl-end]*/ 加到代理js头部注释掉，这里获取到则可以过滤不拦截
    //begin-add by raosj
    NSString *url = webView.URL.absoluteString;
    BOOL exist = NO;
    for (NSString *str in self.jumpUrlInterceptArr) {
        if([url containsString:str]){
            exist = YES;
            break;
        }
    }
    if (exist) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kNoInterceptJumpNotification" object:self.viewController userInfo:@{@"url":url}];
        return;
    }
    //end
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginResetNotification object:webView]];
    
}

- (void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation
{
    NSLog(@"%s__%@",__FUNCTION__,webView.URL.absoluteString);
    CDVViewController* vc = (CDVViewController*)self.viewController;
    [CDVUserAgentUtil releaseLock:vc.userAgentLockToken];

    //禁止长按
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
 
    //禁止选择
//    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];

    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPageDidLoadNotification object:webView]];

}

- (void)webView:(WKWebView*)theWebView didFailProvisionalNavigation:(WKNavigation*)navigation withError:(NSError*)error
{
    NSLog(@"%s__%@",__FUNCTION__,theWebView.URL.absoluteString);
    [self webView:theWebView didFailNavigation:navigation withError:error];
}

- (void)webView:(WKWebView*)theWebView didFailNavigation:(WKNavigation*)navigation withError:(NSError*)error
{
    NSLog(@"%s__%@",__FUNCTION__,theWebView.URL.absoluteString);
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPageLoadErrorNotification object:theWebView]];
    
    CDVViewController* vc = (CDVViewController*)self.viewController;
    [CDVUserAgentUtil releaseLock:vc.userAgentLockToken];

    NSString* message = [NSString stringWithFormat:@"Failed to load webpage with error: %@", [error localizedDescription]];
    NSLog(@"%@", message);

    NSURL* errorUrl = vc.errorURL;
    if (errorUrl) {
        //ks fix
        errorUrl = [NSURL URLWithString:[NSString stringWithFormat:@"?error=%@", [message stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  characterSetWithCharactersInString:@"\"#%<>[\\]^`{|}+"].invertedSet]] relativeToURL:errorUrl];
        NSLog(@"%@", [errorUrl absoluteString]);
        [theWebView loadRequest:[NSURLRequest requestWithURL:errorUrl]];
    }else{
        //提示加载错误的信息
        NSString *errorMessage = error.localizedDescription;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }
}

//- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
//{
//    NSLog(@"ks log --- webview did terminate,will reload");
//    [webView reload];
//}

- (BOOL)defaultResourcePolicyForURL:(NSURL*)url
{
    // all file:// urls are allowed
    if ([url isFileURL]) {
        return YES;
    }

    return NO;
}

- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction*) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler
{
    NSLog(@"%s__%@",__FUNCTION__,webView.URL.absoluteString);
    NSURL* url = [navigationAction.request URL];
    
    CDVViewController* vc = (CDVViewController*)self.viewController;
    // jsbridge://cmp?isSync=true&bridge='CoreBridge'&action='back'
    // jsbridge://cmp?isSync=true&bridge='CoreBridge'&action='setTitle'&param='xxx'
    // jsbridge://cmp?isSync=true&bridge='CoreBridge'&action='setShowProgress'&param='xxx'
    if ([[url scheme] isEqualToString:@"jsbridge"]) {
        NSURLComponents *urlComp = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSString *queryStr = urlComp.query;
        if ([queryStr containsString:@"CoreBridge"]) {
            if ([queryStr containsString:@"back"]) {
                if ([vc respondsToSelector:@selector(closeViewController)]) {
                    [vc performSelector:@selector(closeViewController)];
                }
            } else if ([queryStr containsString:@"setTitle"]) {
                // 第三方SPA应用设置标题
                for (NSURLQueryItem *item in urlComp.queryItems) {
                    if ([item.name isEqualToString:@"param"]) {
                        NSString *title = item.value;
                        vc.title = title;
                    }
                }
            } else if ([queryStr containsString:@"setShowProgress"]) {
                // 第三方SPA应用设置加载进度条是否显示
                for (NSURLQueryItem *item in urlComp.queryItems) {
                    if ([item.name isEqualToString:@"param"]) {
                        NSString *isShow = item.value;
                        #pragma clang diagnostic push
                        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        if ([vc respondsToSelector:NSSelectorFromString(@"setShowBannerProgress:")]) {
                            [vc performSelector:NSSelectorFromString(@"setShowBannerProgress:") withObject:isShow];
                        }
                        #pragma clang diagnostic pop
                       
                    }
                }
                
            }
            return decisionHandler(WKNavigationActionPolicyCancel);
        }
        
        NSArray *queryItems = urlComp.queryItems;
        NSString *callbackID;
        for (NSURLQueryItem *item in queryItems) {
            NSString *itemKey = item.name;
            if ([itemKey isEqualToString:@"bridgeid"]) {
                callbackID = [item.value copy];
            }
        }
        [vc.commandQueue fetchJSBridgeCommandsFromJsWithID:callbackID];
        return decisionHandler(WKNavigationActionPolicyCancel);
    }
    //如果是a链接点击直接打开文档，则下载后打开预览
    else if (navigationAction.navigationType == WKNavigationTypeLinkActivated && [url.scheme.lowercaseString hasPrefix:@"http"]) {
        //支持部分文档预览
        NSString *fileString = @"pdf,docx,xlsx,pptx,png,jpg,jpeg,rtf,gif,txt,mp3,wav,";
        if ([fileString containsString:url.path.lastPathComponent.pathExtension.lowercaseString]) {
            NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    [self showMsg:error.description fromVC:self.viewController];
                }else {
                    if (location) {
                        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
                        NSURL *destinationURL = [documentsURL URLByAppendingPathComponent:[response suggestedFilename]];
                        [[NSFileManager defaultManager] moveItemAtURL:location toURL:destinationURL error:nil];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:destinationURL];
                            self.documentInteractionController.delegate = self;
                            [self.documentInteractionController presentPreviewAnimated:YES];
                        });
                    }else{
                        [self showMsg:@"加载失败" fromVC:self.viewController];
                    }
                }
            }];
            [downloadTask resume];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }

    /**
     【COOKIE 3】对服务器端重定向(302)/浏览器重定向(a标签[包括 target="_blank"]) 进行同步 cookie 处理。
     由于所有的跳转都会是 NSMutableURLRequest 类型，同时也无法单独区分出 302 服务器端重定向跳转，所以这里统一对服务器端重定向(302)/浏览器重定向(a标签[包括 target="_blank"])进行同步 cookie 处理。
     */
//    if ([navigationAction.request isKindOfClass:NSMutableURLRequest.class]) {
//        [KKWebViewCookieManager syncRequestCookie:(NSMutableURLRequest *)navigationAction.request];
//    }
    
    /*
     * Give plugins the chance to handle the url
     */
    BOOL anyPluginsResponded = NO;
    BOOL shouldAllowRequest = NO;

    for (NSString* pluginName in vc.pluginObjects) {
        CDVPlugin* plugin = [vc.pluginObjects objectForKey:pluginName];
        SEL selector = NSSelectorFromString(@"shouldOverrideLoadWithRequest:navigationType:");
        if ([plugin respondsToSelector:selector]) {
            anyPluginsResponded = YES;
            // https://issues.apache.org/jira/browse/CB-12497
            int navType = (int)navigationAction.navigationType;
            if (WKNavigationTypeOther == navigationAction.navigationType) {
                navType = (int)WKNavigationTypeOther;
            }
            shouldAllowRequest = (((BOOL (*)(id, SEL, id, int))objc_msgSend)(plugin, selector, navigationAction.request, navType));
            if (!shouldAllowRequest) {
                break;
            }
        }
    }

    if (anyPluginsResponded) {
        if (shouldAllowRequest) {
            if (navigationAction.targetFrame == nil) {
                //https://blog.csdn.net/qq_28160831/article/details/88908031
                [webView loadRequest:navigationAction.request];
            }
            
            CDVViewController* vc = (CDVViewController*)self.viewController;
            SEL selector = NSSelectorFromString(@"shouldOverrideLoadWithRequest:navigationType:");
            if ([vc respondsToSelector:selector]) {
              int navType = (int)navigationAction.navigationType;
              shouldAllowRequest = (((BOOL (*)(id, SEL, id, int))objc_msgSend)(vc, selector, navigationAction.request, navType));
            }
        }
        
        if (shouldAllowRequest) {
            return decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            return decisionHandler(WKNavigationActionPolicyCancel);
        }
    }

    /*
     * Handle all other types of urls (tel:, sms:), and requests to load a url in the main webview.
     */
    BOOL shouldAllowNavigation = [self defaultResourcePolicyForURL:url];
    if (shouldAllowNavigation) {
        if (navigationAction.targetFrame == nil) {
            [webView loadRequest:navigationAction.request];
        }
        return decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    }

    return decisionHandler(WKNavigationActionPolicyCancel);
}

// 2、在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"%s__%@",__FUNCTION__,webView.URL.absoluteString);
    // iOS 12 之后，响应头里 Set-Cookie 不再返回。 所以这里针对系统版本做区分处理。
    if (@available(iOS 11.0, *)) {
        // 【COOKIE 4】同步 WKWebView cookie 到 NSHTTPCookieStorage。
        [KKWebViewCookieManager copyWKHTTPCookieStoreToNSHTTPCookieStorageForWebViewOniOS11:webView withCompletion:nil];
    } else {
        // 【COOKIE 4】同步服务器端响应头里的 Set-Cookie，既把 WKWebView cookie 同步到 NSHTTPCookieStorage。
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}


#pragma mark - Plugin interface

- (void)allowsBackForwardNavigationGestures:(CDVInvokedUrlCommand*)command;
{
    id value = [command argumentAtIndex:0];
    if (!([value isKindOfClass:[NSNumber class]])) {
        value = [NSNumber numberWithBool:NO];
    }

    WKWebView* wkWebView = (WKWebView*)_engineWebView;
    wkWebView.allowsBackForwardNavigationGestures = [value boolValue];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self.viewController;
}
//提示框
- (void)showMsg:(NSString *)msg fromVC:(UIViewController *)fromVC{
    if (!msg.length) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 点击确定按钮后的操作
    }];
    [alertController addAction:okAction];
    [fromVC presentViewController:alertController animated:YES completion:nil];

}
@end

#pragma mark - CDVWKWeakScriptMessageHandler

@implementation CDVWKWeakScriptMessageHandler

- (instancetype)initWithScriptMessageHandler:(id<WKScriptMessageHandler>)scriptMessageHandler
{
    self = [super init];
    if (self) {
        _scriptMessageHandler = scriptMessageHandler;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //这里是我们自己跟js交互的操作，这个要先于cordova初始化完毕之前
    /*if ([message.name isEqualToString:kCMPBridgeName]) {
        NSString *body = message.body;
        NSDictionary *param = [CMPBridgeTool dictionaryWithJsonString:body];
        [CMPBridgeTool jsToNativeWithParamDic:param webview:message.webView];
        return;
    }*/
    [self.scriptMessageHandler userContentController:userContentController didReceiveScriptMessage:message];
}




@end
