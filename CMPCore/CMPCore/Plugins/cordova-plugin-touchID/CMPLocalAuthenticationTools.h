//
//  CMPLocalAuthenticationTools.h
//  M3
//
//  Created by CRMO on 2019/1/15.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CMPLocalAuthenticationType) {
    CMPLocalAuthenticationTypeNone = 0,
    CMPLocalAuthenticationTypeTouchID = 1 << 0,
    CMPLocalAuthenticationTypeFaceID = 1 << 1,
    CMPLocalAuthenticationTypePassCode = 1 << 2,
};

typedef NS_ENUM(NSUInteger, CMPLocalAuthenticationError) {
    CMPLocalAuthenticationErrorFallback = 0, // 用户点击fallbcak按钮
    CMPLocalAuthenticationErrorParamsIllegal, // 参数错误
    CMPLocalAuthenticationErrorBiometryNotAvailable, // 识别硬件不可用
    CMPLocalAuthenticationErrorVerifyFail, // 识别错误
    CMPLocalAuthenticationErrorNotEnrolled, // 没有设置Touch ID、Face ID
    CMPLocalAuthenticationErrorCanceled, // 用户点击取消
    CMPLocalAuthenticationErrorLocked, // 识别被锁定
    CMPLocalAuthenticationErrorUnkown, // 其它错误
};

typedef void(^CMPLocalAuthenticationFallbackAction)(void);
typedef void(^CMPLocalAuthenticationCompletion)(BOOL result, CMPLocalAuthenticationType type, NSError * _Nullable error);

@interface CMPLocalAuthenticationTools : CMPObject

/**
 获取设备支持的认证方式
 */
+ (CMPLocalAuthenticationType)supportType;

/**
 用户是否设置指纹
 */
+ (BOOL)isEnrolled;

/**
 是否被锁定
 */
+ (BOOL)isLocked;

/**
 验证生物特征

 @param fallbackTitle fallback Title
 @param usePassCode 生物特征验证失败弹出锁屏密码
 @param fallbackAction fallback回调
 @param completion 回调验证结果
 */
+ (void)verifyWithFallbackTitle:(NSString *)fallbackTitle
                    usePassCode:(BOOL)usePassCode
                 fallbackAction:(_Nullable CMPLocalAuthenticationFallbackAction)fallbackAction
                     completion:(_Nullable CMPLocalAuthenticationCompletion)completion;

/**
 验证生物特征，不需要fallback操作

 @param completion 回调验证结果
 */
+ (void)verifyUsePassCode:(BOOL)usePassCode Completion:(_Nullable CMPLocalAuthenticationCompletion)completion;

@end

NS_ASSUME_NONNULL_END
