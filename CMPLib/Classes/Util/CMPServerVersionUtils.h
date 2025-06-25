//
//  CMPServerversionUtils.h
//  M3
//
//  Created by youlin on 2020/3/3.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CMPServerVersion) {
    CMPServerVersionV7_0 = 180,
    CMPServerVersionV7_0_SP1 = 210,
    CMPServerVersionV7_0_SP2 = 250,
    CMPServerVersionV7_1 = 260,
    CMPServerVersionV7_1_SP1 = 310,
    CMPServerVersionV8_0 = 350,
    CMPServerVersionV8_0_SP1 = 410,
    CMPServerVersionV8_1 = 420,
    CMPServerVersionV8_1_SP1 = 429,
    CMPServerVersionV8_1_SP2 = 432,
    CMPServerVersionV8_2 = 442,
    CMPServerVersionV8_2_810 = 450,
    CMPServerVersionV8_3 = 459,
    CMPServerVersionV9_0_730 = 463,
};

NS_ASSUME_NONNULL_BEGIN

@interface CMPServerVersionUtils : NSObject

+ (BOOL)serverIsV8_0;

+ (BOOL)serverIsLaterV8_0;
+ (BOOL)serverIsLaterV8_0WithServerVersion:(NSString *)version;

+ (BOOL)serverIsLaterV8_0_SP1;
+ (BOOL)serverIsLaterV8_0_SP1WithServerVersion:(NSString *)version;

+ (BOOL)serverIsLaterV8_1;
+ (BOOL)serverIsLaterV8_1WithServerVersion:(NSString *)version;

+ (BOOL)serverIsLaterV8_1SP1;
+ (BOOL)serverIsLaterV8_1SP2;
+ (BOOL)serverIsLaterV8_2;
+ (BOOL)serverIsLaterV8_2_810;

+ (BOOL)serverIsLaterV8_3;

//v463
+ (BOOL)serverIsLaterV9_0_730;

/// 是否已经设置过服务器
+ (BOOL)isServerHasSetUp;
+ (NSError *)versionIsLowError;

#pragma mark - 工具方法
+ (NSInteger)intValueOfServerVersion:(NSString *)serverVersion;

@end

NS_ASSUME_NONNULL_END
