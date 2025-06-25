//
//  CMPFaceConstant.h
//  M3
//
//  Created by Shoujian Rao on 2023/9/20.
//

#ifndef CMPFaceConstant_h
#define CMPFaceConstant_h

#define LocalString(key) NSLocalizedStringFromTable(key, @"CMPFaceLocalization", nil)

#define kFaceEEDomain @"seeyoncloudv5test"
//#define kFaceEENetworkHost @"https://faceid.seeyoncloud.com"
#define kClientId @"BM9rifoCWbM6_bEUlpuAoqpwpbWL4cx5"
#define kClientSecret @"L_4PJU6Qf6dA4401rgOYdHmJEZ3rWVJh"

//#define kClientId @"02B4ECCF5C1445B1A1F753CEA43E3AE6"
//#define kClientSecret @"BDD75A1530144942971BF087FA3D10CE"

#define kFaceEEAlgorithm @"FACEEE-HMAC-SHA256"


#define kFaceEEBoundsRect self.view.bounds
#define kFaceEEBoundsSize kFaceEEBoundsRect.size
#define kFaceEEBoundsWidth kFaceEEBoundsSize.width
#define kFaceEEBoundsHeight kFaceEEBoundsSize.height

#define kFaceEEiOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define kFaceEEColorWithRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kFaceEENSHeight     (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)

#define kFaceEEIsIPhoneX  \
    ({BOOL isPhoneX = NO;\
        if (@available(iOS 11.0, *)) {\
            isPhoneX = [[UIApplication sharedApplication] statusBarFrame].size.height > 20.0;\
        }\
    (isPhoneX);})

#define kFaceEEIsIPhoneIsland  \
    ({BOOL isPhoneX = NO;\
        if (@available(iOS 11.0, *)) {\
            isPhoneX = ([[UIApplication sharedApplication] statusBarFrame].size.height > 50.0);\
        }\
    (isPhoneX);})

//64, 118, 245
#define kFaceEEBlueColor [UIColor colorWithRed:0.25 green:0.46 blue:0.96 alpha:1]

//60, 111, 230
#define kFaceEEHighlightBlueColor [UIColor colorWithRed:0.24 green:0.44 blue:0.9 alpha:1]

//88, 91, 102
#define kFaceEELightBlackColor [UIColor colorWithRed:0.35 green:0.36 blue:0.4 alpha:1]

//46, 50, 64
#define kFaceEEBlackColor [UIColor colorWithRed:0.18 green:0.2 blue:0.25 alpha:1]

#define kFaceEEPinAdd @"FaceEEPinAdd"

#define kFaceEEVersion @"1.9.12"
#define kFaceEEOS @"ios"
#define kFaceEEType @"app"
#define kFaceEEBizNo @"1234567"
#define kFaceEEApiVersion @"v1"

#define kFaceEENotifyId @"FaceEENotifyId"

#define kFaceEENotificationOpenURL @"kFaceEENotificationOpenURL"

#define kFaceEELifetimeSeconds @"lifetime_seconds"
#define kFaceEEOfflineExpireIn @"expires_in"

#ifdef DEBUG
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...)
#endif

#define kOtpSizeScale frame.size.width/375
//64, 118, 245
#define kOtpBlueColor [UIColor colorWithRed:0.25 green:0.46 blue:0.96 alpha:1.0]
//253, 77, 77
#define kOtpRedColor [UIColor colorWithRed:0.99 green:0.30 blue:0.30 alpha:1.0]
//255, 132, 132
#define kOtpRedFlashColor [UIColor colorWithRed:1 green:0.52 blue:0.52 alpha:1.0]

#define kFaceEESmallBounds CGRectMake(0, 0, 8, 8)
#define kFaceEEBigBounds CGRectMake(0, 0, 16, 16)
#define kFaceEEPosition CGPointMake(CGRectGetWidth(_numLab.frame)/2.0, CGRectGetHeight(_numLab.frame)/2.0)
#define kFaceEESmallRadius 4
#define kFaceEEBigRadius 8
#define kFaceEEDotDistance 3

#define kFaceEEAgreementPrivacyURL @"https://bj-faceid-prod-asset.oss-cn-beijing.aliyuncs.com/faceid-enterprise-doc/faceid-agreement.html"
#define kFaceEEAgreementPrivacyURLEn @"https://bj-faceid-test-asset.oss-cn-beijing.aliyuncs.com/faceid-enterprise-doc/faceid-agreement-en.html"
#define kFaceEEAgreementUserURL @"https://bj-faceid-prod-asset.oss-cn-beijing.aliyuncs.com/faceid-enterprise-doc/usage-agreement.html"
#define kFaceEEAgreementUserURLEn @"https://bj-faceid-test-asset.oss-cn-beijing.aliyuncs.com/faceid-enterprise-doc/usage-agreement-en.html"

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

#endif /* CMPFaceConstant_h */
