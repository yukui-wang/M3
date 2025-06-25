//
//  CMPHorizontalMenuView.h
//  YFMHorizontalMenu
//
//  Created by CMP on 2018/11/26.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPlipsePageControl.h"

typedef enum {
    CMPHorizontalMenuViewPageControlAlimentRight,    //右上角靠右
    CMPHorizontalMenuViewPageControlAlimentCenter,   //下面居中
} CMPHorizontalMenuViewPageControlAliment;

typedef enum {
    CMPHorizontalMenuViewPageControlStyleClassic,    //系统自带经典样式
    CMPHorizontalMenuViewPageControlStyleAnimated,   //动画效果
    CMPHorizontalMenuViewPageControlStyleNone,       //不显示pageControl
}CMPHorizontalMenuViewPageControlStyle;


@class CMPHorizontalMenuView;
@class CMPHorizontalMenuItem;

@protocol CMPHorizontalMenuViewDataSource <NSObject>
@optional

/**
 数据的num

 @param horizontalMenuView 控件本身
 @return 返回数量
 */
- (NSInteger)numberOfItemsInHorizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView;
/**
每个菜单的title

 @param horizontalMenuView 控件本身
 @param index 当前下标
 @return 返回标题
 */
- (NSString *)horizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView titleForItemAtIndex:(NSInteger )index;

/**
 每个菜单的图片地址路径

 @param horizontalMenuView 当前控件
 @param index 当前下标
 @return 返回图片的URL路径
 */
- (NSURL *)horizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView iconURLForItemAtIndex:(NSInteger)index;

- (NSString *)horizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView localIconStringForItemAtIndex:(NSInteger)index;

@end


@protocol CMPHorizontalMenuViewDelegate <NSObject>
@optional

/**
 菜单中图片的尺寸

 @param horizontalMenuView 当前控件
 @return 图片的尺寸
 */
- (CGSize)iconSizeForHorizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView;

/**
 返回当前页数的pageControl的颜色

 @param horizontalMenuView 当前控件
 @return 颜色
 */
- (UIColor *)colorForCurrentPageControlInHorizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView;
/**
 当选项被点击回调
 
 @param horizontalMenuView 当前控件
 @param index 点击下标
 */
- (void)horizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView didSelectItemAtIndex:(NSInteger)index;

- (void)horizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView WillEndDraggingWithVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;

// 不需要自定义轮播cell的请忽略以下两个的代理方法

// ========== 轮播自定义cell ==========

/** 如果你需要自定义cell样式，请在实现此代理方法返回你的自定义cell的class。 */
- (Class)customCollectionViewCellClassForHorizontalMenuView:(CMPHorizontalMenuView *)view;
/** 如果你需要自定义cell样式，请在实现此代理方法返回你的自定义cell的Nib。 */
- (UINib *)customCollectionViewCellNibForHorizontalMenuView:(CMPHorizontalMenuView *)view;

/** 如果你自定义了cell样式，请在实现此代理方法为你的cell填充数据以及其它一系列设置 */
- (void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index horizontalMenuView:(CMPHorizontalMenuView *)view;
@end

@interface CMPHorizontalMenuView : UIView

@property (nonatomic,weak) id<CMPHorizontalMenuViewDataSource> dataSource;

@property (nonatomic,weak) id<CMPHorizontalMenuViewDelegate>   delegate;

/** pagecontrol 样式，默认为动画样式 */
@property (nonatomic,assign) CMPHorizontalMenuViewPageControlStyle pageControlStyle;
/** 分页控件位置 */
@property (nonatomic,assign) CMPHorizontalMenuViewPageControlAliment pageControlAliment;

@property (strong, nonatomic)   UIImage                         *defaultImage;

/** 分页控件距离轮播图的底部间距（在默认间距基础上）的偏移量 */
@property (nonatomic,assign) CGFloat pageControlBottomOffset;

/** 分页控件距离轮播图的右边间距（在默认间距基础上）的偏移量 */
@property (nonatomic, assign) CGFloat pageControlRightOffset;

/** 分页控件小圆标大小 */
@property (nonatomic, assign) CGSize pageControlDotSize;

/** 当前分页控件小圆标颜色 */
@property (nonatomic, strong) UIColor *currentPageDotColor;

/** 其他分页控件小圆标颜色 */
@property (nonatomic, strong) UIColor *pageDotColor;

/** 当前分页控件小圆标图片 */
@property (nonatomic, strong) UIImage *currentPageDotImage;

/** 其他分页控件小圆标图片 */
@property (nonatomic, strong) UIImage *pageDotImage;

/** 圆点之间的距离 默认 10*/
@property (nonatomic, assign) CGFloat controlSpacing;
/** 是否在只有一张图时隐藏pagecontrol，默认为YES */
@property (nonatomic, assign) BOOL hidesForSinglePage;

@property (nonatomic, strong) NSArray <CMPHorizontalMenuItem *>*menuItems;
/**
 刷新
 */
- (void)reloadData;
/**
 几页
 */
-(NSInteger)numOfPage;

/**
在targetView上显示
*/
- (void)showMenuFromView:(UIView *)targetView;
/**
隐藏菜单
*/
- (void)hideMenu;

@end

@interface CMPHorizontalMenuItem:NSObject

@property (nonatomic,copy) NSString *itemTile;
@property (nonatomic,copy) NSString *itemIconTitle;
@property (nonatomic,strong) id target;
@property (nonatomic,assign) SEL action;

- (instancetype)initWithItemTile:(NSString *)itemTile itemIconTitle:(NSString *)itemIconTitle target:(id)target action:(SEL)action;

@end
