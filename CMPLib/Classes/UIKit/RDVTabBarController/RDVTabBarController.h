// RDVTabBarController.h
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

#import <UIKit/UIKit.h>
#import "RDVTabBar.h"
#import "RDVTabBarShortcutItem.h"
#import "RDVTabBarItem.h"

@protocol RDVTabBarControllerDelegate;

@interface RDVTabBarController : UIViewController <RDVTabBarDelegate>

/**
 * The tab bar controller’s delegate object.
 */
@property (nonatomic, weak) id<RDVTabBarControllerDelegate> delegate;

/**
 * An array of the root view controllers displayed by the tab bar interface.
 */
@property (nonatomic, copy) IBOutletCollection(UIViewController) NSArray *viewControllers;

/**
 * The tab bar view associated with this controller. (read-only)
 */
@property (nonatomic, readonly) RDVTabBar *tabBar;

/**
 TabBar 方向，默认 RDVTabBarHorizontal
 */
@property (assign, nonatomic) RDVTabBarOrientation orientation;

/**
 * The view controller associated with the currently selected tab item.
 */
@property (nonatomic, weak) UIViewController *selectedViewController;

/**
 * The index of the view controller associated with the currently selected tab item.
 */
@property (nonatomic) NSUInteger selectedIndex;

/**
 * A Boolean value that determines whether the tab bar is hidden.
 */
@property (nonatomic, getter=isTabBarHidden) BOOL tabBarHidden;

@property (nonatomic, assign) BOOL tabBarAlwaysHidden;

/**
 * Changes the visibility of the tab bar.
 */
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;
/**
 设置头像
 注意：仅 iPad，竖直排版的 TabBar 生效
 
 @param image 头像图片
 */
- (void)setPortait:(UIImage *)image;

/**
 设置快捷操作按钮
 注意：仅 iPad，竖直排版的 TabBar 生效

 @param items 快捷菜单图标数组
 */
- (void)setShortcuts:(NSArray<RDVTabBarShortcutItem*> *)items;

/**
 替换选中页面
 */
- (void)replaceSelectedViewController:(UIViewController *)viewController;

/**
 设置badge显示状态

 @param show 是否展示
 @param index index
 */
- (void)setBadgeShow:(BOOL)show atIndex:(NSInteger)index;

//扩展导航badge显示
- (void)setExpandBadgeShow:(BOOL)show atIndex:(NSInteger)index;
- (void)postNotificationForXZ;

//是否可以pan打开扩展导航
@property (nonatomic, assign) BOOL canPanExpandNavi;
//是否可以编辑扩展导航
@property (nonatomic, assign) BOOL canEditExpandNavi;

@end

@protocol RDVTabBarControllerDelegate <NSObject>
@optional

- (BOOL)tabBarController:(RDVTabBarController *)tabBar shouldSelectItemAtIndex:(NSInteger)index incompleteOperationBlock:(void(^)(void))block;

/**
 * Tells the delegate that the user selected an item in the tab bar.
 */
- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;

/**
 询问 delegate tabBar现在是否可以操作
 */
- (BOOL)tabBarControllerCanUse:(RDVTabBarController *)tabBarController;

/**
 点击头像按钮回调
 */
- (void)tabBarControllerDidTapPortrait:(RDVTabBarController *)tabBarController;

/**
 点击底菜单栏回调
 */
- (BOOL)tabBarController:(RDVTabBarController *)tabBarController didSelectShortcutAtIndex:(NSInteger)index incompleteOperationBlock:(void (^)(void))block;

- (void)expandTabBarItemClick:(id)item;
- (void)expandTabBarEditClick:(id)sender;

@end

@interface UIViewController (RDVTabBarControllerItem)

/**
 * The tab bar item that represents the view controller when added to a tab bar controller.
 */
@property(nonatomic, setter = rdv_setTabBarItem:) RDVTabBarItem *rdv_tabBarItem;

/**
 * The nearest ancestor in the view controller hierarchy that is a tab bar controller. (read-only)
 */
@property(nonatomic, readonly) RDVTabBarController *rdv_tabBarController;

@end

@interface UIViewController (RDVTabBarControllerItemInternal)

- (void)cmp_setTabBarController:(RDVTabBarController *)tabBarController;
- (void)cmp_removeFromParentVc;

@end
