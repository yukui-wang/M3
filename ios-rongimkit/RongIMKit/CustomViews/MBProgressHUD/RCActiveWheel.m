//
//  RCActiveWheel.m
//  RongIMKit
//
//  Created by Zhaoqianyu on 2018/5/12.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCActiveWheel.h"

@interface RCActiveWheel ()
@property (nonatomic) BOOL *ptimeoutFlag;
@end

@implementation RCActiveWheel

- (id)initWithView:(UIView *)view {
    self = [super initWithView:view];
    if (self) {
        self.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.tintColor = [UIColor blackColor];
    }
    return self;
}

- (id)initWithWindow:(UIWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    self.processString = nil;
}

+ (RCActiveWheel *)showHUDAddedTo:(UIView *)view {
    RCActiveWheel *hud = [[RCActiveWheel alloc] initWithView:view];
    hud.contentColor = [UIColor whiteColor];
    [view addSubview:hud];
    [hud showAnimated:YES];
    return hud;
}

+ (void)showPromptHUDAddedTo:(UIView *)view text:(NSString *)text {
    RCActiveWheel *hud = [RCActiveWheel showHUDAddedTo:view];
    hud.mode = RCMBProgressHUDModeText;
    hud.detailsLabel.text = text;
    hud.detailsLabel.textColor = [UIColor whiteColor];

    [hud hideAnimated:YES afterDelay:2.0f];
}

+ (void)dismissForView:(UIView *)view {
    RCMBProgressHUD *hud = [super HUDForView:view];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES];
}

+ (void)dismissViewDelay:(NSTimeInterval)interval forView:(UIView *)view warningText:(NSString *)text;
{
    RCActiveWheel *wheel = (RCActiveWheel *)[super HUDForView:view];
    ;
    [wheel performSelector:@selector(setWarningString:) withObject:text afterDelay:0];
    [RCActiveWheel performSelector:@selector(dismissForView:) withObject:view afterDelay:interval];
}

+ (void)dismissViewDelay:(NSTimeInterval)interval forView:(UIView *)view processText:(NSString *)text {
    RCActiveWheel *wheel = (RCActiveWheel *)[super HUDForView:view];
    ;
    wheel.processString = text;
    [RCActiveWheel performSelector:@selector(dismissForView:) withObject:view afterDelay:interval];
}

+ (void)dismissForView:(UIView *)view delay:(NSTimeInterval)interval {
    [RCActiveWheel performSelector:@selector(dismissForView:) withObject:view afterDelay:interval];
}

- (void)setProcessString:(NSString *)processString {
    // self.labelColor = [UIColor colorWithRed:219/255.0f green:78/255.0f blue:32/255.0f alpha:1];
    self.label.text = processString;
}

- (void)setWarningString:(NSString *)warningString {
    self.label.textColor = [UIColor redColor];
    self.label.text = warningString;
}

+ (void)hidePromptHUDDelay:(UIView *)view text:(NSString *)text {
    RCActiveWheel *wheel = (RCActiveWheel *)[super HUDForView:view];
    //  hud.square = YES;
    wheel.mode = RCMBProgressHUDModeText;
    wheel.label.text = nil;
    wheel.detailsLabel.text = text;
    wheel.detailsLabel.textColor = [UIColor whiteColor];
    [wheel hideAnimated:YES afterDelay:2.0f];
}

@end
