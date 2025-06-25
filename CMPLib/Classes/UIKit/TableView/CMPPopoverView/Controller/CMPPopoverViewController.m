//
//  CMPPopoverViewController.m
//  CMPLib
//
//  Created by MacBook on 2019/11/6.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPPopoverViewController.h"
#import "UIView+CMPView.h"
#import "CMPCAAnimation.h"
#import <CMPLib/CMPCore.h>

static NSString * const kHideShowingViewKey = @"hideShowingViewKey";
CGFloat const CMPPopoverShowingViewTimeInterval = 0.3f;

@interface CMPPopoverViewController ()

/* shareView是否在显示中 */
@property (assign, nonatomic) BOOL isShowingViewShowing;
/* 原始frame */
@property (assign, nonatomic) CGRect showingF;
/* 隐藏时的frame */
@property (assign, nonatomic) CGRect hideingF;

@end

@implementation CMPPopoverViewController

#pragma mark - life circle

- (void)dealloc {
    DDLogDebug(@"---%s----",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.clearColor;
    [self.view addSubview:self.showingView];
    self.showingView.userInteractionEnabled = YES;
    
    [self showShowingView];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.isShowingViewShowing) {
        [self hideShowingView];
        if (self.viewClicked) self.viewClicked(YES);
    }else {
        [self showShowingView];
    }
}

/// view布局，主要用于处理ipad横竖屏切换问题
- (void)viewDidLayoutSubviews {
    if (CMP_IPAD_MODE) {
        self.showingView.center = CGPointMake(self.view.width/2.f, self.view.height/2.f);
    }
    [super viewDidLayoutSubviews];
}

#pragma mark - 显示隐藏shareView
- (void)showShowingView {
    self.isShowingViewShowing = YES;
    [CMPCAAnimation cmp_animationScaleMagnifyWithView:self.showingView timeInterval:CMPPopoverShowingViewTimeInterval];
    self.showingView.alpha = 0;
    [UIView animateWithDuration:CMPPopoverShowingViewTimeInterval animations:^{
        self.showingView.alpha = 1.f;
    }];
}

- (void)hideShowingView {
    self.isShowingViewShowing = NO;
    [CMPCAAnimation cmp_animationScaleShrinkWithView:self.showingView timeInterval:CMPPopoverShowingViewTimeInterval];
    [UIView animateWithDuration:CMPPopoverShowingViewTimeInterval animations:^{
        self.showingView.alpha = 0;
    }];
}


- (void)hideViewWithoutAnimation {
    if (self.viewClicked) self.viewClicked(NO);
}


@end
