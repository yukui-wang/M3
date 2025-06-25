//
//  CMPLoginRsaTools.m
//  M3
//
//  Created by CRMO on 2018/11/13.
//

#import "CMPLoginRsaTools.h"
#import "SvUDIDTools.h"
#import <CMPLib/NSDate+CMPDate.h>
#import "RSAUtil.h"

@implementation CMPLoginRsaTools

+ (NSString *)signWithPrivate:(NSString *)str {
    NSString *s = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCdToujkvUAgaeNz59DBycVBEN0B+do2mhrfWCclrS0bfK01jDWg68mInP91SXlAObRfS6xaMNfZ6G1aqJ7Q4IW/4BUo6ixD4Kw63eadkTTdLtCHwqtrZKBZqB6DOAnOFPyE3TT8iceNbl86wd68UbBAybtVEpHZYmzQHWcazLfzQIDAQAB";
    NSString* sig = [RSAUtil encryptString:str publicKey:s];
    return sig;
}

+ (NSDictionary *)appendRsaParam:(NSDictionary *)param {
    NSMutableDictionary *m = [param mutableCopy];
    NSString *UDID = [SvUDIDTools UDID];
    NSString *time = [[NSDate date] cmp_secondStr];
    NSString *eUDID = [CMPLoginRsaTools signWithPrivate:UDID] ?: @"";
    NSString *eTime = [CMPLoginRsaTools signWithPrivate:time] ?: @"";
    [m setObject:eUDID forKey:@"deviceID"];
    [m setObject:eTime forKey:@"sendTime"];
    return [m copy];
}

@end
