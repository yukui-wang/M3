//
//  CMPSMEncryptManager.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/2/22.
//

#import "CMPSMEncryptManager.h"
#import <CMPLib/NSDate+CMPDate.h>

@implementation CMPSMEncryptManager

+(instancetype)shareInstance
{
    static id manager ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

-(NSString *)sm4Key
{
    if (!_sm4Key || _sm4Key.length == 0) {
        _sm4Key = [GMSm4Utils createSm4Key];
    }
    NSLog(@"ks log --- %s -- val: %@",__func__,_sm4Key);
    return _sm4Key;
}

-(NSArray *)sm2KeyPair
{
    if (!_sm2KeyPair) {
        _sm2KeyPair = [GMSm2Utils createKeyPair];
    }
    NSLog(@"ks log --- %s -- val: %@",__func__,_sm2KeyPair);
    return _sm2KeyPair;
}

-(NSString *)encryptText:(NSString *)text
{
    NSLog(@"ks log --- %s",__func__);
    if (!text || text.length == 0) {
        return @"";
    }
    NSString *sm4Key = [CMPSMEncryptManager shareInstance].sm4Key;
    NSString *timestr = [[NSDate date] cmp_millisecondStr];
    NSString *str = [NSString stringWithFormat:@"cmp%@%@%@%@",[CMPSMEncryptManager mixStr],text,[CMPSMEncryptManager mixStr],timestr];
    NSString *resultToken = [GMSm4Utils ecbEncryptText:str key:sm4Key];
    NSString *tempResultToken = resultToken;
    NSArray *sm2KeyArr = [CMPSMEncryptManager shareInstance].sm2KeyPair;
    if (sm2KeyArr && sm2KeyArr.count>1) {
        resultToken = [GMSm2Utils encryptText:resultToken publicKey:sm2KeyArr[0]];
    }
    NSLog(@"ks log --- %s -- 加密text:%@\n拼接后str:%@\nsm4加密key:%@\nsm4 ecb加密后:%@\nsm2加密公钥:%@\nsm2加密后:%@",__func__,text,str,sm4Key,tempResultToken,sm2KeyArr[0],resultToken);
    return resultToken;
}

-(NSString *)decryptText:(NSString *)text
{
    if (!text || text.length == 0) {
        return @"";
    }
    NSString *resultStr;
    NSArray *sm2KeyArr = [CMPSMEncryptManager shareInstance].sm2KeyPair;
    if (sm2KeyArr && sm2KeyArr.count>1) {
        resultStr = [GMSm2Utils decryptToText:text privateKey:sm2KeyArr[1]];
    }
    NSString *tempResultStr = resultStr;
    NSString *sm4Key = [CMPSMEncryptManager shareInstance].sm4Key;
    resultStr = [GMSm4Utils ecbDecryptText:resultStr key:sm4Key];
    NSString *tempResultStr2 = resultStr;
    NSString *mixStr = [CMPSMEncryptManager mixStr];
    if ([resultStr containsString:mixStr]) {
        NSArray *arr = [resultStr componentsSeparatedByString:mixStr];
        if (arr.count>2) {
            resultStr = arr[1];
        }
    }
    NSLog(@"ks log --- %s -- 解密text:%@\nsm2解密私钥:%@\nsm2解密后:%@\nsm4解密key:%@\nsm4 ecb解密后:%@\n结果str:%@",__func__,text,sm2KeyArr[1],tempResultStr,sm4Key,tempResultStr2,resultStr);
    return resultStr;
}

//-(NSData *)encryptData:(NSData *)data
//{
//
//}
//
//-(NSData *)decryptData:(NSData *)data
//{
//
//}

+(NSString *)mixStr
{
    return @"ro2rh";
}

@end
