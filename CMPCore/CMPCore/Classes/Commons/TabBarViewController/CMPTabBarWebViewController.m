//
//  CMPTabBarWebViewController.m
//  M3
//
//  Created by youlin on 2018/6/29.
//

#import "CMPTabBarWebViewController.h"
#import <CMPLib/CMPAppManager.h>
#import "CMPTabBarItemAttribute.h"
#import <CMPLib/AFNetworkReachabilityManager.h>
#import "CMPCheckUpdateManager.h"
#import "CMPWebAppsDownloadProgressView.h"
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/CMPCachedResManager.h>
#import "CMPLoginConfigInfoModel.h"
#import <CMPLib/CMPH5ConfigModel.h>
#import <CMPLib/UIImage+CMPImage.h>
#import <WebKit/WebKit.h>
#import "CMPMigrateWebDataViewController.h"

@interface CMPTabBarWebViewController () {
    BOOL _needReloadWebview;
}
@property (copy, nonatomic) NSString *firstPage;
/** 下载进度页面 **/
@property (strong, nonatomic) CMPWebAppsDownloadProgressView *progressView;
@property (strong, nonatomic) UIButton *appButton; // 直接加到View上的常用应用按钮
@property (strong, nonatomic) UIButton *bannerAppButton; // 放在顶部导航的常用应用按钮
@property (strong, nonatomic) UIButton *bannerFarwardPageButton; // 放在顶部导航的前进按钮
@property (strong, nonatomic) UIButton *bannerBackPageButton; // 放在顶部导航的后退按钮

@property (strong, nonatomic) NSMutableArray *rightBarButtonItems;

@property (assign, nonatomic) BOOL isAddAppButton;

@end

@implementation CMPTabBarWebViewController

#pragma mark-
#pragma mark Life Circle

- (void)dealloc {
    self.viewDidAppearCallBack = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    _needReloadWebview = YES;
    if ([[CMPCheckUpdateManager sharedManager] canShowApp]) {
        [self _setup];
        [super viewDidLoad];
    } else { // 如果应用包正在下载，先展示应用包下载页面
        [self.progressView showInView:self.view];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appsDownloadAction:) name:kNotificationName_AppsDownload object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uesrLogout:)
                                                 name:kNotificationName_UserLogout object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    if (_needReloadWebview && INTERFACE_IS_PAD) {
        //OA-218293 【PAD-待办/应用中心banner】横屏状态下登录，出现显示问题
        [(WKWebView *)self.webView reload];
    }
    _needReloadWebview = NO;
}
- (void)setupNaviBar {
    [super setupNaviBar];
    [self bringXZIconToFront];
}
- (void)bringXZIconToFront {
    //小致图标会被遮住
    UIView *view = [self.view viewWithTag:kViewTag_XiaozIcon];
    if (view) {
        [self.view bringSubviewToFront:view];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.viewDidAppearCallBack) {
        self.viewDidAppearCallBack();
    }
    [self bringXZIconToFront];
}

- (void)pageDidLoad:(NSNotification *)notification {
    [self.rightBarButtonItems removeAllObjects];
    self.isAddAppButton = NO;
    
    id webView = notification.object;
    NSString *url = nil;
    WKWebView *tmpWebview = webView;
    url = tmpWebview.URL.absoluteString;
    
    // V7.1版本，常用应用配置在顶部导航右边
    if ([CMPCore sharedInstance].serverIsLaterV7_1) {
        CMPLoginConfigInfoModel_2 *configInfo = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:[CMPCore sharedInstance].currentUser.configInfo];
        if (self.currentURL && !self.currentURL.isFileURL && [self _isTopPage]) {
            [self.rightBarButtonItems addObject:self.bannerBackPageButton];
            [self.rightBarButtonItems addObject:self.bannerFarwardPageButton];
        }
        if (configInfo.portal.isShowCommonApp && self.itemAttribute && INTERFACE_IS_PHONE) {
            [self.rightBarButtonItems addObject:self.bannerAppButton];
            self.isAddAppButton = YES;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(addRightButtons)
                   withObject:nil
                   afterDelay:0.3];
    }
    
    // 中转页面不展示返回按钮
    if ([url containsString:@"m3-transit-page.html"]) {
        self.backBarButtonItemHidden = YES;
        return;
    }
    
    // 存储第一次加载的Url
    if ([NSString isNull:self.firstPage]) {
        self.firstPage = url;
    }
    
    // 第一个页面不展示返回按钮，其它页面展示
    if ([self.firstPage isEqualToString:url] ||
        ([CMPCore sharedInstance].serverIsLaterV7_1 && [self _isTopPage])) {
        if (!self.bannerNavigationBar.isBannarAddLeftButtonItems) {
            self.backBarButtonItemHidden = YES;
        }
    } else {
        self.backBarButtonItemHidden = NO;
    }

    // 2.5.0版本，应用配置到底导航，标题根据是否有返回按钮移动位置
    if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
        [self reLayoutSubViews];
    }
    
    [self progressFinishedLoad];
    
    
//    self.backBarButtonItemHidden = NO;
//    [self.rightBarButtonItems removeAllObjects];
    //[super pageDidLoad:notification];
}

#pragma mark-
#pragma mark 应用包下载进度

- (void)appsDownloadAction:(NSNotification *)aNotification {
    if ([CMPCheckUpdateManager sharedManager].firstDownloadDone) return;
    [self dispatchAsyncToMain:^{
        NSDictionary *aValue = aNotification.object;
        NSString *state = [aValue objectForKey:@"state"];
        
        if ([state isEqualToString:@"start"]) {
            [self.progressView updateProgress:0 animation:NO];
        } else if ([state isEqualToString:@"progress"]) {
            CGFloat aProgress = [[aValue objectForKey:@"value"] floatValue];
            [self.progressView updateProgress:aProgress animation:YES];
        } else if ([state isEqualToString:@"success"]) {
            [self _setup];
            [super viewDidLoad];
            [self.progressView hide];
            self.progressView = nil;
        } else if ([state isEqualToString:@"fail"]) {
            NSString *zipAppName = aValue[@"zipAppName"];
            [self.progressView showErrorWithZipAppName:zipAppName retryAction:^{
                [[CMPCheckUpdateManager sharedManager] redownload];
            }];
        }
    }];
}

- (CMPWebAppsDownloadProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[CMPWebAppsDownloadProgressView alloc] init];
    }
    return _progressView;
}

#pragma mark-
#pragma mark 重写函数

- (CMPBannerTitleType)bannerTitleType {
    if ([CMPCore sharedInstance].serverIsLaterV2_5_0 && self.backBarButtonItemHidden) {
        return CMPBannerTitleTypeLeft;
    } else {
        return CMPBannerTitleTypeCenter;
    }
}

- (BOOL)autoShowBackButton {
    return NO;
}

- (void)layoutSubviewsWithFrame:(CGRect)frame {
    [super layoutSubviewsWithFrame:frame];
    [self layoutAppButton];
}

#pragma mark-
#pragma mark 常用应用

- (void)updateCommonAppButtonColor:(UIColor *)color {
    UIImage *image = [[UIImage imageNamed:[CMPFeatureSupportControl bannerAppIcon]] cmp_imageWithTintColor:color];
    [self.appButton setImage:image forState:UIControlStateNormal];
    [self.bannerAppButton setImage:image forState:UIControlStateNormal];
}

- (void)hideCommonAppButton:(BOOL)hide {
    [self.bannerAppButton setHidden:hide];
    [self.appButton setHidden:hide];
}
- (void)hideBannerBackPageButton:(BOOL)hide {
    [self.bannerBackPageButton setHidden:hide];
}
- (void)hideBannerFarwardPageButton:(BOOL)hide {
    [self.bannerFarwardPageButton setHidden:hide];
}

- (void)addRightButtons {    
    if (!self.hideBannerNavBar) {
        self.bannerNavigationBar.rightViewsMargin = 0.0f;
        self.bannerNavigationBar.rightMargin = 5.0f;
        [self.bannerNavigationBar insertRightBarButtonItems:self.rightBarButtonItems];
    } else {
        CMPH5ConfigModel *h5Config = [[CMPCore sharedInstance] h5Config];
        NSArray *blackList = h5Config.commonAppBlackList;
        // 当前应用ID不在黑名单里才展示常用应用入口
        if (INTERFACE_IS_PHONE && self.isAddAppButton && ![blackList containsObject:self.itemAttribute.appID]) {
            if([self.view.subviews containsObject:self.appButton]){
                //如果已经存在应用按钮，则不再添加
                return;
            }
            [self.view addSubview:self.appButton];
            [self layoutAppButton];
        }else{
            [self.appButton removeFromSuperview];
        }
    }
}

- (NSMutableArray *)rightBarButtonItems {
    if (!_rightBarButtonItems) {
        _rightBarButtonItems = [NSMutableArray array];
    }
    return _rightBarButtonItems;
}

- (UIButton *)commonAppButton {
    UIButton *button = [[UIButton alloc] initWithFrame:kBannerIconButtonFrame];
    UIImage *image = [[UIImage imageNamed:[CMPFeatureSupportControl bannerAppIcon]]cmp_imageWithTintColor:CMPThemeManager.sharedManager.iconColor];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pushCommonAppView) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)appButton {
    if (!_appButton) {
        _appButton = [self commonAppButton];
    }
    return _appButton;
}

- (UIButton *)bannerAppButton {
    if (!_bannerAppButton) {
        _bannerAppButton = [self commonAppButton];
    }
    return _bannerAppButton;
}

- (void)layoutAppButton {
    if (_appButton && [_appButton superview] == self.view) {
        _appButton.cmp_x = self.view.cmp_width - 42 - 5;
        _appButton.cmp_y = CMP_STATUSBAR_HEIGHT + 5;
    }
}

/**
 打开常用应用
 */
- (void)pushCommonAppView
{
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    NSString *aStr = kM3CommonAppUrl;
    aCMPBannerViewController.startPage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    aCMPBannerViewController.hideBannerNavBar = NO;
    aCMPBannerViewController.backBarButtonItemHidden = NO;
    aCMPBannerViewController.statusBarStyle = 0;
    [self.navigationController pushViewController:aCMPBannerViewController animated:YES];
}

#pragma mark - 第三方页面导航

- (UIButton *)forwardPageButton {
    UIButton *button = [[UIButton alloc] initWithFrame:kBannerIconButtonFrame];
    UIImage *image = [[UIImage imageNamed:@"banner_farward_page"]cmp_imageWithTintColor:CMPThemeManager.sharedManager.iconColor];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(forwardPageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)backPageButton {
    UIButton *button = [[UIButton alloc] initWithFrame:kBannerIconButtonFrame];
    UIImage *image = [[UIImage imageNamed:@"banner_back_page"]cmp_imageWithTintColor:CMPThemeManager.sharedManager.iconColor];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backPageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)bannerFarwardPageButton {
    if (!_bannerFarwardPageButton) {
        _bannerFarwardPageButton = [self forwardPageButton];
    }
    return _bannerFarwardPageButton;
}

-(UIButton *)bannerBackPageButton {
    if (!_bannerBackPageButton) {
        _bannerBackPageButton = [self backPageButton];
    }
    return _bannerBackPageButton;
}

- (void)forwardPageButtonAction:(UIButton *)sender {
    WKWebView *webView = (WKWebView *)self.webView;
    if ([webView canGoForward]) {
        [webView goForward];
    }
}

- (void)backPageButtonAction:(UIButton *)sender {
     WKWebView *webView = (WKWebView *)self.webView;
     if ([webView canGoBack]) {
         [webView goBack];
     }
}

#pragma mark-
#pragma mark 私有方法

/**
 初始化startPage
 */
- (void)_setup {
    NSString *indexPath = nil;
    if (self.itemAttribute.app) { // 中转页面
        self.hideBannerNavBar = YES;
        indexPath = [self transitPageIndexPathWithAttribute:self.itemAttribute];
    } else if (self.itemAttribute.appID) {
        indexPath = [self appIndexPathWithAttribute:self.itemAttribute];
    } else if (self.startPageUrl) {
        self.hideBannerNavBar = YES;
        indexPath = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:self.startPageUrl]];
    }
    indexPath = [indexPath appendHtmlUrlParam:@"isroot" value:@"true"];
    self.startPage = indexPath;
    self.backBarButtonItemHidden = YES;
}

- (NSString *)transitPageIndexPathWithAttribute:(CMPTabBarItemAttribute *)attr {
    CMPDBAppInfo *appInfo = [CMPAppManager appInfoWithAppId:@"52"
                                                    version:@"1.0.0"
                                                   serverId:kCMP_ServerID
                                                     owerId:kCMP_OwnerID];
    if (!appInfo.path) {
        return nil;
    }
    
    NSString *aRootPath = [CMPCachedResManager rootPathWithHost:appInfo.url_schemes version:attr.version];
    if (aRootPath) {
        NSString *indexPath = nil;
        NSString *entry = [NSString stringWithFormat:@"layout/m3-transit-page.html?id=%@", attr.appKey];
        indexPath = [aRootPath stringByAppendingPathComponent:entry];
        indexPath = [@"file://" stringByAppendingString:indexPath];
        return indexPath;
    }
    return nil;
}

- (NSString *)appIndexPathWithAttribute:(CMPTabBarItemAttribute *)attr {
    return [CMPAppManager appIndexPageWithAppId:attr.appID version:attr.version serverId:kCMP_ServerID];
}

- (BOOL)_isTopPage {
    if (!self.pageStack) {
        return NO;
    }
    return self.pageStack.count == 1;
}

- (void)uesrLogout:(NSNotification *)notif {
    //注销通知防止踢下线后，向h5发didAppear通知，导致h5发hasPendingAndMessage请求导致踢其他设备
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [((WKWebView *)self.webView) loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    [self.webView removeFromSuperview];
}


-(void)reloadData
{
//#if APPSTORE
//
//#else
    [((WKWebView *)[CMPMigrateWebDataViewController shareInstance].webViewEngine.engineWebView) reload];
    WKWebView *web = self.webView;
    if (web) {
        [web reload];
    }
//#endif
    
}

@end
