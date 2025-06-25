//
//  CMPWKWebViewEngine.m
//  M3
//
//  Created by Kaku Songu on 11/15/21.
//

#import "CMPWKWebViewEngine.h"
#import <CordovaLib/CDVWKWebView.h>
#import <CordovaLib/KKWebViewCookieManager.h>
#import <CordovaLib/WKUserContentController+IMYHookAjax.h>
#import <CordovaLib/WKWebConstant.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPSafariViewController.h>
#import <CMPLib/CMPWKURLSchemeHandler.h>
#import "CMPWKURLSchemeDataProvider.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "AppDelegate.h"
#import <CMPLib/CMPIntercepter.h>

@interface CMPWKWebViewEngine()
{
    NSString *_firstOutsideUrl;//第一个外部url
    NSInteger _protocolRegisterTag;//2:当前页面取消了注册的，页面关闭时(pop)需要重新注册
    NSInteger _hookInstallTag;//2:当前页面移除了hook的，需要installhook
}
@end

@implementation CMPWKWebViewEngine
    
- (void)dealloc
{
    if ([CMPCore sharedInstance].needHandleUrlScheme){
        [self unregisterProtocol];
    }else{
        [self registerProtocol];
    }
    if ([self.engineWebView isKindOfClass:[CDVWKWebView class]]) {
        CDVWKWebView *aWebView = (CDVWKWebView *)self.engineWebView;
        if (aWebView.webViewID) {
            [CDVWKWebView remove:aWebView.webViewID];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (NSClassFromString(@"WKWebView") == nil) {
            return nil;
        }
        NSDictionary* settings = self.commandDelegate.settings;
        
        CDVWKWeakScriptMessageHandler *weakScriptMessageHandler = [[CDVWKWeakScriptMessageHandler alloc] initWithScriptMessageHandler:self];
        
        WKUserContentController* userContentController = [[WKUserContentController alloc] init];
        WKWebViewConfiguration* configuration = [self createConfigurationFromSettings:settings];
        [userContentController imy_installHookAjax];
        [userContentController addScriptMessageHandler:weakScriptMessageHandler name:CDV_BRIDGE_NAME];
        [userContentController addScriptMessageHandler:weakScriptMessageHandler name:kCMPBridgeName];
        configuration.userContentController = userContentController;
        
        if ([CMPCore sharedInstance].needHandleUrlScheme){
            CMPWKURLSchemeHandler *schemeHandler = [[CMPWKURLSchemeHandler alloc] init];
            schemeHandler.delegate = [CMPWKURLSchemeDataProvider shareInstance];
            [configuration setURLSchemeHandler:schemeHandler forURLScheme:@"cmp"];
        }
        
        CDVWKWebView* wkWebView = [[CDVWKWebView alloc] initWithFrame:frame configuration:configuration];
        wkWebView.UIDelegate = self.uiDelegate;
        wkWebView.navigationDelegate = self.uiDelegate;
        wkWebView.scrollView.showsVerticalScrollIndicator = NO;
        self.engineWebView = wkWebView;
        
        if ([CMPCore sharedInstance].needHandleUrlScheme){
            [KKWebViewCookieManager copyNSHTTPCookieStorageToWKHTTPCookieStoreForWebViewOniOS11:wkWebView withCompletion:nil];
        }
        
        if (@available(iOS 16.4, *)) {
            wkWebView.inspectable = YES;
        } else {
            // Fallback on earlier versions
        }
    }

    return self;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"%s__%@",__FUNCTION__,webView.URL.absoluteString);
    NSURL *curUrl = navigationAction.request.URL;
    if ([CMPCore sharedInstance].needHandleUrlScheme){
        [self unregisterProtocol];
        if (!curUrl.fileURL){
            if (![curUrl.host hasSuffix:@"ctrip.com"]){//V5-60674 单独处理，携程有问题，获取到首页数据但没有显示，且会多出一个空白请求
                [self removeHook];
            }else{
                [self registerProtocol];
                [self installHook];
            }
        }else {
            [self installHook];
        }
    }else{
        if (INTERFACE_IS_PHONE) {
            CDVWKWebView *aWeb = webView;
            CDVViewController *ctrl = aWeb.viewController;
            NSString *startPage = ctrl.startPage;
            if (startPage && _protocolRegisterTag != 2) {
                BOOL needUnregister = NO;
                NSURL *startUrl = [NSURL URLWithString:startPage];
                if (startUrl.fileURL){
                    if (!curUrl.fileURL && !_firstOutsideUrl) {
                        _firstOutsideUrl = curUrl.absoluteString;
                        if ([_firstOutsideUrl containsString:@"cmpprtat=1"]) {
                            needUnregister = YES;
                        }
                    }
                }else{
                    if ([startPage containsString:@"cmpprtat=1"]) {
                        needUnregister = YES;
                    }
                }
                 if (needUnregister) {
                    [self unregisterProtocol];
                    [self removeHook];
                    _protocolRegisterTag = 2;
                }
            }
        }
    }
    [super webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
}

-(void)removeHook
{
    if (_hookInstallTag != 2) {
        WKUserContentController *controller = ((WKWebView *)self.engineWebView).configuration.userContentController;
    //    if (@available(iOS 14.0, *)) {
    //        [controller removeAllScriptMessageHandlers];
    //    } else {
    //        [controller imy_uninstallHookAjax];//handler
    //        [controller removeScriptMessageHandlerForName:kCMPBridgeName];//handler
    //        [controller removeScriptMessageHandlerForName:CDV_BRIDGE_NAME];//handler
    //    }
        [controller removeAllUserScripts];
        
        _hookInstallTag = 2;
    }
}

-(void)installHook
{
    if (_hookInstallTag != 1) {
        WKUserContentController *controller = ((WKWebView *)self.engineWebView).configuration.userContentController;
        
    //    [controller imy_installHookAjax];//handler
        [controller imy_injectJsSourceForLocalStorage];//script
        [controller imy_injectProxy];//script
        
        _hookInstallTag = 1;
    }
}

-(void)registerProtocol
{
    if (_protocolRegisterTag !=1) {
        [[CMPIntercepter sharedInstance] registerClass];
        _protocolRegisterTag = 1;
    }
}

-(void)unregisterProtocol
{
    if (_protocolRegisterTag !=2) {
        [[CMPIntercepter sharedInstance] unregisterClass];
        _protocolRegisterTag = 2;
    }
}

/**
 ks debug --- 调试用sfsafari加载第三方
 */
//- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction*) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler
//{
//    NSLog(@"%s__%@",__FUNCTION__,webView.URL.absoluteString);
//    NSURL* url = [navigationAction.request URL];
//
//    if (url.scheme && [url.scheme hasPrefix:@"http"]) {
//        if (![url.path containsString:@"seeyon"]) {
//            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
//            UIViewController *vc = self.viewController;
//            [vc addChildViewController:safari];
//            [webView addSubview:safari.view];
//            safari.view.frame = webView.bounds;
//            decisionHandler(WKNavigationActionPolicyCancel);
//            return;
//        }
//    }
//
//    [super webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
//}

@end
