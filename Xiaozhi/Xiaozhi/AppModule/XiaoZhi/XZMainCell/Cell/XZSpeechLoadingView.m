//
//  XZSpeechLoadingView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/7/9.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZSpeechLoadingView.h"

@interface XZSpeechLoadingView () {
    NSInteger  _count;
    
}
@property(nonatomic, strong)UIView *point1;
@property(nonatomic, strong)UIView *point2;
@property(nonatomic, strong)UIView *point3;
@property(nonatomic, strong)NSTimer *timer;
@end


@implementation XZSpeechLoadingView

- (UIView *)pointView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    view.layer.cornerRadius = 4;
    [self addSubview:view];
    return view;
}


- (void)setup {
    if (!self.point1) {
        self.point1 = [self pointView];
        self.point1.backgroundColor = RGBACOLOR(41, 127, 251, 0.4);
        [self.point1 setFrame:CGRectMake(20, self.frame.size.height/2-4, 8, 8)];
    }
    if (!self.point2) {
        self.point2 = [self pointView];
        self.point2.backgroundColor = RGBACOLOR(41, 127, 251, 0.7);
        [self.point2 setFrame:CGRectMake(38, self.frame.size.height/2-4, 8, 8)];
    }
    if (!self.point3) {
        self.point3 = [self pointView];
        self.point3.backgroundColor = RGBACOLOR(41, 127, 251, 1);
        [self.point3 setFrame:CGRectMake(56, self.frame.size.height/2-4, 8, 8)];
    }
}

- (void)show {
    self.hidden = NO;
    [self stopTimer];
    [self initTimer];
}

- (void)hide {
    self.hidden = YES;
    [self stopTimer];
}

- (void)initTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = nil;
    _count = 0;
}


+ (CGFloat)defWidth {
    return 84;
}

- (void)timerAction {
    NSArray *colors = @[RGBACOLOR(41, 127, 251, 0.4),RGBACOLOR(41, 127, 251, 0.7),RGBACOLOR(41, 127, 251, 1)];
    self.point1.backgroundColor = colors[_count%3];
    self.point2.backgroundColor = colors[(_count+1)%3];
    self.point3.backgroundColor = colors[(_count+2)%3];
    _count ++;
}

@end
