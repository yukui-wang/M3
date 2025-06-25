//
//  CMPLoadingView.m
//  CMPLib
//
//  Created by CRMO on 2018/10/29.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "CMPLoadingView.h"
#import "UIColor+Hex.h"
#import "CMPThemeManager.h"

static const CGFloat CMPLoadingAnimationDuration = 1.1;

@implementation CMPLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    CALayer *roatingPart = [[CALayer alloc] init];
    roatingPart.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width);
    roatingPart.contentsGravity = kCAGravityResizeAspectFill;
    roatingPart.masksToBounds = YES;// 裁剪多余
    roatingPart.contents = (__bridge id _Nullable)([UIImage imageNamed:@"loading_animate_icon"].CGImage);
    [self.layer addSublayer:roatingPart];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.toValue = [NSNumber numberWithFloat:2*M_PI];
    anim.duration = CMPLoadingAnimationDuration;
    anim.beginTime = CACurrentMediaTime();
    anim.repeatCount = INFINITY;
    anim.removedOnCompletion = NO;//默认YES，会在退到后台停止动画
    anim.autoreverses = NO;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [roatingPart addAnimation:anim forKey:@"loadingAnimation"];
}

@end
