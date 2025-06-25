//
//  CMPOcrGradientProgressView.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/26.
//

#import "CMPOcrGradientProgressView.h"
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/Masonry.h>

@interface CMPOcrGradientProgressView ()

@property (nonatomic, strong) CALayer *bgLayer;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation CMPOcrGradientProgressView

- (CALayer *)bgLayer {
    if (!_bgLayer) {
        _bgLayer = [CALayer layer];
        _bgLayer.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _bgLayer.anchorPoint = CGPointMake(0, 0);
        _bgLayer.backgroundColor = self.bgProgressColor.CGColor;
        _bgLayer.cornerRadius = self.frame.size.height / 2.;
        [self.layer addSublayer:_bgLayer];
    }
    return _bgLayer;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.bounds = CGRectMake(0, 0, self.frame.size.width * self.progress, self.frame.size.height);
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(1, 0);
        _gradientLayer.anchorPoint = CGPointMake(0, 0);
        NSArray *colorArr = self.colorArr;
        _gradientLayer.colors = colorArr;
        _gradientLayer.cornerRadius = self.frame.size.height / 2.;
        [self.layer addSublayer:_gradientLayer];
    }
    return _gradientLayer;
}

#pragma mark - SET ---> data

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self updateView];
}

- (void)setColorArr:(NSArray *)colorArr {
    if (colorArr.count >= 2) {
        _colorArr = colorArr;
        [self updateView];
    }
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
        [self simulateViewDidLoad];
        self.colorArr = @[(id)k16RGBColor(0x88e0fb).CGColor,(id)k16RGBColor(0x4585f4).CGColor];
        self.progress = 0.65;
    }
    return self;
}

- (void)simulateViewDidLoad {
    [self addSubViewTree];
}

- (void)config {
    self.bgProgressColor = k16RGBColor(0xf6f6f6);
}

- (void)addSubViewTree {
    [self bgLayer];
    [self gradientLayer];
}

- (void)updateView {
    self.gradientLayer.bounds = CGRectMake(0, 0, self.frame.size.width * self.progress, self.frame.size.height);
    self.gradientLayer.colors = self.colorArr;
}

@end
