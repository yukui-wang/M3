//
//  CMPCAAnimation.h
//
//  Created by Harley He on 2018/8/10.
//  Copyright © 2018 Harley He. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 fade                   //交叉淡化过渡(不支持过渡方向)
 push                   //新视图把旧视图推出去
 moveIn                 //新视图移到旧视图上面
 reveal                 //将旧视图移开,显示下面的新视图
 cube                   //立方体翻滚效果
 oglFlip                //上下左右翻转效果
 suckEffect             //收缩效果，向布被抽走(不支持过渡方向)
 rippleEffect           //水波效果(不支持过渡方向)
 pageCurl               //向上翻页效果
 pageUnCurl             //向下翻页效果
 cameraIrisHollowOpen   //相机镜头打开效果(不支持过渡方向)
 cameraIrisHollowClose  //相机镜头关上效果(不支持过渡方向)
 */
typedef enum : NSUInteger {
    CMPTransitionTypeFade = 100110, //交叉淡化过渡(不支持过渡方向)
    CMPTransitionTypePush, //新视图把旧视图推出去
    CMPTransitionTypeMoveIn, //新视图移到旧视图上面
    CMPTransitionTypeReveal, //将旧视图移开,显示下面的新视图
    CMPTransitionTypeCube, //立方体翻滚效果
    CMPTransitionTypeFlip, //左右翻转效果
    CMPTransitionTypeOglFlip, //上下左右翻转效果
    CMPTransitionTypeSuckEffect, //收缩效果，向布被抽走(不支持过渡方向)
    CMPTransitionTypeRippleEffect, //水波效果(不支持过渡方向)
    CMPTransitionTypePageCurl, //向上翻页效果
    CMPTransitionTypePageUncurl, //向下翻页效果
    CMPTransitionTypePageCameraIrisHollowOpen, //相机打开效果
    CMPTransitionTypePageCameraIrisHollowClose //相机关闭效果
} CMPTransitionType;

@interface CMPCAAnimation : NSObject

#pragma mark - scale

/// 放大view动画
/// @param view 执行动画的view
/// @param timeInterval 动画时长
+ (void)cmp_animationScaleMagnifyWithView:(UIView *)view timeInterval:(CGFloat)timeInterval;

/// 缩小view动画
/// @param view 执行动画的view
/// @param timeInterval 动画时长
+ (void)cmp_animationScaleShrinkWithView:(UIView *)view timeInterval:(CGFloat)timeInterval;

+ (void)cmp_animationScaleMagnifyWithLayer:(CALayer *)layer timeInterval:(CGFloat)timeInterval;
+ (void)cmp_animationScaleShrinkWithLayer:(CALayer *)layer timeInterval:(CGFloat)timeInterval;


/// 转场动画
/// @param view 转场动画执行的view
/// @param type 转场动画样式
/// @param timeInterval 动画时间长
/// @param subType 动画子样式
+ (void)cmp_transitionWithView:(UIView *)view type:(CMPTransitionType)type timeInterval:(CGFloat)timeInterval transitionType:(CATransitionSubtype)subType;


/// 转场动画 支持动画类型详细看 CMPTransitionType
/// @param layer 要执行动画的layer
/// @param type 执行动画的类型 详细看CMPTransitionType
/// @param timeInterval 执行动画的时间
/// @param subType 执行动画的方向 支持 CMPCAAnimationTransitionTypeFromRigh CMPCAAnimationTransitionTypeFromLeft CMPCAAnimationTransitionTypeFromTop
/// CMPCAAnimationTransitionTypeFromBottom  传空的话，就采用默认不设置方向时的系统默认方向
+ (void)cmp_transitionWithLayer:(CALayer *)layer type:(CMPTransitionType)type timeInterval:(CGFloat)timeInterval transitionType:(CATransitionSubtype)subType;

+ (void)cmp_animShowNextViewWithAnimView:(UIView *)v;

@end
