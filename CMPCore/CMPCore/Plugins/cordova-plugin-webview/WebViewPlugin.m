//
//  WebViewPlugin.m
//  CMPCore
//
//  Created by lin on 15/9/22.
//
//

#import "WebViewPlugin.h"
#import "AppDelegate.h"
#import <CMPLib/JSONKit.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPTabBarWebViewController.h"
#import "CMPFocusMenuView.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/UIImage+CMP.h>
@implementation WebViewPlugin

- (void)open:(CDVInvokedUrlCommand*)command
{
    NSDictionary *parameter = [command.arguments lastObject];
    NSString *url = [parameter objectForKey:@"url"];
    NSString *appID = [parameter objectForKey:@"uid"];
    NSInteger iOSStatusBarStyle = [[parameter objectForKey:@"iOSStatusBarStyle"] integerValue];
    NSArray *paramList = [appID componentsSeparatedByString:@"|"];
    NSString *version = nil;
    if (paramList.count == 2) {
        appID = [paramList objectAtIndex:0];
        version = [paramList objectAtIndex:1];
    }
    NSString *indexPath = [CMPAppManager appIndexPageWithAppId:appID version:version serverId:kCMP_ServerID];
    //是否新开页面
    //    id  vNewOB = [parameter objectForKey:@"isNew"];
    //    BOOL isNew = NO;
    //    if ([vNewOB isKindOfClass:[NSNumber class]]) {
    //        isNew = [vNewOB boolValue];
    //    }
    BOOL nativebanner = [[parameter objectForKey:@"useNativebanner"] boolValue];
    if ([NSString isNull:url] && [NSString isNull:indexPath]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    NSString *href = indexPath ? indexPath : url;
    href = [href urlCFEncoded];
    //    aCMPBannerViewController.startPage = href;
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
    if (localHref) {
        if ([localHref containsString:@"://"]) {
            aCMPBannerViewController.startPage = localHref;
        }
        else {
            aCMPBannerViewController.startPage = [NSString stringWithFormat:@"file://%@", localHref];
        }
    }
    else {
        aCMPBannerViewController.startPage = href;
    }
    aCMPBannerViewController.hideBannerNavBar = !nativebanner;
    aCMPBannerViewController.backBarButtonItemHidden = !nativebanner;
    //    aCMPBannerViewController.title = header;
    aCMPBannerViewController.statusBarStyle = iOSStatusBarStyle;
    if (self.viewController.navigationController) {
        [self.viewController.navigationController pushViewController:aCMPBannerViewController animated:YES];
    }
    else {
        [self.viewController presentViewController:aCMPBannerViewController animated:YES completion:^{
            
        }];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)close:(CDVInvokedUrlCommand*)command
{
    CMPBannerWebViewController *webviewcontroller = (CMPBannerWebViewController *)self.viewController;
    if (webviewcontroller.willClose) {
        return;
    }
    NSDictionary *parameter = [command.arguments lastObject];
    NSString *animate = [parameter objectForKey:@"closeAnimate"];
    BOOL aAnimated = YES;
    if ([self.viewController isKindOfClass:[CMPBaseWebViewController class]]) {
        CMPBaseWebViewController *aController = (CMPBaseWebViewController *)self.viewController;
        aAnimated = !aController.disableAnimated;
    }
    if ([self.viewController isKindOfClass:[CMPBannerWebViewController class]]) {
        CMPBannerWebViewController *vc = (CMPBannerWebViewController *)self.viewController;
        if (vc.viewWillClose) {
            vc.viewWillClose();
            vc.viewWillClose = nil;
        }
    }
    
    if (![NSString isNull:animate]) {
        aAnimated = [animate boolValue];
    }
    if (self.viewController.navigationController) {
        if (self.viewController.navigationController.viewControllers[0] == self.viewController) { // 是RootView
            [self.viewController.navigationController dismissViewControllerAnimated:aAnimated completion:nil];
        } else {
            [self.viewController.navigationController popViewControllerAnimated:aAnimated];
        }
    }
    else {
        [self.viewController dismissViewControllerAnimated:aAnimated completion:^{
            
        }];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/// 设置是否监听图片长按事件
- (void)setPictureLongClickEnable:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    BOOL isEnable = [param[@"enable"] boolValue];
    if (isEnable) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    CMPBaseWebViewController *webVc = (CMPBaseWebViewController *)self.viewController;
    UILongPressGestureRecognizer *longGr = nil;
    for (UIGestureRecognizer *gr in webVc.webView.gestureRecognizers) {
        if ([gr isKindOfClass:UILongPressGestureRecognizer.class]) {
            longGr = (UILongPressGestureRecognizer *)gr;
            break;
        }
    }
    
    if (longGr) {
        [webVc.webView removeGestureRecognizer:longGr];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"去除长按手势监听失败，原因：未找到相应的长按手势监听器"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)setWebViewBgColor:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *color = param[@"color"];
    
    if (color.length && [self.viewController isKindOfClass:NSClassFromString(@"CMPBannerWebViewController")]) {
        CMPBannerWebViewController *bannerVC = (CMPBannerWebViewController *)self.viewController;
        
        if (color.length >7) {
            bannerVC.webView.backgroundColor = [UIColor RGBA:color];
        }else{
            bannerVC.webView.backgroundColor = [UIColor colorWithHexString:color];
        }
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}

- (void)inputmode:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *input_mode = param[@"input_mode"];
    if ([input_mode isEqualToString:@"over"]) {
        if (self.webView) {
            WKWebView *wk = (WKWebView *)self.webView;
            wk.scrollView.scrollEnabled = NO;
            //            [[NSNotificationCenter defaultCenter] removeObserver:self.webView name:UIKeyboardWillHideNotification object:nil];
            //            [[NSNotificationCenter defaultCenter] removeObserver:self.webView name:UIKeyboardWillShowNotification object:nil];
            //            [[NSNotificationCenter defaultCenter] removeObserver:self.webView name:UIKeyboardWillChangeFrameNotification object:nil];
            //            [[NSNotificationCenter defaultCenter] removeObserver:self.webView name:UIKeyboardDidChangeFrameNotification object:nil];
        }
    }else{
        if (self.webView) {
            WKWebView *wk = (WKWebView *)self.webView;
            wk.scrollView.scrollEnabled = YES;
        }
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)FocusMenu:(CDVInvokedUrlCommand *)command{
    NSDictionary *param = command.arguments.lastObject;
    WKWebView *wk = nil;
    CGFloat naviHeight = CMP_STATUSBAR_HEIGHT;
    
    if (@available(iOS 16.0, *)) {
        UIEdgeInsets ins = self.viewController.view.safeAreaInsets;
        CGFloat st = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;
        if (ins.top > st){
            CGFloat h = ins.top - st;
            naviHeight += h;//iphone15 的状态栏高度为54，顶部安全区域为59
        }
    }
    
    if ([self.viewController isKindOfClass:CMPTabBarWebViewController.class]) {
        CMPTabBarWebViewController *tabWebVC = (CMPTabBarWebViewController *)self.viewController;
        wk = (WKWebView *)tabWebVC.webView;
        naviHeight += [tabWebVC bannerBarHeight];
    }else if ([self.viewController isKindOfClass:CMPBannerWebViewController.class]) {
        CMPBannerWebViewController *bannerWebVC = (CMPBannerWebViewController *)self.viewController;
        wk = (WKWebView *)bannerWebVC.webView;
        naviHeight += [bannerWebVC bannerBarHeight];
    }
    [self showFocusMenuWithParam:param inWK:wk onVC:self.viewController naviHeight:naviHeight command:command];
    
}

- (void)FocusMenuFromVC:(CMPBannerWebViewController *)fromVC{
    self.viewController = fromVC;
    NSDictionary *param = @{
        @"left":@(14),
        @"top":@(100),
        @"width":@(UIScreen.mainScreen.bounds.size.width - 28),
        @"height":@(100),
    };
    WKWebView *wk = nil;
    CGFloat naviHeight = CMP_STATUSBAR_HEIGHT;
    if ([self.viewController isKindOfClass:CMPBannerWebViewController.class]) {
        CMPBannerWebViewController *bannerWebVC = (CMPBannerWebViewController *)self.viewController;
        wk = (WKWebView *)bannerWebVC.webView;
        naviHeight += [bannerWebVC bannerBarHeight];
    }
    [self showFocusMenuWithParam:param inWK:wk onVC:self.viewController naviHeight:naviHeight command:nil];
    
}


- (void)showFocusMenuWithParam:(NSDictionary *)param inWK:(WKWebView *)wk onVC:(UIViewController *)VC naviHeight:(CGFloat)naviHeight command:(CDVInvokedUrlCommand *)command{
    
    NSArray *topGroup = param[@"topGroup"];
    
    NSInteger count = 0;
    if ([topGroup isKindOfClass:NSArray.class]) {
        for (id arr in topGroup) {
            if ([arr isKindOfClass:NSArray.class]) {
                NSArray *a = arr;
                count += a.count;
            }
        }
    }
    
    if (!count) {
        return;
    }
    
    CGFloat left = [param[@"left"] floatValue];
    CGFloat top = [param[@"top"] floatValue];
    CGFloat width = [param[@"width"] floatValue];
    CGFloat height = [param[@"height"] floatValue];
    
    if (width<=0 || height <= 0) {
        return;
    }
    
    if (CMP_IPAD_MODE) {//ipad左边tab宽度
        CGRect f = VC.rdv_tabBarController.tabBar.frame;
        left += f.size.width;
    }
    
    CGFloat webViewScale = wk.scrollView.zoomScale;
    CGFloat wkY = wk.frame.origin.y;
    if (wkY>0) {
        wkY = 0;
    }
    
    CGRect webViewRect = CGRectMake(left * webViewScale, top * webViewScale, width * webViewScale, height * webViewScale);
    CGFloat screenScale = 1;//[UIScreen mainScreen].scale;
    CGRect screenRect = CGRectMake(webViewRect.origin.x / screenScale, webViewRect.origin.y / screenScale, webViewRect.size.width / screenScale, webViewRect.size.height / screenScale);
    
    //截图
    UIGraphicsBeginImageContextWithOptions(screenRect.size, NO, 0.0);
    [wk drawViewHierarchyInRect:CGRectMake(-screenRect.origin.x, -screenRect.origin.y+wkY, wk.bounds.size.width, wk.bounds.size.height) afterScreenUpdates:YES];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //添加View
    UIView *tabView = VC.rdv_tabBarController.view;
    
    CMPFocusMenuView *menuView = [[CMPFocusMenuView alloc]initWithFrame:tabView.frame];
    [tabView addSubview:menuView];
    [tabView bringSubviewToFront:menuView];
    menuView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        menuView.alpha = 1;
    }];
    
    // 使用系统毛玻璃
//    __weak typeof(self) weakSelf = self;
//    [menuView showFocusImage:img inPosition:CGRectMake(screenRect.origin.x,screenRect.origin.y + naviHeight+wkY, screenRect.size.width, screenRect.size.height) topGroup:topGroup didSelectItem:^(CMPFocusMenuItem *item) {
//        
//        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"key" : item.key?:@""}];
//        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//    }];
    
    // 使用高斯模糊
    UIImage *viewImage = [UIImage yw_screenShot];
    
    __weak typeof(self) weakSelf = self;
    [menuView showFocusImage:img screenImage:viewImage inPosition:CGRectMake(screenRect.origin.x,screenRect.origin.y + naviHeight+wkY, screenRect.size.width, screenRect.size.height) topGroup:topGroup didSelectItem:^(CMPFocusMenuItem *item) {
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"key" : item.key?:@""}];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}
//openKeyboard
- (void)openKeyboard:(CDVInvokedUrlCommand *)command{
    NSDictionary *param = command.arguments.lastObject;
    NSString *domId = param[@"domId"];//domId需要带#，只能是大小写数字_#
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"] invertedSet];
    BOOL isValid = ([domId rangeOfCharacterFromSet:set].location == NSNotFound);
    if (isValid) {
        WKWebView *wk = (WKWebView *)self.webView;
        NSString *js = [NSString stringWithFormat:@"var searchInput = document.querySelector('#%@');if (searchInput){searchInput.focus();}",domId];
        [wk evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            NSLog(@"");
        }];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"domId无效"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

@end
