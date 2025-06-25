//
//  CMPAccessTokenManager.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/2/16.
//

#import "CMPAccessTokenManager.h"
#import <CMPLib/CMPAppManager.h>
#import "CMPSMEncryptManager.h"

static double accessTokenExperiedSpace = 7200;

@implementation CMPAccessTokenManager

+(NSDictionary *)generateNewAccessTokenByParams:(NSDictionary *)params
{
    if (!params ||![params isKindOfClass:[NSDictionary class]]) {
        return @{@"message":@"input params error",@"code":@(1001)};
    }
//    NSString *security = params[@"security"];
//    if (!security || security.length == 0) {
//        return @{@"message":@"input params error: security null",@"code":@(1001)};;
//    }
    NSString *version = params[@"version"];
    if (!version || version.length == 0) {
        return @{@"message":@"input params error: version null",@"code":@(1001)};;
    }
    NSString *appId = params[@"appInfoId"];
    if (!appId || appId.length == 0) {
        return @{@"message":@"input params error: appid null",@"code":@(1001)};;
    }
    //校验appid是否在本地应用列表里，如果不在就得校验appname
    NSString *appName = params[@"appName"]?:@"";
    id appIdDict = [[CMPAppManager appInfoMapWithAppId] objectForKey:appId];
    if (appIdDict) {
        id appInfo = appIdDict[version];
        if (appInfo && [appInfo isKindOfClass:CMPDBAppInfo.class]) {
            appName = ((CMPDBAppInfo *)appInfo).bundle_display_name;
        }
    }
    if (!appName || appName.length == 0) {
        return @{@"message":@"input params error: appname null",@"code":@(1001)};;
    }
    
    NSDate* date = [NSDate date];
    NSTimeInterval a = [date timeIntervalSince1970];
    double expir = (a + accessTokenExperiedSpace) *1000;
    
    NSString *resultToken = [[CMPSMEncryptManager shareInstance] encryptText:appId];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:@(200) forKey:@"code"];
    [result setObject:@"success" forKey:@"message"];
    [result setObject:resultToken forKey:@"accessToken"];
    [result setObject:[NSString stringWithFormat:@"%f",expir] forKey:@"tokenExpiredTime"];
    NSLog(@"ks log --- %s -- result: %@",__func__,result);
    return result;
}


+(BOOL)verifyAccessTokenExperied:(NSString *)accessToken
{
    BOOL isExperid = NO;
    
    NSString *resultStr;
    NSArray *sm2KeyArr = [CMPSMEncryptManager shareInstance].sm2KeyPair;
    if (sm2KeyArr && sm2KeyArr.count>1) {
        resultStr = [GMSm2Utils decryptToText:accessToken privateKey:sm2KeyArr[1]];
    }
    NSString *sm4Key = [CMPSMEncryptManager shareInstance].sm4Key;
    resultStr = [GMSm4Utils ecbDecryptText:resultStr key:sm4Key];
    NSString *mixStr = [CMPSMEncryptManager mixStr];
    if ([resultStr containsString:mixStr]) {
        NSArray *arr = [resultStr componentsSeparatedByString:mixStr];
        if (arr.count>2) {
            resultStr = arr.lastObject;
        }
    }
    //now
    NSDate* date = [NSDate date];
    NSTimeInterval a = [date timeIntervalSince1970];
    //input time
    double inputTimestrap = [resultStr doubleValue]/1000;
    
    double sp = a-inputTimestrap;
    if (sp>accessTokenExperiedSpace) {
        isExperid = YES;
    }
    
    return isExperid;
}

@end
