//
//  CMPNavigationController.h
//  ScreenShotBack
//
//  Created by 郑文明 on 16/5/10.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "CMPNavigationController.h"
#import "CMPBaseViewController.h"
#import "CMPAppDelegate.h"
#import "CMPBannerWebViewController.h"
#import "RDVTabBarController.h"
#import "CMPSplitViewController.h"
#import <CMPLib/CMPEmptyViewController.h>
#import "CMPBannerViewController.h"
#import "CMPIntercepter.h"
#import "UIImage+CMP.h"
@interface CMPNavigationController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>
@end

@implementation CMPNavigationController

// 打开边界多少距离才触发pop
#define DISTANCE_TO_POP 50
#define DISTANCE_SPEED 500
- (id)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        self.showTabBarInRootVC = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //屏蔽系统的手势
    self.interactivePopGestureRecognizer.enabled = NO;
    if ([CMPFeatureSupportControl allowPopGesture]) {
        self.arrayScreenshot = [NSMutableArray array];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.delegate = self;
        [self.view addGestureRecognizer:_panGesture];
    }
}

- (BOOL)isRTL {
    //是否是阿拉伯语言
    if ([UIView appearance].semanticContentAttribute == UISemanticContentAttributeForceRightToLeft) {
        return YES;
    }
    return NO;
}


- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    BOOL enablePanGesture = YES;
    if ([self.topViewController conformsToProtocol:@protocol(CMPNavigationControllerProtocol)]) {
        enablePanGesture = (BOOL)[self.topViewController performSelector:@selector(enablePanGesture)];
    }
    if (enablePanGesture && gestureRecognizer.view == self.view) {
        CGPoint translate = [gestureRecognizer locationInView:self.view];
        if (([self isRTL] && translate.x > CMP_SCREEN_WIDTH-50) ||
            (![self isRTL] && translate.x < 50)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ||
        [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")]||
        [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPagingSwipeGestureRecognizer")]) //
    {
        UIView *aView = otherGestureRecognizer.view;
        if ([aView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *sv = (UIScrollView *)aView;
            if (sv.contentOffset.x==0) {
                return YES;
            }
        }
        return NO;
    }
    return YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    if (_forceDisablePanGestureBack) {
        return;
    }
    CMPAppDelegate *appdelegate = (CMPAppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIViewController *rootVC = appdelegate.window.rootViewController;
    UIViewController *presentedVC = rootVC.presentedViewController;
    
    static NSDate *gestureBeginTime = nil;
    static NSDate *gestureEndTime = nil;
    
    if (self.viewControllers.count == 1) {
        if (self.presentingViewController) {
            if (panGesture.state == UIGestureRecognizerStateEnded) {
                CGPoint point_inView = [panGesture translationInView:self.view];//偏移
                if (([self isRTL] && point_inView.x < -DISTANCE_TO_POP) ||
                    (![self isRTL] && point_inView.x >= DISTANCE_TO_POP) ) {
                    CMPBaseWebViewController *aViewController = self.viewControllers.lastObject;
                    if ([aViewController isKindOfClass:[CMPBaseWebViewController class]]) {
                        if (!aViewController.disableGestureBack) {
                            [aViewController backBarButtonAction:nil];
                        }
                    }
                    else if ([aViewController isKindOfClass:[CMPBannerViewController class]]) {
                        [aViewController backBarButtonAction:nil];
                    }
                    else {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }
        }
        return;
    }
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        appdelegate.screenshotView.frame = appdelegate.screenshotView.bounds;
        appdelegate.screenshotView.imgView.image = [_arrayScreenshot lastObject];
        appdelegate.screenshotView.hidden = NO;
        gestureBeginTime = [NSDate date];
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint point_inView = [panGesture translationInView:self.view];
        CGFloat point_x = point_inView.x;
     
        BOOL canMove = NO;
        CGFloat tx = 0;
        if ([self isRTL]) {
            if (point_x<-10) {
                canMove = YES;
                tx = -10+point_x;
            }
        }
        else {
            if (point_x>= 10) {
                canMove = YES;
                tx = point_x-10;
            }
        }
        if (canMove)
        {
            CMPBaseWebViewController *aViewController = self.viewControllers.lastObject;
            if ([aViewController isKindOfClass:[CMPBaseWebViewController class]] && aViewController.disableGestureBack) {
                return;
            }
            //ks fix -- V5-50504 解决controller不是push的手势返回问题
            if ([aViewController isKindOfClass:CMPBannerWebViewController.class]){
                CMPBannerWebViewController *bannerWebCtrl = aViewController;
                if (bannerWebCtrl.pageStack.count>1) {
                    if (bannerWebCtrl.backButtonDidClick){
                        return;
                    }
                }
            }
            //[appdelegate.screenshotView showEffectChange:point_inView];
            CGAffineTransform transform = CGAffineTransformMakeTranslation(tx, 0);
            rootVC.view.transform = transform;
            presentedVC.view.transform = transform;
            rootVC.view.layer.shadowOpacity = 0.5;
            presentedVC.view.layer.shadowOpacity = 0.5;
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded)
    {
        gestureEndTime = [NSDate date];
        CGPoint point_inView = [panGesture translationInView:self.view];
        NSTimeInterval intervaliTime = [gestureEndTime timeIntervalSinceDate:gestureBeginTime];
        CGFloat distance = point_inView.x;
        CGFloat speed =  distance/intervaliTime;
        BOOL canBack = NO;
        CGFloat tx = 0;
        if ([self isRTL]) {
            if (distance <= -DISTANCE_TO_POP || speed <= -DISTANCE_SPEED) {
                canBack = YES;
                tx = -CMP_SCREEN_WIDTH;
            }
        }
        else {
            if (distance >= DISTANCE_TO_POP || speed >= DISTANCE_SPEED) {
                canBack = YES;
                tx = CMP_SCREEN_WIDTH;
            }
        }
        if (canBack) {
            UIViewController *commonWebViewController = self.viewControllers.lastObject;
            if ([commonWebViewController isKindOfClass:NSClassFromString(@"CMPCommonWebViewController")]) {
                if (![CMPCore sharedInstance].needHandleUrlScheme){
                    [[CMPIntercepter sharedInstance] registerClass];
                }
            }
            
            CMPBaseWebViewController *aViewController = self.viewControllers.lastObject;
            if ([aViewController isKindOfClass:[CMPBaseWebViewController class]] && aViewController.disableGestureBack) {
                [aViewController backBarButtonAction:nil];
                return;
            }
            //ks fix -- V5-50504 解决controller不是push的手势返回问题
            if ([aViewController isKindOfClass:CMPBannerWebViewController.class]){
                CMPBannerWebViewController *bannerWebCtrl = aViewController;
                if (bannerWebCtrl.pageStack.count>1){
                    if (bannerWebCtrl.backButtonDidClick){
                        bannerWebCtrl.backButtonDidClick();
                        return;
                    }
                }
            }
            [UIView animateWithDuration:0.3 animations:^{
                CGAffineTransform transform = CGAffineTransformMakeTranslation(tx, 0);
                rootVC.view.transform = transform;
                presentedVC.view.transform = transform;
                //[appdelegate.screenshotView showEffectChange:CGPointMake(320, 0)];
            } completion:^(BOOL finished) {
                UIViewController *currentVC = self.viewControllers.lastObject;
                [self popViewControllerAnimated:NO];
                if ([currentVC isKindOfClass:[CMPBannerViewController class]]) {
                    CMPBannerViewController *aVC = (CMPBannerViewController *)currentVC;
                    if (aVC.panGestureBackBlock) {
                        aVC.panGestureBackBlock();
                    }
                }
                rootVC.view.transform = CGAffineTransformIdentity;
                presentedVC.view.transform = CGAffineTransformIdentity;
                appdelegate.screenshotView.hidden = YES;
                rootVC.view.layer.shadowOpacity = 0.0;
                presentedVC.view.layer.shadowOpacity = 0.0;
            }];
        }
        else {
            [UIView animateWithDuration:0.3 animations:^{
                rootVC.view.transform = CGAffineTransformIdentity;
                presentedVC.view.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                appdelegate.screenshotView.hidden = YES;
                rootVC.view.layer.shadowOpacity = 0.0;
                presentedVC.view.layer.shadowOpacity = 0.0;
            }];
        }
    }
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    [[CMPIntercepter sharedInstance] registerClass];
    
    NSArray *arr = [super popToViewController:viewController animated:animated];
    if ([self shouldHandleRDVTabBar]) {
        if (self.arrayScreenshot.count > arr.count) {
            for (int i = 0; i < arr.count; i++) {
                [self.arrayScreenshot removeLastObject];
            }
        }
        
        if ([self.viewControllers indexOfObject:viewController] == 0 && self.showTabBarInRootVC) {

            RDVTabBarController *tabBarController = [self rdv_tabBarController];
            [tabBarController setTabBarHidden:NO animated:YES];
        }
        //ks fix V5-9984 iOS14，退出和解散群组后底导航消失
        //苹果iOS14后有一个问题，popToViewController后，即使到根视图self.viewControllers也不止一个，而且根视图不是在第一个，所以上面的判断进不去，所以添加了下面的兼容处理
        else if (viewController.isRoot && self.showTabBarInRootVC) {

            RDVTabBarController *tabBarController = [self rdv_tabBarController];
            [tabBarController setTabBarHidden:NO animated:YES];
        }
    }
    if (CMP_IPAD_MODE) {
        NSInteger masterStackSize = self.cmp_splitViewController.masterStackSize;
        NSInteger currentCount = self.viewControllers.count;
        if (masterStackSize != 0 && masterStackSize > currentCount) {
            self.cmp_splitViewController.masterStackSize = currentCount;
        }
        if ([self.topViewController cmp_inDetailStack] && self.viewControllers.count == 1) {
            //横屏状态下，如果显示空界面，需要清空master列表的选中状态
            UIViewController *viewController = self.cmp_splitViewController.masterNavigation.topViewController;
            if ([viewController isKindOfClass:[CMPBaseViewController class]]) {
                CMPBaseViewController *aViewController = (CMPBaseViewController *)viewController;
                [aViewController cmp_didClearDetailViewController];
            }
            if ([viewController isKindOfClass:[CMPBaseWebViewController class]]) {
                CMPBaseWebViewController *aViewController = (CMPBaseWebViewController *)viewController;
                [aViewController cmp_didClearDetailViewController];
            }
        }
    }
   if (([viewController isKindOfClass:[CMPEmptyViewController class]] || [viewController cmp_inMasterStack]) && [viewController cmp_isFullScreen]) {
       [self.splitViewController cmp_switchSplitScreen];
    }
    return arr;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count == 0) {
        return [super pushViewController:viewController animated:animated];
    }
    
    if ([self shouldHandleRDVTabBar]) {
        CMPAppDelegate *appdelegate = (CMPAppDelegate *)[UIApplication sharedApplication].delegate;
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(appdelegate.window.frame.size.width, appdelegate.window.frame.size.height), YES, 0);
//        [appdelegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        UIImage *viewImage = [UIImage yw_screenShot];
        [self.arrayScreenshot addObject:viewImage];
        appdelegate.screenshotView.imgView.image = viewImage;
        
        RDVTabBarController *tabBarController = [self rdv_tabBarController];
        [tabBarController setTabBarHidden:YES animated:YES];
    }
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
//    [[CMPIntercepter sharedInstance] registerClass];

    if (CMP_IPAD_MODE &&
        [self.topViewController cmp_inMasterStack] &&
        self.cmp_splitViewController.masterStackSize != 0) {
        self.cmp_splitViewController.masterStackSize--;
    }
    if (CMP_IPAD_MODE) {
        if ([self.topViewController cmp_inDetailStack] && self.viewControllers.count == 2) {
            //横屏状态下，如果显示空界面，需要清空master列表的选中状态
            UIViewController *viewController = self.cmp_splitViewController.masterNavigation.topViewController;
            if ([viewController isKindOfClass:[CMPBaseViewController class]]) {
                CMPBaseViewController *aViewController = (CMPBaseViewController *)viewController;
                [aViewController cmp_didClearDetailViewController];
            }
            if ([viewController isKindOfClass:[CMPBaseWebViewController class]]) {
                CMPBaseWebViewController *aViewController = (CMPBaseWebViewController *)viewController;
                [aViewController cmp_didClearDetailViewController];
            }
        }
    }
    
    UIViewController *v = [super popViewControllerAnimated:animated];
    
    UIViewController *lastViewController = v.navigationController.viewControllers.lastObject;
    
    if (([lastViewController isKindOfClass:[CMPEmptyViewController class]] || [lastViewController cmp_inMasterStack]) && [v cmp_isFullScreen]) {
        [self.splitViewController cmp_switchSplitScreen];
    }
    
    if ([self shouldHandleRDVTabBar]) {
        [self.arrayScreenshot removeLastObject];
        UIViewController *controller = [self topViewController];
        if ([controller isKindOfClass:[CMPBannerWebViewController class]]) {
            //        CMPBannerWebViewController *webController = (CMPBannerWebViewController *)controller;
            //        [webController popPageStack];
        }
        
        if ([self.viewControllers indexOfObject:controller] == 0 && [self.parentViewController isKindOfClass:[RDVTabBarController class]]) {
            RDVTabBarController *tabBarController = [self rdv_tabBarController];
            [tabBarController setTabBarHidden:NO animated:YES];
        }

    }
    return v;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    if ([self shouldHandleRDVTabBar]) {
        CMPAppDelegate *appdelegate = (CMPAppDelegate *)[UIApplication sharedApplication].delegate;
        if (self.arrayScreenshot.count > 2) {
            [self.arrayScreenshot removeObjectsInRange:NSMakeRange(1, self.arrayScreenshot.count - 1)];
        }
        
        UIImage *image = [self.arrayScreenshot lastObject];
        if (image) {
            appdelegate.screenshotView.imgView.image = image;
        }
        RDVTabBarController *tabBarController = [self rdv_tabBarController];
        if ([self.parentViewController isKindOfClass:NSClassFromString(@"CMPTabBarViewController")]) {
            [tabBarController setTabBarHidden:NO animated:YES];
        }
    }
    if (CMP_IPAD_MODE &&
        self.cmp_splitViewController.masterStackSize != 0) {
        self.cmp_splitViewController.masterStackSize = 1;
    }
        
    return [super popToRootViewControllerAnimated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateEnablePanGesture:(BOOL)panGestureEnable
{
    if (panGestureEnable && _panGesture) {
        [self.view removeGestureRecognizer:_panGesture];
        [self.view addGestureRecognizer:_panGesture];
    }
    else {
        [self.view removeGestureRecognizer:_panGesture];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

- (void)dealloc {
    [_arrayScreenshot removeAllObjects];
    _arrayScreenshot = nil;
    
    [self.view removeGestureRecognizer:_panGesture];
    _panGesture.delegate = nil;
    _panGesture = nil;
}

- (BOOL)shouldHandleRDVTabBar
{
    // 如果当前是pad并且是v7.1sp1后版本
    if (INTERFACE_IS_PAD && [CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
        return NO;
    }
    return YES;
}

-(NSMutableArray<CMPNavigationCallBack> *)willShowViewControllerAlwaysCallBackArr {
    if (!_willShowViewControllerAlwaysCallBackArr) {
        _willShowViewControllerAlwaysCallBackArr = [NSMutableArray array];
    }
    return _willShowViewControllerAlwaysCallBackArr;
}

@end

