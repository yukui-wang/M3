//
//  CMPCommonWebViewController.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/1/21.
//

#import "CMPCommonWebViewController.h"
#import <Webkit/Webkit.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/UIViewController+KSSafeArea.h>
#if __has_include("CDVWKProcessPoolFactory.h")
#import "CDVWKProcessPoolFactory.h"
#endif
#import "CMPIntercepter.h"
#import "NSObject+CMPHUDView.h"
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/CMPThemeManager.h>

#define kCloseWebViewMessageHandler @"CloseNoInterceptWebMessageHandler"

@interface CMPCommonWebViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler,UIDocumentInteractionControllerDelegate>
{
    UINavigationBar *_navigationBar;
}
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) UINavigationItem *navItem;
@property (nonatomic,strong) UIBarButtonItem *backButtonItem;
@property (nonatomic,strong) UIBarButtonItem *closeButtonItem;
@property (nonatomic,strong) UIBarButtonItem *openInSafariButtonItem;
@property (nonatomic,strong) UIDocumentInteractionController *documentInteractionController;
@end

@implementation CMPCommonWebViewController

- (void)dealloc
{
    if (_webView) {
        [_webView removeObserver:self forKeyPath:@"title"];
        [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
        _webView.UIDelegate = nil;
        _webView.navigationDelegate = nil;
    }
}

-(instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _needNav = YES;
        _url = url;
    }
    return self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _needNav = YES;
    }
    return self;
}

-(WKWebView *)webView
{
    if (!_webView) {
        WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
#if __has_include("CDVWKProcessPoolFactory.h")
        configuration.processPool = [[CDVWKProcessPoolFactory sharedFactory] sharedProcessPool];
#endif
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
        if (@available(iOS 13.0, *)) {
           configuration.defaultWebpagePreferences.preferredContentMode = WKContentModeMobile;
        }
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        
        if (@available(iOS 16.4, *)) {
            _webView.inspectable = YES;
        } else {
            // Fallback on earlier versions
        }
        
        //获取应用的cookie
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookies];
        //同步cookie到webView
        for (NSHTTPCookie *cookie in cookies) {
            [_webView.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:nil];
        }
        
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        [_webView.configuration.userContentController addScriptMessageHandler:self name:kCloseWebViewMessageHandler];
    }
    return _webView;
}

-(UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.alpha = 0;
    }
    return _progressView;
}

-(UINavigationItem *)navItem
{
    if (!_navItem) {
        _navItem = [[UINavigationItem alloc] init];
    }
    return _navItem;
}

-(UIBarButtonItem *)backButtonItem
{
    if (!_backButtonItem) {
        _backButtonItem = [[UIBarButtonItem alloc] initWithImage:[[CMPThemeManager sharedManager] skinColorImageWithName:@"banner_return"] style:UIBarButtonItemStylePlain target:self action:@selector(_backAct:)];
    }
    return _backButtonItem;
}

-(UIBarButtonItem *)closeButtonItem
{
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithImage:[[CMPThemeManager sharedManager] skinColorImageWithName:@"banner_close"] style:UIBarButtonItemStylePlain target:self action:@selector(_closeAct:)];
    }
    return _closeButtonItem;
}

-(UIBarButtonItem *)openInSafariButtonItem
{
    if (!_openInSafariButtonItem) {
        
        _openInSafariButtonItem = [[UIBarButtonItem alloc] initWithImage:[[CMPThemeManager sharedManager] skinColorImageWithName:@"safari"] style:UIBarButtonItemStylePlain target:self action:@selector(_openInSafariAct:)];
    }
    return _openInSafariButtonItem;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];// [UIColor whiteColor];

    if (_needNav) {
        _navigationBar = [[UINavigationBar alloc] init];
        [_navigationBar setItems:@[self.navItem]];
        [_navigationBar setTranslucent:true];
        [_navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [_navigationBar setShadowImage:[UIImage new]];
        [_navigationBar setAlpha:1];
        [_navigationBar setBackgroundColor:[UIColor cmp_colorWithName:@"white-bg"]];
        [self.view addSubview:_navigationBar];
        [_navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(@([UIApplication sharedApplication].statusBarFrame.size.height));
            make.left.right.offset(0);
            make.height.equalTo(@(44));
        }];
    }
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.baseSafeView);
        if (_needNav && _navigationBar) {
            make.top.equalTo(_navigationBar.mas_bottom);
        }else{
            make.top.offset(0);
        }
    }];
    
    [contentView addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(contentView);
    }];
    
    [contentView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(contentView);
        make.height.mas_equalTo(@(2));
    }];
    
    
    self.webView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld context:nil];

    [self reload];
    
}

-(void)reload
{
    NSLog(@"ks log --- %s -- url : %@",__func__,_url);
    if (_url) {
        if ([_url isFileURL]) {
            [self.webView loadFileURL:_url allowingReadAccessToURL:_url.URLByDeletingLastPathComponent];
        }else{
//            NSURLRequest *req = [[NSURLRequest alloc] initWithURL:_url];
            NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:_url];
            req = [self handelRequest:req];//加入ltoken等app登录信息
            [self.webView loadRequest:req];
        }
    }else{
        
    }
}

- (NSMutableURLRequest *)handelRequest:(NSMutableURLRequest *)request {
    BOOL isCurrentServer = NO;
    Class CMPServerUtils = NSClassFromString(@"CMPServerUtils");
    SEL isCurrentServerSEL = NSSelectorFromString(@"isCurrentServer:");
    isCurrentServer  = [CMPServerUtils performSelector:isCurrentServerSEL withObject:request.URL];
       
    if (isCurrentServer) {
        Class CMPCoreClass = NSClassFromString(@"CMPCore");
        SEL sharedInstance = NSSelectorFromString(@"sharedInstance");
        SEL contentTicketSEL = NSSelectorFromString(@"contentTicket");
        SEL contentExtensionSEL = NSSelectorFromString(@"contentExtension");
        SEL tokenSEL = NSSelectorFromString(@"token");
        
        id CMPCore = [CMPCoreClass performSelector:sharedInstance];
        NSString *aTicket =  [CMPCore performSelector:contentTicketSEL];
        NSString *aExtension = [CMPCore performSelector:contentExtensionSEL];
        NSString *token = [CMPCore performSelector:tokenSEL];
        
        if ([aTicket isKindOfClass:[NSString class]] && aTicket.length > 0) {
            [request setValue:aTicket forHTTPHeaderField:@"Content-Ticket"];
        }
        if ([aExtension isKindOfClass:[NSString class]] && aExtension.length > 0) {
            [request setValue:aExtension forHTTPHeaderField:@"Content-Extension"];
        }
        if ([token isKindOfClass:[NSString class]] && token.length > 0) {
            [request setValue:token forHTTPHeaderField:@"ltoken"];
        }
    }
    NSLog(@"ks log --- urlRequest final result: %@,%@,%@",request.URL,request.allHTTPHeaderFields,request.HTTPBody);
    return request;
}

-(void)_backAct:(UIBarButtonItem *)item
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else{
        [self _close];
    }
}

-(void)_closeAct:(UIBarButtonItem *)item
{
    [self _close];
}

-(void)_close
{
    if (![CMPCore sharedInstance].needHandleUrlScheme){
        [[CMPIntercepter sharedInstance] registerClass];
    }

    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.closeBlock) {
                self.closeBlock();
            }
        }];
    }else if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)_openInSafariAct:(UIBarButtonItem *)item
{
    //使用safari打开本页面
    if ([[UIApplication sharedApplication] canOpenURL:self.webView.URL]) {
        [[UIApplication sharedApplication]openURL:self.webView.URL options:@{} completionHandler:nil];
    }
}

-(void)updateNavLeftItem
{
//    if ([self.webView canGoBack]) {
        [self.navItem setLeftBarButtonItems:@[self.backButtonItem,self.closeButtonItem]];
//    }else{
//        [self.navItem setLeftBarButtonItems:@[self.closeButtonItem]];
//    }
}

-(void)updateNavRightItem
{
    [self.navItem setRightBarButtonItems:@[self.openInSafariButtonItem]];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.webView &&[keyPath isEqualToString:@"title"]){
        self.navItem.title = ((WKWebView * )self.webView).title;
    }else if ([keyPath isEqual: @"estimatedProgress"] && object == self.webView) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if(self.webView.estimatedProgress >= 1.0f)
        {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //设置webview的userAgent
    __weak typeof(self) weakSelf = self;
    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id o, NSError *error) {
        if ([o isKindOfClass:NSString.class]) {
            NSString *userAgent = o;
            NSString *version = [NSString stringWithFormat:@"seeyon-m3/%@",[CMPCore clinetVersion]];
            if (![userAgent containsString:version]) {
                userAgent = [userAgent stringByAppendingString:version];
                [weakSelf.webView setCustomUserAgent:userAgent];
            }
        }
    }];
    
    [self updateNavLeftItem];
    if ([webView.URL.absoluteString containsString:@"openinsafari=yes"]) {
        [self updateNavRightItem];//使用safari浏览器打开
    }
    
    NSURL *url = navigationAction.request.URL;
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated && [url.scheme.lowercaseString hasPrefix:@"http"]) {//兼容a标签点击
        //支持部分文档预览
        NSString *fileString = @"pdf,docx,xlsx,pptx,png,jpg,jpeg,rtf,gif,txt,mp3,wav,mp4,mov";
        if ([fileString containsString:url.path.lastPathComponent.pathExtension.lowercaseString]) {
            NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    [self.view cmp_showHUDError:error];
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
                        [self.view cmp_showHUDWithText:@"加载失败"];
                    }
                }
            }];
            [downloadTask resume];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }else if (![url.scheme.lowercaseString hasPrefix:@"http"]){//其他scheme
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"ks log --- %s -- %@",__func__,error);
    if (_loadResultBlk) {
        _loadResultBlk(webView,error,@(-1));
    }else{
        //提示加载错误的信息
        NSString *errorMessage = error.localizedDescription;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
//    if (_loadResultBlk) {
//        _loadResultBlk(webView,nil,@(0));
//    }
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (_loadResultBlk) {
        _loadResultBlk(webView,nil,@(1));
    }
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"ks log --- %s -- %@",__func__,error);
    if (_loadResultBlk) {
        _loadResultBlk(webView,error,@(-1));
    }
}
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, card);
    }
}

#pragma mark - WKUIDelegate

//window.open(url,_blank)的方式会打开safari处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (navigationAction.targetFrame == nil || !navigationAction.targetFrame.isMainFrame) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
    }
    return nil;
}

- (void)webView:(WKWebView*)webView runJavaScriptAlertPanelWithMessage:(NSString*)message
    initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action){
        completionHandler();
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    UIViewController* rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootController presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView*)webView runJavaScriptConfirmPanelWithMessage:(NSString*)message
    initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)(BOOL result))completionHandler{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action){
        completionHandler(YES);
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];

    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* action){
        completionHandler(NO);
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:cancel];

    UIViewController* rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootController presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView*)webView runJavaScriptTextInputPanelWithPrompt:(NSString*)prompt
          defaultText:(NSString*)defaultText initiatedByFrame:(WKFrameInfo*)frame
    completionHandler:(void (^)(NSString* result))completionHandler{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:prompt
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action){
        completionHandler(((UITextField*)alert.textFields[0]).text);
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];

    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* action){
        completionHandler(nil);
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.text = defaultText;
    }];

    UIViewController* rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - WKUserContentControllerDelegate
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if ([message.name isEqualToString:kCloseWebViewMessageHandler]) {
        //h5中js调用window.webkit.messageHandlers.CloseNoInterceptWebMessageHandler.postMessage("");
        [self _closeAct:nil];//关闭本web容器
    }
}



@end
