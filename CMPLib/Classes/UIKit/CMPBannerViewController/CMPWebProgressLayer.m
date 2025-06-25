//
//  CMPWebProgressLayer.m
//  CMPLib
//
//  Created by 曾祥洁 on 2018/9/25.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import "CMPWebProgressLayer.h"
#import "NSTimer+Addition.h"
#import <CMPLib/CMPThemeManager.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define PROGRESS_COLOR [UIColor cmp_colorWithName:@"theme-bgc"]

static CGFloat const kProgressWidth = 3.0f;
static NSTimeInterval const kFastTimeInterval = 0.03;
@implementation CMPWebProgressLayer{
    CAShapeLayer *_layer;
    NSTimer *_timer;
    CGFloat _plusWidth; // < 增加点
}

+ (instancetype)layerWithFrame:(CGRect)frame {
    CMPWebProgressLayer *layer = [self new];
    layer.frame = frame;
    
    return layer;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.anchorPoint = CGPointMake(0, 0.5);
    self.lineWidth = kProgressWidth;
    self.strokeColor = PROGRESS_COLOR.CGColor;
    __weak typeof(self) weakSelf = self;
    _timer = [NSTimer cmp_scheduledTimerWithTimeInterval:kFastTimeInterval repeats:YES block:^(NSTimer *timer) {
        [weakSelf pathChanged:timer];
    }];
    [_timer pause];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, kProgressWidth)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH, kProgressWidth)];
    
    self.path = path.CGPath;
    self.strokeEnd = 0;
    _plusWidth = 0.01;
}


- (void)pathChanged:(NSTimer *)timer {
    if (self.strokeEnd >= 0.97) {
        [timer pause];
        return;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.strokeEnd += _plusWidth;
    
    if (self.strokeEnd > 0.8) {
        _plusWidth = 0.001;
    }
    [CATransaction commit];
}

- (void)startLoad {
    [_timer resumeWithTimeInterval:kFastTimeInterval];
}

- (void)finishedLoad {
    [self closeTimer];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.strokeEnd = 1.0;
    [CATransaction commit];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hidden = YES;
        [self removeFromSuperlayer];
    });
}

- (void)dealloc {
    NSLog(@"progressView dealloc");
    [self closeTimer];
}

#pragma mark - private
- (void)closeTimer {
    [_timer invalidate];
    _timer = nil;
}

@end
