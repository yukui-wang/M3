//
//  SyBaseViewController.m
//  M1Core
//
//  Created by admin on 12-10-26.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kControllerSuffix @"Controller"

#import "CMPBaseWebViewController.h"
#import "NSString+CMPString.h"
#import "CMPURLProtocol.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "CMPCachedUrlParser.h"
#import "CMPAppDelegate.h"
#import "CMPJSBridge_JS.h"
#import "NSObject+CMPHUDView.h"
#import <CMPLib/CMPStringConst.h>
#import <CordovaLib/WKUserContentController+IMYHookAjax.h>
#import <CordovaLib/CDVWKWebViewEngine.h>
#import <CordovaLib/CDVWKWebView.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/UIViewController+KSSafeArea.h>

@interface CMPBaseWebViewController ()<UIGestureRecognizerDelegate> {
    UIView *_loadingView;
    NSInteger _showLoadingViewCounter; // 显示加载窗体计算
}

- (CGFloat)navigationBarHeight; // 获取navigationbar高度
- (void)updateLoadingViewFrame;

/** JsBridge代码是否加载 **/
@property (assign, nonatomic) BOOL isJsBridgeLoad;



@end

@implementation CMPBaseWebViewController
@synthesize param = _param;
@synthesize mainView = _mainView;
@synthesize shouldHandleFrame = _shouldHandleFrame;
@synthesize modalParentController = _modalParentController;
@synthesize mainFrame = _mainFrame;
@synthesize cModalViewController = _modalViewController;

- (void)dealloc 
{
    [_param release];
    _param = nil;
    
    [_mainView release];
    _mainView = nil;
    
    [_modalParentController release];
    _modalParentController = nil;

    [_loadingView release];
    _loadingView = nil;
    
    [_modalViewController.view removeFromSuperview];
    [_modalViewController release];
    _modalViewController = nil;
	
	[_statusBarView release];
	_statusBarView = nil;
    
    [_currentURL release];
    _currentURL = nil;
 /*   [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_ConfigInfoDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_AppListDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_UserInfoDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDVPageDidLoadNotification object:nil];
  */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [super dealloc];
}

- (id)init 
{
    self = [super init];
    if (self) {
        self.shouldHandleFrame = YES;
    }
    return self;
}

- (BOOL)navigationBarHidden
{
    return YES;
}

- (CGFloat)navigationBarHeight 
{
    BOOL aHidden = [self navigationBarHidden];
    if (aHidden) {
        return 0.0f;
    }
    UINavigationBar *aBar = self.navigationController.navigationBar;
    return aBar.originY + aBar.height;
}

- (CGRect)mainFrame
{
    CGRect frame = self.view.bounds;
    
    if ([self isOptimizationStatusBarForiOS7] && ![UIApplication sharedApplication].statusBarHidden) {
        
        frame.origin.y = [UIView staticStatusBarHeight];
        frame.size.height -= [UIView staticStatusBarHeight];
        
    }
    if (IS_IPHONE_X_Landscape) {
        frame.origin.x += 44;
        frame.size.width -= 44*2;
    }
    
    return frame;
}

- (void)loadView
{
    [super loadView];
    CGRect frame = [self mainFrame];
    if (!_statusBarView) {
        _statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, [UIView staticStatusBarHeight])];
        _statusBarView.tag = 999001;
        _statusBarView.backgroundColor = [self statusBarColorForiOS7];
        [self.view addSubview:_statusBarView];
        [self layoutStatusBarView];
    }
    [self setup];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.mainView = (CMPBaseView *)self.webView;
    
	// add by guoyl for ios 7
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applistAndConfigDidUpdate:) name:kNotificationName_ConfigInfoDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applistAndConfigDidUpdate:) name:kNotificationName_AppListDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applistAndConfigDidUpdate:) name:kNotificationName_UserInfoDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad:) name:CDVPageDidLoadNotification object:self.webView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidStart:) name:CDVPluginResetNotification object:self.webView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageLoadError:) name:CDVPageLoadErrorNotification object:self.webView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignKeyboard:) name:kNotificationName_WebviewResignKeyboard object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_migrateWebDataSyncFinish) name:@"kNotificationName_MigrateWebDataSyncFinish" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    // 实现图片长按识别功能
    if (CMPCore.sharedInstance.serverIsLaterV8_0) {
        UILongPressGestureRecognizer *longPressed = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)] autorelease];
        longPressed.delegate = self;
        [self.webView addGestureRecognizer:longPressed];
    }
}

- (void)applistAndConfigDidUpdate:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    NSDictionary *userInfo = notification.userInfo;
    BOOL success = NO;
    if (userInfo) {
        success = [userInfo[@"result"] boolValue];
    }
    NSString *errorMessage = success ? @"" : @"数据获取失败";
    if ([notification.name isEqualToString:kNotificationName_ConfigInfoDidUpdate]) {
        NSString *js = [NSString stringWithFormat:@"cmp.event.trigger('M3ConfigOrApplistRequestCompleted', document, {type: 'config',message:'%@'})", errorMessage];
        [self.commandDelegate evalJs:js];
        DDLogInfo(@"zl---configInfo更新完成,给H5发送通知：%@", errorMessage);
    } else if ([notification.name isEqualToString:kNotificationName_AppListDidUpdate]) {
        NSString *js = [NSString stringWithFormat:@"cmp.event.trigger('M3ConfigOrApplistRequestCompleted', document, {type: 'applist',message:'%@'})", errorMessage];
        [self.commandDelegate evalJs:js];
        DDLogInfo(@"zl---applist更新完成,给H5发送通知：%@", errorMessage);
    } else if ([notification.name isEqualToString:kNotificationName_UserInfoDidUpdate]) {
        NSString *js = [NSString stringWithFormat:@"cmp.event.trigger('M3ConfigOrApplistRequestCompleted', document, {type: 'userInfo',message:'%@'})", errorMessage];
        [self.commandDelegate evalJs:js];
        DDLogInfo(@"zl---userInfo更新完成,给H5发送通知：%@", errorMessage);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateRotaion];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateRotaion];
    
//    NSString *aStr = nil;
    if (self.isPushedController) {
        self.isPushedController = NO;
//        aStr = @"cmp.event.trigger('com.seeyon.m3.phone.webBaseVC.didAppear','document',{type:'back'})";
         [self fireDidAppearEvent:@"{type:'back'}"];
    } else {
//        aStr = @"cmp.event.trigger('com.seeyon.m3.phone.webBaseVC.didAppear','document',{})";
        [self fireDidAppearEvent:nil];
    }
//    [self.commandDelegate evalJs:aStr];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"viewDidAppear" object:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self fireDidDisAppearEvent:nil];
//    NSString *aStr = @"cmp.event.trigger('com.seeyon.m3.phone.webBaseVC.didDisAppear','document')";
//    [self.commandDelegate evalJs:aStr];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"viewWillDisappear" object:self];
}

//- (void)applicationDidBecomeActive:(NSNotification *)notification{
//    NSString *aStr = @"cmp.event.trigger('com.seeyon.m3.phone.webBaseVC.didAppear','document')";
//    [self.commandDelegate evalJs:aStr];
//}
//
//- (void)applicationWillResignActive:(NSNotification *)notification{
//    NSString *aStr = @"cmp.event.trigger('com.seeyon.m3.phone.webBaseVC.didDisAppear','document')";
//    [self.commandDelegate evalJs:aStr];
//}

- (void)setup
{
    // todo
}

- (void)setupStatusBarViewBackground:(UIColor *)color
{
    _statusBarView.backgroundColor =color;
}

- (void)reLayoutSubViews
{
    [self dispatchAsyncToMain:^{
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        CGRect mainViewFrame = [self mainFrame];
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            [self layoutSubviewsForPortraitWithFrame:mainViewFrame];
            [self layoutSubviewsWithFrame:mainViewFrame];
        }
        else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            [self layoutSubviewsForLandscapeWithFrame:mainViewFrame];
            [self layoutSubviewsWithFrame:mainViewFrame];
        }
        
        [self layoutStatusBarView];
                
        [self updateLoadingViewFrame];
    }];
}

- (void)layoutStatusBarView{
    CGFloat statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        statusBarHeight = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    [_statusBarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(statusBarHeight);
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!CGSizeEqualToSize(self.preViewSize, self.view.frame.size) && [self isViewControllerVisable]) {
        [self reLayoutSubViews];
    }
    self.preViewSize = self.view.frame.size;

}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    //只给显示的页面发送事件
    if ([self isViewControllerVisable]
        /**ks add -- 新增判断条件 V5-49563【移动端查看报表】【IOS】移动端查看报表从横屏模式返回竖屏模式后，操作按钮位置按照异常**/
        || (self.isViewLoaded && self.isLandscapeWhenPushChildController)) {
        [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            NSString *aStr = @"cmp.event.trigger('CMPOrientationChange','document')";
            [self.commandDelegate evalJs:aStr];
        }];
       
    }
}

- (void)layoutSubviewsForPortraitWithFrame:(CGRect)frame
{
    
}

- (void)layoutSubviewsForLandscapeWithFrame:(CGRect)frame
{
    
}

- (void)layoutSubviewsWithFrame:(CGRect)frame 
{
    
}

-(void)hiddenStatusBarWhenLandscape{
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
        
        
    }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        
        [[UIApplication sharedApplication]setStatusBarHidden:YES];
        
        
    }
    
}

- (void)updateLoadingViewFrame
{
    if (_loadingView) {
        CGRect f = [self mainFrame];
        _loadingView.frame = f;
    }
}

// loadingView
- (void)showLoadingViewWithText:(NSString *)aStr
{
    [self cmp_showProgressHUDInView:self.view];
}

- (void)showLoadingView
{
    [self showLoadingViewWithText:SY_STRING(@"common_table_loading")];
}

- (void)hideLoadingView
{
    if (_showLoadingViewCounter > 0) {
        _showLoadingViewCounter --;
    }
    if (_showLoadingViewCounter <= 0) {
        [self cmp_hideProgressHUD];
    }
}

- (void)hideLoadingViewWithoutCount {
    _showLoadingViewCounter = 0;
    [self cmp_hideProgressHUD];
}

- (void)showToastWithText:(NSString *)text {
    [self cmp_showHUDWithText:text inView:self.view];
}

// 是否优化状态栏为iOS7
- (BOOL)isOptimizationStatusBarForiOS7 {
	if ((self.isInPopoverController || self.preferredContentSize.width != 0 || self.preferredContentSize.height != 0) && INTERFACE_IS_PAD) {
		return NO;
	}
	return NO;
}

- (UIColor *)statusBarColorForiOS7
{
    return [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1.0];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{

    return NO;
}

- (void)setAllowRotation:(BOOL)allowRotation
{
    _allowRotation = allowRotation;
    [self updateRotaion];
}

- (void)updateRotaion
{
    CMPAppDelegate *aAppDelegate = (CMPAppDelegate *)[UIApplication sharedApplication].delegate;
    aAppDelegate.allowRotation = _allowRotation;
    if (!aAppDelegate.allowRotation) {
        [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
        [UIViewController attemptRotationToDeviceOrientation];
    }
}

- (BOOL)shouldOverrideLoadWithRequest:(NSURLRequest*)request navigationType:(WKNavigationType)navigationType
{
    self.currentURL = request.URL;
    return [self customShouldOverrideLoadWithRequest:request navigationType:navigationType];
}

- (BOOL)customShouldOverrideLoadWithRequest:(NSURLRequest*)request navigationType:(WKNavigationType)navigationType
{
    return YES;
}


- (void)setStartPage:(NSString *)startPage {
    [super setStartPage:startPage];
    if ([startPage containsString:@"cmp_orientation=auto"]) {
        self.allowRotation = YES;
    }
}

- (void)pushVc:(UIViewController *)vc
          inVc:(UIViewController *)parentVc
      inDetail:(BOOL)inDetail
   clearDetail:(BOOL)clearDetail
       animate:(BOOL)animate {
    
}

#pragma mark-
#pragma mark 注入JS

/**
 注入JSBridge代码
 */
- (void)injectJSFile {
    if (_isJsBridgeLoad) {
        return;
    }
    _isJsBridgeLoad = YES;
    NSString *js = jsBridge_js();
    [self.webViewEngine evaluateJavaScript:js completionHandler:nil];
}

- (void)backBarButtonAction:(id)sender
{
    //todo
}

- (void)fireDidAppearEvent:(NSString *)aParam
{
//    aStr = @"cmp.event.trigger('com.seeyon.m3.phone.webBaseVC.didAppear','document',{type:'back'})";
    NSString *aStr = @"cmp.event.trigger('com.seeyon.m3.phone.webBaseVC.didAppear','document')";
    if ([NSString isNotNull:aParam]) {
        aStr = [NSString stringWithFormat:@"cmp.event.trigger('com.seeyon.m3.phone.webBaseVC.didAppear','document', %@)", aParam];
    }
    [self.commandDelegate evalJs:aStr];
}

- (void)fireDidDisAppearEvent:(NSString *)aParam
{
    NSString *aStr = @"cmp.event.trigger('com.seeyon.m3.phone.webBaseVC.didDisAppear','document')";
    [self.commandDelegate evalJs:aStr];
}

- (void)onAppDidBecomeActive:(NSNotification*)notification
{
    [super onAppDidBecomeActive:notification];
    [self fireDidAppearEvent:nil];
//    NSString *aStr = @"cmp.event.trigger('com.seeyon.m3.phone.webBaseVC.didAppear','document')";
//    [self.commandDelegate evalJs:aStr];
}

- (void)onAppWillResignActive:(NSNotification*)notification
{
    [super onAppWillResignActive:notification];
//    NSString *aStr = @"cmp.event.trigger('com.seeyon.m3.phone.webBaseVC.didDisAppear','document')";
//    [self.commandDelegate evalJs:aStr];
    [self fireDidDisAppearEvent:nil];
}

//用于iPad模式下，右侧界面返回到空界面
- (void)cmp_didClearDetailViewController {
   [self fireDidAppearEvent:@"{type:'back'}"];
}

#pragma mark - 网页中图片长按处理

//OA-114074 iPhone客户端，键盘弹出的情况下。当手机锁屏后，再次开启，进入到手势密码页面。键盘不能收起
- (void)resignKeyboard:(NSNotification *)noti
{
    if (self.webViewEngine) {
        [self.webViewEngine evaluateJavaScript:@"var cmpFocusFiled = document.querySelector(':focus');\
         if (cmpFocusFiled) { \
         cmpFocusFiled.blur();\
         }" completionHandler:nil];
    }
}

- (void)pageDidStart:(NSNotification *)notification{
}

- (void)pageLoadError:(NSNotification *)notification {
}

- (void)pageDidLoad:(NSNotification *)notification {
}

// 长按识别图中二维码
- (void)longPressed:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognizer locationInView:self.webView];
    // 获取手势所在图片的URL，js中图片的地址是用src引用的
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
//    WKWebView *webview = (WKWebView *)self.webView;
    [self.webViewEngine evaluateJavaScript:imgURL completionHandler:^(NSString *urlToSave, NSError *aError) {
        if ([NSString isNotNull:urlToSave]) {
            [self showImageOptionsWithUrl:urlToSave];
        }
    }];
  /*  NSString *urlToSave = [webview stringByEvaluatingJavaScriptFromString:imgURL];
    
    if (urlToSave.length == 0) {
        return;
    }
    [self showImageOptionsWithUrl:urlToSave];
   */
}

- (void)showImageOptionsWithUrl:(NSString *)imgURL
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
   
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
    UIImage*image = [UIImage imageWithData:data];
    NSArray *features = [CMPCommonTool scanQRCodeWithImage:image];
    if (features.count == 0) {
        return;
    }
    
    // 识别图中二维码
    UIAlertAction *judgeCode = [UIAlertAction actionWithTitle:SY_STRING(@"review_image_recognizeQRCode_in_pic") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableDictionary *params = NSMutableDictionary.dictionary;
        params[@"vc"] = self;
        params[@"scanImage"] = image;
        [NSNotificationCenter.defaultCenter postNotificationName:CMPShowBlankScanVCNoti object: params];
    }];
    
    // 保存图片到手机
//    UIAlertAction *saveImage = [UIAlertAction actionWithTitle:SY_STRING(@"common_save") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        
//        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//        
//    }];
    
    // 取消
    UIAlertAction *cancell = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    
    if (features.count >= 1) {
        [alertController addAction:judgeCode];
    }
    
    //[alertController addAction:saveImage];
    [alertController addAction:cancell];
    if (alertController.popoverPresentationController) {//适配ipad弹框
        [alertController.popoverPresentationController setPermittedArrowDirections:0];//去掉arrow箭头
        alertController.popoverPresentationController.sourceView = self.view;
        alertController.popoverPresentationController.sourceRect = CGRectMake(0, 0, self.view.width, self.view.height);
    }
    [self presentViewController:alertController animated:YES completion:nil];
    
}
// 功能：显示图片保存结果
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error){
        [self showToastWithText:SY_STRING(@"review_image_saveToPhotoAlbumFailed")];
    }else {
      // 这一句仅仅是提示保存成功
        [self showToastWithText:SY_STRING(@"common_save_success")];
    }
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    __block NSString *title = nil;
    [self.webViewEngine evaluateJavaScript:@"document.title" completionHandler:^(NSString *object, NSError *error) {
        title = object;
    }];
   
    if ([NSString isNull:title]) {
        title = self.webViewEngine.URL.absoluteString;
    }
    
    if ([NSString isNull:title]) {
        title = NSStringFromClass(self.class);
    }
    
    return title;
}



-(NSMutableDictionary *)extParamDic
{
    if (!_extParamDic) {
        _extParamDic = [[NSMutableDictionary alloc] init];
    }
    return _extParamDic;
}

//ks add 发版前先注释掉
- (NSString*)userAgent
{
    NSString *userAgent = [super userAgent];
    if (self.extParamDic[@"cmpignore"]) {
        userAgent = [userAgent stringByAppendingFormat:@" (cmpignore=%@)",self.extParamDic[@"cmpignore"]];
    }
    return userAgent;
}

//- (UIView*)newCordovaViewWithFrame:(CGRect)bounds
//{
//    UIView *webview = [super newCordovaViewWithFrame:bounds];
//    if ([webview isKindOfClass:CDVWKWebView.class]) {
//
//        WKWebView *wkv = (CDVWKWebView *)webview;
//
//        CDVWKWebViewEngine *webviewEngine = self.webViewEngine;
//
//        // re-create WKWebView, since we need to update configuration
//        WKWebViewConfiguration* configuration = wkv.configuration;
//
//        WKUserContentController* userContentController = wkv.configuration.userContentController;
//        NSURL *aUrl = [self appUrl];
//
////        [userContentController imy_installHookAjax];
////        [userContentController imy_injectProxy];
//        if (aUrl.isFileURL) {
//            [userContentController imy_injectJsSourceForLocalStorage];
//        }
//
//        configuration.userContentController = userContentController;
//
//        WKWebView* wkWebView = [[CDVWKWebView alloc] initWithFrame:bounds configuration:configuration];
//        wkWebView.UIDelegate = webviewEngine.uiDelegate;
//        wkWebView.navigationDelegate = webviewEngine.uiDelegate;
//        webviewEngine.engineWebView = wkWebView;
//    }
//
//    return self.webViewEngine.engineWebView;
//
//
//}

-(void)_migrateWebDataSyncFinish
{
    [((WKWebView *)self.webViewEngine.engineWebView) reload];
}

-(void)refresh
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [((WKWebView *)self.webViewEngine.engineWebView) reload];
    });
}
@end
