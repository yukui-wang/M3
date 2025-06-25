// RDVTabBarController.m
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import <objc/runtime.h>
#import "CMPConstant.h"
#import "UIView+RTL.h"
#import "CMPCore.h"
static CGFloat kTabBarWidthVertical = 80;

@interface UIViewController (RDVTabBarControllerItemInternal)

- (void)cmp_setTabBarController:(RDVTabBarController *)tabBarController;

/**
 从父ViewController移除
 */
- (void)cmp_removeFromParentVc;

@end

@interface RDVTabBarController ()

@property (strong, nonatomic) UIView *contentView;
@property (nonatomic, readwrite) RDVTabBar *tabBar;

@property (nonatomic, assign) CGPoint beginPoint;

@end

@implementation RDVTabBarController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[self contentView]];
    [self.view addSubview:[self tabBar]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setSelectedIndex:[self selectedIndex]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.orientation == RDVTabBarVertical) {
        [self layoutForVertical];
    } else {
        [self layoutForHorizontal];
    }
    [self postNotificationForXZ];
}
- (void)postNotificationForXZ{
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationName_TabbarSelectedViewControllerChanged object:self.selectedViewController];
}


- (void)layoutForVertical {
    CGSize viewSize = self.view.bounds.size;
    CGFloat tabBarWidth = kTabBarWidthVertical;
    CGFloat tabBarHeight = viewSize.height;
    CGFloat contenViewWidth = viewSize.width;
    CGFloat contentViewHeight = viewSize.height;
    
    if (!self.tabBarHidden && ![[self tabBar] isTranslucent]) {
        contenViewWidth -= tabBarWidth;
    } else if (self.tabBarHidden) {
        tabBarWidth = 0;
    }
    
    [[self tabBar] setFrame:CGRectMake(0, 0, tabBarWidth, tabBarHeight)];
    [[self tabBar] setOrientation:RDVTabBarVertical];
    [[self contentView] setFrame:CGRectMake(tabBarWidth, 0, contenViewWidth, contentViewHeight)];
    [[[self selectedViewController] view] setFrame:[[self contentView] bounds]];
    
    [[self tabBar] resetFrameToFitRTL];
    [[self contentView] resetFrameToFitRTL];
    [[[self selectedViewController] view] resetFrameToFitRTL];
}

- (void)layoutForHorizontal {
    CGSize viewSize = self.view.bounds.size;
    CGFloat tabBarHeight = self.canPanExpandNavi?216+12:65;
    CGFloat originY = self.canPanExpandNavi?86:65;//初始tabbar高度为36+50
    if (@available(iOS 11.0, *)) {
        CGFloat safeAreaBottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
        tabBarHeight += safeAreaBottom;
        originY += safeAreaBottom;
    }
    
    CGFloat tabBarStartingY = viewSize.height;
    CGFloat contentViewHeight = viewSize.height;
    
    if (!self.tabBarHidden) {
        tabBarStartingY = viewSize.height - originY;// tabBarHeight;
        if (![[self tabBar] isTranslucent]) {
            contentViewHeight -= originY;
        }
    }
    [[self tabBar] setFrame:CGRectMake(0, tabBarStartingY, viewSize.width, tabBarHeight)];
    [[self tabBar] setOrientation:RDVTabBarHorizontal];
    [[self contentView] setFrame:CGRectMake(0, 0, viewSize.width, contentViewHeight)];
    [[[self selectedViewController] view] setFrame:[[self contentView] bounds]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.selectedViewController.preferredStatusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.selectedViewController.preferredStatusBarUpdateAnimation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskAll;
    for (UIViewController *viewController in [self viewControllers]) {
        if (![viewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
            return UIInterfaceOrientationMaskPortrait;
        }
        
        UIInterfaceOrientationMask supportedOrientations = [viewController supportedInterfaceOrientations];
        
        if (orientationMask > supportedOrientations) {
            orientationMask = supportedOrientations;
        }
    }
    
    return orientationMask;
}

////推迟底部HomeIndicator的响应
//- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures{
//    return UIRectEdgeBottom;
//}
#pragma mark - Methods

- (void)replaceSelectedViewController:(UIViewController *)viewController {
    if (self.selectedViewController) {
        [self.selectedViewController cmp_removeFromParentVc];
    }
    
    [viewController cmp_setTabBarController:self];
    self.selectedViewController = viewController;
    _selectedIndex = 1000;
    [self addChildViewController:viewController];
    viewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:viewController.view];
    [self.selectedViewController didMoveToParentViewController:self];
    
    [self.view setNeedsLayout];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [self.delegate tabBarController:self didSelectViewController:viewController];
    }
}

//- (UIViewController *)selectedViewController {
//    return [self.viewControllers objectAtIndex:self.selectedIndex];
//}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.viewControllers.count) {
        return;
    }
    
    if (self.selectedViewController) {
        [self.selectedViewController cmp_removeFromParentVc];
    }
    
    _selectedIndex = selectedIndex;
    [self.tabBar setSelectedItem:self.tabBar.items[selectedIndex]];
    
    self.selectedViewController = [self.viewControllers objectAtIndex:selectedIndex];
    [self addChildViewController:self.selectedViewController];
    self.selectedViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.selectedViewController.view];
    [self.selectedViewController didMoveToParentViewController:self];

    [self.view setNeedsLayout];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (_viewControllers && _viewControllers.count) {
        for (UIViewController *viewController in _viewControllers) {
            [viewController cmp_removeFromParentVc];
        }
    }

    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        _viewControllers = [viewControllers copy];
        
        NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
        
        for (UIViewController *viewController in viewControllers) {
            RDVTabBarItem *tabBarItem = [[RDVTabBarItem alloc] init];
            [tabBarItem setTitle:viewController.title];
            [tabBarItems addObject:tabBarItem];
            [viewController cmp_setTabBarController:self];
        }
        
        [[self tabBar] setItems:tabBarItems];
    } else {
        for (UIViewController *viewController in _viewControllers) {
            [viewController cmp_setTabBarController:nil];
        }
        
        _viewControllers = nil;
    }
}

- (NSInteger)indexForViewController:(UIViewController *)viewController {
    UIViewController *searchedController = viewController;
    while (searchedController.parentViewController != nil && searchedController.parentViewController != self) {
        searchedController = searchedController.parentViewController;
    }
    return [[self viewControllers] indexOfObject:searchedController];
}

- (RDVTabBar *)tabBar {
    if (!_tabBar) {
        _tabBar = [[RDVTabBar alloc] initWithCanExpand:self.canPanExpandNavi canEdit:self.canEditExpandNavi];
        [_tabBar setBackgroundColor:[UIColor clearColor]];
        [_tabBar setDelegate:self];
        
        __weak typeof(self) wSelf = self;
        _tabBar.ExpandNaviItemClick = ^(id item) {
            NSLog(@"");
            if ([wSelf.delegate respondsToSelector:@selector(expandTabBarItemClick:)]) {
                [wSelf.delegate expandTabBarItemClick:item];
            }
        };
        _tabBar.ExpandNaviEditButtonClick = ^(id sender) {
            NSLog(@"");
            if ([wSelf.delegate respondsToSelector:@selector(expandTabBarEditClick:)]) {
                [wSelf.delegate expandTabBarEditClick:sender];
            }
        };
    }
    return _tabBar;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [_contentView setBackgroundColor:[UIColor whiteColor]];
    }
    return _contentView;
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    // make sure any pending layout is done, to prevent spurious animations
//    [self.view layoutIfNeeded];
    if([CMPCore sharedInstance].showingTopScreen){
        return;
    }
    if (_tabBarAlwaysHidden) {
        hidden = YES;
    }
    
    _tabBarHidden = hidden;
    [self.view setNeedsLayout];
    
    [[self tabBar] setHidden:_tabBarHidden];

//    if (!_tabBarHidden) {
//        [[self tabBar] setHidden:NO];
//    }
//
//    [UIView animateWithDuration:(animated ? 0.24 : 0) animations:^{
//        [self.view layoutIfNeeded];
//    } completion:^(BOOL finished){
//        if (self.tabBarHidden) {
//            [[self tabBar] setHidden:YES];
//        }
//    }];
    [self.tabBar showMaskView:hidden];
}

- (void)setTabBarHidden:(BOOL)hidden {
    [self setTabBarHidden:hidden animated:NO];
}

- (void)setTabBarAlwaysHidden:(BOOL)tabBarAlwaysHidden {
    _tabBarAlwaysHidden = tabBarAlwaysHidden;
    [self setTabBarHidden:tabBarAlwaysHidden];
}

- (void)setPortait:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabBar.portraitView setImage:image forState:UIControlStateNormal];
    });
}

- (void)setShortcuts:(NSArray<RDVTabBarShortcutItem*> *)items {
    self.tabBar.shortcutItems = items;
}

- (void)setBadgeShow:(BOOL)show atIndex:(NSInteger)index {
    if (index < 0 || index > (self.tabBar.items.count - 1)) {
        return;
    }
    
    RDVTabBarItem *item = self.tabBar.items[index];
    [item setShowBadge:show];
}
//扩展导航
- (void)setExpandBadgeShow:(BOOL)show atIndex:(NSInteger)index {
    if (index < 0 || index > (self.tabBar.expandItems.count - 1)) {
        return;
    }
    [self.tabBar setExpandBadgeAt:index show:show];
}

#pragma mark - RDVTabBarDelegate

- (BOOL)tabBarCanUse:(RDVTabBar *)tabBar {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarControllerCanUse:)]) {
        return [self.delegate tabBarControllerCanUse:self];
    }
    return YES;
}

- (BOOL)tabBar:(RDVTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index incompleteOperationBlock:(void (^)(void))block {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarController:shouldSelectItemAtIndex:incompleteOperationBlock:)]) {
        return [self.delegate tabBarController:self shouldSelectItemAtIndex:index incompleteOperationBlock:block];
    }
    return YES;
}

- (void)tabBar:(RDVTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= [[self viewControllers] count]) {
        return;
    }
    
    [self setSelectedIndex:index];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [self.delegate tabBarController:self didSelectViewController:[self viewControllers][index]];
    }
}

- (void)tabBarDidSelectPortrait:(RDVTabBar *)tabBar {
    if ([self.delegate respondsToSelector:@selector(tabBarControllerDidTapPortrait:)]) {
        [self.delegate tabBarControllerDidTapPortrait:self];
    }
}

- (BOOL)tabBar:(RDVTabBar *)tabBar didSelectShortcutAtIndex:(NSInteger)index incompleteOperationBlock:(void (^)(void))block {
    if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectShortcutAtIndex:incompleteOperationBlock:)]) {
       return [self.delegate tabBarController:self didSelectShortcutAtIndex:index incompleteOperationBlock:block];
    }
    return YES;
}

@end

#pragma mark - UIViewController+RDVTabBarControllerItem

@implementation UIViewController (RDVTabBarControllerItemInternal)

- (void)cmp_setTabBarController:(RDVTabBarController *)tabBarController {
    objc_setAssociatedObject(self, @selector(rdv_tabBarController), tabBarController, OBJC_ASSOCIATION_ASSIGN);
}

- (void)cmp_removeFromParentVc {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end

@implementation UIViewController (RDVTabBarControllerItem)

- (RDVTabBarController *)rdv_tabBarController {
    RDVTabBarController *tabBarController = objc_getAssociatedObject(self, @selector(rdv_tabBarController));
    
    if (!tabBarController && self.parentViewController) {
        tabBarController = [self.parentViewController rdv_tabBarController];
    }
    
    return tabBarController;
}

- (RDVTabBarItem *)rdv_tabBarItem {
    RDVTabBarController *tabBarController = [self rdv_tabBarController];
    NSInteger index = [tabBarController indexForViewController:self];
    return [[[tabBarController tabBar] items] objectAtIndex:index];
}

- (void)rdv_setTabBarItem:(RDVTabBarItem *)tabBarItem {
    RDVTabBarController *tabBarController = [self rdv_tabBarController];
    
    if (!tabBarController) {
        return;
    }
    
    RDVTabBar *tabBar = [tabBarController tabBar];
    NSInteger index = [tabBarController indexForViewController:self];
    
    NSMutableArray *tabBarItems = [[NSMutableArray alloc] initWithArray:[tabBar items]];
    [tabBarItems replaceObjectAtIndex:index withObject:tabBarItem];
    [tabBar setItems:tabBarItems];
}

@end
