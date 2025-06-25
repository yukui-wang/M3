//
//  UIView+RTL.m
//  M3
//
//  Created by 程昆 on 2019/9/2.
//

#import "UIView+RTL.h"
#import "SOLocalization.h"

@implementation UIView (RTL)


+ (BOOL)isRTL {
    if ([[SOLocalization staticLocalization].region isEqualToString:SOLocalizationArbic]) {
        return YES;
    }
    return NO;
}


- (void)setRTLFrame:(CGRect)frame width:(CGFloat)width {
    if ([UIView isRTL]) {
        if (self.superview == nil) {
            NSLog(@"RTL-must invoke after have superView");
            return;
        }
        CGFloat x = width - frame.origin.x - frame.size.width;
        frame.origin.x = x;
    }
    self.frame = frame;
}

- (void)setRTLFrame:(CGRect)frame {
    [self setRTLFrame:frame width:self.superview.frame.size.width];
}

- (void)resetFrameToFitRTL {
    if ([UIView isRTL]) {
        [self setRTLFrame:self.frame];
    }
}

- (void)resetFrameToFitRTLWithSuperViewWidth:(CGFloat)width{
    if ([UIView isRTL]) {
        if ([UIView isRTL]) {
            if (self.superview == nil) {
                NSLog(@"RTL-must invoke after have superView");
                return;
            }
            CGRect frame = self.frame;
            CGFloat x = width - frame.origin.x - frame.size.width;
            frame.origin.x = x;
            self.frame = frame;
        }
    }
}

+ (UIEdgeInsets)rtl_EdgeInsetsWithInsets:(UIEdgeInsets)insets {
    if (insets.left != insets.right && [self isRTL]) {
        CGFloat temp = insets.left;
        insets.left = insets.right;
        insets.right = temp;
    }
    return insets;
}

@end
