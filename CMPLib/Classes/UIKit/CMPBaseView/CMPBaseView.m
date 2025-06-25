//
//  CMPBaseView.m
//  M1Core
//
//  Created by admin on 12-10-26.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kModalTransitionDuration        0.5

#import "CMPBaseView.h"
#import "NSObject+CMPHUDView.h"

@interface CMPBaseView()
{
    UIView *_loadingView;
    NSInteger _showLoadingViewCounter; // 显示加载窗体计算
    
    UIView *_loadingBackgroundView;
    BOOL _loadingOnShow;
}
@end

@implementation CMPBaseView
@synthesize viewController = _viewController;
@synthesize modalParentView = _modalParentView;
@synthesize contentSize = _contentSize;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        if (self.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [self setupForPad];
        }
        else {
            [self setupForPhone];
        }
        [self customLayoutSubviews];
    }
    return self;
}

- (void)setup {
}

- (void)setupForPhone 
{
}

- (void)setupForPad 
{
}

- (void)dealloc
{
//    [_progressHUD release];
//    _progressHUD = nil;
    
    [_loadingView release];
    _loadingView = nil;
    
    [_modalParentView release];
	_modalParentView = nil;
    _viewController = nil;
    [_modalView removeFromSuperview];
	[_modalView release];
	_modalView = nil;
    
    [_loadingBackgroundView removeFromSuperview];
    SY_RELEASE_SAFELY(_loadingBackgroundView);
    
    [super dealloc];
}

- (void)setFrame:(CGRect)frame
{
    BOOL isResizing = YES;
    if (frame.size.width == self.width && frame.size.height == self.height) {
        isResizing = NO;
    }
    [super setFrame:frame];
    if (isResizing) {
        [self customLayoutSubviews];
    }
}

- (void)customLayoutSubviews 
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [self layoutSubviewsForPortrait];
    }
    else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self layoutSubviewsForLandscape];
    }
    if (self.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self layoutSubviewsForPad];
    }
    else {
        [self layoutSubviewsForPhone];
    }
}

- (void)layoutSubviewsForPad {
    
}

- (void)layoutSubviewsForPhone {

}

- (void)layoutSubviewsForPortrait 
{
    if (self.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self layoutSubviewsForPadPortrait];
    }
    else {
        [self layoutSubviewsForPhonePortrait];
    }
}

- (void)layoutSubviewsForLandscape 
{
    if (self.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self layoutSubviewsForPadLandscape];
    }
    else {
        [self layoutSubviewsForPhoneLandscape];
    }
}

- (void)layoutSubviewsForPhonePortrait {
}

- (void)layoutSubviewsForPhoneLandscape {
}

- (void)layoutSubviewsForPadPortrait {
}

- (void)layoutSubviewsForPadLandscape {
}

- (CGSize)contentSize
{
    if (_contentSize.width == 0 || _contentSize.height == 0) {
        return CGSizeMake(self.width, self.height);
    }
    return _contentSize;
}

- (void)updateLoadingViewFrame
{
    if (_loadingView) {
        CGRect f = [self frame];
        _loadingView.frame = f;
    }
}

// 模态窗体
- (void)showLoadingView
{
    [self cmp_showProgressHUDInView:self];
}

// loadingView
- (void)showLoadingViewWithText:(NSString *)aStr
{
    [self cmp_showHUDWithText:aStr inView:self];
}

- (void)hideLoadingView
{
    [self cmp_hideProgressHUD];
}

@end
