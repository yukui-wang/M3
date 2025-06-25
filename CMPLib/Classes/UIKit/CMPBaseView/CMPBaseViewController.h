//
//  CMPBaseViewController.h
//  M1Core
//
//  Created by admin on 12-10-26.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CMPViewController.h"
#import "CMPBaseView.h"
#import "CMPScreenshotControlProtocol.h"
#import <CMPLib/UIViewController+KSSafeArea.h>

@interface CMPBaseViewController : UIViewController<CMPScreenshotControlProtocol>
{
    @protected
    @public
    id _param; // 参数对象
    CMPBaseView *_mainView;
    BOOL _shouldHandleFrame; // 是否需要处理frame
    UIViewController            *_modalViewController;// 
    CMPBaseViewController        *_modalParentController;
	UIView *_statusBarView;
}

@property (nonatomic, retain) id param;
@property (nonatomic, retain) CMPBaseView *mainView;
@property (nonatomic, assign) BOOL shouldHandleFrame; // 是否在横竖屏切换的时候修改frame
@property (nonatomic, retain) CMPBaseViewController *modalParentController;
@property (nonatomic, readonly) CGRect mainFrame;
@property (nonatomic, readonly) UIViewController *cModalViewController;
/**
 * 是否允许转向
 */
@property(nonatomic,assign)BOOL allowRotation;
@property (nonatomic, assign) BOOL disableGestureBack; // 禁用手势返回


- (BOOL)navigationBarHidden; // 是否显示navigationController navigationBar

- (void)setup; // 创建subview，以及初始化数据
- (void)layoutSubviewsForPortraitWithFrame:(CGRect)frame;  // 横向布局子views defalut
- (void)layoutSubviewsForLandscapeWithFrame:(CGRect)frame; // 纵向布局子views
- (void)layoutSubviewsWithFrame:(CGRect)frame; // 横纵没有变化调用 
- (void)setupStatusBarViewBackground:(UIColor *)color;
- (void)reLayoutSubViews;

// 模态窗体
- (void)showLoadingViewWithText:(NSString *)aStr;
- (void)showLoadingView;
- (void)hideLoadingView;
// 直接隐藏loadingview
- (void)hideLoadingViewWithoutCount;

/**
 展示纯文字提示框

 @param text 提提示文字内容
 */
- (void)showToastWithText:(NSString *)text;

// add by guoyl for ios 7
- (BOOL)isOptimizationStatusBarForiOS7; // 是否优化状态栏为iOS7,子类可以重新，根据需求
- (UIColor *)statusBarColorForiOS7;

//返回statusBar
- (UIView *)statusBarView;

//用于iPad模式下，右侧界面返回到空界面,
- (void)cmp_didClearDetailViewController;

@end
