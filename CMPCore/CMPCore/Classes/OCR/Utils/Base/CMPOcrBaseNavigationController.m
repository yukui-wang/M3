#import "CMPOcrBaseNavigationController.h"
#import "CMPOcrBaseViewController.h"
#import "CustomDefine.h"
#import "UIView+Layer.h"

@interface CMPOcrBaseNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation CMPOcrBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:ESFontPingFangMedium(16),
                                                 NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationBar setShadowImage:[UIImage new]];
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

    UIImage *backImage = [[UIImage imageNamed:@"navBackButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationBar.backIndicatorImage = backImage;
    self.navigationBar.backIndicatorTransitionMaskImage = backImage;
    __weak CMPOcrBaseNavigationController *weakSelf = self;
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            self.navigationBar.barTintColor = [UIColor whiteColor];
            [self.navigationBar setShadowImage:[UIImage new]];
            [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        }
    }
#endif
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray* viewControllers = navigationController.viewControllers;
    if ([viewControllers.lastObject isKindOfClass:[CMPOcrBaseViewController class]]) {
        [(CMPOcrBaseViewController *)viewControllers.lastObject addNavigationBackButton];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if (self.topViewController.interactivePopGestureRecognizerDisable) {
//        self.interactivePopGestureRecognizer.enabled = NO;
//        return;
//    }
//
//    NSArray* viewControllers = navigationController.viewControllers;
//    if (viewControllers.count > 1) {
//        if([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//            self.interactivePopGestureRecognizer.enabled = YES;
//        }
//    } else {
//        if([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//            self.interactivePopGestureRecognizer.enabled = NO;
//        }
//    }
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

#pragma mark - Override

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count >= 1) {
        viewController.hidesBottomBarWhenPushed = YES;
        
        if (viewController.hidesBottomBarWhenPushed) {
            viewController.hidesBottomBarWhenPushed = NO;
        }
    }
    [super pushViewController:viewController animated:animated];
}

/**
 Tips：覆盖父类方法，将状态栏的风格控制下放到每一个子级控制分别控制
 
 @return 返回当前状态栏风格控制对象
 */
- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}
@end
