//
//  SyModalView.m
//  M1Core
//
//  Created by guoyl on 13-1-28.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//

#import "CMPModalView.h"
#import "CMPGlobleManager.h"
#import "CMPKeyboardStateListener.h"

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

@interface CMPModalView () {
    UIView *_backgroundView;
    CGRect _fromRect;
    UIView *_inView;
    CGRect _keyboardRect;
    CGRect _contentViewRect;
}
- (void)updateFrame;
@end

@implementation CMPModalView
@synthesize contentView = _contentView;
@synthesize autoHide = _autoHide;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        self.backgroundColor = [UIColor clearColor];
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.4;
        [self addSubview:_backgroundView];
        self.autoHide = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidde:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
}

- (void)popWithContentView:(UIView *)aContentView
{
    [_backgroundView removeFromSuperview];
    [self addSubview:_backgroundView];
    _inView = nil;
    [_contentView removeFromSuperview];
    self.contentView = nil;
    aContentView.userInteractionEnabled = YES;
    self.contentView = aContentView;
    [self addSubview:aContentView];
    [self updateFrame];
    if ([CMPKeyboardStateListener sharedInstance].isVisible) {
        _keyboardRect = [CMPKeyboardStateListener sharedInstance].keyboardRect;
        [self layoutContentViewForKeyboardWillShow];
    }
}

- (void)presentView:(UIView *)aView fromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated autoHide:(BOOL)autoHide
{
    [_backgroundView removeFromSuperview];
    self.autoHide = autoHide;
    [aView removeFromSuperview];
    self.contentView = nil;
    self.contentView = aView;
    [self addSubview:aView];
    _fromRect = rect;
    _inView = nil;
    _inView = view;
    [self updateFrame];
}

- (void)popWithContentView:(UIView *)aContentView autoHide:(BOOL)autoHide
{
    self.autoHide = autoHide;
    [self popWithContentView:aContentView];
}

- (void)willChangeStatusBarOrientation:(NSNotification *)notification
{
    
}

- (void)updateFrame
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat angle = 0.0;
    CGRect newFrame = CGRectZero;
    CGFloat statusHeight = 0.0f;//[UIView statusBarHeight];
    CGSize mainSize = [UIView mainScreenSize];
    CGFloat max = MAX(mainSize.width, mainSize.height);
    CGFloat min = MIN(mainSize.width, mainSize.height);
//    if (INTERFACE_IS_PHONE) {
        newFrame = CGRectMake(0, - statusHeight , min, max);
        CGRect frame = self.contentView.frame;
        frame.origin.x = newFrame.size.width/2 - frame.size.width/2;
        frame.origin.y = newFrame.size.height/2 - frame.size.height/2;
        self.frame = newFrame;
        _contentViewRect = frame;
        self.contentView.frame = frame;
        return;
//    }
    
 /*
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            newFrame = CGRectMake(0, - statusHeight , min, max);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI / 2.0f;
            newFrame = CGRectMake(statusHeight, 0, min, max);
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI / 2.0f;
            newFrame = CGRectMake(- statusHeight , 0, min, max);
            break;
        default:
            angle = 0.0;
            newFrame = CGRectMake(0, statusHeight, min, max);
            break;
    }
    if (IOS8_Later) {
        angle = 0.0;
        newFrame.size.width = max;
        newFrame.size.height = min;
    }
    self.transform = CGAffineTransformMakeRotation(angle);
    self.frame = newFrame;
    _backgroundView.frame = self.bounds;
    // set the contentview origin
    CGRect frame = self.contentView.frame;
    if (UIInterfaceOrientationIsLandscape(orientation) && !IOS8_Later) {
        frame.origin.x = self.height/2 - self.contentView.width/2;
        frame.origin.y = self.width/2 - self.contentView.height/2;
    }else {
        frame.origin.x = self.width/2 - self.contentView.width/2;
        frame.origin.y = self.height/2 - self.contentView.height/2;
    }
    if (_inView) {
        CGRect f = [self convertRect:_fromRect fromView:_inView];
        frame.origin.x = f.origin.x;
        frame.origin.y = f.origin.y + _fromRect.size.height;
    }
    
    _contentViewRect = frame;
    self.contentView.frame = frame;
  */
}

- (void)didChangeStatusBarOrientation:(NSNotification *)notification
{
    [self updateFrame];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.autoHide) {
        return;
    }
    UITouch *touchObj = (UITouch *)[touches anyObject];
    CGPoint location = [touchObj locationInView:self];
    CGRect cf = self.contentView.frame;
    CGPoint cOrigin = cf.origin;
    if ( location.x > cOrigin.x && location.y > cOrigin.y && location.x < cOrigin.x + self.contentView.width \
        && location.y < cOrigin.y + self.contentView.height) {
        return;
    }
    [[CMPGlobleManager sharedSyGlobleManager] dismissModalView:YES];
}

- (CGFloat)keyboardHeight
{
    CGFloat h = _keyboardRect.size.height;
    if (h > _keyboardRect.size.width) {
        h = _keyboardRect.size.width;
    }
    return h;
}

- (CGFloat )heigtForSelf
{
    if (INTERFACE_IS_PAD) {
        return self.height > self.width ?self.width :self.height;
    }
    else {
        return self.height < self.width ?self.width :self.height;
    }
}

- (void)layoutContentViewForKeyboardWillShow
{
    if (_contentView) {
        CGRect f = _contentViewRect;
        f.origin.y = self.heigtForSelf - [self keyboardHeight] -_contentViewRect.size.height -20;
        if ( f.origin.y <10) {
            f.origin.y  = 10;
        }
        [_contentView setFrame:f];
    }
}
- (void)layoutContentViewForKeyboardWillHidde
{
    if (_contentView) {
        [_contentView setFrame:_contentViewRect];
    }
}
-(void)keyboardWillShow:(NSNotification *)notification
{
    _keyboardRect = [[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"%@", NSStringFromCGRect(_keyboardRect));
    [self layoutContentViewForKeyboardWillShow];
}
-(void)keyboardWillHidde:(NSNotification *)notification
{
    _keyboardRect = CGRectZero;
    [self layoutContentViewForKeyboardWillHidde];
}

@end
