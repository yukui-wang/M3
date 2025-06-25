//
//  RCExtensionUtility.h
//  RongExtensionKit
//
//  Created by 岑裕 on 2016/10/12.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RCExtensionUtility : NSObject

/*!
 获取文字显示的尺寸

 @param text            文字
 @param font            字体
 @param constrainedSize 文字显示的容器大小

 @return 文字显示的尺寸

 @discussion 该方法在计算iOS 7以下系统显示的时候默认使用NSLineBreakByTruncatingTail模式。
 */
+ (CGSize)getTextDrawingSize:(NSString *)text font:(UIFont *)font constrainedSize:(CGSize)constrainedSize;

/*!
 获取文件消息中消息类型对应的图片名称

 @param fileType    文件类型
 @return            图片名称
 */
+ (NSString *)getFileTypeIcon:(NSString *)fileType;

/*!
 获取资源包中的图片

 @param name        图片名
 @param bundleName  图片所在的Bundle名
 @return            图片
 */
+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName;

/**
 获取RCColor.plist文件中色值

 @param key 色值对应的key
 @param colorStr 原始颜色
 @return 最终返回的颜色
 */
+ (UIColor *)color:(NSString *)key originalColor:(NSString *)colorStr;

+ (NSString *)getPinYinUpperFirstLetters:(NSString *)hanZi;

+ (BOOL)showProgressViewFor:(UIView *)view text:(NSString *)text animated:(BOOL)animated;

+ (BOOL)hideProgressViewFor:(UIView *)view animated:(BOOL)animated;

/**
获取 keyWindow

@return UIWindow
*/
+ (UIWindow *)getKeyWindow;

/**
 获取当前 window 的 safeAreaInsets

 @return 当前 window 的 safeAreaInsets
 */
+ (UIEdgeInsets)getWindowSafeAreaInsets;

/**
动态颜色设置

 @param lightColor  亮色
 @param darkColor  暗色
 @return 修正后的图片
*/
+ (UIColor *)generateDynamicColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;

@end
