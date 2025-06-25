//
//  BFWaterView.m
//  M3
//
//  Created by wujiansheng on 2018/12/12.
//  


#import "BFAIPWaterView.h"

@interface BFAIPWaterView ()
@property (nonatomic, readwrite, retain) CADisplayLink *displayLink;
@property (nonatomic, readwrite, retain) CAShapeLayer *shapeLayer;
@property (nonatomic, readwrite, retain) CAShapeLayer *shapeLayer2;
@property (nonatomic, readwrite, assign) CGFloat offset;
@property (nonatomic, readwrite, assign) CGFloat speed;
@property (nonatomic, readwrite, assign) CGFloat waveHeight;
@property (nonatomic, readwrite, assign) CGFloat waveWidth;
@property (nonatomic, readwrite, assign) CGFloat h;
@property (nonatomic, readwrite, assign) NSInteger increase;
@end

@implementation BFAIPWaterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _offset = 0;
        _speed = 3;
        _waveWidth = frame.size.width;
        _waveHeight = 10;
        _h = 20;
        _increase = -1;
        
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.bounds;
        [self.layer addSublayer:_shapeLayer];
        
        _shapeLayer2 = [CAShapeLayer layer];
        _shapeLayer2.frame = self.bounds;
        [self.layer addSublayer:_shapeLayer2];
    }
    return self;
}

- (void)startAnimation {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(doAnimation)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)stopAnimation {
    self.displayLink.paused = YES;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)doAnimation
{
    _offset += _speed;
//    if (_h == 0 && _increase == -1) {
//        _increase = 1;
//    } else if (_h == 40 && _increase == 1) {
//        _increase = -1;
//    }
//    _h += _increase;
    //设置第一条波曲线的路径
    CGMutablePathRef pathRef = CGPathCreateMutable();
    //起始点
    CGFloat startY = _waveHeight*sinf(_offset*M_PI/_waveWidth);
    CGPathMoveToPoint(pathRef, NULL, 0, startY);
    //第一个波的公式
    for (CGFloat i = 0.0; i < _waveWidth; i ++) {
        CGFloat y = _waveHeight*sinf(2.5*M_PI*i/_waveWidth + _offset*M_PI/_waveWidth) + _h;
        CGPathAddLineToPoint(pathRef, NULL, i, y);
    }
    CGPathAddLineToPoint(pathRef, NULL, self.bounds.size.width, self.bounds.size.height);
    CGPathAddLineToPoint(pathRef, NULL, 0, self.bounds.size.height);
    CGPathCloseSubpath(pathRef);
    //设置第一个波layer的path
    _shapeLayer.path = pathRef;
    _shapeLayer.fillColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    CGPathRelease(pathRef);
    
    //设置第二条波曲线的路径
    CGMutablePathRef pathRef2 = CGPathCreateMutable();
    CGFloat startY2 = _waveHeight*sinf(_offset*M_PI/_waveWidth + M_PI/4);
    CGPathMoveToPoint(pathRef2, NULL, 0, startY2);
    //第二个波曲线的公式
    for (CGFloat i = 0.0; i < _waveWidth; i ++) {
        CGFloat y = _waveHeight*sinf(2.5*M_PI*i/_waveWidth + 3*_offset*M_PI/_waveWidth + M_PI/4) + _h;
        CGPathAddLineToPoint(pathRef2, NULL, i, y);
    }
    CGPathAddLineToPoint(pathRef2, NULL, self.bounds.size.width, self.bounds.size.height);
    CGPathAddLineToPoint(pathRef2, NULL, 0, self.bounds.size.height);
    CGPathCloseSubpath(pathRef2);
    
    _shapeLayer2.path = pathRef2;
    _shapeLayer2.fillColor = [UIColor colorWithWhite:1 alpha:0.6].CGColor;
    CGPathRelease(pathRef2);
}
@end
