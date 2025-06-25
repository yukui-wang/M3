//
//  UIView+SyView.h
//  M1Core
//
//  Created by admin on 12-10-30.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "CMPConstant.h"

#define IS_VAILABLE_IOS8  ([[[UIDevice currentDevice] systemVersion] intValue] >= 8)

@interface UIView (CMPView)

// 方便直接实用view大小的宽、高
@property (nonatomic, readonly) CGFloat originX;
@property (nonatomic, readonly) CGFloat originY;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, readonly) UIUserInterfaceIdiom userInterfaceIdiom;

#pragma mark-
#pragma mark 快捷获取、设置Frame

@property (assign, nonatomic, readonly) CGFloat cmp_right;
@property (assign, nonatomic, readonly) CGFloat cmp_left;
@property (assign, nonatomic, readonly) CGFloat cmp_top;
@property (assign, nonatomic) CGFloat cmp_bottom;
@property (assign, nonatomic) CGFloat cmp_x;
@property (assign, nonatomic) CGFloat cmp_y;
@property (assign, nonatomic) CGFloat cmp_width;
@property (assign, nonatomic) CGFloat cmp_height;
@property (assign, nonatomic) CGPoint cmp_origin;
@property (assign, nonatomic) CGSize cmp_size;
@property (assign, nonatomic) CGFloat cmp_centerX;
@property (assign, nonatomic) CGFloat cmp_centerY;

@property (nonatomic, copy) void (^layoutSubviewsCallback)(UIView *superview);

+ (CGSize)mainScreenSize;
+ (CGFloat)staticStatusBarHeight;
- (UIImage*) imageWithUIView:(UIView*) view;
-(void)removeAllSubviews;


/**
 扩展可点击区域
 
 @param offset 点击区域增加的offset
 */
- (void)cmp_expandClickArea:(UIOffset)offset;

/**
 截取当前View的截图
 */
- (UIImage *)grabScreenshot;

/**
 截取当前View的截图，指定size大小

 @param size 截图Size
 */
- (UIImage *)grabScreenshotWithSize:(CGSize)size;

/**
 *  @判断view是否显示
 */
- (BOOL)isShowingOnKeyWindow;


/// 设置圆角
- (void)cmp_setRoundView;
- (void)cmp_setCornerRadius:(CGFloat)radius;


/// 设置顶部两角为圆角的view
/// @param cornerRadius radius
/// @param bgColor 背景颜色
- (CAShapeLayer *)cmp_setTopCornerWithRadius:(CGFloat)cornerRadius bgColor:(UIColor *)bgColor;

/// 设置底部两角为圆角的view
/// @param cornerRadius radius
/// @param bgColor 背景颜色
- (CAShapeLayer *)cmp_setBottomCornerWithRadius:(CGFloat)cornerRadius bgColor:(UIColor *)bgColor;

/// 设置底部四角为圆角的view
/// @param cornerRadius radius
/// @param bgColor 背景颜色
- (CAShapeLayer *)cmp_setRoundCornerWithRadius:(CGFloat)cornerRadius bgColor:(UIColor *)bgColor;

/// 设置边框颜色，一旦调用这个方法就会把边框显示出来
/// @param color 设置边框的颜色
- (void)cmp_setBorderWithColor:(UIColor *)color;

@end
