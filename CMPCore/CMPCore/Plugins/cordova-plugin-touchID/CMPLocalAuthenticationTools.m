//
//  CMPLocalAuthenticationTools.m
//  M3
//
//  Created by CRMO on 2019/1/15.
//

#import "CMPLocalAuthenticationTools.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <CMPLib/CMPAlertView.h>

NSString * const CMPLocalAuthenticationErrorDomain = @"com.seeyon.CMPLocalAuthenticationTools";

@implementation CMPLocalAuthenticationTools

+ (CMPLocalAuthenticationType)supportType {
    LAContext *context = [[LAContext alloc] init];
    CMPLocalAuthenticationType type = [[self class] _supportTypeWithContext:context];
    [context invalidate];
    return type;
}

+ (BOOL)isEnrolled {
    BOOL isEnrolled = NO;
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        isEnrolled = YES;
    } else {
        if (error.code == LAErrorPasscodeNotSet ||
            error.code == kLAErrorBiometryNotEnrolled) { // 没有设置
            CMPLocalAuthenticationType type = [[self class] _supportTypeWithContext:context];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = [[self class] _settingMessageWithType:type];
                UIAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:nil message:message cancelButtonTitle:SY_STRING(@"common_isee") otherButtonTitles:nil callback:nil];
                [aAlertView show];
            });
        }
        isEnrolled = (error.code == kLAErrorBiometryLockout);
    }
    [context invalidate];
    return isEnrolled;
}

+ (BOOL)isLocked {
    BOOL isLocked = NO;
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        if (error.code == kLAErrorBiometryLockout) {
            isLocked = YES;
        }
    }
    [context invalidate];
    return isLocked;
}

+ (BOOL)isFaceIDEnable:(LAContext *)context {
    BOOL isEnable = NO;
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        isEnable = YES;
    }
    [context invalidate];
    return isEnable;
}

+ (void)verifyUsePassCode:(BOOL)usePassCode Completion:(_Nullable CMPLocalAuthenticationCompletion)completion {
    [[self class] verifyWithFallbackTitle:@""
                              usePassCode:usePassCode
                           fallbackAction:nil
                               completion:completion];
}

+ (void)verifyWithFallbackTitle:(NSString *)fallbackTitle
                    usePassCode:(BOOL)usePassCode
                 fallbackAction:(CMPLocalAuthenticationFallbackAction)fallbackAction
                     completion:(CMPLocalAuthenticationCompletion)completion {
    [[self class] _verifyWithFallbackTitle:fallbackTitle usePassCode:usePassCode fallbackAction:fallbackAction completion:^(BOOL result, CMPLocalAuthenticationType type, NSError * _Nullable error) {
        if (completion) {
            completion(result, type, error);
        }
    }];
}

+ (void)_verifyWithFallbackTitle:(NSString *)fallbackTitle
                     usePassCode:(BOOL)usePassCode
                  fallbackAction:(CMPLocalAuthenticationFallbackAction)fallbackAction
                      completion:(CMPLocalAuthenticationCompletion)completion {
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = fallbackTitle;
    
    CMPLocalAuthenticationType type = [[self class] _supportTypeWithContext:context];
    if (type == CMPLocalAuthenticationTypeNone) {
        NSError *error = [NSError errorWithDomain:CMPLocalAuthenticationErrorDomain
                                             code:CMPLocalAuthenticationErrorBiometryNotAvailable
                                         userInfo:nil];
        if (completion) {
            completion(NO, type, error);
        }
        return;
    }
    
    NSString *reason = [[self class] _reasonWithType:type];
    NSError *aError = nil;
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&aError]) {
        // 没有权限，没有设置，提示去设置
        if (aError.code == LAErrorPasscodeNotSet ||
            aError.code == LAErrorTouchIDNotAvailable ||
            aError.code == LAErrorTouchIDNotEnrolled) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = [[self class] _settingMessageWithType:type];
                UIAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:nil message:message cancelButtonTitle:SY_STRING(@"common_isee") otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
                    if (completion) {
                        NSError *error = [NSError errorWithDomain:CMPLocalAuthenticationErrorDomain code:CMPLocalAuthenticationErrorNotEnrolled userInfo:nil];
                        completion(NO, type, error);
                    }
                }];
                [aAlertView show];
            });
        } else if (aError.code == kLAErrorBiometryLockout) {
            // 设备被锁定，自动弹出系统密码界面
            if (usePassCode) {
                [[self class] _verifyWithPasscode:context reason:reason type:type completion:completion];
            } else {
                if (completion) {
                    NSError *error = [NSError errorWithDomain:CMPLocalAuthenticationErrorDomain code:CMPLocalAuthenticationErrorLocked userInfo:nil];
                    completion(NO, type, error);
                }
            }
        }
        return;
    }
    
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            if (completion) {
                completion(success, type, nil);
            }
            return;
        }
        
        // 用户点击fallback
        if (error.code == LAErrorUserFallback) {
            if (fallbackAction) {
                fallbackAction();
            }
            return;
        }
        
        CMPLocalAuthenticationError errorCode = CMPLocalAuthenticationErrorUnkown;
        
        if (error.code == kLAErrorBiometryLockout) { // 被锁定
            errorCode = CMPLocalAuthenticationErrorLocked;
        } else if (error.code == LAErrorAuthenticationFailed) { // 识别失败
            errorCode = CMPLocalAuthenticationErrorVerifyFail;
        } else if (error.code == LAErrorPasscodeNotSet ||
                   error.code == kLAErrorBiometryNotEnrolled) { // 没有设置
            errorCode = CMPLocalAuthenticationErrorNotEnrolled;
        } else if (error.code == LAErrorAppCancel ||
                   error.code == LAErrorSystemCancel ||
                   error.code == LAErrorUserCancel) { // 用户点击取消
            errorCode = CMPLocalAuthenticationErrorCanceled;
        } else if (error.code == kLAErrorBiometryNotAvailable) {
            errorCode = CMPLocalAuthenticationErrorBiometryNotAvailable;
        }
        
        // 验证时，Face ID 连续错误5次，自动唤起系统密码界面
        if (usePassCode &&
//            type == CMPLocalAuthenticationTypeFaceID &&
//            error.code == CMPLocalAuthenticationErrorCanceled &&
            [[self class] isLocked]) {
//            NSString *reason = [[self class] _reasonWithType:CMPLocalAuthenticationTypeFaceID];
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    if (completion) {
                        completion(success, type, nil);
                    }
                    return;
                }
                
                CMPLocalAuthenticationError errorCode = CMPLocalAuthenticationErrorUnkown;
                
                if (error.code == LAErrorAppCancel ||
                    error.code == LAErrorSystemCancel ||
                    error.code == LAErrorUserCancel) { // 用户点击取消
                    errorCode = CMPLocalAuthenticationErrorCanceled;
                }
                
                if (completion) {
                    NSError *aError = [NSError errorWithDomain:CMPLocalAuthenticationErrorDomain code:errorCode userInfo:nil];
                    completion(success, type, aError);
                }
            }];
            return;
        }
        
        if (completion) {
            NSError *aError = [NSError errorWithDomain:CMPLocalAuthenticationErrorDomain code:errorCode userInfo:nil];
            completion(success, type, aError);
        }
    }];
}

#pragma mark-
#pragma mark 私有方法

+ (void)_verifyWithPasscode:(LAContext *)context
                     reason:(NSString *)reason
                       type:(CMPLocalAuthenticationType)type
                 completion:(CMPLocalAuthenticationCompletion)completion {
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            if (completion) {
                completion(success, type, nil);
            }
            return;
        }
        
        CMPLocalAuthenticationError errorCode = CMPLocalAuthenticationErrorUnkown;
        
        if (error.code == LAErrorAppCancel ||
            error.code == LAErrorSystemCancel ||
            error.code == LAErrorUserCancel) { // 用户点击取消
            errorCode = CMPLocalAuthenticationErrorCanceled;
        }
        
        if (completion) {
            NSError *aError = [NSError errorWithDomain:CMPLocalAuthenticationErrorDomain code:errorCode userInfo:nil];
            completion(success, type, aError);
        }
    }];
}

/**
 根据type获取提示用户识别的国际化文案
 */
+ (NSString *)_reasonWithType:(CMPLocalAuthenticationType)type {
    NSString *reason = nil;
    if (type == CMPLocalAuthenticationTypeTouchID) {
        reason = SY_STRING(@"touchid_verify_reason");
    } else if (type == CMPLocalAuthenticationTypeFaceID) {
        reason = SY_STRING(@"faceid_verify_reason");
    } else {
        DDLogError(@"zl---[%s]:type Error", __FUNCTION__);
    }
    return reason;
}

+ (NSString *)_lockMessageWithType:(CMPLocalAuthenticationType)type {
    NSString *reason = nil;
    if (type == CMPLocalAuthenticationTypeTouchID) {
        reason = SY_STRING(@"touchid_lock");
    } else if (type == CMPLocalAuthenticationTypeFaceID) {
        reason = SY_STRING(@"faceid_lock");
    } else {
        DDLogError(@"zl---[%s]:type Error", __FUNCTION__);
    }
    return reason;
}

+ (NSString *)_settingMessageWithType:(CMPLocalAuthenticationType)type {
    NSString *reason = nil;
    if (type == CMPLocalAuthenticationTypeTouchID) {
        reason = SY_STRING(@"touchid_unavailable");
    } else if (type == CMPLocalAuthenticationTypeFaceID) {
        reason = SY_STRING(@"faceid_unavailable");
    } else {
        DDLogError(@"zl---[%s]:type Error", __FUNCTION__);
    }
    return reason;
}

+ (CMPLocalAuthenticationType)_supportTypeWithContext:(LAContext *)context {
    CMPLocalAuthenticationType type = CMPLocalAuthenticationTypeNone;
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        type = [[self class] _typeWithContext:context];
    } else {
        if (error.code == kLAErrorBiometryNotAvailable) {
            type = CMPLocalAuthenticationTypeNone;
        } else {
            type = [[self class] _typeWithContext:context];
        }
    }
    return type;
}


+ (CMPLocalAuthenticationType)_typeWithContext:(LAContext *)context {
    CMPLocalAuthenticationType type = CMPLocalAuthenticationTypeNone;
    if (@available(iOS 11.0, *)) {
        switch (context.biometryType) {
            case LABiometryTypeTouchID:
                type = CMPLocalAuthenticationTypeTouchID;
                break;
            case LABiometryTypeFaceID:
                type = CMPLocalAuthenticationTypeFaceID;
                break;
            case LABiometryNone:
                DDLogError(@"zl---[%s]:context.biometryType error!", __FUNCTION__);
                type = CMPLocalAuthenticationTypeNone;
                break;
        }
    } else {
        // iOS 11之前只有TouchID
        type = CMPLocalAuthenticationTypeTouchID;
    }
    return type;
}


@end
