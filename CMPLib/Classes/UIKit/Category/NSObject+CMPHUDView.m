//
//  NSObject+CMPHUDView.m
//  CMPLib
//
//  Created by CRMO on 2018/11/5.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "NSObject+CMPHUDView.h"
#import "CMPLoadingView.h"
#import "CMPConstant.h"
#import "NSObject+Thread.h"
#import "CMPLoadSuccessView.h"
#import "CMPThemeManager.h"

static NSString *bottomHudKey = @"bottomHudKey";

@implementation NSObject (CMPHUDView)

- (void)cmp_showHUDError:(NSError *)error{
    [self cmp_showHUDWithText:error.domain inView:[self defaultShowInView]];
}

- (void)cmp_showHUDWithText:(NSString *)aStr inView:(UIView *)view completionBlock:(MBProgressHUDCompletionBlock)completionBlock {
    if ([NSString isNull:aStr]) {
        //空就不显示了
        return;
    }
    [self cmp_hideProgressHUD];
    [self dispatchAsyncToMain:^{
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.color = [UIColor cmp_colorWithName:@"dark-bgc"];
        hud.labelColor = [UIColor cmp_colorWithName:@"reverse-fc"];
        hud.detailsLabelText = aStr;
        hud.detailsLabelFont = [UIFont systemFontOfSize:16];
        hud.completionBlock = completionBlock;
        [hud show:YES];
        objc_setAssociatedObject(self, @selector(cmp_showProgressHUD), hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [hud hide:YES];
            if ([view isMemberOfClass:[UIWindow class]]) {
                [(UIWindow *)view resignKeyWindow];
            }
            objc_setAssociatedObject(self, @selector(cmp_showProgressHUD), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        });
    }];
}

- (UIView *)defaultShowInView {
    UIView *view = [UIApplication sharedApplication].delegate.window;
    return view;
}

- (void)cmp_showHUDWithText:(NSString *)aStr completionBlock:(MBProgressHUDCompletionBlock) completionBlock {
    [self cmp_showHUDWithText:aStr inView:[self defaultShowInView] completionBlock:completionBlock];
}

- (void)cmp_showHUDWithText:(NSString *)aStr {
    [self cmp_showHUDWithText:aStr inView:[self defaultShowInView]];
}

- (void)cmp_showHUDToBottomWithText:(NSString *)aStr{
//    [self cmp_showHUDWithText:aStr inView:[self defaultShowInView]];
    if ([NSString isNull:aStr]) {
        return;
    }
//    [self cmp_hideProgressHUD];
    UIView *view = [self defaultShowInView];
    [self dispatchAsyncToMain:^{
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        hud.yOffset = (view.height - 160)/2;
        hud.mode = MBProgressHUDModeText;
        hud.color = [UIColor cmp_colorWithName:@"dark-bgc"];
        hud.labelColor = [UIColor cmp_colorWithName:@"reverse-fc"];
        hud.detailsLabelText = aStr;
        hud.detailsLabelFont = [UIFont systemFontOfSize:16];
        [hud show:YES];
        
        objc_setAssociatedObject(self, &bottomHudKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [hud hide:YES];
            if ([view isMemberOfClass:[UIWindow class]]) {
                [(UIWindow *)view resignKeyWindow];
            }
            objc_setAssociatedObject(self, &bottomHudKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        });
    }];
}

- (void)cmp_showHUDWithText:(NSString *)aStr inView:(UIView *)view {
    [self cmp_showHUDWithText:aStr inView:view completionBlock:nil];
}

- (void)cmp_showProgressHUDInView:(UIView *)view {
    [self cmp_showProgressHUDWithText:SY_STRING(@"common_table_loading") inView:view];
}
- (void)cmp_showProgressHUDInView:(UIView *)view yOffset:(CGFloat)yOffset {
    [self cmp_showProgressHUDWithText:SY_STRING(@"common_table_loading") inView:view yOffset:yOffset];
}

- (void)cmp_showProgressHUDWithText:(NSString *)aStr inView:(UIView *)view {
    [self cmp_showProgressHUDWithText:aStr inView:view yOffset:0];
}

- (void)cmp_showProgressHUDWithText:(NSString *)aStr inView:(UIView *)view yOffset:(CGFloat)yOffset{
    [self cmp_hideProgressHUD];
    [self dispatchAsyncToMain:^{
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[CMPLoadingView alloc] initWithFrame:CGRectMake(0, 0, 30, 42*0.8 + 10)];
        hud.labelFont = [UIFont systemFontOfSize:12];
        hud.minSize = CGSizeMake(100, 100);
        hud.color = [UIColor cmp_colorWithName:@"dark-bgc"];
        hud.labelColor = [UIColor cmp_colorWithName:@"reverse-fc"];
        hud.yOffset = yOffset;
        [hud show:YES];
        hud.labelText = aStr;
        objc_setAssociatedObject(self, @selector(cmp_showProgressHUD), hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

- (void)cmp_showProgressHUD {
    [self cmp_showProgressHUDWithText:SY_STRING(@"common_table_loading")];
}

- (void)cmp_showProgressHUDWithText:(NSString *)aStr {
    [self cmp_showProgressHUDWithText:aStr inView:[self defaultShowInView]];
}


- (void)cmp_hideProgressHUD {
    [self cmp_hideProgressHUDWithCompletionBlock:nil];
}

- (void)cmp_hideProgressHUDWithCompletionBlock:(MBProgressHUDCompletionBlock)completionBlock {
    [self dispatchAsyncToMain:^{
        MBProgressHUD *hud = objc_getAssociatedObject(self, @selector(cmp_showProgressHUD));
        if (hud) {
            hud.removeFromSuperViewOnHide = YES;
            if (completionBlock) {
                hud.completionBlock = completionBlock;
            }
            [hud hide:YES];
            objc_setAssociatedObject(self, @selector(cmp_showProgressHUD), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }];
}

- (void)cmp_showSuccessHUDWithText:(NSString *)text {
    [self cmp_showSuccessHUDInView:[self defaultShowInView] text:text completionBlock:nil];
}

- (void)cmp_showSuccessHUD {
    [self cmp_showSuccessHUDInView:[self defaultShowInView] completionBlock:nil];
}

- (void)cmp_showSuccessHUDWithText:(NSString *)text completionBlock:(MBProgressHUDCompletionBlock)completionBlock {
     [self cmp_showSuccessHUDInView:[self defaultShowInView] text:text completionBlock:completionBlock];
}

- (void)cmp_showSuccessHUDWithCompletionBlock:(MBProgressHUDCompletionBlock)completionBlock {
     [self cmp_showSuccessHUDInView:[self defaultShowInView] completionBlock:completionBlock];
}

- (void)cmp_showSuccessHUDInView:(UIView *)view {
    [self cmp_showSuccessHUDInView:view completionBlock:nil];
}

- (void)cmp_showSuccessHUDInView:(UIView *)view completionBlock:(MBProgressHUDCompletionBlock __nullable)completionBlock {
    [self cmp_showSuccessHUDInView:view text:SY_STRING(@"common_load_success") completionBlock:completionBlock];
}

- (void)cmp_showSuccessHUDInView:(UIView *)view text:(NSString *)text completionBlock:(MBProgressHUDCompletionBlock __nullable)completionBlock {
    [self dispatchAsyncToMain:^{
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[CMPLoadSuccessView alloc] initWithFrame:CGRectMake(0, 0, 42*0.8, 42*0.8 + 10)];
        hud.labelFont = [UIFont systemFontOfSize:14];
        hud.minSize = CGSizeMake(100, 100);
        hud.color = [UIColor cmp_colorWithName:@"dark-bgc"];
        hud.labelColor = [UIColor cmp_colorWithName:@"reverse-fc"];
        hud.completionBlock = completionBlock;
        [hud show:YES];
        hud.labelText = text;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [hud hide:YES];
            if ([view isMemberOfClass:[UIWindow class]]) {
                [(UIWindow *)view resignKeyWindow];
            }
        });
    }];
}

@end
