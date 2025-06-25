//
//  UILabel+RTL.m
//  M3
//
//  Created by 程昆 on 2019/9/2.
//

#import "UILabel+RTL.h"
#import "UIView+RTL.h"

@implementation UILabel (RTL)

+ (void)load
{
    SOSwizzleInstanceMethod(self, @selector(initWithFrame:), @selector(rtl_initWithFrame:));
    SOSwizzleInstanceMethod(self, @selector(setTextAlignment:), @selector(rtl_setTextAlignment:));
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
    if ([UIView isRTL] && ![self isKindOfClass:NSClassFromString(@"UITextFieldLabel")]) {
        if (textAlignment == NSTextAlignmentNatural || textAlignment == NSTextAlignmentLeft) {
            textAlignment = NSTextAlignmentRight;
        } else if (textAlignment == NSTextAlignmentRight) {
            textAlignment = NSTextAlignmentLeft;
        }
    }
    [self rtl_setTextAlignment:textAlignment];
}


@end
