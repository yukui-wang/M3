//
//  CMPSplitViewController.m
//  CMPLib
//
//  Created by CRMO on 2019/5/6.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPSplitViewController.h"
#import "CMPNavigationController.h"
#import "CMPEmptyViewController.h"
#import "RDVTabBarController.h"
#import "UIColor+Hex.h"
#import "UIView+RTL.h"
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/CMPCommonTool.h>


@interface CMPSplitViewController ()
@property (strong, nonatomic) UIView *seperateLine;
@end

@implementation CMPSplitViewController

#pragma mark-
#pragma mark Life Circle

+ (instancetype)splitWithMasterVc:(UIViewController *)vc delegate:(id)delegate {
    CMPSplitViewController *spliteVc = [[CMPSplitViewController alloc] init];
    CMPEmptyViewController *emptyVc = [[CMPEmptyViewController alloc] init];
    CMPNavigationController *detailNav = [[CMPNavigationController alloc] initWithRootViewController:emptyVc];
    detailNav.navigationBarHidden = YES;
    CMPNavigationController *masterNav = [[CMPNavigationController alloc] initWithRootViewController:vc];
    masterNav.navigationBarHidden = YES;
    spliteVc.viewControllers = @[masterNav, detailNav];
    spliteVc.view.backgroundColor = [UIColor colorWithHexString:@"#F8F9FB"];
    //spliteVc.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    if (InterfaceOrientationIsPortrait) {
        spliteVc.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    } else {
        spliteVc.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    }
    spliteVc.presentsWithGesture = NO;
    spliteVc.preferredPrimaryColumnWidthFraction = 0.38;
    spliteVc.minimumPrimaryColumnWidth = 340;
    spliteVc.maximumPrimaryColumnWidth = 420;
    spliteVc.delegate = delegate;
    return spliteVc;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.seperateLine = [[UIView alloc] init];
    self.seperateLine.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    [self.view addSubview:self.seperateLine];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateStackAnimation:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateSeperateLineFrame];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
     [self updateSeperateLineFrame];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wunsupported-availability-guard"
    if (!@available(iOS 13,*)) {
        if ([UIView isRTL] && self.cmp_splitViewController.preferredDisplayMode != UISplitViewControllerDisplayModePrimaryHidden) {
            UIView *masterContentView = self.view.subviews[2];
            masterContentView.cmp_x -= 80;
        }
    };
    #pragma clang diagnostic pop
}

- (void)updateSeperateLineFrame {
     self.seperateLine.frame = CGRectMake(self.masterNavigation.view.cmp_width, 0, 1, self.masterNavigation.view.cmp_height);
    [self.seperateLine resetFrameToFitRTL];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (![self cmp_isFullScreen]) {
            if (InterfaceOrientationIsPortrait) {
                self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
            } else {
                self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
            }
        }
        if (self.rdv_tabBarController.selectedIndex != 1000) {
            [self.rdv_tabBarController setSelectedIndex:self.rdv_tabBarController.selectedIndex];
        } else {
            [self.rdv_tabBarController replaceSelectedViewController:self.rdv_tabBarController.selectedViewController];
        }
        [self updateStackAnimation:NO];
        //[self updateSeperateLineFrame];
    } completion:nil];
}

#pragma mark-
#pragma mark 路由管理

- (void)showDetailViewController:(UIViewController *)vc {
//    CMPNavigationController *nav = [[CMPNavigationController alloc] init];
//    NSMutableArray *vcs = [NSMutableArray array];

//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (orientation == UIDeviceOrientationPortrait ||
//        orientation == UIDeviceOrientationPortraitUpsideDown) {
//        if (self.masterStackSize == 0) {
//            [vcs addObject:vc];
//        } else {
//            NSArray *mergeStack = self.detailNavigation.viewControllers;
//            NSArray *masterStack = [mergeStack subarrayWithRange:NSMakeRange(0, self.masterStackSize)];
//            [vcs addObjectsFromArray:masterStack];
//            [vcs addObject:vc];
//        }
//    } else {
//        CMPEmptyViewController *emptyVc = [CMPEmptyViewController emptyViewController];
//        [vcs addObject:emptyVc];
//        [vcs addObject:vc];
//   }
    
//    [vcs addObjectsFromArray:self.detailNavigation.viewControllers];
//    [vcs addObject:vc];
    
    [self.detailNavigation pushViewController:vc animated:YES];
    //[self showDetailViewController:self.detailNavigation sender:self];
    
//    nav.viewControllers = [vcs copy];
//    [self showDetailViewController:nav sender:self];
}

- (void)clearDetailViewController {
    CMPEmptyViewController *emptyVc = [CMPEmptyViewController emptyViewController];
    CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:emptyVc];
    nav.navigationBarHidden = YES;
    [self showDetailViewController:nav sender:self];
}

- (void)updateStackAnimation:(BOOL)animation {
    // 如果当前页签没有被选中，不需要更新栈
    if (self != [self rdv_tabBarController].selectedViewController) {
        return;
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self updateStackWithDisplayMode:orientation animation:animation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CMPSplitViewControllerDidUpdateStack object:self];
}

/**
 路由栈管理核心函数
 竖屏->横屏：拆分mergeStack
 横屏->竖屏：合并mergeStack
 */
- (void)updateStackWithDisplayMode:(UIInterfaceOrientation)orientation animation:(BOOL)animation {
    // 竖屏，栈合并为mergeStack
    if (orientation == UIDeviceOrientationPortrait ||
        orientation == UIDeviceOrientationPortraitUpsideDown) {
        if (self.masterStackSize != 0) {
            DDLogDebug(@"zl---上一个状态也为竖屏，不合并MergeStack，避免重复");
            return;
        }
        self.seperateLine.hidden = YES;
        
        // 记录操作区大小
        self.masterStackSize = self.masterNavigation.viewControllers.count;
        
        NSMutableArray *mergeStack = [NSMutableArray array];
        [mergeStack addObjectsFromArray:self.masterNavigation.viewControllers];
        
        for (UIViewController *vc in self.detailNavigation.viewControllers) {
            // 去掉内容区的空页面
            if (![vc isMemberOfClass:[CMPEmptyViewController class]]) {
                [mergeStack addObject:vc];
            }
        }
        
        // MergeStack = masterStack + detailStack
        [self.detailNavigation setViewControllers:[mergeStack copy] animated:animation];
    } else if (orientation == UIDeviceOrientationLandscapeLeft ||
               orientation == UIDeviceOrientationLandscapeRight) { // 拆分mergeStack
        if (self.masterStackSize == 0) {
            DDLogDebug(@"zl---上一个状态也为横屏，不拆分MergeStack，避免重复");
            return;
        }
        
        NSArray *mergeStack = [self.detailNavigation.viewControllers copy];
        
        if (self.masterStackSize >= mergeStack.count) { // 内容区没有内容
            [self.masterNavigation setViewControllers:mergeStack animated:NO];
            [self.detailNavigation setViewControllers:@[[CMPEmptyViewController new]] animated:NO];
        } else { // 内容区还有内容
            [self.masterNavigation setViewControllers:[mergeStack subarrayWithRange:NSMakeRange(0, self.masterStackSize)] animated:animation];
            
            // 拆分内容区时，在内容区栈顶加入空页面
            NSMutableArray *detailVcs = [NSMutableArray array];
            [detailVcs addObject:[CMPEmptyViewController emptyViewController]];
            [detailVcs addObjectsFromArray:[mergeStack subarrayWithRange:NSMakeRange(self.masterStackSize, mergeStack.count - self.masterStackSize)]];
            [self.detailNavigation setViewControllers:[detailVcs copy] animated:animation];
        }
        
        // 销毁mergeStack
        self.masterStackSize = 0;
        self.seperateLine.hidden = NO;
        if ([self cmp_isFullScreen]) {
            self.seperateLine.hidden = YES;
        }
        
        [NSNotificationCenter.defaultCenter postNotificationName:CMPSplitViewContrllerDidBecomeLandscapeNoti object:nil];
    } else {
        DDLogError(@"CMPSplitViewController updateStackWithDisplayMode:%ld", (long)orientation);
    }
    
    
}

#pragma mark-
#pragma mark Getter

- (CMPNavigationController *)masterNavigation {
    return self.viewControllers.firstObject;
}

- (CMPNavigationController *)detailNavigation {
    return self.viewControllers.lastObject;
}

- (void)updateSeperateLineHidden:(BOOL)hidden {
    if (hidden) {
        self.seperateLine.hidden = YES;
    }
    else {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            self.seperateLine.hidden = NO;
            //竖屏全屏切换横屏时，再退出全屏，隐藏侧导航后界面变化有延迟，导致masterNavigation view frame 改变延迟，
            [self performSelector:@selector(updateSeperateLineFrame) withObject:nil afterDelay:0.1];
        }
    }
}

- (void)didSeleted {
    if (![self cmp_isFullScreen]) {
        if (InterfaceOrientationIsPortrait) {
            self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
        } else {
            self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        }
    }
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    NSString *title = nil;
    if (InterfaceOrientationIsPortrait) {
        title = [self getControllerTitleWithVC:self.detailNavigation];
    } else {
        NSString *title1 = [self getControllerTitleWithVC:self.masterNavigation];
        NSString *title2 = [self getControllerTitleWithVC:self.detailNavigation];
        title = [NSString stringWithFormat:@"%@,%@",title1,title2];
    }
    return title;
}

- (NSString *)getControllerTitleWithVC:(UIViewController *)vc {
    NSString *title = nil;
    UIViewController *frontVc = [CMPCommonTool recursiveFindCurrentShowViewControllerFromViewController:vc];
    if ([frontVc respondsToSelector:@selector(currentPageScreenshotControlTitle)]) {
        title = [(id)frontVc currentPageScreenshotControlTitle];
    }
    if ([NSString isNull:title]) {
        title = NSStringFromClass(frontVc.class);
    }
    return title;
}

@end

@implementation UIViewController (CMPSplitViewController)

- (CMPSplitViewController *)cmp_splitViewController {
    if ([self isKindOfClass:[CMPSplitViewController class]]) {
        return (CMPSplitViewController *)self;
    } else {
        CMPSplitViewController *split = (CMPSplitViewController *)self.splitViewController;
        return split;
    }
}

- (void)cmp_showDetailViewController:(UIViewController *)vc {
    [self.cmp_splitViewController showDetailViewController:vc];
}

- (void)cmp_clearDetailViewController {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return;
    }
    if ([self cmp_inMasterStack]) {
        [self.cmp_splitViewController clearDetailViewController];
    }
}

- (void)cmp_pushPageInMasterView:(UIViewController *)vc navigation:(UINavigationController *)nav {
    [nav pushViewController:vc animated:YES];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIDeviceOrientationPortrait ||
        orientation == UIDeviceOrientationPortraitUpsideDown) {
        self.cmp_splitViewController.masterStackSize++;
    }
}

- (BOOL)cmp_canPushInDetail {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    return [self cmp_inMasterStack];
}

- (BOOL)cmp_inMasterStack {
    CMPSplitViewController *split = self.cmp_splitViewController;
    
    if (!split) {
        return NO;
    }
    
    NSArray *masterArr = nil;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        CMPNavigationController *nav = split.detailNavigation;
        NSInteger masterStackSize = split.masterStackSize;
        if (masterStackSize > nav.viewControllers.count) {
            masterStackSize = nav.viewControllers.count;
        }
        masterArr = [nav.viewControllers subarrayWithRange:NSMakeRange(0, masterStackSize)];
    } else {
        CMPNavigationController *nav = split.masterNavigation;
        masterArr = nav.viewControllers;
        if (!nav || ![nav isKindOfClass:[CMPNavigationController class]] ||
            nav.viewControllers.count == 0) {
            return NO;
        }
    }

    return [masterArr containsObject:self];
}

- (BOOL)cmp_inDetailStack {
    return ![self cmp_inMasterStack];
}

- (BOOL)cmp_isFullScreen {
    return self.cmp_splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryHidden && self.rdv_tabBarController.tabBarHidden;
}

- (void)cmp_switchFullScreenInner {
    [self.rdv_tabBarController setTabBarHidden:YES animated:NO];
    self.cmp_splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    [self.cmp_splitViewController updateSeperateLineHidden:YES];
}

- (void)cmp_switchFullScreen {
    [self performSelector:@selector(cmp_switchFullScreenInner) withObject:nil afterDelay:0.5];
}

- (void)cmp_switchSplitScreen {
    [self.rdv_tabBarController setTabBarHidden:NO animated:NO];
    //self.cmp_splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    if (InterfaceOrientationIsPortrait) {
        self.cmp_splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    } else {
        self.cmp_splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    }
    [self.cmp_splitViewController updateSeperateLineHidden:NO];

}


@end
