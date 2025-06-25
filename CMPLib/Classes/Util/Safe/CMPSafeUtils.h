//
//  CMPSafeUtils.h
//  CMPLib
//
//  Created by youlin on 2017/9/12.
//  Copyright © 2017年 CMPCore. All rights reserved.
//

#import "CMPObject.h"

typedef void(^CMPDidScreenCapture)(void);
typedef void(^CMPDidScreenShot)(void);

@interface CMPSafeUtils : CMPObject

/**
 获取安全管理单例
 */
+ (instancetype)sharedInstance;

/**
 开启后台模糊效果
 */
- (void)startBackgroundBlur;

/**
 注册录屏、投屏通知
 仅iOS 11后有效

 @param block 开始录屏、投屏会调用block
 */
- (void)observeScreenCapture:(CMPDidScreenCapture)block;

/**
 注册截屏通知

 @param block 用户截屏会调用block
 */
- (void)observeScreenShot:(CMPDidScreenShot)block;

/**
 判断该设备是否越狱
 */
+ (BOOL)isJailbreak;

/**
 检查是否开启了代理
 */
+ (BOOL)checkHTTPEnable;

/**
 是否正在录屏、投屏
 仅iOS 11后有效
 */
+ (BOOL)isScreenCapture;

/**
 检测应用包名是否被修改
 */
+ (BOOL)checkBundleID;

/**
 检查代码段的MD5值是否发生变化
 */
+ (BOOL)checkCodeMD5;

/**
 开启反调试
 */
- (void)startAntiDebug;

@end
