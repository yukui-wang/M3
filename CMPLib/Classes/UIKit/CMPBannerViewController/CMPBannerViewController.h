//
//  SyBannerViewController.h
//  M1IPhone
//
//  Created by guoyl on 12-12-5.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kBannerButton_Left              1               //
#define kBannerButton_Right             2               //

#import "CMPBaseViewController.h"
#import "CMPBannerNavigationBar.h"

typedef void(^PanGestureBackBlock)(void);

@interface CMPBannerViewController : CMPBaseViewController {
}

@property (nonatomic, readonly) CMPBannerNavigationBar *bannerNavigationBar;
@property (nonatomic, assign) BOOL backBarButtonItemHidden;
@property (nonatomic, readonly) UIImage *bannerBackgroundImage;
@property (nonatomic, assign) BOOL hideBannerNavBar; // 是否隐藏导航条
@property (nonatomic, copy) NSString *bannerViewTitle;
@property (nonatomic, assign) BOOL showBackButton;

//手势密码返回后的事件，用于处理某些界面需要在返回后处理某些数据，例如小致需要清空语音、unit数据
@property (nonatomic, copy) PanGestureBackBlock panGestureBackBlock;

- (CGFloat)bannerBarHeight;

/**
 顶部导航标题样式，默认居中
 需要修改重载该函数
 */
- (CMPBannerTitleType)bannerTitleType;
- (void)showNavBar:(BOOL)isShow animated:(BOOL)animated;
/**
 子类重载该函数自定义顶部导航按钮
 */
- (void)setupBannerButtons;

/**
 设置标题
 */
- (void)setTitle:(NSString *)title;

/**
 自定义返回按钮点击事件
 */
- (void)backBarButtonAction:(id)sender;

- (NSString *)backBarButtonTitle;

// 如果为返回为nil就是图片颜色
- (UIColor *)bannerNavigationBarBackgroundColor;

- (UIButton *)bannerSearchButton;
- (UIButton *)bannerReturnButton;
- (UIButton *)bannerCloseButton;

/**
 设置下拉导航栏显示手势是否可用,默认不可用
 */
- (void)setPanGesturEnabled:(BOOL)enabled;


@end

