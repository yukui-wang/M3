//
//  CMPWaterMarkUtil.h
//  CMPLib
//
//  Created by CRMO on 2018/7/2.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import "CMPObject.h"

@interface CMPWaterMarkStyle : CMPObject

/** 旋转角度 **/
@property (assign, nonatomic) CGFloat rotationAngle;
/** 字体大小 **/
@property (strong, nonatomic) UIFont *textFont;
/** 字体颜色 **/
@property (strong, nonatomic) UIColor *textColor;
/** 文字透明度 **/
@property (assign, nonatomic) CGFloat textAlpha;
/** x方向的内边距 **/
@property (assign, nonatomic) CGFloat paddingX;
/** y方向的内边距 **/
@property (assign, nonatomic) CGFloat paddingY;

/**
 获取默认样式
 */
+ (instancetype)defaultStyle;

@end

@interface CMPWaterMarkUtil : CMPObject

/**
 初始化CMPWaterMarkUtil

 @param text 初始化文字
 @param style 样式
 @return CMPWaterMarkUtil实例
 */
- (instancetype)initWithText:(NSString *)text Style:(CMPWaterMarkStyle *)style;

/**
 向指定view添加水印

 @param view 需要添加水印的view
 */
- (void)addWaterMarkToView:(UIView *)view;

@end
