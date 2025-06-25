//
//  XZSpeechWave.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/4.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZSpeechWave.h"

@interface XZSpeechWave () {
    BOOL _isShow;
}
@property(nonatomic,assign) CGFloat volume;
@property (nonatomic,strong) CAGradientLayer *gradientLayer1;
@property (nonatomic,strong) CAGradientLayer *gradientLayer2;
@property (nonatomic,strong) CAGradientLayer *gradientLayer3;
@property (nonatomic,assign) CGFloat waveW ;//水纹周期
@property (nonatomic,assign) CGFloat wavesWidth;
@property (nonatomic,assign) CGFloat currentK; //当前波浪高度Y
@property (nonatomic,assign) CGFloat waveA1;//振幅1
@property (nonatomic,assign) CGFloat waveA2;
@property (nonatomic,assign) CGFloat waveA3;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic,assign) CGFloat offsetX; //位移

@end

@implementation XZSpeechWave

- (CAGradientLayer *)gradientLayerWithColors:(NSArray *)colors {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.bounds;
    layer.colors =  colors;
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(1, 0);
    return layer;
}

- (CAShapeLayer *)shapeLayerWithWidth:(CGFloat)width {
    CAShapeLayer *layer = [CAShapeLayer layer];
    //设置闭环的颜色
    //设置边缘线的宽度
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.lineWidth = width;
    return layer;
}

- (NSArray *)colors1 {
    UIColor *color1 = [UIColor colorWithRed:41/255.0 green:127/255.0 blue:251/255.0 alpha:0];
    UIColor *color2 = [UIColor colorWithRed:38/255.0 green:114/255.0 blue:231/255.0 alpha:1];
    UIColor *color3 = [UIColor colorWithRed:44/255.0 green:239/255.0 blue:225/255.0 alpha:1];
    UIColor *color4 = [UIColor colorWithRed:44/255.0 green:242/255.0 blue:224/255.0 alpha:0];
    NSArray *colors = @[(__bridge id)color1.CGColor,(__bridge id)color2.CGColor,(__bridge id)color3.CGColor,(__bridge id)color4.CGColor];
    return colors;
}

- (NSArray *)colors2 {
    return [self colors1];
}

- (NSArray *)colors3 {
    UIColor *color1 = [UIColor colorWithRed:100/255.0 green:90/255.0 blue:255/255.0 alpha:0];
    UIColor *color2 = [UIColor colorWithRed:102/255.0 green:90/255.0 blue:255/255.0 alpha:1];
    UIColor *color3 = [UIColor colorWithRed:164/255.0 green:114/255.0 blue:255/255.0 alpha:1];
    UIColor *color4 = [UIColor colorWithRed:165/255.0 green:115/255.0 blue:255/255.0 alpha:0];
    NSArray *colors = @[(__bridge id)color1.CGColor,(__bridge id)color2.CGColor,(__bridge id)color3.CGColor,(__bridge id)color4.CGColor];
    return colors;
}

- (void)show {
    _isShow = YES;
    if (!self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeWaveCallback)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    self.wavesWidth = self.frame.size.width;
    //设置波浪纵向位置
    self.currentK = self.frame.size.height/2;//屏幕居中
    //设置周期
    self.waveW = M_PI * 4/self.frame.size.width;
    //设置振幅
    self.waveA1 = 28;//57
    self.waveA2 = 22;//45
    self.waveA3 = 14;//28
}

- (void)showWaveWithVolume:(NSInteger)volume {
    if (volume <10) {
    }
    else if ( volume >70) {
        self.volume = 1.0;
    }
    else {
        self.volume = (volume-10)/60.0f;
    }
}

- (void)showWave {
    
    if (!_gradientLayer1) {
        _gradientLayer1 = [self gradientLayerWithColors:[self colors1]];
        [self.layer addSublayer:self.gradientLayer1];
    }
    if (!_gradientLayer2) {
        _gradientLayer2 = [self gradientLayerWithColors:[self colors2]];
        [self.layer addSublayer:self.gradientLayer2];
    }
    if (!_gradientLayer3) {
        _gradientLayer3 = [self gradientLayerWithColors:[self colors3]];
        [self.layer addSublayer:self.gradientLayer3];
    }
    
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGMutablePathRef path2 = CGPathCreateMutable();
    CGMutablePathRef path3 = CGPathCreateMutable();
    
    CGFloat y1 = _currentK;
    CGFloat y2 = _currentK;
    CGFloat y3 = _currentK;
    
    CGPathMoveToPoint(path1, nil, 0, y1);
    CGPathMoveToPoint(path2, nil, 0, y2);
    CGPathMoveToPoint(path3, nil, 0, y3);
    
    for (NSInteger i = 0.0f; i<= self.wavesWidth; i++) {
        CGFloat t = 1.0;
        if (i < self.wavesWidth/4 ) {
            t = 0.01+0.99 *(i *4/self.wavesWidth);
        }
        else if ( i > self.wavesWidth*3/4) {
            t = 1-0.99 *((i-self.wavesWidth *3/4) *4/self.wavesWidth);
        }
        else {
            t = 1.0;
        }
        y1 =  -self.waveA1 *self.volume*t * sin(_waveW * (self.wavesWidth -i)+_offsetX)+_currentK;
        CGPathAddLineToPoint(path1, nil, i, y1);
        
        y2 = -self.waveA2 *self.volume*t * sin(_waveW * (self.wavesWidth -i)-M_PI_2+_offsetX)+_currentK;
        CGPathAddLineToPoint(path2, nil, i, y2);
        
        y3 = -self.waveA3 *self.volume*t * sin(_waveW * (self.wavesWidth -i)+M_PI_2+_offsetX)+_currentK;
        CGPathAddLineToPoint(path3, nil, i, y3);
    }
    
    CAShapeLayer *shapeLayer1 = [self shapeLayerWithWidth:2];
    CAShapeLayer *shapeLayer2 = [self shapeLayerWithWidth:1];
    CAShapeLayer *shapeLayer3 = [self shapeLayerWithWidth:1];
    
    shapeLayer1.path = path1;
    shapeLayer2.path = path2;
    shapeLayer3.path = path3;
    
    _gradientLayer1.mask = shapeLayer1;
    _gradientLayer2.mask = shapeLayer2;
    _gradientLayer3.mask = shapeLayer3;
    CGPathRelease(path1);
    CGPathRelease(path2);
    CGPathRelease(path3);
}

- (void)invokeWaveCallback{
    _offsetX += 0.3;
    [self showWave];
}

- (void)stop {
    [self.displayLink invalidate];
    self.displayLink = nil;
    _isShow = NO;
}

- (void)customLayoutSubviews {
    
    self.wavesWidth = self.frame.size.width;
    //设置波浪纵向位置
    self.currentK = self.frame.size.height/2;//屏幕居中
    //设置周期
    self.waveW = M_PI * 4/self.frame.size.width;
    _gradientLayer1.frame = self.bounds;
    _gradientLayer2.frame = self.bounds;
    _gradientLayer3.frame = self.bounds;

}

@end

