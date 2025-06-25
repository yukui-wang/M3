//
//  CMPNavigationPlugin.m
//  CMPCore
//
//  Created by youlin on 2016/8/6.
//
//

#import "CMPNavigationPlugin.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CordovaLib/CDVWKWebView.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/UIImage+JCColor2Image.h>
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/UIViewController+CWLateralSlide.h>
#import <CMPLib/UIImageView+WebCache.h>
#import "CMPNavigationBarMaskView.h"
@interface CMPNavigationPlugin () {
    
}

@end

@implementation CMPNavigationPlugin

- (void)overrideBackbutton:(CDVInvokedUrlCommand *)command
{
    BOOL overide = [[command.arguments lastObject] boolValue];
    CMPBannerWebViewController *aController = (CMPBannerWebViewController *)self.viewController;
    __weak __typeof(self)weakSelf = self;
    if (overide) {
        aController.backButtonDidClick = ^{
            if (aController.ignoreJsBackHandle) {
                [aController.navigationController popViewControllerAnimated:YES];
                return;
            };
            [weakSelf.commandDelegate evalJs:@"cordova.fireDocumentEvent(\"backbutton\")"];
        };
    } else {
        aController.backButtonDidClick = nil;
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// 设置导航栏标题
- (void)setTitle:(CDVInvokedUrlCommand *)command
{
    NSDictionary *parameter = [command.arguments lastObject];
    NSString *title = [parameter objectForKey:@"title"];
    [(CMPBannerWebViewController *)self.viewController setTitle:title];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// 设置返回按钮样式，默认是尖角返回样式，当设置为关闭按钮样式，closeButton按钮自动隐藏
// 0=默认返回  1=关闭样式
- (void)setBackButtonStyle:(CDVInvokedUrlCommand *)command
{
    NSDictionary *parameter = [command.arguments lastObject];
    NSInteger aType = [[parameter objectForKey:@"type"] integerValue];
    CMPBannerWebViewController *aController = (CMPBannerWebViewController *)self.viewController;
    [aController setBackButtonStyle:aType];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// 设置关闭按钮隐藏值
- (void)setCloseButtonHidden:(CDVInvokedUrlCommand *)command
{
    NSDictionary *parameter = [command.arguments lastObject];
    BOOL hidden = [[parameter objectForKey:@"hidden"] boolValue];
    [(CMPBannerWebViewController *)self.viewController setCloseButtonHidden:hidden];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)pushPage:(CDVInvokedUrlCommand *)command
{
    CMPBannerWebViewController *controller = (CMPBannerWebViewController *)self.viewController;
    NSDictionary *parameter = [command.arguments firstObject];
    BOOL slideWeb = [[[parameter objectForKey:@"options"] objectForKey:@"slideWeb"] boolValue];
    if (slideWeb) {
        [self openSlideWeb:command];
    }else{
        [controller pushPage:parameter];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}


- (void)popPage:(CDVInvokedUrlCommand *)command
{
    CMPBannerWebViewController *controller = (CMPBannerWebViewController *)self.viewController;
    NSDictionary *parameter = [command.arguments firstObject];
    NSInteger aBackIndex = [[parameter objectForKey:@"backIndex"] integerValue];
    [controller popPage:parameter backIndex:aBackIndex];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setGestureBackState:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [command.arguments lastObject];
    if (!parameter || ![parameter isKindOfClass:[NSDictionary class]]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    NSNumber *stateNumber = parameter[@"state"];
    if (![CMPCore sharedInstance].allowPopGesture) {//v7.1新增,如果服务器配置项不允许手势返回,返回错误信息
        if (stateNumber.boolValue) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"服务器禁止滑动返回手势"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return ;
        }
    }
    //    CMPNavigationController *nav = (CMPNavigationController *)self.viewController.navigationController;
    //    [nav updateEnablePanGesture:stateNumber.boolValue];
    CMPBaseWebViewController *aWebViewController = (CMPBaseWebViewController *)self.viewController;
    aWebViewController.disableGestureBack = !stateNumber.boolValue;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)lockPageOnPad:(CDVInvokedUrlCommand *)command
{
    NSDictionary *parameter = [command.arguments lastObject];
    BOOL state = [parameter[@"state"] boolValue];
    CMPBannerWebViewController *controller = (CMPBannerWebViewController *)self.viewController;
    controller.isLockPageOnPad = state;
    controller.isLockPageOnPad = NO;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

+ (NSString *)getParams:(NSDictionary *)aDict
{
    // 根据webviewId查找webview所在的viewcontroller
    NSString *aWebViewID = [aDict objectForKey:@"webviewId"];
    CDVWKWebView *aWebview = [CDVWKWebView webViewWithID:aWebViewID];
    CMPBannerWebViewController *aController = (CMPBannerWebViewController *)aWebview.viewController;
    return  [aController getParams];
}

+ (NSString *)getBackParams:(NSDictionary *)aDict
{
    // 根据webviewId查找webview所在的viewcontroller
    NSString *aWebViewID = [aDict objectForKey:@"webviewId"];
    CDVWKWebView *aWebview = [CDVWKWebView webViewWithID:aWebViewID];
    CMPBannerWebViewController *aController = (CMPBannerWebViewController *)aWebview.viewController;
    return  [aController getBackData];
}

- (void)setNavigationBarHidden:(CDVInvokedUrlCommand *)command
{
    //0. 隐藏 1.显示 2.隐藏且可以下拉显示 3.显示且可以上划隐藏下拉显示
    CMPBannerWebViewController *aController = (CMPBannerWebViewController *)self.viewController;
    NSNumber *parameter = [command.arguments lastObject];
    [aController showNavBarforWebView:parameter];
}

- (void)addRightButton:(CDVInvokedUrlCommand *)command{
    NSArray *parameterArr = [command.arguments firstObject];
    if (!parameterArr || ![parameterArr isKindOfClass:[NSArray class]]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *parameter  in parameterArr) {
        
        NSString *type = [parameter objectForKey:@"type"];
        NSString *idKey = [parameter objectForKey:@"id"];
        if ([type isEqualToString:@"text"]) {
            NSString *text = [parameter objectForKey:@"text"];
            NSString *textColor = [parameter objectForKey:@"textColor"];
            NSInteger textSize = [[parameter objectForKey:@"textSize"] integerValue];
            
            UIColor *defaultTextColor = [UIColor cmp_colorWithName:@"main-fc"];
            if (textColor) {
                defaultTextColor = CMP_HEXSTRINGCOLOR(textColor);
            }
            NSInteger  defaultTextSize = 16;
            if (textSize) {
                defaultTextSize = textSize;
            }
            
            UIButton *addButton = [UIButton buttonWithTitle:text textColor:defaultTextColor textSize:defaultTextSize];
            [CMPBannerNavigationBar addPlugFlagForView:addButton];
            [items addObject:addButton];
            addButton.buttonId = idKey;
            [addButton addTarget:self action:@selector(addRightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
        } else if ([type isEqualToString:@"image"]){
            
            NSString *imageUrl = [parameter objectForKey:@"imageUrl"];
            
            if ([CMPCachedUrlParser chacedUrl:[NSURL URLWithString:imageUrl]]) {
                imageUrl = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:imageUrl]];
            }
            
            UIButton *addButton = [UIButton buttonWithImagePath:imageUrl frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
            [CMPBannerNavigationBar addPlugFlagForView:addButton];
            [items addObject:addButton];
            addButton.buttonId = idKey;
            [addButton addTarget:self action:@selector(addRightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
    
    CMPBannerNavigationBar *bannerNavigationBar = ((CMPBannerWebViewController *)self.viewController).bannerNavigationBar;
    [bannerNavigationBar removeAddPlugRightBarButton];
    [bannerNavigationBar insertRightBarButtonItems:items];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    
}

//删除导航栏右边所有按钮
- (void)removeAllRightButton:(CDVInvokedUrlCommand *)command{
    CMPBannerNavigationBar *bannerNavigationBar = ((CMPBannerWebViewController *)self.viewController).bannerNavigationBar;
    for (UIButton *button in bannerNavigationBar.rightBarButtonItems) {
        [button removeFromSuperview];
    }
}

- (void)addLeftButton:(CDVInvokedUrlCommand *)command{
    
    NSArray *parameterArr = [command.arguments firstObject];
    if (!parameterArr || ![parameterArr isKindOfClass:[NSArray class]]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *parameter  in parameterArr) {
        
        UIButton *button = [UIButton cmp_buttonWithParamDic:parameter];
        [button addTarget:self action:@selector(addLeftButtonAction:) forControlEvents:UIControlEventTouchDown];
        [items addObject:button];
    }
    
    UIButton *button = items.firstObject;
    CMPBannerWebViewController *controller = (CMPBannerWebViewController *)self.viewController;
    if ([controller isKindOfClass:[CMPBannerWebViewController class]]) {
        if (button.cmp_ButtonType == CMPButtonTypeWithBgColorAndRadius) {
            controller.titleType = CMPBannerTitleTypeNull;
        } else {
            controller.titleType = CMPBannerTitleTypeNullWithTextButton;
        }
    }
    
    CMPBannerNavigationBar *bannerNavigationBar = ((CMPBannerWebViewController *)self.viewController).bannerNavigationBar;
    bannerNavigationBar.isBannarAddLeftButtonItems = YES;
    if (button.cmp_ButtonType == CMPButtonTypeWithBgColorAndRadius) {
        bannerNavigationBar.titleType = CMPBannerTitleTypeNull;
    } else {
        bannerNavigationBar.titleType = CMPBannerTitleTypeNullWithTextButton;
    }
    [bannerNavigationBar setLeftBarButtonItems:items];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)activeLeftButton:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [command.arguments firstObject];
    NSString *idStr = parameter[@"id"];
    for (UIButton *abutton in ((CMPBannerWebViewController *)self.viewController).bannerNavigationBar.leftBarButtonItems) {
        if ([abutton.buttonId isEqualToString:idStr]) {
            if (abutton.cmp_ButtonType == CMPButtonTypeWithBgColorAndRadius) {
                abutton.layer.shadowColor = abutton.buttonShadowColor.CGColor;
                abutton.layer.shadowOffset = CGSizeMake(0,2);
                abutton.layer.shadowOpacity = 1;
                abutton.layer.shadowRadius = 6;
            }
            abutton.selected = YES;
            abutton.cmp_size = abutton.buttonActiveSize;
            NSString *js = [NSString stringWithFormat:@"cmp.event.trigger('CMPHeaderEventTrigger', document, {id: '%@'})", abutton.buttonId];
            [self.commandDelegate evalJs:js];
        }
    }
    [((CMPBannerWebViewController *)self.viewController).bannerNavigationBar autoLayout];
}

- (void)addRightButtonAction:(UIButton *)button {
    NSString *js = [NSString stringWithFormat:@"cmp.event.trigger('CMPHeaderEventTrigger', document, {id: '%@'})", button.buttonId];
    [self.commandDelegate evalJs:js];
}

- (void)addLeftButtonAction:(UIButton *)button {
    button.selected = YES;
    if (button.selected) {
        button.cmp_size = button.buttonActiveSize;
        if (button.cmp_ButtonType == CMPButtonTypeWithBgColorAndRadius) {
            button.layer.shadowColor = button.buttonShadowColor.CGColor;
            button.layer.shadowOffset = CGSizeMake(0,2);
            button.layer.shadowOpacity = 1;
            button.layer.shadowRadius = 6;
        }
    }
    
    for (UIButton *abutton in ((CMPBannerWebViewController *)self.viewController).bannerNavigationBar.leftBarButtonItems) {
        if (abutton != button) {
            abutton.selected = NO;
            abutton.cmp_size = abutton.buttonSize;
            if (abutton.buttonType == CMPButtonTypeWithBgColorAndRadius) {
                abutton.layer.shadowOpacity = 0;
            }
        }
    }
    [((CMPBannerWebViewController *)self.viewController).bannerNavigationBar autoLayout];
    NSString *js = [NSString stringWithFormat:@"cmp.event.trigger('CMPHeaderEventTrigger', document, {id: '%@'})", button.buttonId];
    [self.commandDelegate evalJs:js];
}

- (void)webviewDestroy:(CDVInvokedUrlCommand *)command {
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
            if (self.viewController.navigationController.topViewController == self.viewController) {
                [self.viewController.navigationController popViewControllerAnimated:aAnimated];
            } else {
                NSMutableArray *mViewControllers = [self.viewController.navigationController.viewControllers mutableCopy];
                [mViewControllers removeObject:self.viewController];
                self.viewController.navigationController.viewControllers = [mViewControllers autorelease];
            }
        }
    }
    else {
        [self.viewController dismissViewControllerAnimated:aAnimated completion:^{
            
        }];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setNavigationBarGlobalStyle:(CDVInvokedUrlCommand *)command{
    NSDictionary *parameter = [command.arguments firstObject];
    NSString *color = parameter[@"color"];
    NSString *backgroundColor = parameter[@"backgroundColor"];
    CMPBannerWebViewController *bannerWebViewController = (CMPBannerWebViewController *)self.viewController;
    CMPBannerNavigationBar *bannerNavigationBar = bannerWebViewController.bannerNavigationBar;
    if (bannerNavigationBar) {
        bannerNavigationBar.isSetNavigationBarGlobalStyle = YES;
        if (![NSString isNull:backgroundColor]) {
            [bannerNavigationBar setBannerBackgroundColor:CMP_HEXSTRINGCOLOR(backgroundColor)];
            bannerNavigationBar.bottomLineView.backgroundColor = CMP_HEXSTRINGCOLOR(backgroundColor);
            [bannerWebViewController setupStatusBarViewBackground:CMP_HEXSTRINGCOLOR(backgroundColor)];
            ((CMPBannerWebViewController *)self.viewController).bannerNavigationBar.globalBackgroundColor = CMP_HEXSTRINGCOLOR(backgroundColor);
        }else{
            bannerNavigationBar.globalBackgroundColor = [UIColor whiteColor];
        }
        if (![NSString isNull:color]) {
            bannerNavigationBar.bannerTitleView.textColor = CMP_HEXSTRINGCOLOR(color);
            bannerNavigationBar.globalColor = CMP_HEXSTRINGCOLOR(color);
        }else{
            bannerNavigationBar.bannerTitleView.textColor = [UIColor cmp_colorWithName:@"main-fc"];
            bannerNavigationBar.globalColor = [CMPThemeManager sharedManager].iconColor;
        }
        [bannerWebViewController setDefaultBackButtonAndCloseButton];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)switchFullScreenMode:(CDVInvokedUrlCommand *)command {
    UIViewController *vc = self.viewController;
    CDVPluginResult *pluginResult = nil;
    
    if (![vc cmp_inDetailStack]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"只能在内容区调用全屏插件"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSDictionary *parameter = [command.arguments firstObject];
    id fullScreenValue = parameter[@"fullScreen"];
    if (!fullScreenValue || [fullScreenValue isKindOfClass:[NSNull class]]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    BOOL fullScreen = [fullScreenValue boolValue];
    if (fullScreen) {
        [self.viewController.cmp_splitViewController cmp_switchFullScreen];
    } else {
        [self.viewController.cmp_splitViewController cmp_switchSplitScreen];
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)isFullScreenMode:(CDVInvokedUrlCommand *)command {
    NSString *fullScreenMode = @"0";
    if (CMP_IPAD_MODE) {
        fullScreenMode = self.viewController.cmp_splitViewController.cmp_isFullScreen ? @"1" : @"0";
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:fullScreenMode];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)clearDetailPad:(CDVInvokedUrlCommand *)command {
    if (CMP_IPAD_MODE && [self.viewController cmp_canPushInDetail]) {
        [self.viewController cmp_clearDetailViewController];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)isInDetailPad:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;
    if (CMP_IPAD_MODE) {
        pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[self.viewController cmp_inDetailStack]];
    } else {
        pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not a pad"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)hideTitleDivider:(CDVInvokedUrlCommand *)command {
    BOOL isHidden = [[command.arguments firstObject] boolValue];
    if ([self.viewController isKindOfClass:[CMPBannerWebViewController class]]) {
        CMPBannerWebViewController *bannerWebViewController = (CMPBannerWebViewController *)self.viewController;
        CMPBannerNavigationBar *bannerNavigationBar = bannerWebViewController.bannerNavigationBar;
        [bannerNavigationBar hideBottomLine:isHidden];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openSlideWeb:(CDVInvokedUrlCommand *)command{
    NSDictionary *parameter = [command.arguments firstObject];
    NSString *url = [parameter objectForKey:@"url"];
    if (!url) {//测试数据
//        url = @"http://baidu.com";
        return;
    }
    if (url.length) {
        NSDictionary *options = [parameter objectForKey:@"options"];
        BOOL useNativebanner = [[options objectForKey:@"useNativebanner"] boolValue];
        
        CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
        NSString *indexPath = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:url]];
        if (!indexPath) {//如果本地找不到对应页面，则保持原有页面
            indexPath = url;
        }
        
        
        aCMPBannerViewController.pageParam = parameter;
        aCMPBannerViewController.hideBannerNavBar = !useNativebanner;
        
        aCMPBannerViewController.startPage = indexPath;
        
        self.viewController.navigationController.delegate = aCMPBannerViewController;
        
        //配置滑动参数
        CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration defaultConfiguration];
        conf.direction = CWDrawerTransitionFromRight;
        conf.showAnimDuration = 0.3f;
        CGFloat maxWidth = UIScreen.mainScreen.bounds.size.width * (314.0/375.0);
        conf.distance = MIN(maxWidth,386);
        
        CMPNavigationController *navi = [[CMPNavigationController alloc]initWithRootViewController:aCMPBannerViewController];//只能是navi方式包装
        [self.viewController cw_showDrawerViewController:navi animationType:CWDrawerAnimationTypeMask configuration:conf];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)closeSlideWeb:(CDVInvokedUrlCommand *)command{
    [self.viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)useNewModule:(CDVInvokedUrlCommand *)command{
    NSDictionary *parameter = [command.arguments firstObject];
    NSString *useNewModule = [parameter objectForKey:@"useNewModule"];
    
    if ([useNewModule isEqualToString:@"useNewModule"]) {//使用头部占位图-新模板
        [self addNavigationBackgroundImage:command];
    }else if ([useNewModule isEqualToString:@"notUseNewModule"]){//不使用头部占位图
        [self removeNavigationBackgroundImage:command];
    }
}

- (void)addNavigationBackgroundImage:(CDVInvokedUrlCommand *)command{
    NSDictionary *parameter = [command.arguments firstObject];
    NSString *image_url = [parameter objectForKey:@"image_url"];//图片地址（本地应用包地址或远程）
    
    UIViewController *vc = self.viewController;
    if ([vc isKindOfClass:CMPBannerWebViewController.class]) {
        CMPBannerWebViewController *aController = (CMPBannerWebViewController *)vc;
        UIView *v = [aController.view viewWithTag:222101];
        if (!v) {
            CGFloat statusBarHeight = [UIView staticStatusBarHeight];
            CGFloat h = aController.bannerBarHeight + statusBarHeight;
            UIImageView *igv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, h)];
            igv.tag = 222101;
            igv.image = [UIImage cmp_autoImageNamed:@"banner_newTemplate_white" darkNamed:@"banner_newTemplate_dark"];
            igv.contentMode = UIViewContentModeScaleToFill;
            [aController.view addSubview:igv];
            [aController.view sendSubviewToBack:igv];
                        
            [igv mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.mas_equalTo(0);
                make.height.mas_equalTo(h);
            }];
            
            NSURL *imageURL = [NSURL URLWithString:image_url];
            if (imageURL) {
                UIImage *image = nil;
                if ([CMPCachedUrlParser chacedUrl:imageURL]) {
                    NSString *localPath = [CMPCachedUrlParser cachedPathWithUrl:imageURL];
                    localPath = [localPath replaceCharacter:@"file://" withString:@""];
                    if (localPath) {
                        image = [UIImage imageWithContentsOfFile:localPath];
                    }
                }
                if (image) {
                    igv.image = image;
                }else{
                    UIImage *placeholderImage = [UIImage cmp_autoImageNamed:@"banner_newTemplate_white" darkNamed:@"banner_newTemplate_dark"];
                    [igv sd_setImageWithURL:imageURL placeholderImage:placeholderImage];
                }
            }
            
            aController.bannerNavigationBar.backgroundColor = UIColor.clearColor;
            aController.bannerNavigationBar.bottomLineView.hidden = YES;//隐藏底部的线条
            [aController setupStatusBarViewBackground:UIColor.clearColor];//设置状态栏背景色
        }        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)removeNavigationBackgroundImage:(CDVInvokedUrlCommand *)command{
    UIViewController *vc = self.viewController;
    if ([vc isKindOfClass:CMPBannerWebViewController.class]) {
        CMPBannerWebViewController *aController = (CMPBannerWebViewController *)vc;
        UIView *v = [aController.view viewWithTag:222101];
        [v removeFromSuperview];
        
        UIColor *backgroundColor = aController.bannerNavigationBar.globalBackgroundColor;
        if(!backgroundColor){
            backgroundColor = [UIColor cmp_colorWithName:@"theme-bdc"];
        }
        [aController.bannerNavigationBar setBannerBackgroundColor:backgroundColor];
        aController.bannerNavigationBar.bottomLineView.backgroundColor = backgroundColor;
        [aController setupStatusBarViewBackground:backgroundColor];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)showOverView:(CDVInvokedUrlCommand *)command{
    NSDictionary *parameter = [command.arguments firstObject];
    NSString *showOverView = [parameter objectForKey:@"showOverView"];//showOverView\hideOverView
    NSString *rgba = [parameter objectForKey:@"color"];
    NSString *clickId = [parameter objectForKey:@"id"];
    
    UIViewController *vc = self.viewController;
    if ([vc isKindOfClass:CMPBannerWebViewController.class]) {
        CMPBannerWebViewController *aController = (CMPBannerWebViewController *)vc;
        
        if ([showOverView isEqualToString:@"showOverView"]) {
            UIView *v = [aController.view viewWithTag:222102];//遮罩
            if (!v) {
                CGFloat statusBarHeight = [UIView staticStatusBarHeight];
                CGFloat h = aController.bannerBarHeight + statusBarHeight;
                                                
                CMPNavigationBarMaskView *maskV = [[CMPNavigationBarMaskView alloc]initWithClickId:clickId fromVC:aController];
                maskV.tag = 222102;
                maskV.backgroundColor = [UIColor RGBA:rgba];
                [aController.view addSubview:maskV];
                [aController.view bringSubviewToFront:maskV];
                [maskV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.top.mas_equalTo(0);
                    make.height.mas_equalTo(h);
                }];
            }
        }else{
            //变透明：h5调原生200ms动画
            UIView *v = [aController.view viewWithTag:222102];//遮罩
            [UIView animateWithDuration:0.2 animations:^{
                v.alpha = 0;
            } completion:^(BOOL finished) {
                [v removeFromSuperview];
            }];
        }
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//打开presentFullScreenWeb
- (void)presentFullScreenWeb:(CDVInvokedUrlCommand *)command{
    NSDictionary *parameter = [command.arguments firstObject];
    NSString *url = [parameter objectForKey:@"url"];
    NSString *webBgColor = [parameter objectForKey:@"webBgColor"];
//    url = @"http://baidu.com";
    if (!url) {//测试数据
//        url = @"http://baidu.com";
        return;
    }
    if (url.length) {
        NSDictionary *options = [parameter objectForKey:@"options"];
        BOOL useNativebanner = [[options objectForKey:@"useNativebanner"] boolValue];
        
        CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
        NSString *indexPath = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:url]];
        if (!indexPath) {//如果本地找不到对应页面，则保持原有页面
            indexPath = url;
        }
        aCMPBannerViewController.pageParam = parameter;
        aCMPBannerViewController.hideBannerNavBar = !useNativebanner;
        aCMPBannerViewController.startPage = indexPath;
        
        aCMPBannerViewController.presentAlphaBgColor = webBgColor;
        self.viewController.navigationController.delegate = aCMPBannerViewController;
        
        aCMPBannerViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

        [self.viewController.rdv_tabBarController presentViewController:aCMPBannerViewController animated:NO completion:^{
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}

//dismissFullScreenWeb
- (void)dismissFullScreenWeb:(CDVInvokedUrlCommand *)command{
    if ([self.viewController isKindOfClass:CMPBannerWebViewController.class]
        || [self.viewController isMemberOfClass:CMPBannerWebViewController.class]) {
        CMPBannerWebViewController *bannerWeb = (CMPBannerWebViewController *)self.viewController;
        if (bannerWeb.presentAlphaBgColor.length) {
            [self.viewController dismissViewControllerAnimated:NO completion:^{
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
            return;
        }
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
