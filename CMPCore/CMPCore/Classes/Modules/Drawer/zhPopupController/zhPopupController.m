//
//  zhPopupController.m
//  <https://github.com/snail-z/zhPopupController.git>
//
//  Created by zhanghao on 2016/11/15.
//  Copyright © 2017年 snail-z. All rights reserved.
//

#import "zhPopupController.h"
#import <objc/runtime.h>
#import "CMPStringConst.h"
#import "CMPConstant.h"
#import "CMPSplitViewController.h"
@interface zhPopupController () <UIGestureRecognizerDelegate> {
    NSTimer *_timer;
    BOOL _isKeyboardVisible;
    BOOL _directionalVertical;
    BOOL _isDirectionLocked;
}
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, weak) UIView *proxyView;
@property (nonatomic, assign) CGFloat panoOriginY;//触摸时view的Y

@end

@implementation zhPopupController

- (void)defaultValueInitialization {
    _isPresenting = NO;
    _maskType = zhPopupMaskTypeBlackOpacity;
    _maskAlpha = 0.5;
    _layoutType = zhPopupLayoutTypeCenter;
    _presentationStyle = zhPopupSlideStyleFade;
    _dismissonStyle = -1;
    _windowLevel = zhPopupWindowLevelNormal;
    _presentationTransformScale = 0.5;
    _dismissonTransformScale = 0.5;
    _dismissOnMaskTouched = YES;
    _dismissAfterDelay = 0;
    _panGestureEnabled = NO;
    _panDismissRatio = 0.5;
    _offsetSpacing = 0;
    _keyboardOffsetSpacing = 0;
    _keyboardChangeFollowed = NO;
    _becomeFirstResponded = NO;
    _directionalVertical = NO;
    _isDirectionLocked = NO;
    _isKeyboardVisible = NO;
}

- (instancetype)initWithView:(UIView *)aView size:(CGSize)size {
    if (self = [super init]) {
        [self defaultValueInitialization];
        CGSize _size = CGSizeEqualToSize(CGSizeZero, size) ? aView.bounds.size : size;
        aView.frame = CGRectMake(0, 0, _size.width, _size.height);
        _popupView = aView;
        __weak typeof(self) _self = self;
        self.defaultDismissBlock = ^(zhPopupController * _Nonnull popupController) {
            [_self dismiss];
        };
    }
    return self;
}

//处理旋转
- (void)handRotation:(NSNotification *)notifi{
    if ([notifi.name isEqualToString:kNotificationName_CMPSplitViewControllerDidUpdateStack]) {
        if ([notifi.object isKindOfClass:NSClassFromString(@"CMPSplitViewController")]) {
//            CMPSplitViewController *splitVC = (CMPSplitViewController *)notifi.object;
//            CGRect rect = splitVC.view.bounds;
            CGFloat w = UIScreen.mainScreen.bounds.size.width;
            CGFloat h = UIScreen.mainScreen.bounds.size.height;
            
            self.maskView.frame = CGRectMake(0, 0, w, h);
            
            CGRect frame = self.popupView.frame;
            frame.size.width = w;
            
            
            
            CGFloat smallH = self.smallHeight;//159+20;
            if (frame.size.height > smallH) {//高抽屉，需要更新height
                CGFloat midY = ((812.0-492.0)/812.0) * h;
                self.midPositionY = midY;//更新旋转后的midPositionY
                self.initTopY = midY;
                
                if (self.popupPosition == zhPopupPositionMiddle) {//中间
                    frame.size.height = h - self.midPositionY;
                    frame.origin.y = self.midPositionY;
                }else if(self.popupPosition == zhPopupPositionTop){//顶部
                    frame.size.height = h - self.topPositionY;
                    frame.origin.y = self.topPositionY;
                }
            }else{//矮抽屉
                frame.origin.y = h - smallH;
                frame.size.height = smallH;
            }
            
            self.popupView.frame = frame;
        }
    }
}

- (void)presentDuration:(NSTimeInterval)duration
                  delay:(NSTimeInterval)delay
                options:(UIViewAnimationOptions)options
                bounced:(BOOL)isBounced
             completion:(void (^)(void))completion {
    if (self.isPresenting) return;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handRotation:) name:kNotificationName_CMPSplitViewControllerDidUpdateStack object:nil];
    
    self.maskView.alpha = 0;
    [self prepareSlideStyle];
    self.popupView.center = [self prepareCenter];
    
    __block void (^finishedCallback)(void) = ^() {
        self->_isPresenting = YES;
        if (self.didPresentBlock) {
            self.didPresentBlock(self);
        } else {
            if ([self.delegate respondsToSelector:@selector(popupControllerDidPresent:)]) {
                [self.delegate popupControllerDidPresent:self];
            }
        }
        
        if (self.dismissAfterDelay > 0) {
            self->_timer = [NSTimer timerWithTimeInterval:self.dismissAfterDelay target:self selector:@selector(timerPerform) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:self->_timer forMode:NSRunLoopCommonModes];
        }
        
        if (completion) completion();
    };
    
    if (self.keyboardChangeFollowed && self.becomeFirstResponded) {
        self.popupView.center = [self finalCenter];
        if (self.willPresentBlock) {
            self.willPresentBlock(self);
        } else {
            if ([self.delegate respondsToSelector:@selector(popupControllerWillPresent:)]) {
                [self.delegate popupControllerWillPresent:self];
            }
        }
        
        [UIView animateWithDuration:duration delay:delay options:options animations:^{
            self.maskView.alpha = 1;
            [self finalSlideStyle];
        } completion:^(BOOL finished) {
            finishedCallback();
        }];
    } else {
     
        if (self.willPresentBlock) {
            self.willPresentBlock(self);
        } else {
            if ([self.delegate respondsToSelector:@selector(popupControllerWillPresent:)]) {
                [self.delegate popupControllerWillPresent:self];
            }
        }
        
        if (isBounced) {
            [UIView animateWithDuration:duration * 0.25 delay:delay options:options animations:^{
                self.maskView.alpha = 1;
            } completion:NULL];
            
            [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:0.6 initialSpringVelocity:0.25 options:options animations:^{
                [self finalSlideStyle];
                self.popupView.center = [self finalCenter];
            } completion:^(BOOL finished) {
                finishedCallback();
            }];
        } else {
            [UIView animateWithDuration:duration delay:delay options:options animations:^{
                self.maskView.alpha = 1;
                [self finalSlideStyle];
                self.popupView.center =  [self finalCenter];
            } completion:^(BOOL finished) {
                finishedCallback();
            }];
        }
        
    }
}
- (void)dismissDuration:(NSTimeInterval)duration
                  delay:(NSTimeInterval)delay
                options:(UIViewAnimationOptions)options
             completion:(void (^)(void))completion {
    if (!self.isPresenting) return;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_CMPSplitViewControllerDidUpdateStack object:nil];
    
    _isPresenting = NO;
    if (self.willDismissBlock) {
        self.willDismissBlock(self);
    } else {
        if ([self.delegate respondsToSelector:@selector(popupControllerWillDismiss:)]) {
            [self.delegate popupControllerWillDismiss:self];
        }
    }
    
    [UIView animateWithDuration:duration delay:delay options:options animations:^{
        [self dismissSlideStyle];
        self.popupView.center = [self dismissedCenter];
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self finalSlideStyle];
        [self removeSubviews];
        if (self.didDismissBlock) {
            self.didDismissBlock(self);
        } else {
            if ([self.delegate respondsToSelector:@selector(popupControllerDidDismiss:)]) {
                [self.delegate popupControllerDidDismiss:self];
            }
        }
        
        if (self.dismissAfterDelay > 0) {
            [self->_timer invalidate];
            self->_timer = nil;
        }
        
        if (completion) completion();
    }];
}

- (void)timerPerform {
    if (self.defaultDismissBlock) {
        self.defaultDismissBlock(self);
    }
}

- (void)addSubviewBelow:(UIView *)subview {
    [self.proxyView insertSubview:self.maskView belowSubview:subview];
    [self.proxyView insertSubview:self.popupView aboveSubview:self.maskView];
}

- (void)addSubview {
    [self.proxyView addSubview:self.maskView];
    [self.proxyView addSubview:self.popupView];
}

- (void)removeSubviews {
    [_popupView removeFromSuperview];
    [_maskView removeFromSuperview];
}

- (void)prepareSlideStyle {
    [self takeSlideStyle:self.presentationStyle scale:self.presentationTransformScale];
}

- (void)dismissSlideStyle {
    [self takeSlideStyle:self.dismissonStyle < 0 ? self.presentationStyle : self.dismissonStyle scale:self.dismissonTransformScale];
}

- (void)takeSlideStyle:(zhPopupSlideStyle)slideStyle scale:(CGFloat)scale {
    switch (slideStyle) {
        case zhPopupSlideStyleFade: {
            self.popupView.alpha = 0;
        } break;
        case zhPopupSlideStyleTransform: {
            self.popupView.alpha = 0;
            self.popupView.transform = CGAffineTransformMakeScale(scale, scale);
        } break;
        default: break;
    }
}

- (void)finalSlideStyle {
    switch (self.presentationStyle) {
        case zhPopupSlideStyleFade: {
            self.popupView.alpha = 1;
        } break;
        case zhPopupSlideStyleTransform: {
            self.popupView.alpha = 1;
            self.popupView.transform = CGAffineTransformIdentity;
        } break;
        default: break;
    }
}

- (CGPoint)prepareCenter {
    return [self takeCenter:self.presentationStyle];
}

- (CGPoint)dismissedCenter {
    return [self takeCenter:self.dismissonStyle < 0 ? self.presentationStyle : self.dismissonStyle];
}

- (CGPoint)takeCenter:(zhPopupSlideStyle)slideStyle {
    switch (slideStyle) {
        case zhPopupSlideStyleFromTop:
            return CGPointMake([self finalCenter].x,
                               -self.popupView.bounds.size.height / 2);
        case zhPopupSlideStyleFromLeft:
            return CGPointMake(-self.popupView.bounds.size.width / 2,
                               [self finalCenter].y);
        case zhPopupSlideStyleFromBottom:
            return CGPointMake([self finalCenter].x,
                               self.maskView.bounds.size.height + self.popupView.bounds.size.height / 2);
        case zhPopupSlideStyleFromRight:
            return CGPointMake(self.maskView.bounds.size.width + self.popupView.bounds.size.width / 2,
                               [self finalCenter].y);
        default:
            return [self finalCenter];
    }
}

- (CGPoint)finalCenter {
    switch (self.layoutType) {
        case zhPopupLayoutTypeTop:
            return CGPointMake(self.maskView.center.x,
                               self.popupView.bounds.size.height / 2 + self.offsetSpacing);
        case zhPopupLayoutTypeLeft:
            return CGPointMake(self.popupView.bounds.size.width / 2 + self.offsetSpacing,
                               self.maskView.center.y);
        case zhPopupLayoutTypeBottom:
            if (_initTopY > 0) {
                //改为初始中间状态
                return CGPointMake(self.maskView.center.x,
                                   _initTopY + self.popupView.bounds.size.height / 2 - self.offsetSpacing);
            }else{
                return CGPointMake(self.maskView.center.x,
                                   self.maskView.bounds.size.height - self.popupView.bounds.size.height / 2 - self.offsetSpacing);
            }
        case zhPopupLayoutTypeRight:
            return CGPointMake(self.maskView.bounds.size.width - self.popupView.bounds.size.width / 2 - self.offsetSpacing,
                               self.maskView.center.y);
        case zhPopupLayoutTypeCenter:
            /// only adjust center.y
            return CGPointMake(self.maskView.center.x, self.maskView.center.y + self.offsetSpacing);
        default: break;
    }
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.proxyView.bounds];
        switch (self.maskType) {
            case zhPopupMaskTypeDarkBlur: {
                UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
                blurView.frame = _maskView.bounds;
                [_maskView insertSubview:blurView atIndex:0];
            } break;
            case zhPopupMaskTypeLightBlur: {
                UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
                blurView.frame = _maskView.bounds;
                [_maskView insertSubview:blurView atIndex:0];
            } break;
            case zhPopupMaskTypeExtraLightBlur: {
                UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
                UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
                blurView.frame = _maskView.bounds;
                [_maskView insertSubview:blurView atIndex:0];
            } break;
            case zhPopupMaskTypeWhite: {
                _maskView.backgroundColor = [UIColor whiteColor];
            } break;
            case zhPopupMaskTypeClear: {
                _maskView.backgroundColor = [UIColor clearColor];
            } break;
            case zhPopupMaskTypeBlackOpacity: {
                _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.maskAlpha];
            } break;
            default: break;
        }
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.delegate = self;
        [_maskView addGestureRecognizer:tap];
        if (self.panGestureEnabled) {
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            [self.popupView addGestureRecognizer:pan];
        }
    }
    return _maskView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return ![touch.view isDescendantOfView:self.popupView];
    }
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)g {
    if (self.isPresenting && self.dismissOnMaskTouched) {
        if (self.defaultDismissBlock) {
            self.defaultDismissBlock(self);
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)g {
    if (_isKeyboardVisible || !self.panGestureEnabled) return;
    CGPoint p = [g translationInView:self.maskView];
    CGFloat currentY = g.view.frame.origin.y + p.y;//当前view顶部
    switch (g.state) {
        case UIGestureRecognizerStateBegan:
            _panoOriginY = g.view.frame.origin.y;//触摸时view的Y
            
            if (self.PositionChangedBlock) {//开始touch把table按最大计算
                self.PositionChangedBlock(_topPositionY);
            }
            break;
        case UIGestureRecognizerStateChanged: {
                    
            switch (self.layoutType) {
                case zhPopupLayoutTypeTop: {
                    CGFloat boundary = g.view.bounds.size.height + self.offsetSpacing;
                    if ((CGRectGetMinY(g.view.frame) + g.view.bounds.size.height + p.y) < boundary) {
                        g.view.center = CGPointMake(g.view.center.x, g.view.center.y + p.y);
                    } else {
                        g.view.center = [self finalCenter];
                    }
                    self.maskView.alpha = CGRectGetMaxY(g.view.frame) / boundary;
                } break;
                case zhPopupLayoutTypeLeft: {
                    CGFloat boundary = g.view.bounds.size.width + self.offsetSpacing;
                    if ((CGRectGetMinX(g.view.frame) + g.view.bounds.size.width + p.x) < boundary) {
                        g.view.center = CGPointMake(g.view.center.x + p.x, g.view.center.y);
                    } else {
                        g.view.center = [self finalCenter];
                    }
                    self.maskView.alpha = CGRectGetMaxX(g.view.frame) / boundary;
                } break;
                case zhPopupLayoutTypeBottom: {
                    if (self.popupPosition == zhPopupPositionNone) {
                        CGFloat boundary = self.maskView.bounds.size.height - g.view.bounds.size.height - self.offsetSpacing;
                        if ((g.view.frame.origin.y + p.y) > boundary) {
                            g.view.center = CGPointMake(g.view.center.x, g.view.center.y + p.y);
                        } else {
                            g.view.center = [self finalCenter];
                        }
                        self.maskView.alpha = 1 - (CGRectGetMinY(g.view.frame) - boundary) / (self.maskView.bounds.size.height - boundary);
                    }else{
                        //顶部
                        CGRect frame = g.view.frame;
                        frame.origin.y = MAX(currentY,_topPositionY);
                        g.view.frame = frame;
                    }
                } break;
                case zhPopupLayoutTypeRight: {
                    CGFloat boundary = self.maskView.bounds.size.width - g.view.bounds.size.width - self.offsetSpacing;
                    if ((CGRectGetMinX(g.view.frame) + p.x) > boundary) {
                        g.view.center = CGPointMake(g.view.center.x + p.x, g.view.center.y);
                    } else {
                        g.view.center = [self finalCenter];
                    }
                    self.maskView.alpha = 1 - (CGRectGetMinX(g.view.frame) - boundary) / (self.maskView.bounds.size.width - boundary);
                } break;
                case zhPopupLayoutTypeCenter: {
                    [self directionalLock:p];
                    if (_directionalVertical) {
                        g.view.center = CGPointMake(g.view.center.x, g.view.center.y + p.y);
                        CGFloat boundary = self.maskView.bounds.size.height / 2 + self.offsetSpacing - g.view.bounds.size.height / 2;
                        self.maskView.alpha = 1 - (CGRectGetMinY(g.view.frame) - boundary) / (self.maskView.bounds.size.height - boundary);
                    } else {
                        [self directionalUnlock]; // todo...
                    }
                } break;
                default: break;
            }
            
            [g setTranslation:CGPointZero inView:self.maskView];
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded: {
            
            BOOL isDismissNeeded = NO;
            switch (self.layoutType) {
                case zhPopupLayoutTypeTop: {
                    isDismissNeeded = CGRectGetMaxY(g.view.frame) < self.maskView.bounds.size.height * self.panDismissRatio;
                } break;
                case zhPopupLayoutTypeLeft: {
                    isDismissNeeded = CGRectGetMaxX(g.view.frame) < self.maskView.bounds.size.width * self.panDismissRatio;
                } break;
                case zhPopupLayoutTypeBottom: {
                    if (self.popupPosition == zhPopupPositionNone) {
                        isDismissNeeded = CGRectGetMinY(g.view.frame) > self.maskView.bounds.size.height * self.panDismissRatio;
                    }else{
                        BOOL fastDown = NO;
                        BOOL fastUp = NO;
                        BOOL slowDown = NO;
                        BOOL slowUp = NO;
                        CGFloat factor = 50;
                        CGPoint velocity = [g velocityInView:g.view];
                        if (velocity.y > 0 && velocity.y > factor) {
                            fastDown = YES;NSLog(@"Fast 下拉");
                        } else if (velocity.y < 0 && fabs(velocity.y) > factor) {
                            fastUp = YES;NSLog(@"Fast 上拉");
                        }
                        CGFloat deltaY = currentY - _panoOriginY;
                        if (deltaY > factor) {
                            slowDown = YES;NSLog(@"下拉 more than 30px");
                        } else if (deltaY < -factor) {
                            slowUp = YES;NSLog(@"上拉 more than 30px");
                        }
                        
                        if (self.popupPosition == zhPopupPositionTop) {//只响应下拉
                            if(slowDown){//判断距离去中间、底部、隐藏
                                if (currentY<=_midPositionY+30) {//toMid
                                    [self moveView:g.view toPosition:(zhPopupPositionMiddle)];
                                }else {//hide
                                    isDismissNeeded = YES;
                                }
                            }else if (fastDown) {
                                //toMid
                                [self moveView:g.view toPosition:(zhPopupPositionMiddle)];
                            }else{
                                //toTop
                                [self moveView:g.view toPosition:(zhPopupPositionTop)];
                            }
                        }else if (self.popupPosition == zhPopupPositionMiddle){//中间
                            if (fastUp || slowUp) {//toTop
                                [self moveView:g.view toPosition:(zhPopupPositionTop)];
                            }else if (fastDown || slowDown){//hide
                                isDismissNeeded = YES;
                            }else {//toMid
                                [self moveView:g.view toPosition:(zhPopupPositionMiddle)];
                            }
                        }else{
                            isDismissNeeded = YES;//隐藏状态
                        }
                        
                    }
                } break;
                case zhPopupLayoutTypeRight: {
                    isDismissNeeded = CGRectGetMinX(g.view.frame) > self.maskView.bounds.size.width * self.panDismissRatio;
                } break;
                case zhPopupLayoutTypeCenter: {
                    if (_directionalVertical) {
                        isDismissNeeded = CGRectGetMinY(g.view.frame) > self.maskView.bounds.size.height * self.panDismissRatio;
                        [self directionalUnlock];
                    }
                } break;
                default: break;
            }
            
            if (isDismissNeeded) {
                if (self.defaultDismissBlock) {
                    self.defaultDismissBlock(self);
                }
            } else {
//                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//                    self.maskView.alpha = 1;
//                    g.view.center = [self finalCenter];
//                } completion:NULL];
            }
            
        } break;
        default: break;
    }
}

- (void)moveView:(UIView *)view toPosition:(zhPopupPosition)position{
    CGRect frame = view.frame;
    self.popupPosition = position;
    switch (position) {
        case zhPopupPositionTop:
            frame.origin.y = _topPositionY;
            break;
        case zhPopupPositionMiddle:
            frame.origin.y = _midPositionY;
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.maskView.alpha = 1;
        view.frame = frame;
    } completion:^(BOOL finished) {
        if (self.PositionChangedBlock) {//touch结束把table按实际值计算
            self.PositionChangedBlock(frame.origin.y);
        }
    }];
}

- (void)directionalLock:(CGPoint)translation {
    if (!_isDirectionLocked) {
        _directionalVertical = ABS(translation.x) < ABS(translation.y);
        _isDirectionLocked = YES;
    }
}

- (void)directionalUnlock {
    _isDirectionLocked = NO;
}

- (void)setKeyboardChangeFollowed:(BOOL)keyboardChangeFollowed {
    if (keyboardChangeFollowed) {
        _keyboardChangeFollowed = keyboardChangeFollowed;
        [self bindKeyboardNotifications];
    }
}

- (void)bindKeyboardNotifications {
    if (self.keyboardChangeFollowed) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)unbindKeyboardNotifications {
    if (self.keyboardChangeFollowed) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    _isKeyboardVisible = NO;
    if (_isPresenting) {
        NSDictionary *u = notif.userInfo;
        UIViewAnimationOptions options = [u[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
        NSTimeInterval duration = [u[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.popupView.center = [self finalCenter];
        } completion:NULL];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notif {
    NSDictionary *u = notif.userInfo;
    CGRect frameBegin = [u[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frameEnd = [u[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (frameBegin.size.height > 0 && ABS(CGRectGetMinY(frameBegin) - CGRectGetMinY(frameEnd))) {
        CGRect frameConverted = [self.maskView convertRect:frameEnd fromView:nil];
        CGFloat keyboardHeightConverted = self.maskView.bounds.size.height - CGRectGetMinY(frameConverted);
        if (keyboardHeightConverted > 0) {
            _isKeyboardVisible = YES;
        
            CGFloat originY = CGRectGetMaxY(self.popupView.frame) - CGRectGetMinY(frameConverted);
            CGPoint newCenter = CGPointMake(self.popupView.center.x, self.popupView.center.y - originY - self.keyboardOffsetSpacing);
            NSTimeInterval duration = [u[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            UIViewAnimationOptions options = [u[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
            [UIView animateWithDuration:duration delay:0 options:options animations:^{
                self.popupView.center = newCenter;
            } completion:NULL];
        }
    }
}

- (void)dealloc {
    [self unbindKeyboardNotifications];
}

@end


static void *UIViewzhPopupControllersKey = &UIViewzhPopupControllersKey;

@implementation UIView (zhPopupController)

- (void)zh_presentPopupController:(zhPopupController *)popupController completion:(void (^)(void))completion {
    return [self zh_presentPopupController:popupController duration:0.25 completion:completion];
}

- (void)zh_presentPopupController:(zhPopupController *)popupController duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    return [self zh_presentPopupController:popupController duration:duration bounced:NO completion:completion];
}

- (void)zh_presentPopupController:(zhPopupController *)popupController duration:(NSTimeInterval)duration bounced:(BOOL)isBounced completion:(void (^)(void))completion {
    return [self zh_presentPopupController:popupController duration:duration delay:0 options:UIViewAnimationOptionCurveLinear bounced:isBounced completion:completion];
}

- (void)zh_presentPopupController:(zhPopupController *)popupController duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options bounced:(BOOL)isBounced completion:(void (^)(void))completion {
    NSMutableArray<zhPopupController *> *_popupControllers = objc_getAssociatedObject(self, UIViewzhPopupControllersKey);
    if (_popupControllers.count) {
        return;//如果有，则不继续弹起
    }
    if (!_popupControllers) {
        _popupControllers = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, UIViewzhPopupControllersKey, _popupControllers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    popupController.proxyView = self;
    
    if (_popupControllers.count > 0) {
        [_popupControllers sortUsingComparator:^NSComparisonResult(zhPopupController *obj1, zhPopupController *obj2) {
            return obj1.windowLevel < obj2.windowLevel;
        }];
        
        if (popupController.windowLevel >= _popupControllers.lastObject.windowLevel) {
            [popupController addSubview];
        } else {
            for (zhPopupController *element in _popupControllers) {
                if (popupController.windowLevel < element.windowLevel) {
                    [popupController addSubviewBelow:element.maskView];
                    break;
                }
            }
        }
    } else {
        [popupController addSubview];
    }
    
    if (![_popupControllers containsObject:popupController]) {
        [_popupControllers addObject:popupController];
    }
    [popupController presentDuration:duration delay:delay options:options bounced:isBounced completion:completion];
}

- (void)zh_dissmissPopupController:(zhPopupController *)popupController completion:(void (^)(void))completion {
    return [self zh_dissmissPopupController:popupController duration:0.25 completion:completion];
}

- (void)zh_dissmissPopupController:(zhPopupController *)popupController duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    return [self zh_dissmissPopupController:popupController duration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut completion:completion];
}

- (void)zh_dissmissPopupController:(zhPopupController *)popupController duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion {
    NSMutableArray<zhPopupController *> *_popupControllers = objc_getAssociatedObject(self, UIViewzhPopupControllersKey);
    if (_popupControllers.count > 0) {
        [popupController dismissDuration:duration delay:delay options:options completion:completion];
        [_popupControllers removeObject:popupController];
        if (_popupControllers.count < 1) {
            objc_setAssociatedObject(self, UIViewzhPopupControllersKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

@end


@implementation zhPopupController (Convenient)

- (UIWindow *)keyWindow {
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    if (window) return window;
    if (@available(iOS 13.0, *)) {
        return UIApplication.sharedApplication.windows.firstObject;
    } else {
        return UIApplication.sharedApplication.keyWindow;
    }
}

- (void)show {
    return [self.keyWindow zh_presentPopupController:self completion:NULL];
}

- (void)showInView:(UIView *)view completion:(void (^)(void))completion {
    return [view zh_presentPopupController:self completion:completion];
}

- (void)showInView:(UIView *)view midY:(CGFloat)midY topY:(CGFloat)topY initY:(CGFloat)initY initPosition:(zhPopupPosition)position completion:(void (^)(void))completion {
    self.midPositionY = midY;
    self.topPositionY = topY;
    self.initTopY = initY;
    self.popupPosition = zhPopupPositionMiddle;
    return [view zh_presentPopupController:self completion:completion];
}

- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    return [view zh_presentPopupController:self duration:duration completion:completion];
}

- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration bounced:(BOOL)bounced completion:(void (^)(void))completion {
    return [view zh_presentPopupController:self duration:duration bounced:bounced completion:completion];
}

- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options bounced:(BOOL)bounced completion:(void (^)(void))completion {
    return [view zh_presentPopupController:self duration:duration delay:delay options:options bounced:bounced completion:completion];
}

- (void)dismiss {
    return [self.proxyView zh_dissmissPopupController:self completion:NULL];
}

- (void)dismissWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    return [self.proxyView zh_dissmissPopupController:self completion:completion];
}

- (void)dismissWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion {
    return [self.proxyView zh_dissmissPopupController:self duration:duration delay:delay options:options completion:completion];
}

@end
