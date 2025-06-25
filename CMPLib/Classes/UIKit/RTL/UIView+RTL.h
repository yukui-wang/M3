//
//  UIView+RTL.h
//  M3
//
//  Created by 程昆 on 2019/9/2.
//

#import <UIKit/UIKit.h>
#import <CMPLib/SOSwizzle.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (RTL)

+ (BOOL)isRTL;

- (void)resetFrameToFitRTL;
- (void)resetFrameToFitRTLWithSuperViewWidth:(CGFloat)width;
+ (UIEdgeInsets)rtl_EdgeInsetsWithInsets:(UIEdgeInsets)insets;

@end

NS_ASSUME_NONNULL_END
