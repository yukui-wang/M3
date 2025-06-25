//
//  SyBannerNavigationBar.h
//  M1IPhone
//
//  Created by guoyl on 12-12-5.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kPopoverButtonTag 91929999
#define kBackBarButtonItemTag 1000101020

typedef NS_ENUM(NSUInteger, CMPBannerTitleType) {
    CMPBannerTitleTypeCenter = 0, // 标题居中，2.5.0之前版本样式
    CMPBannerTitleTypeLeft,// 标题居左，2.5.0版本，导航栏样式
    CMPBannerTitleTypeNull, // 标题无，2.6.0版本，导航栏样式,按钮有背景色和圆角
    CMPBannerTitleTypeNullWithTextButton // 标题无，V8.0版本，导航栏样式,按钮无背景色和圆角
};

#import "CMPBaseView.h"
#import "CMPBannerViewTitleLabel.h"

@interface CMPBannerNavigationBar : CMPBaseView

@property (nonatomic, readonly) CMPBannerViewTitleLabel *bannerTitleView;
@property (nonatomic, readonly) UIView *bottomLineView;
@property (assign, nonatomic) CMPBannerTitleType titleType;

@property (nonatomic, strong) NSArray *leftBarButtonItems;
@property (nonatomic, strong) NSArray *rightBarButtonItems;
@property (nonatomic, assign) CGFloat leftMargin; // 左边距
@property (nonatomic, assign) CGFloat rightMargin; // 右边距
@property (nonatomic, assign) CGFloat leftViewsMargin; // 左边view的间距
@property (nonatomic, assign) CGFloat rightViewsMargin; // 右边view的间距

@property (assign, nonatomic) BOOL isBannarAddLeftButtonItems; //是否调用了插件给导航栏添加左部按钮,默认No
@property (assign, nonatomic) BOOL isSetNavigationBarGlobalStyle;//是否调用了插件给导航栏设置全局风格,默认No
@property (strong, nonatomic) UIColor *globalBackgroundColor;//导航栏全局背景颜色
@property (strong, nonatomic) UIColor  *globalColor;//导航栏左边原生按钮及标题颜色

@property (nonatomic,strong) CMPBaseView *titleExtContentView;

/* bannerTitleClicked */
@property (copy, nonatomic) void(^bannerTitleClicked)(void);

- (void)insertLeftBarButtonItem:(UIButton *)aButton atIndex:(NSInteger)index;
- (void)insertLeftBarButtonItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeLeftBarButtonItemAtIndex:(NSInteger)index;


- (void)autoLayout;
- (void)coverRightViews:(BOOL)aValue;
- (void)addBottomLine;
- (void)hideBottomLine:(BOOL)isHidden;
- (void)setBannerBackgroundColor:(UIColor *)backgroundColor;

/**
 设置顶部导航文字
 */
- (void)updateBannerTitle:(NSString *)title;
/**
 给子控件添加标志位,表示非原生添加
 */
+ (void)addPlugFlagForView:(UIView *)view;
/**
 返回是否为非原生添加的控件
 */
+ (BOOL)isAddPlugFlagForView:(UIView *)view;
/**
 调用插件在最后插入一个按钮
 */
- (void)insertRightBarButtonItem:(UIButton *)aButton;
/**
 调用插件在最后插入一个按钮组
 */
- (void)insertRightBarButtonItems:(NSArray *)array;

/**
 删除按钮
 */
- (void)removeRightBarButtonItems:(NSArray *)array;

/**
 删除插件添加的按钮
 */
- (void)removeAddPlugRightBarButton;

@end
