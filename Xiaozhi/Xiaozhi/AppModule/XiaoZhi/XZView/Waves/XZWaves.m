//
//  XZWaves.m
//  M3
//
//  Created by wujiansheng on 2017/11/17.
//

#import "XZWaves.h"

@interface XZWaves ()
@property (nonatomic,retain)CADisplayLink *wavesDisplayLink;
@property (nonatomic,retain)CAShapeLayer *wavesLayer;
@end

@implementation XZWaves 
/*
 y =Asin（ωx+φ）+C
 A表示振幅，也就是使用这个变量来调整波浪的高度
 ω表示周期，也就是使用这个变量来调整在屏幕内显示的波浪的数量
 φ表示波浪横向的偏移，也就是使用这个变量来调整波浪的流动
 C表示波浪纵向的位置，也就是使用这个变量来调整波浪在屏幕中竖直的位置。
 */

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        [self setUpWaves];
    }
    return self;
}


- (void)setUpWaves{
    //设置波浪的宽度
    _wavesWidth = self.frame.size.width;
    //第一个波浪颜色
    //设置波浪的速度
    _wavesSpeed = 1/M_PI;
    //初始化layer
    if (self.wavesLayer == nil) {
        //初始化
        self.wavesLayer = [CAShapeLayer layer];
        //设置闭环的颜色
        //设置边缘线的宽度
        [self.layer addSublayer:self.wavesLayer];
    }
    //设置波浪流动速度
    _wavesSpeed = 0.04;
    //设置振幅
    _waveA = 6;//12;
    //设置周期
    _waveW = 0.5/30.0;
    //设置波浪纵向位置
    _currentK = self.frame.size.height/2;//屏幕居中
}

-(void)getCurrentWave:(CADisplayLink *)displayLink{
    //实时的位移
    //实时的位移
    _wavesWidth = self.width;
    _offsetX += _wavesSpeed;
    [self setCurrentFirstWaveLayerPath];
}

-(void)setCurrentFirstWaveLayerPath{
    //创建一个路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = _currentK;
    //将点移动到 x=0,y=currentK的位置
    CGPathMoveToPoint(path, nil, 0, y);
    for (NSInteger i =0.0f; i<= _wavesWidth; i++) {
        if (_sin) {
            //正弦函数波浪公式
            y = _waveA * sin(_waveW * i+ _offsetX)+_currentK;
        }
        else {
            //余弦函数波浪公式
            y = _waveA * cos(_waveW*i + _offsetX)+_currentK;
        }
        //将点连成线
        CGPathAddLineToPoint(path, nil, i, y);
    }
    CGPathAddLineToPoint(path, nil, _wavesWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    self.wavesLayer.path = path;
    //使用layer 而没用CurrentContext
    CGPathRelease(path);
}

- (void)show{
    [self.wavesDisplayLink invalidate];
    self.wavesLayer.fillColor = self.wavesColor.CGColor;
    //启动定时器
    self.wavesDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave:)];
    [self.wavesDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)stop {
    [self.wavesDisplayLink invalidate];
    self.wavesDisplayLink = nil;
    self.wavesLayer = nil;
    self.wavesColor = nil;
}


@end
