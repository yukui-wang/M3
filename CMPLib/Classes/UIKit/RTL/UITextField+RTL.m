//
//  UITextField+RTL.m
//  M3
//
//  Created by 程昆 on 2019/9/2.
//

#import "UITextField+RTL.h"
#import "UIView+RTL.h"

@implementation UITextField (RTL)

+ (void)load {
    SOSwizzleInstanceMethod(self, @selector(setRightView:), @selector(rtl_setRightView:));
    SOSwizzleInstanceMethod(self, @selector(setLeftView:), @selector(rtl_setLeftView:));
    SOSwizzleInstanceMethod(self, @selector(setRightViewMode:), @selector(rtl_setRightViewMode:));
    SOSwizzleInstanceMethod(self, @selector(setLeftViewMode:), @selector(rtl_setLeftViewMode:));
    SOSwizzleInstanceMethod(self, @selector(initWithFrame:), @selector(rtl_initWithFrame:));
    SOSwizzleInstanceMethod(self, @selector(setTextAlignment:), @selector(rtl_setTextAlignment:));
}

- (void)rtl_setRightView:(UIView *)view {
    if ([UIView isRTL] && ![self isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
        [self rtl_setLeftView:view];
    } else {
        [self rtl_setRightView:view];
    }
}

- (void)rtl_setLeftView:(UIView *)view {
    if ([UIView isRTL] && ![self isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
        [self rtl_setRightView:view];
    } else {
        [self rtl_setLeftView:view];
    }
}

- (void)rtl_setRightViewMode:(UITextFieldViewMode)model {
    if ([UIView isRTL] && ![self isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
        [self rtl_setLeftViewMode:model];
    } else {
        [self rtl_setRightViewMode:model];
    }
}

- (void)rtl_setLeftViewMode:(UITextFieldViewMode)model {
    if ([UIView isRTL] && ![self isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
        [self rtl_setRightViewMode:model];
    } else {
        [self rtl_setLeftViewMode:model];
    }
}

- (instancetype)rtl_initWithFrame:(CGRect)frame
{
    if ([self rtl_initWithFrame:frame]) {
        self.textAlignment = NSTextAlignmentNatural;
    }
    return self;
}

- (void)rtl_setTextAlignment:(NSTextAlignment)textAlignment
{
    if ([UIView isRTL]) {
        if (textAlignment == NSTextAlignmentNatural || textAlignment == NSTextAlignmentLeft) {
            textAlignment = NSTextAlignmentRight;
        } else if (textAlignment == NSTextAlignmentRight) {
            textAlignment = NSTextAlignmentLeft;
        }
    }
    [self rtl_setTextAlignment:textAlignment];
}

@end
