//
//  UIButton+RTL.m
//  CMPLib
//
//  Created by 程昆 on 2019/9/5.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "UIButton+RTL.h"
#import "UIView+RTL.h"

@implementation UIButton (RTL)

+ (void)load
{
    SOSwizzleInstanceMethod(self, @selector(setContentEdgeInsets:), @selector(rtl_setContentEdgeInsets:));
    SOSwizzleInstanceMethod(self, @selector(setImageEdgeInsets:), @selector(rtl_setImageEdgeInsets:));
    SOSwizzleInstanceMethod(self, @selector(setTitleEdgeInsets:), @selector(rtl_setTitleEdgeInsets:));
}

- (void)rtl_setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    [self rtl_setContentEdgeInsets:[UIView rtl_EdgeInsetsWithInsets:contentEdgeInsets]];
}

- (void)rtl_setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    [self rtl_setImageEdgeInsets:[UIView rtl_EdgeInsetsWithInsets:imageEdgeInsets]];
}

- (void)rtl_setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    [self rtl_setTitleEdgeInsets:[UIView rtl_EdgeInsetsWithInsets:titleEdgeInsets]];
}

@end
