//
//  MegFaceEEConfig.h
//  MegFaceEE
//
//  Created by Megvii on 2023/1/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MegFaceEEError;
@class MegFaceEENotification;
@class MegFaceEEVerifyResult;
@class MegFaceEEOTPResult;

typedef NS_ENUM(NSUInteger, MegFaceEECredentialType) {
    MegFaceEECredentialTypeFace = 1,
    MegFaceEECredentialTypeFastPass,
    MegFaceEECredentialTypeFaceidOTP
};

typedef NS_ENUM(NSUInteger, MegFaceEELanguageType) {
    MegFaceEELanguageTypeCh,
    MegFaceEELanguageTypeEn
};

typedef void(^MegFaceEEVerificationSuccess)(MegFaceEEVerifyResult *_Nullable verifyResult);

typedef void(^MegFaceEEScanExitCompletion)(void);
typedef void(^MegFaceEEScanExit)(MegFaceEEScanExitCompletion exitCompletion);
typedef void(^MegFaceEEScanCompletion)(NSString *qrCode, MegFaceEEScanExit toExit);

typedef void(^MegFaceEENotificationSuccess)(NSArray<MegFaceEENotification *> *notifications);

typedef void(^MegFaceEEGetFaceIdOTPCompletion)(MegFaceEEOTPResult *otpResult);

typedef void(^MegFaceEECommonFailed)(MegFaceEEError *error);
typedef void(^MegFaceEECommonSuccess)(void);

typedef void(^MegFaceEEVerificationPageSuccess)(MegFaceEEVerifyResult *_Nullable verifyResult, UIViewController *_Nullable triggerVC);
typedef void(^MegFaceEEPageFailed) (MegFaceEEError *error, UIViewController *_Nullable triggerVC);
typedef void(^MegFaceEEPageSuccess)(UIViewController *triggerVC);
typedef void(^MegFaceEEVerificationProcessSuccess)(MegFaceEEVerifyResult *_Nullable verifyResult, UIViewController *_Nullable triggerVC, NSString *verifyToken);

@class MegFaceEEManager;
typedef void(^MegFaceEEContinueBlock)(UIViewController *vc);
typedef void(^MegFaceEEExitBlock)(void);
typedef void(^MegFaceEEStartFaceDetectBlock)(UIViewController *vc, MegFaceEEManager *manager, MegFaceEEContinueBlock, MegFaceEEExitBlock);

NS_ASSUME_NONNULL_END
