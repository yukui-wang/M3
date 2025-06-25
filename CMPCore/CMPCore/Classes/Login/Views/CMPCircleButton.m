//
//  CRCircleButton.m
//  CRCircleButton
//
//  Created by CRMO on 2018/3/8.
//  Copyright © 2018年 crmo. All rights reserved.
//

#import "CMPCircleButton.h"
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPThemeManager.h>

const CGFloat CMPCircleButtonMainCircleRadius = 56;
const CGFloat CMPCircleButtonIconWidth = 36;
const CGFloat CMPCircleButtonIconHeight = 36;
const CGFloat CMPCircleButtonAnimationDuration = 2;

@interface CMPCircleButton()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *firstCircle;
@property (strong, nonatomic) UIView *secondCircle;
@property (strong, nonatomic) UIView *thirdCircle;
@property (assign, nonatomic) CGFloat mainCircleRadius;

@end

@implementation CMPCircleButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat circleMarginLeft = CGRectGetWidth(self.frame) / 2 - _mainCircleRadius;
    CGFloat circleMarginTop = circleMarginLeft;
    self.firstCircle.frame = CGRectMake(circleMarginLeft, circleMarginTop, _mainCircleRadius * 2, _mainCircleRadius * 2);
    self.secondCircle.frame = CGRectMake(circleMarginLeft, circleMarginTop, _mainCircleRadius * 2, _mainCircleRadius * 2);
    self.thirdCircle.frame = CGRectMake(circleMarginLeft, circleMarginTop, _mainCircleRadius * 2, _mainCircleRadius * 2);
    
    CGFloat iconMarginLeft = CGRectGetWidth(self.frame) / 2 - CMPCircleButtonIconWidth / 2;
    CGFloat iconMarginTop = 34;
    self.imageView.frame = CGRectMake(iconMarginLeft, iconMarginTop, CMPCircleButtonIconWidth, CMPCircleButtonIconHeight);
    
    CGFloat titleMarginLeft = CGRectGetWidth(self.frame) / 2 - 65 / 2;
    self.titleLabel.frame = CGRectMake(titleMarginLeft, 77, 65, 30);
}

#pragma mark-
#pragma mark Private

- (void)setup {
    _mainCircleRadius = CMPCircleButtonMainCircleRadius;
    [self addSubview:self.firstCircle];
    [self addSubview:self.secondCircle];
    [self addSubview:self.thirdCircle];
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
}

- (UIView *)circleView {
    UIView *circle = [[UIView alloc] init];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 0;
    layer.fillColor = [CMPThemeManager sharedManager].themeColor.CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_mainCircleRadius, _mainCircleRadius)
                                                        radius:_mainCircleRadius
                                                    startAngle:0
                                                      endAngle:2 * M_PI
                                                     clockwise:YES];
    layer.path = [path CGPath];
    [circle.layer addSublayer:layer];
    return circle;
}

- (CABasicAnimation *)scaleAnimationFrom:(CGFloat)from to:(CGFloat)to {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.fromValue = [NSNumber numberWithFloat:from];
    anim.toValue = [NSNumber numberWithFloat:to];
    anim.duration = CMPCircleButtonAnimationDuration;
    anim.beginTime = CACurrentMediaTime();
    anim.repeatCount = INFINITY;
    anim.removedOnCompletion = NO;
    anim.autoreverses = YES;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return anim;
}

- (CAAnimationGroup *)opacityAnimationFrom:(CGFloat)from to:(CGFloat)to {
    CABasicAnimation *animA = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animA.fromValue = [NSNumber numberWithFloat:from];
    animA.toValue = [NSNumber numberWithFloat:to];
    
    CABasicAnimation *animB = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animB.fromValue = [NSNumber numberWithFloat:to];
    animB.toValue = [NSNumber numberWithFloat:0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = CMPCircleButtonAnimationDuration * 2;
    group.removedOnCompletion = NO;
    group.repeatCount = INFINITY;
    group.beginTime = CACurrentMediaTime();
    group.animations = @[animA, animB];
    
    return group;
}

#pragma mark-
#pragma mark Getter && Setter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageWithName:@"login_scan" inBundle:@"CMPLogin"];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = SY_STRING(@"login_scan_button");
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _titleLabel;
}

- (UIView *)firstCircle {
    if (!_firstCircle) {
        _firstCircle = [self circleView];
    }
    return _firstCircle;
}

- (UIView *)secondCircle {
    if (!_secondCircle) {
        _secondCircle = [self circleView];
        CABasicAnimation *scaleAnimation = [self scaleAnimationFrom:1 to:1.125];
        CAAnimationGroup *opacityAnimation = [self opacityAnimationFrom:1 to:0.5];
        [_secondCircle.layer addAnimation:scaleAnimation forKey:@"scaleSecond"];
        [_secondCircle.layer addAnimation:opacityAnimation forKey:@"opacitySecond"];
    }
    return _secondCircle;
}

- (UIView *)thirdCircle {
    if (!_thirdCircle) {
        _thirdCircle = [self circleView];
        CABasicAnimation *scaleAnimation = [self scaleAnimationFrom:1 to:1.258];
        CAAnimationGroup *opacityAnimation = [self opacityAnimationFrom:1 to:0.4];
        [_thirdCircle.layer addAnimation:scaleAnimation forKey:@"scaleThird"];
        [_thirdCircle.layer addAnimation:opacityAnimation forKey:@"opacityThird"];
    }
    return _thirdCircle;
}

@end
