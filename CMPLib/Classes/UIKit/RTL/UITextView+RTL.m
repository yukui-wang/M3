//
//  UITextView+RTL.m
//  CMPLib
//
//  Created by 程昆 on 2019/9/5.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "UITextView+RTL.h"
#import "UIView+RTL.h"

@implementation UITextView (RTL)

+ (void)load {
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
