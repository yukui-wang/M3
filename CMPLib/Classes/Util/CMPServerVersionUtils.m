//
//  CMPServerversionUtils.m
//  M3
//
//  Created by youlin on 2020/3/3.
//

#import "CMPServerVersionUtils.h"
#import "CMPCore.h"

@implementation CMPServerVersionUtils

#pragma mark - 版本判断

+ (BOOL)serverIsV8_0 {
    return [self intValueOfServerVersion:CMP_SERVER_VERSION] == CMPServerVersionV8_0;
}

+ (BOOL)serverIsLaterV8_0 {
    return [self serverIsLaterV8_0WithServerVersion:CMP_SERVER_VERSION];
}

+ (BOOL)serverIsLaterV8_0_SP1 {
    return [self serverIsLaterV8_0_SP1WithServerVersion:CMP_SERVER_VERSION];
}

+ (BOOL)serverIsLaterV8_0WithServerVersion:(NSString *)version {
    return [self intValueOfServerVersion:version] >= CMPServerVersionV8_0;
}

+ (BOOL)serverIsLaterV8_0_SP1WithServerVersion:(NSString *)version {
    return [self intValueOfServerVersion:version] >= CMPServerVersionV8_0_SP1;
}



+ (BOOL)serverIsLaterV8_1 {
    return [self serverIsLaterV8_1WithServerVersion:CMP_SERVER_VERSION];
}

+ (BOOL)serverIsLaterV8_1WithServerVersion:(NSString *)version {
    return [self intValueOfServerVersion:version] >= CMPServerVersionV8_1;
}

+ (BOOL)serverIsLaterV8_1SP1 {
    return [self intValueOfServerVersion:CMP_SERVER_VERSION] >= CMPServerVersionV8_1_SP1;
}

+ (BOOL)serverIsLaterV8_1SP2 {
    return [self intValueOfServerVersion:CMP_SERVER_VERSION] >= CMPServerVersionV8_1_SP2;
}

+ (BOOL)serverIsLaterV8_2 {
    return [self intValueOfServerVersion:CMP_SERVER_VERSION] >= CMPServerVersionV8_2;
}

+ (BOOL)serverIsLaterV8_2_810 {
    return [self intValueOfServerVersion:CMP_SERVER_VERSION] >= CMPServerVersionV8_2_810;
}

+ (BOOL)serverIsLaterV8_3 {
    return [self intValueOfServerVersion:CMP_SERVER_VERSION] >= CMPServerVersionV8_3;
}

+ (BOOL)serverIsLaterV9_0_730 {
    return [self intValueOfServerVersion:CMP_SERVER_VERSION] >= CMPServerVersionV9_0_730;
}

+ (BOOL)isServerHasSetUp {
    if ([NSString isNotNull: CMP_SERVER_VERSION]) {
        return YES;
    }
    return NO;;
}

+ (NSError *)versionIsLowError
{
    return [NSError errorWithDomain:@"version is low" code:-1111 userInfo:nil];
}
#pragma mark - 工具方法

+ (NSInteger)intValueOfServerVersion:(NSString *)serverVersion {
    if ([NSString isNull:serverVersion]) {
        return 0;
    }
    NSArray *list = [serverVersion componentsSeparatedByString:@"."];
    NSInteger value = 0;
    for (NSString *str in list) {
        NSInteger num = [str integerValue];
        value = value * 10 + num;
    }
    return value;
}

@end
