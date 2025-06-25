//
//  CMPPopOverManager.m
//  CMPLib
//
//  Created by MacBook on 2019/12/23.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPPopOverManager.h"
#import "CMPVideoSelectView.h"
#import "CMPShareToUCFinishedTipsView.h"


#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPPopFromBottomViewController.h>
#import <CMPLib/CMPPopoverViewController.h>
#import <CMPLib/CMPThemeManager.h>



static CGFloat const kVideoSelectCancelViewH = 64.f;
static CGFloat const kVideoSelectRowH = 50.f;
static NSString * const kWindowBgBlackColor = @"0x333333";

static UIWindow *popoverWindow_ = nil;
static id instance_ = nil;


@interface CMPPopOverManager()<NSCopying>

@end

@implementation CMPPopOverManager

#pragma mark - lazy loading
- (void )initialiseWindow {
    if (!popoverWindow_) {
        popoverWindow_ = [UIWindow.alloc initWithFrame: UIScreen.mainScreen.bounds];
        popoverWindow_.backgroundColor = [[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0];
        popoverWindow_.windowLevel = UIWindowLevelNormal;
        popoverWindow_.hidden = NO;
        [CMPThemeManager.sharedManager setUserInterfaceStyle];
    }
}

#pragma mark - show/hide window
- (void)hideWindowWithAnimation {
    [UIView animateWithDuration:CMPShowingViewTimeInterval - 0.03f animations:^{
        popoverWindow_.backgroundColor = [[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        popoverWindow_.hidden = YES;
        popoverWindow_.rootViewController = nil;
        popoverWindow_ = nil;
    }];
}

- (void)hideWindowWithoutAnimation {
    popoverWindow_.hidden = YES;
    popoverWindow_.rootViewController = nil;
    popoverWindow_ = nil;
}

#pragma mark singleton
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = CMPPopOverManager.alloc.init;
    });
    return instance_;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [super allocWithZone:zone];
    });
    return instance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark videoSelectView显示隐藏

- (void)showVideoSelectViewWithModel:(id)msgModel url:(nullable NSString *)url vc:(nonnull UIViewController *)fromVc from:(nullable NSString *)from fromType:(nullable NSString *)fromType fileId:(nullable NSString *)fileId fileName:(nonnull NSString *)fileName {
    [self showVideoSelectViewWithModel:msgModel url:url vc:fromVc from:from fromType:fromType fileId:fileId canNotShare:NO canNotCollect:![CMPFeatureSupportControl isSupportCollect] canNotSave:NO isUc:NO fileName:fileName];
}

- (void)showVideoSelectViewWithModel:(id)msgModel url:(nullable NSString *)url vc:(nonnull UIViewController *)fromVc from:(nullable NSString *)from fromType:(nullable NSString *)fromType fileId:(nullable NSString *)fileId canNotShare:(BOOL)canNotShare canNotCollect:(BOOL)canNotCollect canNotSave:(BOOL)canNotSave isUc:(BOOL)isUc fileName:(nonnull NSString *)fileName {
    if (canNotShare && canNotCollect && canNotSave) return;
    
    [self initialiseWindow];
    CMPPopFromBottomViewController *vc = CMPPopFromBottomViewController.alloc.init;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = UIScreen.mainScreen.bounds.size.width;
    CGFloat h = kVideoSelectCancelViewH;
    if (!canNotShare) {
        h += kVideoSelectRowH;
    }
    if (!canNotCollect) {
        h += kVideoSelectRowH;
    }
    if (!canNotSave) {
        h += kVideoSelectRowH;
    }
    CMPVideoSelectView *videoSelectView = [CMPVideoSelectView.alloc initWithFrame:CGRectMake(x, y, w, h)];
    videoSelectView.msgModel = msgModel;
    videoSelectView.url = url;
    videoSelectView.vc = fromVc;
    videoSelectView.from = from;
    videoSelectView.fromType = fromType;
    videoSelectView.fileId = fileId.copy;
    videoSelectView.fileName = fileName;
    [videoSelectView setCanNotShare:canNotShare canNotCollect:canNotCollect canNotSave:canNotSave isUc:isUc];
    vc.showingView = videoSelectView;
    popoverWindow_.rootViewController = vc;
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(vc) weakVc = vc;
    videoSelectView.cancelClicked = ^{
        [weakVc hideShowingView];
        [weakSelf hideWindowWithAnimation];
    };
    vc.viewClicked = ^(BOOL hasAnimation) {
        if (hasAnimation) {
            //有动画时，动画消失window
            [weakSelf hideWindowWithAnimation];
        }else {
            //没有动画
            [weakSelf hideWindowWithoutAnimation];
        }
        
    };
    
    [UIView animateWithDuration:CMPShowingViewTimeInterval animations:^{
        popoverWindow_.backgroundColor = [[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0.5f];
    }];
}

/// 显示分享完致信后的提示页面
- (void)showShareToUCFinishedViewWithVc:(UIViewController *)vc {
    [self initialiseWindow];
    CMPPopoverViewController *popoverVC = CMPPopoverViewController.alloc.init;
    CGFloat w = 315.f;
    CGFloat h = 218.f;
    CMPShareToUCFinishedTipsView *view = [[CMPShareToUCFinishedTipsView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    view.center = CGPointMake(CMP_SCREEN_WIDTH/2.f, CMP_SCREEN_HEIGHT/2.f);
    popoverVC.showingView = view;
    __weak typeof(self) weakSelf = self;
    
    view.backToFormerClicked = ^{
        [weakSelf hideWindowWithoutAnimation];
        if (vc.navigationController.childViewControllers.count == 1) {
            [vc.navigationController dismissViewControllerAnimated:YES completion:nil];
        }else {
            [vc.navigationController popViewControllerAnimated:YES];
        }
    };
    
    popoverWindow_.rootViewController = popoverVC;
    popoverVC.viewClicked = ^(BOOL hasAnimation) {
        if (hasAnimation) {
            //有动画时，动画消失window
            [weakSelf hideWindowWithAnimation];
        }else {
            //没有动画
            [weakSelf hideWindowWithoutAnimation];
        }
        
    };
    
    [UIView animateWithDuration:CMPPopoverShowingViewTimeInterval animations:^{
        popoverWindow_.backgroundColor = [[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0.5f];
    }];
}

@end
