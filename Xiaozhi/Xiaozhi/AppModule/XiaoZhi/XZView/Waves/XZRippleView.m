//
//  XZRippleView.m
//  M3
//
//  Created by wujiansheng on 2017/11/13.
//

#import "XZRippleView.h"

@interface XZRippleView () {
    UIImageView *_imageView;
    BOOL _clicked;
}

@property (nonatomic, retain) NSTimer *rippleTimer;
@property (nonatomic, assign) NSInteger mode;

@end

@implementation XZRippleView
- (void)dealloc {
    [_imageView stopAnimating];
    SY_RELEASE_SAFELY(_imageView);
    [self removeAllSubLayers];
    [self.layer removeAllAnimations];
    [self closeRippleTimer];
    [super dealloc];
}
- (void)removeFromParentView
{
    if (self.superview) {
        [_imageView stopAnimating];
        [self closeRippleTimer];
        [self removeAllSubLayers];
        [self removeFromSuperview];
        [self.layer removeAllAnimations];
    }
}

- (void)removeAllSubLayers
{
    for (NSInteger i = 0; [self.layer sublayers].count > 0; i++) {
        [[[self.layer sublayers] firstObject] removeFromSuperlayer];
    }
}

- (void)show
{
    _clicked = NO;
    [self setUpRippleImage];
    
    self.rippleTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(addRippleLayer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_rippleTimer forMode:NSRunLoopCommonModes];
    [self.rippleTimer fire];
  
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [self addGestureRecognizer:tap];
    SY_RELEASE_SAFELY(tap);
}

- (void)click {
    if (_clicked) {
        return;
    }
    _clicked = YES;
    [self rippleButtonTouched:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(rippleViewDidClick:)]) {
        [_delegate rippleViewDidClick:self];
    }
}

- (void)setUpRippleImage
{
    if (!_imageView ) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        _imageView.animationImages = @[XZ_IMAGE(@"xz_animation1.png"),
                                       XZ_IMAGE(@"xz_animation2.png"),
                                       XZ_IMAGE(@"xz_animation3.png"),
                                       XZ_IMAGE(@"xz_animation4.png"),
                                       XZ_IMAGE(@"xz_animation5.png"),];
       
        _imageView.animationDuration = 0.5;
    }
    _imageView.frame = CGRectMake(self.width/2-30, self.height/2-30, 60, 60);
    [_imageView startAnimating];
}

- (void)rippleButtonTouched:(id)sender {
    [self closeRippleTimer];
    [self addRippleLayer];
}

- (void)showAnalysisAnimation {
    [_imageView stopAnimating];
    _imageView.animationImages = @[XZ_IMAGE(@"xz_analysis_animation1.png"),
                                   XZ_IMAGE(@"xz_analysis_animation2.png"),
                                   XZ_IMAGE(@"xz_analysis_animation3.png"),
                                   XZ_IMAGE(@"xz_analysis_animation4.png"),
                                   XZ_IMAGE(@"xz_analysis_animation5.png"),];
    _imageView.animationDuration = 0.5;
    [_imageView startAnimating];
}

- (void)addRippleLayer
{
    UIColor *color = UIColorFromRGB(0x3AADFB);
    CAShapeLayer *rippleLayer = [[[CAShapeLayer alloc] init] autorelease];
    rippleLayer.position = CGPointMake(self.width/2, self.height/2);
    rippleLayer.bounds = _imageView.frame;
    rippleLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:_imageView.frame];
    rippleLayer.path = path.CGPath;
    rippleLayer.strokeColor = color.CGColor;
    
    rippleLayer.lineWidth = 1.5;
    rippleLayer.fillColor = color.CGColor;
    
    [self.layer insertSublayer:rippleLayer below:_imageView.layer];
    
    //addRippleAnimation
    UIBezierPath *beginPath = [UIBezierPath bezierPathWithOvalInRect:_imageView.frame];
    CGRect endRect = CGRectInset(_imageView.frame, -30, -30);
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:endRect];
    
    rippleLayer.path = endPath.CGPath;
    rippleLayer.opacity = 0.0;
    
    CGFloat duration = 2.0f;
    
    CABasicAnimation *rippleAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    rippleAnimation.fromValue = (__bridge id _Nullable)(beginPath.CGPath);
    rippleAnimation.toValue = (__bridge id _Nullable)(endPath.CGPath);
    rippleAnimation.duration = duration;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.6];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    opacityAnimation.duration = duration;
    
    [rippleLayer addAnimation:opacityAnimation forKey:@""];
    [rippleLayer addAnimation:rippleAnimation forKey:@""];
    
    [self performSelector:@selector(removeRippleLayer:) withObject:rippleLayer afterDelay:duration];
}

- (void)removeRippleLayer:(CAShapeLayer *)rippleLayer
{
    [rippleLayer removeFromSuperlayer];
    rippleLayer = nil;
}

- (void)closeRippleTimer
{
    if (self.rippleTimer) {
        if ([self.rippleTimer isValid]) {
            [self.rippleTimer invalidate];
        }
        self.rippleTimer = nil;
    }
}



@end
