//
//  CMPListLoadingCircleView.m
//  CMPLib
//
//  Created by CRMO on 2018/10/27.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "CMPListLoadingCircleView.h"
#import "CMPThemeManager.h"

/** 外圈初始大小 **/
static const CGFloat CMPCircleButtonFirstCircleStartRadius = 11;
/** 内圈初始大小 **/
static const CGFloat CMPCircleButtonSecondCircleStartRadius = 8;
/** 外圈缩放比例 **/
static const CGFloat CMPCircleButtonFirstCircleScale = 0.7;
/** 内圈缩放比例 **/
static const CGFloat CMPCircleButtonSecondCircleScale = 0.25;
/** 动画持续时间 **/
static const CGFloat CMPCircleButtonAnimationDuration = 0.4;

@interface CMPListLoadingCircleView()
@property (strong, nonatomic) CALayer *firstCircle;
@property (strong, nonatomic) CALayer *secondCircle;
@end

@implementation CMPListLoadingCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self.layer addSublayer:self.firstCircle];
    [self.layer addSublayer:self.secondCircle];
}

#pragma mark-
#pragma mark 动画

- (void)startAnimating {
    [self annimationWithLayer:self.firstCircle scale:CMPCircleButtonFirstCircleScale];
    [self annimationWithLayer:self.secondCircle scale:CMPCircleButtonSecondCircleScale];
}

- (void)stopAnimating {
    [self.firstCircle removeAllAnimations];
    [self.secondCircle removeAllAnimations];
}

- (void)annimationWithLayer:(CALayer *)layer scale:(CGFloat)scale {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.fromValue = [NSNumber numberWithFloat:1];
    anim.toValue = [NSNumber numberWithFloat:scale];
    anim.duration = CMPCircleButtonAnimationDuration;
    anim.beginTime = CACurrentMediaTime();
    anim.repeatCount = INFINITY;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeBoth;
    anim.autoreverses = YES;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [layer addAnimation:anim forKey:@"circle"];
}

- (void)setShowPercent:(CGFloat)percent {
    return;
}

#pragma mark-
#pragma mark Getter

- (CALayer *)_circleLayerWithRadius:(CGFloat)radius
                              color:(UIColor *)color
                              scale:(CGFloat)scale {
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 0;
    layer.fillColor = color.CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)
                                                        radius:radius
                                                    startAngle:0
                                                      endAngle:2 * M_PI
                                                     clockwise:YES];
    layer.path = [path CGPath];
    layer.frame = self.bounds;
    return layer;
}

- (CALayer *)firstCircle {
    if (!_firstCircle) {
        _firstCircle = [self _circleLayerWithRadius:CMPCircleButtonFirstCircleStartRadius
                                              color:[UIColor cmp_colorWithName:@"gray-bgc1"]
                                              scale:CMPCircleButtonFirstCircleScale];
    }
    return _firstCircle;
}

- (CALayer *)secondCircle {
    if (!_secondCircle) {
        _secondCircle = [self _circleLayerWithRadius:CMPCircleButtonSecondCircleStartRadius
                                               color:[UIColor cmp_colorWithName:@"p-bg"]
                                               scale:CMPCircleButtonSecondCircleScale];
    }
    return _secondCircle;
}

@end
