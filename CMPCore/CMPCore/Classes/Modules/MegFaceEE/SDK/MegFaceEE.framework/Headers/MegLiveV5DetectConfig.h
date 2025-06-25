//
//  MegLiveV5DetectConfig.h
//  MegLiveV5Detect
//
//  Created by MegviiDev on 2021/10/15.
//

#ifndef MegLiveV5DetectConfig_h
#define MegLiveV5DetectConfig_h
@class MegLiveV5DetectError;

//  活体检测配置类型，默认为`MegLiveV5DetectSignTypeScene`
typedef enum : NSUInteger {
    MegLiveV5DetectSignTypeScene        = 0,  //  使用场景ID
    MegLiveV5DetectSignTypeToken        = 1,  //  使用token
} MegLiveV5DetectSignType;

//  活体检测语言类型，默认值为`MegLiveV5DetectLanguageTypeCh`
typedef enum : NSUInteger {
    MegLiveV5DetectLanguageTypeCh           =  0,  //  中文
    MegLiveV5DetectLanguageTypeEn           =  1,  //  英文
} MegLiveV5DetectLanguageType;

//  活体检测设备垂直检测类型，默认值为`MegLiveV5DetectPhoneVerticalTypeFront2`
typedef enum : NSUInteger {
    MegLiveV5DetectPhoneVerticalTypeContinue          =  1,  //  启用设备垂直检测
    MegLiveV5DetectPhoneVerticalTypeFront2            =  2,  //  仅在检测开启的2秒内启用，之后关闭该功能
    MegLiveV5DetectPhoneVerticalTypeDisable           =  3,  //  禁用设备垂直检测
} MegLiveV5DetectPhoneVerticalType;

//  活体检测错误类型
typedef enum : NSUInteger {
    MegLiveV5DetectErrorTypeOK                                = 1000,
    MegLiveV5DetectErrorTypeBizTokenDenied                    = 1001,
    MegLiveV5DetectErrorTypeIllegalParameter                  = 1002,
    MegLiveV5DetectErrorTypeAuthenticationFail                = 1003,
    MegLiveV5DetectErrorTypeMobileNotSupport                  = 1004,
    MegLiveV5DetectErrorTypeNullPointException                = 1005,
    MegLiveV5DetectErrorTypeRequestFrequently                 = 1006,
    MegLiveV5DetectErrorTypeNetworkTimeout                    = 1007,
    MegLiveV5DetectErrorTypeInternalError                     = 1008,
    MegLiveV5DetectErrorTypeInvalidBundleID                   = 1009,
    MegLiveV5DetectErrorTypeNetworkError                      = 1010,
    MegLiveV5DetectErrorTypeUserCancel                        = 1011,
    MegLiveV5DetectErrorTypeNoCameraPermission                = 1012,
    MegLiveV5DetectErrorTypeNoCameraSupport                   = 1013,
    MegLiveV5DetectErrorTypeFaceInitFail                      = 1014,
    MegLiveV5DetectErrorTypeLivenessFailure                   = 1016,
    MegLiveV5DetectErrorTypeGotoBackground                    = 1017,
    MegLiveV5DetectErrorTypeLivenessTimeout                   = 1018,
    MegLiveV5DetectErrorTypeDataUploadFail                    = 1019,
} MegLiveV5DetectErrorType;


typedef void(^MegLiveV5StartDetectBlock)(MegLiveV5DetectError* error, NSDictionary* extraOutDict);
typedef void(^MegLiveV5EndDetectBlock)(MegLiveV5DetectError* error, NSString* bizTokenStr, NSDictionary* extraOutDict);
typedef void(^MegLiveV5DismissBlock)(void);

#endif /* MegLiveV5DetectConfig_h */
