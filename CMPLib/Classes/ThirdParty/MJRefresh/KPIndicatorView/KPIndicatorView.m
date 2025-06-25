//
//  KPIndicatorView.m
//  Code4AppDemo
//
//  Created by kunpo on 16/3/18.
//  Copyright © 2016年 Eric Wang. All rights reserved.
//

#import "KPIndicatorView.h"
#import "RoundView.h"

@interface KPIndicatorView ()

{
    float _numOfMoveView;
    NSArray *_arrayOfMoveView;
    UIColor *_colorOfMoveView;
    float _speed;
    float _moveViewSize;
    float _moveSize;
    float _w;
    float _r;
    
    NSTimer *_animateTimer;
    NSInteger lastShowNumber;
}


@end




@implementation KPIndicatorView

- (void)dealloc {
    if (_animateTimer) {
        [_animateTimer invalidate];
        _animateTimer = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
//        [self settingDefault];
    }
    
    return self;
}

- (void)settingDefault
{
    _colorOfMoveView = [UIColor darkTextColor];
    _speed = 1.0;
    _numOfMoveView = 12;
    _moveViewSize = 1;
    _moveSize = 1;
    self.hidden = YES;
    [self initMoviews];
}


- (void)setIndicatorWith:(NSString *)image num:(int)num speed:(float)speed backGroundColor:(UIColor *)backColor color:(UIColor *)color moveViewSize:(float)moveViewSize moveSize:(float)moveSize
{
    if (image)
    {
        self.backImage.image = [UIImage imageNamed:image];
    }
    
    if (backColor) {
        self.backgroundColor = backColor;
    }
    _colorOfMoveView = [UIColor darkTextColor];
    if (color) {
        _colorOfMoveView = color;
    }
    _speed = 1.0;
    if (speed > 0) {
        _speed = speed;
    }
    _numOfMoveView = 8;
    if (num > _numOfMoveView) {
        _numOfMoveView = num;
    }
//    _moveViewSize = 1;
//    if ((moveViewSize > 0) && (moveViewSize <= 1)) {
        _moveViewSize = moveViewSize;
//    }
    _moveSize = 1;
    if ((moveSize > 0) &&(moveSize <= 1))
    {
        _moveSize = moveSize;
    }
    
    self.hidden = YES;
    
    [self initMoviews];
}

- (void)initMoviews
{
    float r = self.frame.size.width;
    if (r > self.frame.size.height) {
        r = self.frame.size.height;
    }
    r = r / 2.0;
    r = r * _moveSize;
    float w = r * sin(2 * M_PI / _numOfMoveView) / 2.0;
    
    
    r -= (w / 2.0);
    w = w * _moveViewSize;
    _r = r;
    _w = w;
    NSMutableArray *arr = [NSMutableArray new];
    
    float alpha = 1.0;
    for (int i = 1; i < _numOfMoveView +1; i ++) {
        w = _w * (_numOfMoveView - i + 1) / _numOfMoveView;
        if (w < 1) {
            w = 1;
        }
        CGRect rect = CGRectMake(0 ,0 , w, w);
        
        RoundView *view = [[RoundView alloc] initWithFrame:rect];
        view.viewColor = _colorOfMoveView;
        view.radian = (M_PI * 2.0 / _numOfMoveView) * i -  M_PI / 2;
        CGPoint center = CGPointMake(self.frame.size.width / 2.0 + _r * cos(view.radian),_r * sin(view.radian) + self.frame.size.height / 2.0);
        view.center = center;
        
        view.backgroundColor = _colorOfMoveView;
        view.backgroundColor = [UIColor clearColor];
        view.alpha = alpha * (_numOfMoveView -1) / _numOfMoveView;
        [self addSubview:view];
        [arr addObject:view];
        view = nil;
    }
    _arrayOfMoveView = nil;
    _arrayOfMoveView = [arr copy];
    [arr removeAllObjects];
    arr = nil;
}


- (void)startAnimating
{
    if (_animateTimer) {
        return;
    }
       _animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 / ( _numOfMoveView * _speed) target:self selector:@selector(next) userInfo:nil repeats:YES];
}

- (void)stopAnimating
{
    if (_animateTimer) {
        [_animateTimer invalidate];
        _animateTimer = nil;
    }
    for (int i = 0; i < _numOfMoveView; i ++) {
        RoundView *view = _arrayOfMoveView[i];
        [view removeFromSuperview];
    }
    [self initMoviews];
}

- (void)next {
    for (int i = 0; i < _numOfMoveView; i ++) {
        [UIView animateWithDuration:0.1/ (_numOfMoveView * _speed) animations:^{
            
            RoundView *view = _arrayOfMoveView[i];
            view.radian +=  M_PI_2 / (2.0 *_numOfMoveView);
            CGPoint center = CGPointMake(self.frame.size.width / 2.0 + _r * cos(view.radian),self.frame.size.height / 2.0 + _r * sin(view.radian));
            view.center = center;
            
        }];
    }
}

- (void)setShowPercent:(CGFloat)percent {
    NSInteger showNumber = floor (percent / (1 / _numOfMoveView));
    if (showNumber == lastShowNumber) {
        return;
    }
    lastShowNumber = showNumber;
    
    for (int i = 0; i < _numOfMoveView; i ++) {
        RoundView *view = _arrayOfMoveView[i];
        if (i < showNumber) {
            view.hidden = NO;
        } else {
            view.hidden = YES;
        }
    }
}

@end
