//
//  CMPFontProvider.h
//  CMPLib
//
//  Created by 程昆 on 2018/12/25.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "CMPObject.h"

#define kMinStandardFont [CMPFontProvider currentMinStandardFont]
#define kStandardFont    [CMPFontProvider currentStandardFont]
#define kStandardOneFont [CMPFontProvider currentStandardOneFont]
#define kStandardTwoFont [CMPFontProvider currentStandardTwoFont]
#define kStandardThreeFont [CMPFontProvider currentStandardThreeFont]
#define KMinStandardFontSize 12.0f

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const MinStandardFontChanged;

extern NSString * const MinStandardFontKey;

@interface CMPFontProvider : CMPObject


/**
 设置辅助性文字字体大小

 @param size 辅助性文字字体大小
 */
+(void)setMinStandardFont:(CGFloat)size;

/**
 删除用户字体设置

 @param serverID 服务器ID
 @param userID 用户ID
 */
+(void)deleteFontSettingWithServerID:(NSString *)serverID userID:(NSString *)userID;

/**
 返回辅助性性文字/标签文字字体大小

 @return 辅助性性文字/标签文字字体大小
 */
+(CGFloat)currentMinStandardFont;

/**
 返回正文/说明/小按钮文字字体大小

 @return 正文/说明/小按钮文字字体大小
 */
+(CGFloat)currentStandardFont;

/**
 返回列表标题/按钮文字字体大小

 @return 列表标题/按钮文字字体大小
 */
+(CGFloat)currentStandardOneFont;

/**
 返回大标题/list大文字字体大小

 @return 大标题/list大文字字体大小
 */
+(CGFloat)currentStandardTwoFont;

/**
 返回头部标题/list大文字字体大小
 
 @return 头部标题/list大文字字体大小
 */
+(CGFloat)currentStandardThreeFont;

@end

NS_ASSUME_NONNULL_END
