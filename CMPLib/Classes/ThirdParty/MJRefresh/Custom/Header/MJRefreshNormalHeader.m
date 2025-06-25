//
//  MJRefreshNormalHeader.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "MJRefreshNormalHeader.h"
#import "NSBundle+MJRefresh.h"
#import "KPIndicatorView.h"
#import "UIColor+Hex.h"
#import "CMPListLoadingCircleView.h"
#import "CMPCore.h"

@interface MJRefreshNormalHeader()
{
    __unsafe_unretained UIImageView *_arrowView;
}
@property (weak, nonatomic) KPIndicatorView *loadingView;
@end

@implementation MJRefreshNormalHeader
#pragma mark - 懒加载子控件
- (UIImageView *)arrowView
{
    if (!_arrowView) {
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[NSBundle mj_arrowImage]];
        [self addSubview:_arrowView = arrowView];
    }
    return _arrowView;
}

- (KPIndicatorView *)loadingView
{
    if (!_loadingView) {
        id loadingView;
//        if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
            loadingView = [[CMPListLoadingCircleView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
//        } else {
//            loadingView = [[KPIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
//            [loadingView setIndicatorWith:nil
//                                      num:8 speed:0.5
//                          backGroundColor:nil
//                                    color:[UIColor colorWithHexString:@"#999999"]
//                             moveViewSize:1.2 moveSize:1];
//        }
        
        _loadingView = loadingView;
        self.loadingView.hidden = NO;
        [_loadingView setShowPercent:0];
        [self addSubview:_loadingView];
    }
    return _loadingView;
}

#pragma mark - 公共方法
- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    _activityIndicatorViewStyle = activityIndicatorViewStyle;
    
    self.loadingView = nil;
    [self setNeedsLayout];
}

#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    // 箭头的中心点
//    CGFloat arrowCenterX = self.mj_w * 0.5;
//    if (!self.stateLabel.hidden) {
//        CGFloat stateWidth = self.stateLabel.mj_textWith;
//        CGFloat timeWidth = 0.0;
//        if (!self.lastUpdatedTimeLabel.hidden) {
//            timeWidth = self.lastUpdatedTimeLabel.mj_textWith;
//        }
//        CGFloat textWidth = MAX(stateWidth, timeWidth);
//        arrowCenterX -= textWidth / 2 + self.labelLeftInset;
//    }
//    CGFloat arrowCenterY = self.mj_h * 0.5;
//    CGPoint arrowCenter = CGPointMake(arrowCenterX, arrowCenterY);
    
    
    // 箭头
//    if (self.arrowView.constraints.count == 0) {
//        self.arrowView.mj_size = self.arrowView.image.size;
//        self.arrowView.center = arrowCenter;
//    }
    
    // 圈圈
//    if (self.loadingView.constraints.count == 0) {
//        self.loadingView.center = arrowCenter;
//    }
    
    //有文字的布局
//    CGFloat inset = 8;
//    self.loadingView.mj_x = (self.mj_w - self.stateLabel.mj_textWith - inset - self.loadingView.mj_w) / 2;
//    self.loadingView.mj_y = (self.mj_h - self.loadingView.mj_h) / 2;
//    self.stateLabel.mj_x = self.loadingView.mj_x + self.loadingView.mj_w + inset;
    
    self.loadingView.cmp_centerX = self.cmp_centerX;
    self.loadingView.mj_y = (self.mj_h - self.loadingView.mj_h) / 2;
    self.stateLabel.hidden = YES;
    
//    self.arrowView.tintColor = self.stateLabel.textColor;
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateIdle) {
        if (oldState == MJRefreshStateRefreshing) {
            self.arrowView.transform = CGAffineTransformIdentity;
            
            [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                self.loadingView.alpha = 1.0;
            } completion:^(BOOL finished) {
                // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                if (self.state != MJRefreshStateIdle) return;
                
                self.loadingView.alpha = 1.0;
                [self.loadingView stopAnimating];
                self.arrowView.hidden = YES;
            }];
        } else {
            [self.loadingView stopAnimating];
            self.arrowView.hidden = YES;
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformIdentity;
            }];
        }
    } else if (state == MJRefreshStatePulling) {
        [self.loadingView stopAnimating];
        self.arrowView.hidden = YES;
        [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
            self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
        }];
    } else if (state == MJRefreshStateRefreshing) {
        self.loadingView.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
        [self.loadingView startAnimating];
        self.arrowView.hidden = YES;
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    
    CGFloat offsetY = self.scrollView.mj_offsetY;
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;
    
    if (offsetY > happenOffsetY) {
        return;
    }
    
    // 即将刷新 的临界点
    CGFloat pullingPercent = (happenOffsetY - offsetY) / self.mj_h;
    [_loadingView setShowPercent:pullingPercent];
}

@end
