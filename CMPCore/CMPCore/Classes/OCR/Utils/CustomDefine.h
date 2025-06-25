//
//  CustomDefine.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#ifndef CustomDefine_h
#define CustomDefine_h

#import <UIKit/UIKit.h>
#import "UIView+Layer.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/UIImageView+WebCache.h>
#define ESWhiteAlpha(w, a)  [UIColor colorWithWhite:w alpha:a]
#define ESRound(s) roundf(s*kRate)//roundf(s)

#define ESBoldFont(a) [UIFont boldSystemFontOfSize:a]

#define ESFontPingFangRegular(a)                      [UIFont fontWithName:@"PingFang-SC-Regular" size:a]
#define ESFontPingFangMedium(a)                       [UIFont fontWithName:@"PingFang-SC-Medium" size:a]
#define ESFontPingFangSemibold(a)                     [UIFont fontWithName:@"PingFang-SC-Semibold" size:a]

#define RES_OK(sel) (self.delegate && [self.delegate respondsToSelector:sel])

#define kCMPOcrScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kScale [UIScreen mainScreen].scale
#define kRate  kCMPOcrScreenWidth / 375.0
#define CMPShiPei(number) ((kCMPOcrScreenWidth*(number))/375)

// Get the screen's bounds.
#define kScreenBounds ([UIScreen mainScreen].bounds)

#define kNavHeight IKNavAreaHeight
#define kKeyWindow [UIApplication sharedApplication].keyWindow
#define STRING_WIDTH(string,height,font) [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size.width

#ifndef weakify
    #if __has_feature(objc_arc)
    #define weakify(object) __weak __typeof__(object) weak##_##object = object;
    #else
    #define weakify(object) __block __typeof__(object) block##_##object = object;
    #endif
#endif

#ifndef strongify
    #if __has_feature(objc_arc)
    #define strongify(object) __typeof__(object) object = weak##_##object;
    #else
    #define strongify(object) __typeof__(object) object = block##_##object;
    #endif
#endif

#pragma mark - Generate Color

// color
///< format：0xFFFFFF
#define k16RGBColor(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

///< format：22,22,22
#define kRGBColor(r, g, b) ([UIColor colorWithRed:(r) / 255.0  \
green:(g) / 255.0  \
blue:(b) / 255.0  \
alpha:1])

#define kBlueColor k16RGBColor(0x4280f3)

#define mIKHexColor(hex, a) [UIColor colorWithRed:((hex >> 16 & 0xff) / 255.0) green:((hex >> 8 & 0xff) / 255.0) blue:((hex & 0xff) / 255.0) alpha:(a)]

typedef enum : NSUInteger {
    InvoiceVerifyResult_Valid = 0,//已验真
    InvoiceVerifyResult_HasNotVerify = 3,//未验真
    InvoiceVerifyResult_Invalid = 1,//已作废
    InvoiceVerifyResult_NoNeedVerify = 4,//无需验真
    InvoiceVerifyResult_CheckHasNoInfo = 2//查无此票
} InvoiceVerifyResult;

#endif /* CustomDefine_h */

