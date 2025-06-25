//
//  NSObject+CMPHUDView.h
//  CMPLib
//
//  Created by CRMO on 2018/11/5.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CMPHUDView)

- (void)cmp_showHUDError:(NSError *)error;

/**
 在指定View上用HUD展示提示信息
 1秒后自动隐藏
 
 @param aStr 需要展示的提示文案
 */
- (void)cmp_showHUDWithText:(NSString *)aStr inView:(UIView *)view;

/**
 在当前keyWindow上用HUD展示提示信息
 1秒后自动隐藏
 
 @param aStr 需要展示的提示文案
 */
- (void)cmp_showHUDWithText:(NSString *)aStr;

/**
 在当前keyWindow上用HUD展示提示信息
 1秒后自动隐藏
 
 @param aStr 需要展示的提示文案
 @param completionBlock 文案隐藏过后的回调
 */
- (void)cmp_showHUDWithText:(NSString *)aStr completionBlock:(MBProgressHUDCompletionBlock)completionBlock;

/**
 在指定View上显示loading框
 需要手动调用cmp_hideProgressHUD隐藏
 */
- (void)cmp_showProgressHUDInView:(UIView *)view;
//yOffset 上下偏移
- (void)cmp_showProgressHUDInView:(UIView *)view yOffset:(CGFloat)yOffset;

/**
 在当前keyWindow上显示loading框
 需要手动调用cmp_hideProgressHUD隐藏
 */
- (void)cmp_showProgressHUD;

/**
 在指定View上显示指定文字loading框
 需要手动调用cmp_hideProgressHUD隐藏
 */
- (void)cmp_showProgressHUDWithText:(NSString *)aStr inView:(UIView *)view;

/**
 在当前keyWindow上显示指定文字loading框
 需要手动调用cmp_hideProgressHUD隐藏
 */
- (void)cmp_showProgressHUDWithText:(NSString *)aStr;

/**
 隐藏当前keyWindow上loading框
 */
- (void)cmp_hideProgressHUD;

/**
隐藏当前keyWindow上loading框,completionBlock隐藏动画完成执行
*/
- (void)cmp_hideProgressHUDWithCompletionBlock:(MBProgressHUDCompletionBlock __nullable)completionBlock;

/**
 展示成功提示框
 */
- (void)cmp_showSuccessHUDInView:(UIView *)view;

/**
展示成功提示框
completionBlock 提示框消失后回调
*/
- (void)cmp_showSuccessHUDInView:(UIView *)view completionBlock:(MBProgressHUDCompletionBlock __nullable)completionBlock;

/**
展示成功提示框
completionBlock 提示框消失后回调
*/
- (void)cmp_showSuccessHUD;
- (void)cmp_showSuccessHUDWithCompletionBlock:(MBProgressHUDCompletionBlock __nullable)completionBlock;
- (void)cmp_showSuccessHUDWithText:(NSString *)text;
- (void)cmp_showSuccessHUDWithText:(NSString *)text completionBlock:(MBProgressHUDCompletionBlock)completionBlock;

- (void)cmp_showHUDToBottomWithText:(NSString *)aStr;
@end

NS_ASSUME_NONNULL_END
