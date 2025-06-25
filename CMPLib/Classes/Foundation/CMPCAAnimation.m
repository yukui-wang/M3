//
//  CMPCAAnimation.m
//
//  Created by Harley He on 2018/8/10.
//  Copyright © 2018 Harley He. All rights reserved.
//

#import "CMPCAAnimation.h"
#import <CMPLib/UIView+CMPView.h>

//缩放比例
static CGFloat const CMPCAAnimationScaleRadius = 0.7f;
//默认动画时间
static CGFloat const CMPCAAnimationTimeInterval = 0.75f;

@implementation CMPCAAnimation

+ (void)cmp_animationScaleMagnifyWithLayer:(CALayer *)layer timeInterval:(CGFloat)timeInterval {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(CMPCAAnimationScaleRadius, CMPCAAnimationScaleRadius, 1)];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
        scaleAnimation.duration = timeInterval;
        scaleAnimation.cumulative = NO;
        scaleAnimation.repeatCount = 1;
        [scaleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    //    UIViewAnimationOptionLayoutSubviews
        [layer addAnimation: scaleAnimation forKey:@"myScale"];
}
+ (void)cmp_animationScaleShrinkWithLayer:(CALayer *)layer timeInterval:(CGFloat)timeInterval {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(CMPCAAnimationScaleRadius, CMPCAAnimationScaleRadius, 1)];
    scaleAnimation.duration = timeInterval;
    scaleAnimation.cumulative = NO;
    scaleAnimation.repeatCount = 1;
    [scaleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [layer addAnimation: scaleAnimation forKey:@"myScale"];
}

+ (void)cmp_transitionWithLayer:(CALayer *)layer type:(CMPTransitionType)type timeInterval:(CGFloat)timeInterval transitionType:(CATransitionSubtype)subType {
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
     
     
     kCATransitionFromRight
     kCATransitionFromLeft
     kCATransitionFromTop
     kCATransitionFromBottom
     */
    if (timeInterval == 0) {
        timeInterval = CMPCAAnimationTimeInterval;
    }
    CATransition *transition = [CATransition animation];
    switch (type) {
        case CMPTransitionTypeFade:
            transition.type = @"fade";
            break;
        case CMPTransitionTypePush:
            transition.type = @"push";
            break;
        case CMPTransitionTypeMoveIn:
            transition.type = @"moveIn";
            break;
        case CMPTransitionTypeReveal:
            transition.type = @"reveal";
            break;
        case CMPTransitionTypeCube:
            transition.type = @"cube";
            transition.subtype = kCATransitionFromRight;
            break;
        case CMPTransitionTypeFlip:
            transition.type = @"flip";
            break;
        case CMPTransitionTypeOglFlip:
            transition.type = @"oglFlip";
            break;
        case CMPTransitionTypeSuckEffect:
            transition.type = @"suckEffect";
            break;
        case CMPTransitionTypeRippleEffect:
            transition.type = @"rippleEffect";
            break;
        case CMPTransitionTypePageCurl:
            transition.type = @"pageCurl";
            break;
        case CMPTransitionTypePageUncurl:
            transition.type = @"pageUnCurl";
            break;
        case CMPTransitionTypePageCameraIrisHollowOpen:
            transition.type = @"cameraIrisHollowOpen";
            break;
        case CMPTransitionTypePageCameraIrisHollowClose:
            transition.type = @"cameraIrisHollowClose";
            break;
    }
    /* 过渡方向
    kCATransitionFromRight
    kCATransitionFromLeft
    kCATransitionFromBottom

    kCATransitionFromTop*/
    if (subType) {
        transition.subtype = subType;
    }
    transition.duration = timeInterval;
    [layer addAnimation:transition forKey:nil];
}

#pragma mark - scale
+ (void)cmp_animationScaleMagnifyWithView:(UIView *)view timeInterval:(CGFloat)timeInterval {
    [self cmp_animationScaleMagnifyWithLayer:view.layer timeInterval:timeInterval];
}

+ (void)cmp_animationScaleShrinkWithView:(UIView *)view timeInterval:(CGFloat)timeInterval {
    [self cmp_animationScaleShrinkWithLayer:view.layer timeInterval:timeInterval];
}


+ (void)cmp_transitionWithView:(UIView *)view type:(CMPTransitionType)type timeInterval:(CGFloat)timeInterval transitionType:(CATransitionSubtype)subType {
    [self cmp_transitionWithLayer:view.layer type:type timeInterval:timeInterval transitionType:subType];
}

+ (void)cmp_animShowNextViewWithAnimView:(UIView *)v {
    CGFloat timeInterval = 0.5f;
    
    UIGraphicsBeginImageContextWithOptions(v.cmp_size, YES, 0.0);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *coverImage = UIGraphicsGetImageFromCurrentImageContext();
    //insert snapshot view in front of this one
    __block UIView *coverView = [[UIImageView alloc] initWithImage:coverImage];
    coverView.frame = CMP_SCREEN_BOUNDS;
    [[UIApplication sharedApplication].keyWindow addSubview:coverView];
    UIGraphicsEndImageContext();
    
    [UIView animateKeyframesWithDuration:timeInterval delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        coverView.cmp_y = CMP_SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        coverView.layer.mask = nil;
        [coverView removeFromSuperview];
        coverView = nil;
    }];
    
    
    
}

@end
