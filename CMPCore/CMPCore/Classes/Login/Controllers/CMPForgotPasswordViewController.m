//
//  CMPForgotPasswordViewController.m
//  M3
//
//  Created by CRMO on 2018/9/17.
//

#import "CMPForgotPasswordViewController.h"
#import <CMPLib/SOLocalization.h>
#import <CMPLib/CMPNavigationController.h>


NSString * const kForgotPasswordUrl = @"/m3/apps/m3/my/udate-psw.html";

@interface CMPForgotPasswordViewController ()<WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webview;

@end

@implementation CMPForgotPasswordViewController

- (void)viewDidLoad {
    self.webview = (WKWebView *)self.webView;
    self.webview.navigationDelegate = self;
    self.hideBannerNavBar = YES;
    NSString *forgotPasswordUrl = [CMPCore fullUrlForPath:kForgotPasswordUrl];
    SOLocalization *localization = [SOLocalization sharedLocalization];
    NSString *serverRegion = [localization getServerLanguageKeyWithRegion:localization.region];
    forgotPasswordUrl = [forgotPasswordUrl stringByAppendingFormat:@"?lang=%@",serverRegion];
    forgotPasswordUrl = [forgotPasswordUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"#%^{}\"[]|\\<> "].invertedSet];
    self.startPage = forgotPasswordUrl;
    [super viewDidLoad];
    
    CMPNavigationController *nav = (CMPNavigationController *)self.navigationController;
    [nav updateEnablePanGesture:YES];
}

- (void)loadForgotPasswordPage {
    NSString *startPage = [CMPCore fullUrlForPath:kForgotPasswordUrl];
    NSURLRequest *startRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:startPage]];
    [self.webViewEngine loadRequest:startRequest];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *requestStr = navigationAction.request.URL.absoluteString;
    if ([requestStr isEqualToString:@"jsbridge://cmp?isSync=true&bridge='CoreBridge'&action='back'"]) {
       [self.navigationController popViewControllerAnimated:YES];
       decisionHandler(WKNavigationActionPolicyCancel);
       return;
    } else if ([requestStr isEqualToString:@"jsbridge://cmp?isSync=true&bridge='CoreBridge'&action='refresh'"]) {
       if (webView.isLoading) {
           [webView stopLoading];
       } else {
           [self loadForgotPasswordPage];
       }
       decisionHandler(WKNavigationActionPolicyCancel);
       return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSString *nativePath = [[NSBundle mainBundle] pathForResource:@"nonetwork" ofType:@"html"];
    NSURL *errorURL = [NSURL fileURLWithPath:nativePath];
       
    NSInteger languageType = [CMPCore languageType];
    if (languageType == kLanguageType_En) {
        NSString *URLString = [errorURL absoluteString];
        NSString *URLwithQueryString = [URLString stringByAppendingString: @"?lang=en"];
        errorURL = [NSURL URLWithString:URLwithQueryString];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:errorURL];
    [self.webViewEngine loadRequest:request];
}


@end
