//
//  CMPMessageWebViewController.m
//  CMPCore
//
//  Created by wujiansheng on 2017/7/13.
//
//

#import "CMPMessageWebViewController.h"
#import <CMPLib/AFNetworkReachabilityManager.h>
#import <CMPLib/CMPCachedUrlParser.h>

static NSString * const kMessageHtmlHref = @"http://message.m3.cmp/v1.0.0/";
static NSString * const kMessageDetailHtmlRelativePath = @"layout/message-detail.html";

static NSString * const kMessageMiddlePageHtmlName = @"m3-message-middle-page.html";
static NSString * const kJavaScriptMethodTranslatePage = @"translatePage";

static NSString * const kHtmlUrlParamAppId = @"appId";
static NSString * const kHtmlUrlParaMessageTitle = @"messageTitle";
static NSString * const kDataKey = @"data";
 
@interface CMPMessageWebViewController ()

@end

@implementation CMPMessageWebViewController

#pragma mark – Life Cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [self loadMessageHtml];
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad:) name:CDVPageDidLoadNotification object:self.webView];
    self.allowRotation = NO;
}

#pragma mark – Private Methods

- (void)loadMessageHtml {
    NSString *htmlPreviousPath =  [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:kMessageHtmlHref]];
    NSString *htmlPath = [htmlPreviousPath stringByAppendingFormat:@"/%@",kMessageMiddlePageHtmlName];
    NSURL *htmlPathUrl = [NSURL URLWithString:htmlPath];
    
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:htmlPathUrl.path];
    if (!isExists) {
        NSString *htmlBundlePath = [[NSBundle mainBundle] pathForResource:kMessageMiddlePageHtmlName ofType:nil];
        NSString *htmlContents = [NSString stringWithContentsOfFile:htmlBundlePath encoding:NSUTF8StringEncoding error:nil];
        BOOL isSeccess = [htmlContents writeToURL:htmlPathUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
        if (isSeccess) {
            self.startPage = htmlPath;
        }
    } else {
        self.startPage = htmlPath;
    }
}

#pragma mark – Custom Notification

- (void)pageDidLoad:(NSNotification *)notification {
    NSDictionary *valueDic = @{
        kHtmlUrlParamAppId: self.appId,
        kHtmlUrlParaMessageTitle : self.appName
    };
    NSDictionary *dataDic = @{
        kDataKey : valueDic
    };
    NSString *dataStr = [dataDic JSONRepresentation];
       
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:kMessageHtmlHref]];
    NSString *url = [NSString stringWithFormat:@"%@/%@",localHref,kMessageDetailHtmlRelativePath];
    url = [url appendHtmlUrlParam:kHtmlUrlParamAppId value:self.appId];
    url = [url appendHtmlUrlParam:kHtmlUrlParaMessageTitle value:self.appName];
    
    NSString *javaScript = [NSString stringWithFormat:@"%@('%@','%@')",kJavaScriptMethodTranslatePage,dataStr,url];
    [self.webViewEngine evaluateJavaScript:javaScript completionHandler:nil];
}

@end
