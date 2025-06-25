//
//  SyBannerViewController.m
//  M1IPhone
//
//  Created by guoyl on 12-12-5.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kBannerBarHeight 44
#define kBannerNavBarSeparatorHeight 1
#define kBannerLeftButtonsWidth 120
#define kBannerFirstLeftButtonWidth 70
#define kBannerSecondLeftButtonWidth (kBannerLeftButtonsWidth - kBannerFirstLeftButtonWidth)

#import "UIButton+CMPButton.h"
#import "CMPBannerBackButton.h"
#import "CMPBannerWebViewController.h"
#import "CMPNavigationController.h"
#import "CMPCachedUrlParser.h"
#import "CMPAppDelegate.h"
#import "CMPWebProgressLayer.h"
#import "NSObject+FBKVOController.h"
#import "UIView+CMPView.h"
#import "CMPSplitViewController.h"
#import <CMPLib/CMPAlertView.h>
#import "UIImage+RTL.h"
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/NSURL+CMPURL.h>
#import <CMPLib/RTL.h>
#import "KSSysShareManager.h"
#import "CMPSafariViewController.h"
#import "KSLogManager.h"
#import "CMPURLProtocolManager.h"
#import "CMPCommonWebviewController.h"
#import "CMPIntercepter.h"
#import "UIColor+Hex.h"
typedef NS_ENUM(NSUInteger, CMPBannerWebViewSlidDirection) {
    CMPBannerWebViewSlidLeft,
    CMPBannerWebViewSlidRight,
};

/** 多WebView，最大开启数量 **/
static int const kiPhoneMaxWebView = 50;
static int const kiPadMaxWebView = 50;
/** 多WebView，已开启WebView计数器 **/
static int webViewCounter = 0;

@interface CMPBannerWebViewController ()<UIGestureRecognizerDelegate,UIScrollViewDelegate,CMPNavigationControllerProtocol> {
    CMPBannerBackButton *_backButton; // 返回按钮
    UIButton *_closeButton; // 关闭按钮
    CMPWebProgressLayer *_progressLayer; // 网页加载进度条
}

@property (nonatomic, strong) UIButton *orientationButton;
@property (nonatomic, strong) UIButton *closeRotateButton;

@property (nonatomic, strong) UIImageView *screenShotImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) BOOL isHiddenStatusBar;

@property (nonatomic, strong) UIView *gestureBackView;//适配wkwebview手势事件被preventDefault阻止


@end

@implementation CMPBannerWebViewController

- (void)dealloc {
    if (self.viewLoaded) {
        webViewCounter--;
        DDLogDebug(@"zl---BannerWebView销毁，当前count=%d", webViewCounter);
    }
   
    [self.webView removeObserver:self forKeyPath:@"title"];
   
    self.viewWillClose = nil;
    [_pageStack removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    webViewCounter++;
    DDLogDebug(@"zl---新开BannerWebView，当前count=%d", webViewCounter);
    
    _statusBarView.hidden = self.hideBannerNavBar;
    [self setupNaviBar];
    [self showCloseButton:YES];
    if ([_bannerViewTitle length] > 0) {
        [self updateBannerView];
    }
    self.backBarButtonItemHidden = _backBarButtonItemHidden;
    self.isShowOrientationButton = _isShowOrientationButton;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewHistoryDidChange:)name:@"WebHistoryItemChangedNotification"object:nil];
    self.webView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    // 初始化pageStack
    [self setupRootPage];
    
    //添加滑动手势,处理导航栏隐藏问题
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self.view addGestureRecognizer:self.panGesture];
    self.panGesture.delegate = self;
    self.panGesture.enabled = NO;
   
    //获取h5 标题，低版本某些页面没有调用cordova 插件
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    if (self.isSupportOSystemShare && _bannerNavigationBar) {
        UIButton *shareBtn = [UIButton buttonWithImageName:@"nav_more" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
        [shareBtn addTarget:self action:@selector(_shareAct:) forControlEvents:UIControlEventTouchUpInside];
        [_bannerNavigationBar insertRightBarButtonItem:shareBtn];
    }

    if (self.presentAlphaBgColor.length) {
        self.view.backgroundColor = [UIColor RGBA:self.presentAlphaBgColor];
//        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.webView.backgroundColor = UIColor.clearColor;
    }
    
}

-(void)_shareAct:(UIBarButtonItem *)item
{
    if (self.currentURL.absoluteString.length>0) {
        NSURL *url = self.currentURL;
        [[KSSysShareManager shareInstance] presentActivityViewControllerOn:self sourceView:self.view shareItemsArr:@[url] unSupportTypes:@[] completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

            if (completed && !activityError) {

            }else{

            }
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView &&[keyPath isEqualToString:@"title"]){
         //获取h5 标题，低版本某些页面没有调用cordova 插件
        self.title = ((WKWebView * )self.webView).title;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)panGesture:(UIPanGestureRecognizer *)recognize {
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        return;
    }
    CGPoint panPoint = [recognize translationInView:self.view];
    //隐藏导航栏
    if (panPoint.y <= -kBannerBarHeight) {
        [recognize setTranslation:CGPointMake(0, 0) inView:self.view];
        [self showAnimatedNavBar:NO];
    }else if (panPoint.y >= kBannerBarHeight){
        [recognize setTranslation:CGPointMake(0, 0) inView:self.view];
        [self showAnimatedNavBar:YES];
    }
}

- (void)setupNavigationBarHidden {
    //小致界面重写
    self.navigationController.navigationBarHidden = [self navigationBarHidden];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupNavigationBarHidden];
    
    if([self allowPopGesture ] && !_gestureBackView) {
         //适配wkwebview手势事件被preventDefault阻止
         _gestureBackView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIView isRTL]?self.webView.width-10:0, 10, self.webView.height)];
         [self.webView addSubview:_gestureBackView];
     }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (self.isShowOrientationButton) {
        if (DeviceInterfaceOrientationIsPortrait()) {
            [self showOrientationButton:YES];
        }else{
            [self showCloseRotateButton:YES];
        }
    }
}

-(void)hiddenBarWhenLandscape{
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
        // [self showNavBarforWebView:YES];
    }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [[UIApplication sharedApplication]setStatusBarHidden:YES];
        //[self showNavBarforWebView:NO];
    }
}

- (UIButton *)addBannerButtonWithImageName:(NSString *)imageName action:(SEL)action type:(NSInteger)aType;
{
    return [UIButton buttonWithImage:[UIImage imageNamed:imageName]];
}

- (void)closeViewController
{
    if (self.viewWillClose) {
        self.viewWillClose();
        self.viewWillClose = nil;
    }
    // do back
    BOOL aAnimated = !self.disableAnimated;
    if (self.navigationController) {
        if (self.navigationController.viewControllers[0] == self) { // 是RootView
            [self.navigationController dismissViewControllerAnimated:aAnimated completion:^{
                if (self.dismissCompletionBlock) {
                    self.dismissCompletionBlock();
                }
            }];
        }
        else {
            if (!self.navigationController.delegate) {
                self.navigationController.delegate = self;
            }
            if (CMP_IPAD_MODE) {
               [self cmp_clearDetailViewController];
            }
            [self.navigationController popViewControllerAnimated:aAnimated];
        }
    }
    else {
        [self dismissViewControllerAnimated:aAnimated completion:^{
            if (self.dismissCompletionBlock) {
                self.dismissCompletionBlock();
            }
        }];
    }
}

- (void)backBarButtonAction:(id)sender
{
    if (_backButtonDidClick) {
        _backButtonDidClick();
    } else {
        if ([CMPCore sharedInstance].serverIsLaterV7_1) {
            BOOL isLocalHref = [((WKWebView *)self.webView).URL isFileURL];
            if (isLocalHref) {
                [self closeViewController];
            } else { //第三方页面
                [self goBack];
            }
        } else {
            [self goBack];
        }
    }
}

- (void)goBack {
    if ([self canGoBack]) {
        WKWebView *wk = (WKWebView *)self.webView;
        BOOL currentIsLocal = [wk.URL isFileURL];
        [wk goBack];
        __weak typeof(self) weakSelf = self;
        __weak typeof(wk) weakWk = wk;
        self.goBackCompleteBloack = ^{
            BOOL nextIsLocal = [weakWk.URL isFileURL];
            if (!currentIsLocal && nextIsLocal) {
                //从网页到本地页面 可能是中转界面，估计还有问题
                [weakSelf closeViewController];
            }
        };
        return;
    }
    [self closeViewController];
}

- (BOOL)canGoBack {
//    __block BOOL canGoBack = NO;
//    [self.webViewEngine evaluateJavaScript:@"window.history.length" completionHandler:^(id object, NSError *error) {
//        if ([object integerValue] > 1) {
//            canGoBack = YES;
//        }
//    }];
    return [(WKWebView *)self.webView canGoBack];
}

- (BOOL)navigationBarHidden
{
    return YES;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.hideBannerNavBar = YES;
        self.isShowBannerProgress = NO;//默认不展示进度条
        self.closeButtonHidden = YES;
    }
    return self;
}

- (void)setupNaviBar
{
    //_statusBarView.hidden = self.hideBannerNavBar;
    if (self.hideBannerNavBar && _bannerNavigationBar) {
        [_bannerNavigationBar removeFromSuperview];
        return;
    }
    if (_bannerNavigationBar){
        if (!_bannerNavigationBar.superview) {
            [self.view addSubview:_bannerNavigationBar];
        }
        [self setTitle:self.bannerViewTitle];
        [self reLayoutSubViews];
        return;
        
    };
    CGRect mainFrame = [super mainFrame];
    CGRect f = CGRectMake(0, mainFrame.origin.y, mainFrame.size.width, [self bannerBarHeight]);
    _bannerNavigationBar = [[CMPBannerNavigationBar alloc] initWithFrame:f];
    __weak typeof(self) weakSelf = self;
    _bannerNavigationBar.bannerTitleClicked = ^{
        
        [weakSelf addH5Listener];
    };
    UIColor *aColor = [self bannerNavigationBarBackgroundColor];
    if (aColor) {
        [_bannerNavigationBar setBannerBackgroundColor:aColor];
        self.view.backgroundColor = aColor;
    }
    [self.view addSubview:_bannerNavigationBar];
    [_bannerNavigationBar addBottomLine];
    if (_titleType != CMPBannerTitleTypeCenter && _titleType != CMPBannerTitleTypeNull) {
        _bannerNavigationBar.titleType = _titleType;
    } else {
        _titleType = [self bannerTitleType];
        _bannerNavigationBar.titleType = [self bannerTitleType];
    }
     [self setTitle:self.bannerViewTitle];
    
    if (self.hideBannerNavBar) {
        [_bannerNavigationBar removeFromSuperview];
    }
}

- (CMPBannerTitleType)bannerTitleType {
    return CMPBannerTitleTypeCenter;
}

///取消按钮点击后，通知给H5
- (void)addH5Listener {
    NSString *js = [NSString stringWithFormat:@"cmp.event.trigger('CMPHeaderTitleTrigger', document, {})"];
    [self.commandDelegate evalJs:js];
}

////OA-114074 iPhone客户端，键盘弹出的情况下。当手机锁屏后，再次开启，进入到手势密码页面。键盘不能收起
//- (void)resignKeyboard:(NSNotification *)noti
//{
//    if (self.webViewEngine) {
//        [self.webViewEngine evaluateJavaScript:@"var cmpFocusFiled = document.querySelector(':focus');\
//         if (cmpFocusFiled) { \
//         cmpFocusFiled.blur();\
//         }" completionHandler:nil];
//    }
//}

- (BOOL)shouldOverrideLoadWithRequest:(NSURLRequest*)request navigationType:(WKNavigationType)navigationType
{
    BOOL shouldRequest = [super shouldOverrideLoadWithRequest:request navigationType:navigationType];
    BOOL isMainFrameRequest = [request.URL.absoluteString isEqualToString:request.mainDocumentURL.absoluteString];
    if (shouldRequest && isMainFrameRequest) {
        self.backButtonDidClick = nil;
    }
    return shouldRequest;
}

- (void)pageDidStart:(NSNotification *)notification{
    CGFloat progressY = IS_IPHONE_X_UNIVERSAL ? 88 : 64;
    progressY -= 1;
    if (self.hideBannerNavBar) {
        progressY -= 43;
    }
    if (self.isShowBannerProgress) {
        if (_progressLayer) {
            [self progressFinishedLoad];
        }
        _progressLayer = [CMPWebProgressLayer layerWithFrame:CGRectMake(0, progressY, CMP_SCREEN_WIDTH, 3)];
        [self.view.layer addSublayer:_progressLayer];
        [_progressLayer startLoad];
    }
}

- (void)pageLoadError:(NSNotification *)notification {
    [self progressFinishedLoad];
    if (self.goBackCompleteBloack) {
        self.goBackCompleteBloack();
        self.goBackCompleteBloack = nil;
    }
}

- (void)pageDidLoad:(NSNotification *)notification {
    [self progressFinishedLoad];
    //如果是http远程url地址,始终显示关闭按钮
    if (self.currentURL && !self.currentURL.isFileURL) {
        [self forceShowCloseButton];
    }
    if (self.goBackCompleteBloack) {
        self.goBackCompleteBloack();
        self.goBackCompleteBloack = nil;
    }
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        Class WebViewPlugin = NSClassFromString(@"WebViewPlugin");
//        SEL FocusMenuFromVC = NSSelectorFromString(@"FocusMenuFromVC:");
//        id wp = [[WebViewPlugin alloc] init];
//        if ([wp respondsToSelector:FocusMenuFromVC]) {
//            [wp performSelector:FocusMenuFromVC withObject:self];
//        }
//    });

}


-(void)webViewHistoryDidChange:(NSNotification *)notification {
//    BOOL isLocalHref =  [[NSURL URLWithPathString:self.startPage] isFileURL];;
//    if (isLocalHref) {
//        return;
//    }
    __weak typeof(self) weakSelf = self;
    [self.webViewEngine evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError *error) {
        if (!weakSelf.hideBannerNavBar) {
            [weakSelf setTitle:title];
        }
    }];
}

#pragma mark - progress

- (void)progressFinishedLoad {
    [_progressLayer finishedLoad];
    _progressLayer = nil;
}

#pragma mark - 旋转
- (UIButton *)rotateButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_switch_direction" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(rotateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)closeRotateButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_close_rotate" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(closeRotateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)rotateButtonAction:(UIButton *)button {
    if (@available(iOS 16.0, *)) {
        SEL ss = NSSelectorFromString(@"setNeedsUpdateOfSupportedInterfaceOrientations");
        if (self && [self respondsToSelector:ss]) {
            [self performSelector:ss];
        }
    }
    [UIDevice newApiForSetOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)closeRotateButtonAction:(UIButton *)button {
    if (@available(iOS 16.0, *)) {
        SEL ss = NSSelectorFromString(@"setNeedsUpdateOfSupportedInterfaceOrientations");
        if (self && [self respondsToSelector:ss]) {
            [self performSelector:ss];
        }
    }
    [UIDevice newApiForSetOrientation:UIInterfaceOrientationPortrait];
}
/*
- (void)editButtonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OfficeEditEvent" object:nil];
    [self backBarButtonAction:nil];
}

- (UIButton *)editButton
{
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = kBannarButtonFrame;
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return editButton;
}
*/
- (void)showOrientationButton:(BOOL)isShow{
    NSMutableArray *items = nil;
    if (isShow) {
        if (!_orientationButton) {
            _orientationButton = [self rotateButton];
        }
        items = [NSMutableArray arrayWithObject:_orientationButton];
    } else {
        _orientationButton = nil;
    }
  /*  NSDictionary *options = [self.param objectForKey:@"options"];
    BOOL showEditButton = [[options objectForKey:@"showEditButton"] boolValue];
    showEditButton = YES;
    if (showEditButton) {
        [items addObject:[self editButton]];
    }*/
    [self.bannerNavigationBar setRightBarButtonItems:items];
}

- (void)showCloseRotateButton:(BOOL)isShow{
    NSMutableArray *items = nil;
    if (isShow) {
        if (!_closeRotateButton) {
            _closeRotateButton = [self closeRotateButton];
        }
        items = [NSMutableArray arrayWithObject:_closeRotateButton];
    }else{
        _closeRotateButton = nil;
    }
    if (!_bannerNavigationBar) {
        [self setupNaviBar];
    }
/*   NSDictionary *options = [self.param objectForKey:@"options"];
    BOOL showEditButton = [[options objectForKey:@"showEditButton"] boolValue];
    showEditButton = YES;
    if (showEditButton) {
        [items addObject:[self editButton]];
    }*/
    [self.bannerNavigationBar setRightBarButtonItems:items];
}

- (void)setDefaultBackButtonAndCloseButton {
    self.backBarButtonItemHidden = _backBarButtonItemHidden;
    [self showCloseButton:YES];
}


- (void)showBackButton:(BOOL)aShow
{
    if (!aShow) {
        _backButton = nil;
        NSArray *aButtons = nil;
        if (_closeButton) {
            // 只有关闭按钮，展示图标+文字
            if (CMPFeatureSupportControl.isBannarCloseButtonShowText) {
                _closeButton.frame = CGRectMake(0, 0, kBannerFirstLeftButtonWidth, 44);
                UIImage * aCloseImage = [[UIImage imageNamed:@"banner_close"] cmp_imageWithTintColor:[CMPThemeManager sharedManager].iconColor];
                if (self.bannerNavigationBar.isSetNavigationBarGlobalStyle) {
                    aCloseImage = [aCloseImage cmp_imageWithTintColor:self.bannerNavigationBar.globalColor];
                }
                [_closeButton setImage:aCloseImage forState:UIControlStateNormal];
                _closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            }
            aButtons = [NSArray arrayWithObjects:_closeButton, nil];
        }
        [self.bannerNavigationBar setLeftBarButtonItems:aButtons];
        return;
    }
    if (!_backButton) {
        _backButton = [CMPBannerBackButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, kBannerFirstLeftButtonWidth, 44);
        [_backButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    UIImage *aImage = [self backButtonImage];
    [_backButton setImage:aImage forState:UIControlStateNormal];
  
    UIColor *color = nil;
    if (self.bannerNavigationBar.isSetNavigationBarGlobalStyle) {
        color = self.bannerNavigationBar.globalColor;
    }else{
        color = [CMPThemeManager sharedManager].iconColor;
    }
    if (CMPFeatureSupportControl.isBannarBackButtonShowText) {
        NSAttributedString *backButtonTitle = [[NSAttributedString alloc]
                                               initWithString:SY_STRING(@"common_back")
                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16 weight:UIFontWeightMedium],
                                                            NSForegroundColorAttributeName : color}];
        [_backButton setAttributedTitle:backButtonTitle forState:UIControlStateNormal];
    } else {
        _backButton.frame = CGRectMake(0, 0, kBannerSecondLeftButtonWidth, 44);
    }
    NSArray *aButtons = nil;
    if (_closeButton && self.backButtonStyle == 0) {
        if (CMPFeatureSupportControl.isBannarCloseButtonShowText) {
            _closeButton.frame = CGRectMake(0, 0, kBannerSecondLeftButtonWidth, 44);
            [_closeButton setImage:nil forState:UIControlStateNormal];
            _closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        }
        aButtons = [NSArray arrayWithObjects:_backButton, _closeButton, nil];
    }
    else {
        aButtons = [NSArray arrayWithObjects:_backButton, nil];
    }
    [self.bannerNavigationBar setLeftBarButtonItems:aButtons];
}

- (void)showCloseButton:(BOOL)aShow
{
    if (!aShow || _closeButtonHidden || self.backButtonStyle == 1 || !self.autoShowBackButton) {
        NSArray *aButtons = nil;
        if (_backButton) {
            aButtons = [NSArray arrayWithObjects:_backButton, nil];
        }
        if (!self.bannerNavigationBar.isBannarAddLeftButtonItems) {
            [self.bannerNavigationBar setLeftBarButtonItems:aButtons];
        }
        _closeButton = nil;
        return;
    }
    [self forceShowCloseButton];
    /*if (!_closeButton) {
        //        UIImage *aCloseImage = [UIImage imageNamed:@"CMPBannerButton.bundle/ic_banner_close.png"];
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [_closeButton setImage:aCloseImage forState:UIControlStateNormal];
        UIColor *color = nil;
        if (self.bannerNavigationBar.isSetNavigationBarGlobalStyle) {
            color = self.bannerNavigationBar.globalColor;
        }else{
            color = [CMPThemeManager sharedManager].iconColor;
        }
        NSAttributedString *closeButtonTitle = [[NSAttributedString alloc]
                                                initWithString:SY_STRING(@"common_close")
                                                attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16 weight:UIFontWeightMedium],
                                                             NSForegroundColorAttributeName :color}];
        [_closeButton setAttributedTitle:closeButtonTitle forState:UIControlStateNormal];
        _closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        _closeButton.frame = CGRectMake(0, 0, kBannerSecondLeftButtonWidth, 44);
        [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    NSArray *aButtons = nil;
    if (_backButton) {
        aButtons = [NSArray arrayWithObjects:_backButton, _closeButton, nil];
    }
    else {
        aButtons = [NSArray arrayWithObjects:_closeButton, nil];
    }
    if (!self.bannerNavigationBar.isBannarAddLeftButtonItems) {
        [self.bannerNavigationBar setLeftBarButtonItems:aButtons];
    }
     */
}

- (void)forceShowCloseButton
{
    if (!_closeButton) {
        //        UIImage *aCloseImage = [UIImage imageNamed:@"CMPBannerButton.bundle/ic_banner_close.png"];
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [_closeButton setImage:aCloseImage forState:UIControlStateNormal];
        UIColor *color = nil;
        if (self.bannerNavigationBar.isSetNavigationBarGlobalStyle) {
            color = self.bannerNavigationBar.globalColor;
        }else{
            color = [CMPThemeManager sharedManager].iconColor;
        }
        if (CMPFeatureSupportControl.isBannarCloseButtonShowText) {
            NSAttributedString *closeButtonTitle = [[NSAttributedString alloc]
                                                           initWithString:SY_STRING(@"common_close")
                                                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16 weight:UIFontWeightMedium],
                                                                        NSForegroundColorAttributeName :color}];
            [_closeButton setAttributedTitle:closeButtonTitle forState:UIControlStateNormal];
            _closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        } else {
            UIImage * aCloseImage = [[UIImage imageNamed:@"banner_new_close"] cmp_imageWithTintColor:[CMPThemeManager sharedManager].iconColor];
            if (self.bannerNavigationBar.isSetNavigationBarGlobalStyle) {
               aCloseImage = [aCloseImage cmp_imageWithTintColor:self.bannerNavigationBar.globalColor];
            }
            [_closeButton setImage:aCloseImage forState:UIControlStateNormal];
            _closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
        }
        _closeButton.frame = CGRectMake(0, 0, kBannerSecondLeftButtonWidth, 44);
        [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    NSArray *aButtons = nil;
    if (_backButton) {
        aButtons = [NSArray arrayWithObjects:_backButton, _closeButton, nil];
    }
    else {
        aButtons = [NSArray arrayWithObjects:_closeButton, nil];
    }
    if (!self.bannerNavigationBar.isBannarAddLeftButtonItems) {
        [self.bannerNavigationBar setLeftBarButtonItems:aButtons];
    }
}

- (void)closeButtonAction:(id)sender
{
    [self closeViewController];
}

- (CGFloat)bannerBarHeight
{
    if (self.hideBannerNavBar) {
        return 0.0f;
    }
    if (self.bannerTitleType == CMPBannerTitleTypeCenter) {
        return kBannerBarHeight;
    } else {
        return CMPFeatureSupportControl.bannerHeight;
    }
}

- (CGRect)mainFrame
{
    CGRect mainFrame = [super mainFrame];
    if (!_hideBannerNavBar) {
        mainFrame.origin.y += self.bannerBarHeight;
        mainFrame.size.height -= self.bannerBarHeight;
    }
    return mainFrame;
}

- (void)layoutSubviewsWithFrame:(CGRect)frame
{
    CGRect noBannerFrame = [super mainFrame];
    CGRect haveBannerFrame = frame;
    
    _bannerNavigationBar.frame = CGRectMake(noBannerFrame.origin.x, noBannerFrame.origin.y, noBannerFrame.size.width, [self bannerBarHeight]);
    
    // 适配iOS 11 safe area
    if (@available(iOS 11.0, *)) {
        CGFloat h = 0;
        if (@available(iOS 16.0, *)) {
            UIEdgeInsets ins = self.view.safeAreaInsets;
            CGFloat st = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;
            if (ins.top > st){
                h = ins.top - st;
            }
        }
        if (self.hideBannerNavBar) {
            self.webView.frame = CGRectMake(noBannerFrame.origin.x, -CMP_STATUSBAR_HEIGHT-h, noBannerFrame.size.width, noBannerFrame.size.height + CMP_STATUSBAR_HEIGHT+h);
        } else {
            if (_hideBannerNavBar) {
                self.webView.frame = CGRectMake(noBannerFrame.origin.x, noBannerFrame.origin.y, noBannerFrame.size.width, noBannerFrame.size.height);
            }else{
                self.webView.frame = CGRectMake(noBannerFrame.origin.x, haveBannerFrame.origin.y, noBannerFrame.size.width, haveBannerFrame.size.height);
            }
        }
        if (self.presentAlphaBgColor.length) {//present全屏web
            CGFloat bottomPadding = CMP_SafeBottomMargin_height;
            if (@available(iOS 11.0, *)) {
                bottomPadding = self.view.safeAreaInsets.bottom;
            }
            CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
            CGFloat statusBarHeight = MIN(statusBarFrame.size.width, statusBarFrame.size.height);

            self.webView.frame = CGRectMake(noBannerFrame.origin.x, -statusBarHeight-h, noBannerFrame.size.width, noBannerFrame.size.height + statusBarHeight+h + bottomPadding);
        }
    } else {
        //     add by guoyl for cordova webview
        self.webView.frame = CGRectMake(noBannerFrame.origin.x, haveBannerFrame.origin.y, noBannerFrame.size.width, haveBannerFrame.size.height);
    }
    
    [self updateBannerView];
    if (_gestureBackView) {
        [_gestureBackView setFrame:CGRectMake(0, [UIView isRTL]?self.webView.width-10:0, 10, self.webView.height)];
    }
}


- (void)updateBannerView {
    [self.bannerNavigationBar autoLayout];
}

- (void)setTitle:(NSString *)title {
    self.bannerViewTitle = title;
//    if ([NSString isNull:title]) {
//        return;
//    }
    if (!self.bannerNavigationBar) {
        return;
    }
    self.bannerNavigationBar.titleType = self.titleType;
    [self.bannerNavigationBar updateBannerTitle:title];
    [self updateBannerView];
}

- (void)setBackBarButtonItemHidden:(BOOL)backBarButtonItemHidden
{
    _backBarButtonItemHidden = backBarButtonItemHidden;
    if (!self.bannerNavigationBar) {
        return;
    }
    self.bannerNavigationBar.leftMargin = 0.0f;
    [self showBackButton:!backBarButtonItemHidden];
}

- (void)setIsShowOrientationButton:(BOOL)isShowOrientationButton{
    _isShowOrientationButton = isShowOrientationButton;
    if (isShowOrientationButton) {
        self.allowRotation = isShowOrientationButton;
    }
    if (!self.bannerNavigationBar) {
        return;
    }
    if (DeviceInterfaceOrientationIsPortrait()) {
        [self showOrientationButton:isShowOrientationButton];
    } else {
        [self showCloseRotateButton:isShowOrientationButton];
    }
}


- (void)showLoadingViewWithText:(NSString *)aStr
{
    [super showLoadingViewWithText:aStr];
}

- (void)hideLoadingView
{
    [super hideLoadingView];
}

- (UIColor *)bannerNavigationBarBackgroundColor
{
    return [UIColor cmp_colorWithName:@"white-bg"];
}

- (UIColor *)statusBarColorForiOS7
{
    return [UIColor cmp_colorWithName:@"white-bg"];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.statusBarStyle == 1) {
        return UIStatusBarStyleLightContent;
    }
    return [CMPThemeManager sharedManager].automaticStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return self.isHiddenStatusBar;
}

- (BOOL)isOptimizationStatusBarForiOS7 {
    return !self.hideBannerNavBar;
}

- (void)setStartPage:(NSString *)startPage {
    [super setStartPage:startPage];
    if ([startPage containsString:@"useNativebanner=1"]) {
        [self showNavBar:YES];
        if (self.autoShowBackButton) {
            self.backBarButtonItemHidden = NO;
        }
    }
    
    
}

- (void)setShowBannerProgress:(NSString *)isShowBannerProgress {
    self.isShowBannerProgress = isShowBannerProgress.boolValue;
}


- (void)setCloseButtonHidden:(BOOL)closeButtonHidden
{
    _closeButtonHidden = closeButtonHidden;
//    _closeButton.hidden = _closeButtonHidden;
    [self showCloseButton:YES];
}

- (void)showNavBarforWebView:(NSNumber *)aValue
{
    //0. 隐藏 1.显示 2.隐藏且可以下拉显示 3.显示且可以上划隐藏下拉显示
    NSInteger number = aValue.intValue;
    if (number == 0) {
        [self showNavBar:NO];
        self.panGesture.enabled = NO;
        self.isHiddenStatusBar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    } else if (number == 1){
        [self showNavBar:YES];
        self.panGesture.enabled = NO;
        self.isHiddenStatusBar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }else if(number == 2){
        [self showNavBar:NO];
        self.panGesture.enabled = YES;
        self.isHiddenStatusBar = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }else if(number == 3){
        [self showNavBar:YES];
        self.panGesture.enabled = YES;
        self.isHiddenStatusBar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    if (self.autoShowBackButton) {
        BOOL isHidden = (number == 0);
        [self setBackBarButtonItemHidden:isHidden];
    }
    
}

- (void)showNavBar:(BOOL)aValue
{
    _statusBarView.hidden = !aValue;
    if (InterfaceOrientationIsLandscape) {
        _statusBarView.hidden = YES;
    }
    _hideBannerNavBar = !aValue;
    if (self.isViewLoaded) {
        [self setupNaviBar];
        [self layoutSubviewsWithFrame:[self mainFrame]];
    }
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    if (_progressLayer) {
        CGFloat progressY = IS_IPHONE_X_UNIVERSAL ? 88 : 64;
        progressY -= 1;
        if (self.hideBannerNavBar) {
            progressY -= 43;
        }
        _progressLayer.frame = CGRectMake(0, progressY, CMP_SCREEN_WIDTH, 3);
    }
}

- (void)showAnimatedNavBar:(BOOL)isShow
{
    _hideBannerNavBar = !isShow;
    CGRect mainFrame = [self mainFrame];
    _statusBarView.hidden = YES;
    
    if (isShow) {
        if (!_bannerNavigationBar.superview){
            _bannerNavigationBar.frame = CGRectMake(mainFrame.origin.x,-[self bannerBarHeight], mainFrame.size.width, [self bannerBarHeight]);
            [self.view addSubview:_bannerNavigationBar];
            [_bannerNavigationBar autoLayout];
            [UIView animateWithDuration:0.3 animations:^{
                self.bannerNavigationBar.frame = CGRectMake(mainFrame.origin.x,0, mainFrame.size.width, [self bannerBarHeight]);
                self.webView.frame = CGRectMake(mainFrame.origin.x, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height);
            } ];
        }
    } else{
        if (_bannerNavigationBar.superview) {
            [UIView animateWithDuration:0.3 animations:^{
                self.webView.frame = CGRectMake(mainFrame.origin.x, [self bannerBarHeight], mainFrame.size.width, mainFrame.size.height);
                self.bannerNavigationBar.frame = CGRectMake(mainFrame.origin.x,-self->_bannerNavigationBar.frame.size.height, mainFrame.size.width, self->_bannerNavigationBar.frame.size.height);
            } completion:^(BOOL finished) {
                [self.bannerNavigationBar removeFromSuperview];
            }];
        }
    }
    
    [self updateLoadingViewFrame];
    
}

- (BOOL)autoShowBackButton {
    return YES;
}

- (void)setBackButtonStyle:(NSInteger)aType
{
    _backButtonStyle = aType;
    [self showBackButton:YES];
}

- (UIImage *)backButtonImage
{
    UIImage *image = nil;
    NSString *imageName = nil;
    if (self.backButtonStyle == 1) {
        if (CMPFeatureSupportControl.isBannarBackButtonShowText) {
            imageName = @"banner_close";
        } else {
            imageName = @"banner_new_close";
        }
        image = [[UIImage imageNamed:imageName] cmp_imageWithTintColor:[CMPThemeManager sharedManager].iconColor];
        if (self.bannerNavigationBar.isSetNavigationBarGlobalStyle) {
            image = [image cmp_imageWithTintColor:self.bannerNavigationBar.globalColor];
        }
        return image;
    }
    
    if (CMPFeatureSupportControl.isBannarBackButtonShowText) {
        imageName = @"banner_return";
    } else {
        imageName = @"banner_new_return";
    }
    image = [[UIImage imageNamedAutoRTL:imageName] cmp_imageWithTintColor:[CMPThemeManager sharedManager].iconColor];
    if (self.bannerNavigationBar.isSetNavigationBarGlobalStyle) {
        image = [image cmp_imageWithTintColor:self.bannerNavigationBar.globalColor];
    }
    return image;
}

// 多webview
- (void)setupRootPage
{
    if (!_pageStack) {
        _pageStack = [[NSMutableArray alloc] init];
        if (self.pageParam) {
            [_pageStack addObject:self.pageParam];
        }
        else {
            NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:self.startPage, @"url", nil];
            [_pageStack addObject:aDict];
        }
    }
}

// 打开html页面
- (void)pushPage:(NSDictionary *)aParam
{
    if ([aParam isKindOfClass:[NSString class]]) {
        aParam = [(NSString *)aParam JSONValue];
    }
    if (!aParam) {
        NSLog(@"打开参数为空");
        return;
    }
    
    //记录pushPage点击
//    NSMutableDictionary *mD = [NSMutableDictionary dictionaryWithDictionary:aParam];
//    if (self.pageParam) {
//        [mD setValue:self.pageParam forKey:@"hasRecordPageParam"];
//    }
    if (!self.hasRecordTopScreenClick) {
        self.hasRecordTopScreenClick = YES;
        Class CMPTopScreenManager = NSClassFromString(@"CMPTopScreenManager");
        id instance = [[CMPTopScreenManager alloc] init];
        if ([instance respondsToSelector:NSSelectorFromString(@"pushPageClickByParam:")]) {
            [instance performSelector:NSSelectorFromString(@"pushPageClickByParam:") withObject:aParam];
        }
    }
    
    // 存储当前的
    NSString *href = [aParam objectForKey:@"url"];
    href = [href urlCFEncoded];
    // add by guoyl for custom
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
    
    if ([NSString isNotNull:localHref]) {
        href = localHref;
    }
    
    // pushRoot情况
    BOOL root = [[aParam objectForKey:@"root"] boolValue];
    if (root) {
        [_pageStack removeAllObjects];
    }
    
    // 判断当前是否新开webview
    NSDictionary *options = [aParam objectForKey:@"options"];
    BOOL openWebview = [[options objectForKey:@"openWebview"] boolValue]; // 是否新开webview
    BOOL animated = [[options objectForKey:@"animated"] boolValue]; // 是否动画
    BOOL useNativebanner = [[options objectForKey:@"useNativebanner"] boolValue];
    BOOL replaceTop = [[options objectForKey:@"replaceTop"] boolValue]; // 是否替换栈顶
    BOOL showOrientationButton = [[options objectForKey:@"showOrientationButton"] boolValue]; // 是否默认展示横竖屏切换按钮
    
    // 清空内容区，在内容区展示新页面，仅在 iPad 且 openWebview为YES时生效
    BOOL pushPageInDetail = [[options objectForKey:@"pushInDetailPad"] boolValue];
    // 清空内容区域，仅在iPad 且 openWebview为YES 且 pushInDetailPad为NO时生效
    BOOL clearDetailPage = [options objectForKey:@"clearDetailPad"] ? [[options objectForKey:@"clearDetailPad"] boolValue] : YES;
    BOOL isSupportOSystemShare = [[options objectForKey:@"isSupportOSystemShare"] boolValue];
    
    // 如果WebView的数量到达阈值，不打开新的WebView
    if ([[self class] isWebViewMaxCount]) {
        openWebview = NO;
        self.isTailWebView = YES;
    }
    NSLog(@"ks log --- pushPage:\nhref--%@\nparam--%@",href,aParam);
    //不拦截的跳转
    BOOL noIntercept = ![[CMPIntercepter sharedInstance] needIntercept:href];
    if(noIntercept){
        [[NSNotificationCenter defaultCenter]postNotificationName:kNoInterceptJumpNotification object:self userInfo:@{@"url":href}];
        return;
    }
    
    // 判断是否新开webview
    if (openWebview) {
        self.isLandscapeWhenPushChildController = !DeviceInterfaceOrientationIsPortrait();
        UIViewController *vc;
        NSURL *toUrl = [NSURL URLWithString:href];
        NSInteger openact = [CMPBannerWebViewController actionTypeWithUrl:href];
        switch (openact) {
            case 1:
            {
                CMPSafariViewController *safari = [[CMPSafariViewController alloc] initWithURL:toUrl];
                vc = safari;
                if ([self isKindOfClass:NSClassFromString(@"CMPTabBarWebViewController")]) {
                    [self addChildViewController:safari];
                    [self.view addSubview:safari.view];
                    [safari.view mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.edges.offset(0);
                    }];
                }else{
                    [self presentViewController:vc animated:YES completion:^{
                        
                    }];
                }
                return;
            }
                break;
            case 2:
            {
                if ([self isKindOfClass:NSClassFromString(@"CMPTabBarWebViewController")]) {
                    CMPSafariViewController *safari = [[CMPSafariViewController alloc] initWithURL:toUrl];
                    [self addChildViewController:safari];
                    [self.view addSubview:safari.view];
                    [safari.view mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.edges.offset(0);
                    }];
                    return;
                }else{
                    if ([[UIApplication sharedApplication] canOpenURL:toUrl]) {
                        if (@available(iOS 10.0,*)) {
                            [[UIApplication sharedApplication] openURL:toUrl options:nil completionHandler:^(BOOL success) {
                                                        
                            }];
                        }else{
                            [[UIApplication sharedApplication] openURL:toUrl];
                        }
                        return;
                    }
                }
            }
                break;
            case 3:
            {
                CMPCommonWebViewController *safari = [[CMPCommonWebViewController alloc] initWithURL:toUrl];
                safari.needNav = useNativebanner;
                vc = safari;
                if ([self isKindOfClass:NSClassFromString(@"CMPTabBarWebViewController")]) {
                    [self addChildViewController:safari];
                    [self.view addSubview:safari.view];
                    [safari.view mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.edges.offset(0);
                    }];
                }else{
                    [self pushVc:vc inVc:self inDetail:pushPageInDetail clearDetail:clearDetailPage animate:NO];
                }
                return;
            }
                break;
            default:
                break;
        }
        // 如果新开webview，不需要入当前page堆栈
        CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
        aCMPBannerViewController.hasRecordTopScreenClick = self.hasRecordTopScreenClick;
        aCMPBannerViewController.pageParam = aParam;
        aCMPBannerViewController.hideBannerNavBar = !useNativebanner;
        // TODO: 默认展示横屏切换按钮
        if ([NSString isNotNull:localHref]) {
            aCMPBannerViewController.allowRotation = ((CMPBannerWebViewController *)self.navigationController.topViewController).allowRotation;
        }else {
            //OA-211225 【70-m3】移动端穿透后的分析云报表页面有两个表头，且点击返回按钮一直在刷新当前页面
            //当是第三方APP时，显示关闭按钮
            aCMPBannerViewController.closeButtonHidden = NO;
        }
        aCMPBannerViewController.startPage = href;
        if (showOrientationButton) {
            aCMPBannerViewController.isShowOrientationButton = YES;
        }
//        if (useNativebanner) {
            aCMPBannerViewController.isSupportOSystemShare = isSupportOSystemShare;
//        }
        vc = aCMPBannerViewController;
        
        [self pushVc:vc inVc:self inDetail:pushPageInDetail clearDetail:clearDetailPage animate:animated];
    }
    else {
        // 替换栈顶
        if (replaceTop && _pageStack.count !=0) {
            [_pageStack removeLastObject];
        }
        // 当前webview，需要入当前page堆栈
        [_pageStack addObject:aParam];
        [self _loadUrl:href showNavBar:useNativebanner isSupportOSystemShare:isSupportOSystemShare];
        if (showOrientationButton) {
            self.isShowOrientationButton = YES;
        }

        
        if (animated) {
            [self slide:CMPBannerWebViewSlidLeft];
        }
    }
}

+(NSInteger)actionTypeWithUrl:(NSString *)url
{
    NSInteger act = 0;
    if (url && url.length) {
        if ([url containsString:@"cmpopac=1"] && ![url hasPrefix:@"file://"]) {
            act=1;
        }else if ([url containsString:@"cmpopac=2"]){
            act=2;
        }else if ([url containsString:@"cmpopac=3"]){
            act=3;
        }
    }
    return act;
}


// 关闭html页面
- (BOOL)popPage:(NSDictionary *)aParam backIndex:(NSInteger)aBackIndex
{
    //    NSString *aBackParam = [aParam objectForKey:@"param"];
    if ([aParam isKindOfClass:[NSString class]]) {
        aParam = [(NSString *)aParam JSONValue];
    }
    if (!aParam) {
        NSLog(@"打开参数为空");
        return NO;
    }
    NSDictionary *options = [aParam objectForKey:@"options"];
    BOOL aAnimated = [[options objectForKey:@"animated"] boolValue];
    return [self executePopPage:aParam backIndex:aBackIndex animated:aAnimated];
}

- (BOOL)executePopPage:(NSDictionary *)aParam backIndex:(NSInteger)aBackIndex animated:(BOOL)animated
{
    // 清空内容区域，仅在iPad 且 当前区域为操作区时生效
    BOOL clearDetailPage = [aParam objectForKey:@"clearDetailPad"] ? [[aParam objectForKey:@"clearDetailPad"] boolValue] : YES;
    if (CMP_IPAD_MODE && [self cmp_canPushInDetail] && clearDetailPage) {
        [self cmp_clearDetailViewController];
    }
    
    //判断当前viewcontroller是否可以出栈
    NSInteger aPageCount = _pageStack.count;
    //    if (!self.isTailWebView) { // 如果没有超过阈值，pop 1直接关闭当前WebView
    //        aBackIndex = aPageCount + aBackIndex - 1;
    //    }
    
    if (aBackIndex < _pageStack.count) {
        // 需判断当前view是不是在堆栈最上
        NSArray *aViewControllers = self.navigationController.viewControllers;
        if ([aViewControllers lastObject] != self) {
            [self.navigationController popToViewController:self animated:animated];
        }
        [_pageStack removeObjectsInRange:NSMakeRange(aPageCount - aBackIndex, aBackIndex)];
        
        // 记录backData
        NSDictionary *aDict= [_pageStack lastObject];
        NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:aDict];
        id backData = aParam[@"param"];
        if (backData) {
            [mDict setObject:backData forKey:@"backData"];
        }
        [_pageStack removeLastObject];
        [_pageStack addObject:mDict];
        
        NSString *href = [mDict objectForKey:@"url"];
        href = [href urlCFEncoded];
        NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
        if (localHref) {
            href = localHref;
        }
        
        NSDictionary *options = [aDict objectForKey:@"options"];
        BOOL useNativebanner = [[options objectForKey:@"useNativebanner"] boolValue];
        BOOL isSupportOSystemShare = [[options objectForKey:@"isSupportOSystemShare"] boolValue];
        [self _loadUrl:href showNavBar:useNativebanner isSupportOSystemShare:isSupportOSystemShare];
        if (animated) {
            [self slide:CMPBannerWebViewSlidRight];
        }
    }
    else if (aBackIndex == _pageStack.count) {
        NSArray *aViewControllers = self.navigationController.viewControllers;
        NSUInteger currentIndex = 0;
        if ([aViewControllers containsObject:self]) {
            currentIndex = [aViewControllers indexOfObject:self];
        }
        NSUInteger backToIndex = 0;
        if (currentIndex > 1) {
            backToIndex = currentIndex - 1;
        }
        
        // 记录backData
        id backData = aParam[@"param"];
        if (backData) {
            UIViewController *aController = aViewControllers[backToIndex];
            if ([aController isKindOfClass:[CMPBannerWebViewController class]]) {
                CMPBannerWebViewController *aWebviewController = (CMPBannerWebViewController *)aController;
                NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[aWebviewController.pageStack lastObject]];
                [mDict setObject:backData forKey:@"backData"];
                [aWebviewController.pageStack removeLastObject];
                [aWebviewController.pageStack addObject:[mDict copy]];
            }
        }
       
        //fix OA-212826 
        NSInteger toIndex = currentIndex - 1;
        if (self.viewWillClose) {
            self.viewWillClose();
            self.viewWillClose = nil;
        }
        if (toIndex >= 0) {
            if (!self.navigationController.delegate) {
                self.navigationController.delegate = self;
            }
            UIViewController *aController = aViewControllers[toIndex];
            [self.navigationController popToViewController:aController animated:animated];
        }
        else {
            [self closeViewController];
        }
//        // 需判断当前view是不是在堆栈最上
//        if ([aViewControllers lastObject] != self) {
//            [self.navigationController popToViewController:self animated:animated];
//        }
//        [self closeViewController];
    }
    else {
        // 根据当前的viewController查找到上一viewController
        NSArray *aViewControllers = self.navigationController.viewControllers;
        NSInteger currentIndex = aBackIndex - _pageStack.count;
        NSInteger aViewIndex = [aViewControllers indexOfObject:self];
        NSInteger aPreViewIndex = aViewIndex - 1;
        if (aPreViewIndex < 0) {
            // 下标越界，强制设为0
            aPreViewIndex = 0;
        }
        UIViewController *aController = [aViewControllers objectAtIndex:aPreViewIndex];
        if ([aController isKindOfClass:[CMPBannerWebViewController class]]) {
            CMPBannerWebViewController *aWebviewController = (CMPBannerWebViewController *)aController;
            return [aWebviewController executePopPage:aParam backIndex:currentIndex animated:animated];
        }
        else {
            // 需判断当前view是不是在堆栈最上
            NSArray *aViewControllers = self.navigationController.viewControllers;
            if ([aViewControllers lastObject] != self) {
                [self.navigationController popToViewController:self animated:animated];
            }
            [self closeViewController];
            // 不是webview页面
            return NO;
        }
    }
    return YES;
}

- (NSString *)getParams
{
    NSDictionary *aDict = [_pageStack lastObject];
    NSString *aStr = [aDict objectForKey:@"param"];
    return  aStr;
}

- (NSString *)getBackData
{
    NSDictionary *aDict = [_pageStack lastObject];
    NSString *aStr = [aDict objectForKey:@"backData"];
    return  aStr;
}

+ (BOOL)isWebViewMaxCount {
    NSInteger maxCount = INTERFACE_IS_PAD ? kiPadMaxWebView : kiPhoneMaxWebView;
    if (webViewCounter > maxCount) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setIsTailWebView:(BOOL)isTailWebView {
    _isTailWebView = isTailWebView;
    //    if (_isTailWebView) { // 超过阈值，默认屏蔽手势返回
    //        CMPNavigationController *nav = (CMPNavigationController *)self.navigationController;
    //        [nav updateEnablePanGesture:NO];
    //    }
}

- (BOOL)enablePanGesture {
    return !_isTailWebView;
}

/**
 单页面跳转动画
 */
- (void)slide:(CMPBannerWebViewSlidDirection)direction {
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.layer.shadowOpacity = 0;
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGRect screenshotRect = [self.view frame];
    
    UIImage *image =[self.view grabScreenshot];
    _screenShotImageView = [[UIImageView alloc] initWithFrame:screenshotRect];
    [_screenShotImageView setImage:image];
    
    [self.webView.superview insertSubview:_screenShotImageView aboveSubview:self.webView];
    
    NSTimeInterval duration = 0.3;
    NSTimeInterval delay = 0.1;
    
    CGFloat transitionToX = 0;
    CGFloat webviewToY = self.webView.frame.origin.y;
    
    if (direction == CMPBannerWebViewSlidLeft) {
        transitionToX = -width;
    } else if (direction == CMPBannerWebViewSlidRight) {
        transitionToX = width;
    }
    
    [self.webView setFrame:CGRectMake(-transitionToX, webviewToY, width, height - self.webView.frame.origin.y)];
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (direction == CMPBannerWebViewSlidLeft) {
                             [self.webView.superview sendSubviewToBack:self.screenShotImageView];
                         }
                         [self.screenShotImageView setFrame:CGRectMake(transitionToX, 0, width, height)];
                         [self.webView setFrame:CGRectMake(0, webviewToY, width, height - self.webView.frame.origin.y)];
                     }
                     completion:^(BOOL finished) {
                         [self.screenShotImageView removeFromSuperview];
                         self.screenShotImageView = nil;
                     }];
}

- (void)_loadUrl:(NSString *)url showNavBar:(BOOL)showNavBar isSupportOSystemShare:(BOOL)isSupportOSystemShare {
    
    [_bannerNavigationBar removeFromSuperview];
    self.bannerNavigationBar = nil;
    [self setupStatusBarViewBackground:[self statusBarColorForiOS7]];
    self.statusBarStyle = 0;
    [self setNeedsStatusBarAppearanceUpdate];
    if (![NSURL URLWithString:url].isFileURL) {
        self.allowRotation = NO;
    }
    if ([url containsString:@"cmp_orientation=auto"]) {
        self.allowRotation = YES;
    }
    
    if ([url containsString:@"useNativebanner=1"] || showNavBar) {
        [self showNavBarforWebView:@1];
        
        //kstodo 控制显示或者隐藏系统分享按钮的逻辑
        
    } else if ([url containsString:@"useNativebanner=0"] || !showNavBar) {
        [self showNavBarforWebView:@0];
    }
    
    NSURL *toUrl = [NSURL URLWithString:url];
    NSInteger openact = [CMPBannerWebViewController actionTypeWithUrl:url];
    switch (openact) {
        case 1:
        {
            CMPSafariViewController *safari = [[CMPSafariViewController alloc] initWithURL:toUrl];
            if ([self isKindOfClass:NSClassFromString(@"CMPTabBarWebViewController")]) {
                [self addChildViewController:safari];
                [self.view addSubview:safari.view];
                [safari.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.offset(0);
                }];
            }else{
                [self pushVc:safari inVc:self inDetail:YES clearDetail:NO animate:NO];
            }
            return;
        }
            break;
        case 2:
        {
            if ([self isKindOfClass:NSClassFromString(@"CMPTabBarWebViewController")]) {
                CMPSafariViewController *safari = [[CMPSafariViewController alloc] initWithURL:toUrl];
                [self addChildViewController:safari];
                [self.view addSubview:safari.view];
                [safari.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.offset(0);
                }];
                return;
            }else{
                if ([[UIApplication sharedApplication] canOpenURL:toUrl]) {
                    if (@available(iOS 10.0,*)) {
                        [[UIApplication sharedApplication] openURL:toUrl options:nil completionHandler:^(BOOL success) {
                                                    
                        }];
                    }else{
                        [[UIApplication sharedApplication] openURL:toUrl];
                    }
                    return;
                }
            }
        }
            break;
        case 3:
        {
            CMPCommonWebViewController *safari = [[CMPCommonWebViewController alloc] initWithURL:toUrl];
            safari.needNav = NO;
            if ([self isKindOfClass:NSClassFromString(@"CMPTabBarWebViewController")]) {
                [self addChildViewController:safari];
                [self.view addSubview:safari.view];
                [safari.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.offset(0);
                }];
            }else{
                [self pushVc:safari inVc:self inDetail:YES clearDetail:NO animate:NO];
            }
            return;
        }
            break;
        default:
            break;
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webViewEngine loadRequest:urlRequest];
    
}


/**
 跳转逻辑
 在操作区跳转：
 1. 当前区域是操作区，inDetail 为 NO
 在内容区跳转：
 1. 当前区域是操作区，inDetail 为 YES
 2. 当前区域是内容区，inDetail 为 YES 或 NO
 */
- (void)pushVc:(UIViewController *)vc
          inVc:(UIViewController *)parentVc
      inDetail:(BOOL)inDetail
   clearDetail:(BOOL)clearDetail
       animate:(BOOL)animate {

    parentVc.navigationController.delegate = self;
    
    if (CMP_IPAD_MODE) {
        
        if ([self cmp_inMasterStack]) {
            if (clearDetail) {
                if (![self isResponseTojump]) {
                    [self popUpAlertPushVc:vc inVc:parentVc inDetail:inDetail clearDetail:clearDetail];
                    return;
                }
                [self cmp_clearDetailViewController];
            }
            
            if (inDetail) {
                self.cmp_splitViewController.detailNavigation.delegate = self;
                [parentVc cmp_showDetailViewController:vc];
            } else {
                if (![self isResponseTojump]) {
                    [self popUpAlertPushVc:vc inVc:parentVc inDetail:inDetail clearDetail:clearDetail];
                    return;
                }
                [self cmp_pushPageInMasterView:vc navigation:parentVc.navigationController];
            }
        } else {
            [parentVc.navigationController pushViewController:vc animated:animate];
        }
        
    } else {
        [parentVc.navigationController pushViewController:vc animated:animate];
    }
}

- (BOOL)isResponseTojump {
    BOOL isjump = YES;
    if (CMP_IPAD_MODE) {
        CMPBaseWebViewController *viewController = (CMPBaseWebViewController *)self.cmp_splitViewController.detailNavigation.topViewController;
        if ([viewController isKindOfClass:[CMPBaseWebViewController class]] && viewController.isLockPageOnPad) {
            //[viewController backBarButtonAction:nil];
            isjump = NO;
            return isjump;
        }

        viewController = (CMPBaseWebViewController *)self.cmp_splitViewController.masterNavigation.topViewController;
        if ([viewController isKindOfClass:[CMPBaseWebViewController class]] && viewController.isLockPageOnPad) {
            //[viewController backBarButtonAction:nil];
            isjump = NO;
            return isjump;
        }
    }
    return isjump;
}

- (void)popUpAlertPushVc:(UIViewController *)vc
                    inVc:(UIViewController *)parentVc
                inDetail:(BOOL)inDetail
             clearDetail:(BOOL)clearDetail {
    UIAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:nil message:SY_STRING(@"pad_lock_hint") cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@[SY_STRING(@"common_ok")] callback:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {//取消
            
        } else if (buttonIndex == 1){//确定
            if (clearDetail) {
                [self cmp_clearDetailViewController];
            }
            if (inDetail) {
                [parentVc cmp_showDetailViewController:vc];
            } else {
                [self cmp_pushPageInMasterView:vc navigation:parentVc.navigationController];
            }
        }
    }];
    [aAlertView show];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([navigationController isKindOfClass:[CMPNavigationController class]]) {
        CMPNavigationController *naVC = (CMPNavigationController *)navigationController;
        if (naVC.willShowViewControllerAlwaysCallBack) {
           naVC.willShowViewControllerAlwaysCallBack();
        }
        [naVC.willShowViewControllerAlwaysCallBackArr enumerateObjectsUsingBlock:^(CMPNavigationCallBack  _Nonnull willShowViewControllerAlwaysCallBack, NSUInteger idx, BOOL * _Nonnull stop) {
            willShowViewControllerAlwaysCallBack();
        }];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.topViewController != self && self.navigationController == navigationController) {
        self.isPushedController = YES;
    }
    
    if (CMP_IPAD_MODE) {
        NSString *aStr = nil;
        CMPBaseWebViewController *baseWebViewController = nil;
        long count = 0;
        CMPSplitViewController *splitViewController =  viewController.cmp_splitViewController;
        if (InterfaceOrientationIsLandscape) {
            if (splitViewController.detailNavigation == navigationController) {
                count = navigationController.viewControllers.count - 1;
                baseWebViewController = (CMPBaseWebViewController *)splitViewController.masterNavigation.topViewController;
                if ([baseWebViewController isKindOfClass:[CMPBaseWebViewController class]]) {
                    aStr = [NSString stringWithFormat:@"cmp.event.trigger('CMPDetailWebviewChange','document','%ld')",count];
                    [baseWebViewController.commandDelegate evalJs:aStr];
                }
            }
        } else {
            NSArray *mergeStack = splitViewController.detailNavigation.viewControllers;
            NSInteger masterStackSize = splitViewController.masterStackSize;
            if (masterStackSize > mergeStack.count) {
                masterStackSize = mergeStack.count;
            }
            NSArray *masterStack = [mergeStack subarrayWithRange:NSMakeRange(0, masterStackSize)];
            count = mergeStack.count - masterStackSize;
            
            static long masterStackCount = 0;
            if (![masterStack containsObject:viewController] || masterStackCount == masterStack.count) {
                masterStackCount = masterStack.count;
                if ([masterStack containsObject:viewController] && masterStackCount == masterStack.count) {
                    masterStackCount = 0;
                }
                count = mergeStack.count - masterStackSize;
                baseWebViewController = (CMPBaseWebViewController *)masterStack.lastObject;
                if ([baseWebViewController isKindOfClass:[CMPBaseWebViewController class]]) {
                    aStr = [NSString stringWithFormat:@"cmp.event.trigger('CMPDetailWebviewChange','document','%ld')",count];
                    [baseWebViewController.commandDelegate evalJs:aStr];
                }
            }
        }
    }
    // 回调pushview完成实际
     if (self.didShowViewControllerCallBack) {
         self.didShowViewControllerCallBack();
         self.didShowViewControllerCallBack = nil;
       }
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    NSString *title = self.bannerViewTitle;
    if ([NSString isNull:title]) {
        title = [super currentPageScreenshotControlTitle];
    }
    return title;
}

- (BOOL)allowPopGesture {
    if ([CMPFeatureSupportControl allowPopGesture]) {
        return self.navigationController.viewControllers.count > 1;
    }
    return NO;
}

@end

