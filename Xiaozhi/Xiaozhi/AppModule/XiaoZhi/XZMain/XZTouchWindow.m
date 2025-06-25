//
//  XZTouchWindow.m
//  M3
//
//  Created by wujiansheng on 2017/11/9.
//

#import "XZTouchWindow.h"
#import "SPTools.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPCore.h>

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

@interface XZTouchWindow () {
    CGPoint _startPt;
    UIEdgeInsets _edgeInsets;//靠边偏移
    UIImageView *_tapImgv;
    CGFloat _keyboardHeight;
    CGSize _preScreenSize;
    CGRect _preFrame;
}

@end

@implementation XZTouchWindow

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    self.didClickTapBtn = nil;
    _tapImgv = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupEdgeInsets];
        CGRect f = [UIScreen mainScreen].bounds;
        self.frame = CGRectMake(CGRectGetWidth(f)-60-_edgeInsets.right, CGRectGetHeight(f)-60-_edgeInsets.bottom, 60, 60);
        _preScreenSize = f.size;
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 8;
        //        self.windowLevel = UIWindowLevelAlert - 10;
        self.hidden = NO;
        _keyboardHeight = 0;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGes:)];
        [self addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGes:)];
        [self addGestureRecognizer:tap];
        
        _tapImgv = [[UIImageView alloc] initWithFrame:self.bounds];
        _tapImgv.image = XZ_IMAGE(@"xz_icon_default.png");
        _tapImgv.userInteractionEnabled = YES;
        [self addSubview:_tapImgv];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)setupEdgeInsets {
    if (CMP_IPAD_MODE) {
        _edgeInsets = UIEdgeInsetsMake(10, 80, 10, 0);
    }
    else {
        UIEdgeInsets  edgeInsets = [SPTools xzSafeAreaInsets];
        BOOL tabbarCanExpand = [SPTools tabbarCanExpand];
        _edgeInsets = UIEdgeInsetsMake(edgeInsets.top+10, edgeInsets.left, edgeInsets.bottom+44+(tabbarCanExpand?36:0), edgeInsets.right);
    }
}

//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification {
    CGRect r = [UIScreen mainScreen].bounds;
    if (r.size.width == _preScreenSize.width && r.size.height == _preScreenSize.height) {
        return;
    }
    [self setupEdgeInsets];
    _preScreenSize = r.size;
    
    CGRect frame = self.frame;
    if (_keyboardHeight > 0 ) {
        CGFloat screenHeight = CGRectGetHeight(r);
        CGFloat maxHeight = screenHeight- _keyboardHeight;
        if ( maxHeight >0 && CGRectGetMaxY(self.frame)> maxHeight) {
            frame.origin.y = maxHeight - frame.size.height;
        }
    }
    else {
        frame = CGRectMake(CGRectGetWidth(r)-60-_edgeInsets.right, CGRectGetHeight(r)-60-_edgeInsets.bottom, 60, 60);
    }
    if (frame.origin.y < _edgeInsets.top) {
        frame.origin.y = _edgeInsets.top;
    }
    self.frame = frame;
}

- (void)handlePanGes:(UIPanGestureRecognizer*)panGes {
    
    CGRect availableRect = [UIScreen mainScreen].bounds;
    availableRect.size.height -= _keyboardHeight;
    CGSize screenSize = availableRect.size;
    
    if (panGes.state == UIGestureRecognizerStateBegan) {
        _startPt = [panGes locationInView:self];
    }
    CGPoint p = [panGes locationInView:self];
    CGPoint newcenter = CGPointMake(self.center.x + p.x - _startPt.x, self.center.y + p.y - _startPt.y);
    //限制区域
    float halfx = CGRectGetMidX(self.bounds);
    newcenter.x = MAX(halfx+_edgeInsets.left, newcenter.x);
    newcenter.x = MIN(CGRectGetWidth(availableRect) - halfx - _edgeInsets.right, newcenter.x);
    
    float halfy = CGRectGetMidY(self.bounds);
    newcenter.y = MAX(halfy+_edgeInsets.top, newcenter.y);
    newcenter.y = MIN(CGRectGetHeight(availableRect) - halfy - _edgeInsets.bottom, newcenter.y);
    
    self.center = newcenter;
    if (panGes.state == UIGestureRecognizerStateEnded) {
        //自动靠边
        BOOL toLeft = (self.center.x - _edgeInsets.left) - (screenSize.width - self.center.x - _edgeInsets.right) < 0;
        BOOL toTop = (self.center.y - _edgeInsets.top) - (screenSize.height - self.center.y - _edgeInsets.bottom) < 0;
        float minX = MIN(self.center.x - _edgeInsets.left, screenSize.width - self.center.x - _edgeInsets.right);
        float minY = MIN(self.center.y - _edgeInsets.top, screenSize.height - self.center.y - _edgeInsets.bottom);
        CGPoint newcenter = self.center;
        float halfx = CGRectGetMidX(self.bounds);
        float halfy = CGRectGetMidY(self.bounds);
        if (minX > minY && toTop) {//靠上
            newcenter.y = _edgeInsets.top + halfy;
        } else if (minX <= minY && toLeft) {//靠左
            newcenter.x = _edgeInsets.left + halfx;
        } else if (minX > minY && !toTop) {//靠下
            newcenter.y = screenSize.height - _edgeInsets.bottom - halfy;
        }  else if (minX <= minY && !toLeft) {//靠右
            newcenter.x = screenSize.width - _edgeInsets.right - halfx;
        }
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.center = newcenter;
        } completion:^(BOOL finished) {
            
        }];
        _preFrame = CGRectZero;
    }
}

- (void)handleTapGes:(UITapGestureRecognizer*)tap {
    if (_didClickTapBtn) {
        _didClickTapBtn(YES);
    }
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    if (self.hidden) {
        return;
    }
    if (_keyboardHeight == 0) {
        _preFrame = self.frame;
    }
    CGRect r = [[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = r.size.height;
    _keyboardHeight = keyboardHeight;
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat maxHeight = screenHeight- _keyboardHeight;
    if (keyboardHeight > 0 && maxHeight >0 && CGRectGetMaxY(self.frame)> maxHeight) {
        CGRect frame = self.frame;
        frame.origin.y = maxHeight - frame.size.height;
        double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            self.frame = frame;
        }];
    }
}

-(void)keyboardWillHide:(NSNotification *)notification {
    _keyboardHeight = 0;
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.frame;
    if (_preFrame.size.width != 0 && _preFrame.size.height != 0) {
        frame = _preFrame;
    }
    if (frame.origin.x < _edgeInsets.left || frame.origin.y < _edgeInsets.top || (self.superview  && (CGRectGetMaxX(frame) > self.superview.width || CGRectGetMaxY(frame) > self.superview.height))) {
        CGRect f = self.superview.bounds;
        frame = CGRectMake(CGRectGetWidth(f)-60-_edgeInsets.right, CGRectGetHeight(f)-60-_edgeInsets.bottom, 60, 60);
    }
    [UIView animateWithDuration:duration animations:^{
        self.frame = frame;
        self->_preFrame = CGRectZero;
    }];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden && self.superview) {
        //调整下位置防止touch window 跑到屏幕外了
        if (CGRectGetMaxX(self.frame) > self.superview.width
            || CGRectGetMaxY(self.frame) > self.superview.height
            || self.originX < 0
            || self.originY < 0) {
            CGRect f = self.superview.bounds;
            self.frame = CGRectMake(CGRectGetWidth(f)-60-_edgeInsets.right, CGRectGetHeight(f)-60-_edgeInsets.bottom, 60, 60);
        }
    }
}

- (void)showInView:(UIView *)aView frame:(CGRect) f {    
    [self removeFromSuperview];
    if (!aView) {
        return;
    }
    [aView addSubview:self];
    [aView bringSubviewToFront:self];
    self.tag = kViewTag_XiaozIcon;
    f = CGRectMake(CGRectGetWidth(f)-60, CGRectGetHeight(f)-60, 60, 60);
    if (self.originX > f.origin.x) {
        self.cmp_x = f.origin.x;
    }
    if (self.originY > f.origin.y) {
        self.cmp_y = f.origin.y;
    }
}

@end
