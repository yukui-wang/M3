//
//  CMPCameraShutterButton.m
//  CMPLib
//
//  Created by MacBook on 2019/12/19.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPCameraShutterButton.h"
#import "POP.h"

#import <CMPLib/UIView+CMPView.h>


static CGFloat const kBigCircleW = 6.f;
static CGFloat const kSmallCircleW = 1.f;
static CGFloat const kInnerRectMargin = 21.f;

static CGFloat const kVideoTimeInerval = 16.f;

@interface CMPCameraShutterButton()

/* shapeLayer */
@property (strong, nonatomic) CAShapeLayer *animShapeLayer;
/* innerShapeLayer */
@property (strong, nonatomic) UIView *innerShapeLayer;

@end

@implementation CMPCameraShutterButton
#pragma mark - lazy loading
- (UIView *)innerShapeLayer {
    if (!_innerShapeLayer) {
        UIColor *drawColor = UIColor.whiteColor;
        CGFloat wh = self.width - 2*(kBigCircleW + kSmallCircleW);
        //内圆
        _innerShapeLayer = UIView.alloc.init;
        _innerShapeLayer.frame = CGRectMake(0 ,0 , wh, wh);
        _innerShapeLayer.center = CGPointMake(self.width/2.f, self.height/2.f);
        _innerShapeLayer.backgroundColor = drawColor;
        _innerShapeLayer.userInteractionEnabled = NO;
        [_innerShapeLayer cmp_setRoundView];
        
    }
    return _innerShapeLayer;
}

- (CAShapeLayer *)animShapeLayer {
    if (!_animShapeLayer) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.width/2.f];
        _animShapeLayer = [CAShapeLayer layer];
        _animShapeLayer.frame = self.bounds;
        _animShapeLayer.path = path.CGPath;
        _animShapeLayer.strokeColor = UIColor.redColor.CGColor;
        _animShapeLayer.lineWidth = kBigCircleW;
        _animShapeLayer.lineCap = kCALineCapRound;
        _animShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _animShapeLayer.strokeStart = 0;
        _animShapeLayer.strokeEnd = 0;
    }
    return _animShapeLayer;
}

#pragma mark - initialise views

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.status = CMPCameraShutterButtonStatusPhoto;
        [self configLayers];
    }
    return self;
}

- (void)configLayers {
    UIColor *drawColor = UIColor.whiteColor;
    CGPoint center = CGPointMake(self.width/2.f, self.height/2.f);
    //内圆
    [self addSubview:self.innerShapeLayer];
    
    //外圈
    CAShapeLayer *outerCirleLayer = CAShapeLayer.layer;
    outerCirleLayer.fillColor = UIColor.clearColor.CGColor;
    outerCirleLayer.lineWidth = kBigCircleW;
    outerCirleLayer.lineCap = kCALineCapRound;
    outerCirleLayer.strokeColor = drawColor.CGColor;
    
    UIBezierPath *outerCirclePath = [UIBezierPath bezierPathWithArcCenter:center radius:self.width/2.f startAngle:0 endAngle:2*M_PI clockwise:YES];
    outerCirleLayer.path = outerCirclePath.CGPath;
    [self.layer insertSublayer:outerCirleLayer atIndex:0];
    
    
}


/// 点击拍摄视频后倒计时转圈动画
/// @param layer 执行动画的图层
- (void)drawCircleAnimation:(CAShapeLayer*)layer {
    CGFloat timeInterval = kVideoTimeInerval;
    if (self.videoMaxTime) {
        timeInterval = self.videoMaxTime;
    }
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
    anim.fromValue = [NSNumber numberWithInteger:0];
    anim.toValue = [NSNumber numberWithInteger:1];
    anim.beginTime = CACurrentMediaTime();
    anim.duration = timeInterval;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [anim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            if (self.videoShutCompleted) {
                self.videoShutCompleted();
            }
        }else {
            POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
            anim.toValue = [NSNumber numberWithInteger:0];
            anim.beginTime = CACurrentMediaTime();
            anim.springSpeed = 6.f;
            [anim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
                if (finished) {
                    [self.animShapeLayer pop_removeAllAnimations];
                    [self.animShapeLayer removeFromSuperlayer];
                    self.animShapeLayer = nil;
                }
            }];
            [layer pop_addAnimation:anim forKey:nil];
        }
    }];
    [layer pop_addAnimation:anim forKey:nil];
}

/// 改变当前拍摄按钮中间view为圆圈
/// @param bgColor 改变后的背景颜色
- (void)changeInnerLayerToCycleWithBgColor:(UIColor *)bgColor {
    [UIView animateWithDuration:0.25f animations:^{
        CGFloat wh = self.width - 2*(kBigCircleW + kSmallCircleW);
        //内圆
        self.innerShapeLayer.frame = CGRectMake(0 ,0 , wh, wh);
        self.innerShapeLayer.center = CGPointMake(self.width/2.f, self.height/2.f);
        self.innerShapeLayer.backgroundColor = bgColor;
        [self.innerShapeLayer cmp_setRoundView];
    }];
    
}

/// 改变当前拍摄按钮中间view为矩形
/// @param bgColor 改变后的背景颜色
- (void)changeInnerLayerToRectWithBgColor:(UIColor *)bgColor {
    [UIView animateWithDuration:0.25f animations:^{
        CGFloat wh = self.width - 2*(kInnerRectMargin);
        //内圆
        self.innerShapeLayer.frame = CGRectMake(0 ,0 , wh, wh);
        self.innerShapeLayer.center = CGPointMake(self.width/2.f, self.height/2.f);
        self.innerShapeLayer.backgroundColor = bgColor;
        [self.innerShapeLayer cmp_setCornerRadius:4.f];
    }];
    
}

#pragma mark 倒计时动画开关
- (void)startAnim {
    [self.layer addSublayer:self.animShapeLayer];
    [self drawCircleAnimation:self.animShapeLayer];
}

- (void)stopAnim {
    [self.animShapeLayer pop_removeAllAnimations];
    [self.animShapeLayer removeFromSuperlayer];
}

/// 收缩播放按钮中间view
- (void)shrink {
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.1f animations:^{
        self.innerShapeLayer.cmp_width -= 6.f;
        self.innerShapeLayer.cmp_height -= 6.f;
        self.innerShapeLayer.center = CGPointMake(self.width/2.f, self.height/2.f);
        [self.innerShapeLayer cmp_setRoundView];
    }];
}

/// 扩张播放按钮中间view
- (void)expand {
    self.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.1f animations:^{
        self.innerShapeLayer.cmp_width += 6.f;
        self.innerShapeLayer.cmp_height += 6.f;
        self.innerShapeLayer.center = CGPointMake(self.width/2.f, self.height/2.f);
        [self.innerShapeLayer cmp_setRoundView];
    }];
}
@end
