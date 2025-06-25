//
//  TouchIDPlugin.h
//  CMPCore
//
//  Created by youlin on 16/7/14.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPLocalAuthenticationPlugin : CDVPlugin

/**
 调用生物特征识别认证身份
 @param fallbackTitle fallback按钮标题
 @return
 Error:
 CMPLocalAuthenticationErrorFallback = 0, // 用户点击fallbcak按钮
 CMPLocalAuthenticationErrorParamsIllegal = 1, // 参数错误
 CMPLocalAuthenticationErrorBiometryNotAvailable = 2, // 识别硬件不可用
 CMPLocalAuthenticationErrorVerifyFail = 3, // 识别错误
 CMPLocalAuthenticationErrorNotEnrolled = 4, // 没有设置Touch ID、Face ID
 CMPLocalAuthenticationErrorCanceled = 5, // 用户点击取消
 CMPLocalAuthenticationErrorLocked = 6, // 识别被锁定
 CMPLocalAuthenticationErrorUnkown = 7, // 其它错误
 */
- (void)verify:(CDVInvokedUrlCommand *)command;

/**
 获取设备支持的硬件类型

 @return
 CMPLocalAuthenticationTypeNone = 0, // 没有生物特征识别硬件
 CMPLocalAuthenticationTypeTouchID = 1 << 0, // 支持指纹
 CMPLocalAuthenticationTypeFaceID = 1 << 1, // 支持面容
 */
- (void)supportType:(CDVInvokedUrlCommand *)command;

/**
 设置生物识别模块开关，登录，工资条

 @param  {"faceID":{"login":1,"salary":1},"touchID":{"login":1,"salary":1}}
 */
- (void)setLocalAuthenticationState:(CDVInvokedUrlCommand *)command;

/**
 获取生物识别模块开关，登录，工资条

 @param command {"faceID":{"login":1,"salary":1},"touchID":{"login":1,"salary":1}}
 */
- (void)getLocalAuthenticationState:(CDVInvokedUrlCommand *)command;

/**
 获取用户有没有设置 指纹、人脸

 @param command
 */
- (void)getEnrolledState:(CDVInvokedUrlCommand *)command;

@end
