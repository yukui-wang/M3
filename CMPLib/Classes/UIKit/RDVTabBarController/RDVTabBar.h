// RDVTabBar.h
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

typedef NS_ENUM(NSUInteger, RDVTabBarOrientation) {
    RDVTabBarHorizontal, // 水平排版
    RDVTabBarVertical, // 竖直排版
};

@class RDVTabBar, RDVTabBarItem ,RDVTabBarShortcutItem; 

@protocol RDVTabBarDelegate <NSObject>

/**
 询问delegate tabBar是否可用
 */
- (BOOL)tabBarCanUse:(RDVTabBar *)tabBar;

/**
 询问delegate tabBar是否可用选中
 */
- (BOOL)tabBar:(RDVTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index incompleteOperationBlock:(void(^)(void))block;

/**
 * Tells the delegate that the specified tab bar item is now selected.
 */
- (void)tabBar:(RDVTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index;

/**
 点击头像
 */
- (void)tabBarDidSelectPortrait:(RDVTabBar *)tabBar;

/**
 点击快捷菜单按钮

 @param tabBar tabBar
 @param index 点击的index
 */
- (BOOL)tabBar:(RDVTabBar *)tabBar didSelectShortcutAtIndex:(NSInteger)index incompleteOperationBlock:(void (^)(void))block;

@end

@interface RDVTabBar : UIView

//扩展导航初始化
- (instancetype)initWithCanExpand:(BOOL)expand canEdit:(BOOL)canEdit;
@property (nonatomic, copy) void(^ExpandNaviEditButtonClick)(id);
@property (nonatomic, copy) void(^ExpandNaviItemClick)(id);
@property (nonatomic, copy) void(^tabbarMoveBlock)(void);
- (void)showMaskView:(BOOL)show;
- (void)setExpandBadgeAt:(NSInteger)index show:(BOOL)show;
/**
 * The tab bar’s delegate object.
 */
@property (nonatomic, weak) id <RDVTabBarDelegate> delegate;

/**
 * The items displayed on the tab bar.
 */
@property (nonatomic, copy) NSArray *items;

@property (nonatomic, copy) NSArray *expandItems;//NSDictionary

/**
 * The currently selected item on the tab bar.
 */
@property (nonatomic, weak) id selectedItem;

/**
 * backgroundView stays behind tabBar's items. If you want to add additional views, 
 * add them as subviews of backgroundView.
 */
@property (nonatomic, readonly) UIView *backgroundView;

/**
 头像
 仅 RDVTabBarVertical 模式展示
 */
@property (nonatomic, readonly) UIButton *portraitView;

/**
 下方快捷功能菜单按钮
 仅 RDVTabBarVertical 模式展示
 */
@property (nonatomic, copy) NSArray *shortcutItems;

/**
 * Sets the height of tab bar.
 */
- (void)setHeight:(CGFloat)height;

/*
 * Enable or disable tabBar translucency. Default is NO.
 */
@property (nonatomic, getter=isTranslucent) BOOL translucent;

/**
 TabBar 方向，默认 RDVTabBarHorizontal
 */
@property (assign, nonatomic) RDVTabBarOrientation orientation;

/**
 点击头像
 */
- (void)portraitDidSelected:(id)sender;

/**
点击快捷菜单
*/
- (void)shortcutDidSelected:(RDVTabBarShortcutItem *)sender;

/**
 首页是应用中心 iPad调用有效
 */
- (void)homePageCommonAppDidSelected;

//隐藏分隔线
- (void)hideSeperateView;

@end
