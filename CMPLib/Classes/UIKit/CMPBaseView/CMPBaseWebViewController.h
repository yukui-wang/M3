//
//  SyBaseViewController.h
//  M1Core
//
//  Created by admin on 12-10-26.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CMPViewController.h"
#import "CMPBaseView.h"
#import <CordovaLib/CDVViewController.h>
#import <WebKit/WebKit.h>
#import "CMPScreenshotControlProtocol.h"
#import <CMPLib/UIDevice+TFDevice.h>

@interface CMPBaseWebViewController : CDVViewController<CMPScreenshotControlProtocol>
{
    @protected
    @public
    id _param; // 参数对象
    CMPBaseView *_mainView;
    BOOL _shouldHandleFrame; // 是否需要处理frame
    UIViewController            *_modalViewController;// 
    CMPBaseWebViewController        *_modalParentController;
	UIView *_statusBarView;
}

@property (nonatomic, retain) id param;
@property (nonatomic, retain) CMPBaseView *mainView;
@property (nonatomic, assign) BOOL shouldHandleFrame; // 是否在横竖屏切换的时候修改frame
@property (nonatomic, retain) CMPBaseWebViewController *modalParentController;
@property (nonatomic, readonly) CGRect mainFrame;
@property (nonatomic, readonly) UIViewController *cModalViewController;
@property (nonatomic, assign) BOOL disableAnimated; // 禁用动画包括进入、退出动画
@property (nonatomic, assign) BOOL disableGestureBack; // 禁用手势返回
@property (nonatomic, assign) BOOL isLockPageOnPad; //页面是否加锁,默认No
@property (nonatomic, strong) NSMutableDictionary *extParamDic;//ks add用于存储额外参数等
@property (nonatomic, assign) BOOL isLandscapeWhenPushChildController;

/** 是否第一次进入控制器页面 **/
@property (assign, nonatomic) BOOL isPushedController;

/**
 * 是否允许转向
 */
@property(nonatomic,assign)BOOL allowRotation;
/**
 * 记录变化前的view size
 */
@property(nonatomic,assign)CGSize preViewSize;
@property(nonatomic,copy)NSURL *currentURL;


- (BOOL)navigationBarHidden; // 是否显示navigationController navigationBar
- (void)updateLoadingViewFrame;

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
- (void)showToastWithText:(NSString *)text;

// add by guoyl for ios 7
- (BOOL)isOptimizationStatusBarForiOS7; // 是否优化状态栏为iOS7,子类可以重新，根据需求
- (UIColor *)statusBarColorForiOS7;
- (void)backBarButtonAction:(id)sender;

/**
 根据参数判断在操作区还是内容区跳转页面
 
 @param vc 需要展示的ViewController
 @param parentVc 当前ViewController
 @param inDetail 在内容区展示新页面，仅在 iPad 且 openWebview为YES时生效
 @param clearDetail 清空内容区域，仅在iPad 且 openWebview为YES 且 pushInDetailPad为NO时生效
 @param animate 播放动画
 */
- (void)pushVc:(UIViewController *)vc
          inVc:(UIViewController *)parentVc
      inDetail:(BOOL)inDetail
   clearDetail:(BOOL)clearDetail
       animate:(BOOL)animate;

- (void)cmp_didClearDetailViewController;

- (BOOL)shouldOverrideLoadWithRequest:(NSURLRequest*)request navigationType:(WKNavigationType)navigationType;

-(void)refresh;
@end
