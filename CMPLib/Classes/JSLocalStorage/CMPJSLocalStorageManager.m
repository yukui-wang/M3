//
//  CMPJSLocalStorageManager.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2021/11/11.
//

#import "CMPJSLocalStorageManager.h"
#import "NSString+CMPString.h"
#import "CMPJSLocalStorageDBProvider.h"

@interface CMPJSLocalStorageManager()
@property (nonatomic,strong) NSMutableDictionary *valsDic;
@property (nonatomic,strong) CMPJSLocalStorageDBProvider *dbProvider;
@end

@implementation CMPJSLocalStorageManager

+(NSString *)identifier
{
    return @"jsLocalStorage";
}

+(NSString *)_finalKey:(NSString *)oriKey
{
    return [[self userDefaultsKeyWithIdentifier:[self identifier] isGlobal:YES] stringByAppendingString:oriKey];
}

+ (BOOL)setItem:(NSString *)value forKey:(NSString *)key
{
//    NSLog(@"%s__begin__%@:%@",__FUNCTION__,key,value);
    if ([NSString isNull:key]) {
        return NO;
    }
    if ([NSString isNull:value]) {
        NSLog(@"ks log --- localstorage 存入的值为空：%@，key：%@",value,key);
        return NO;
    }
    @synchronized (self) {
        NSString *vv = [NSString stringWithFormat:@"%@",value];
        id r = vv;
//        if (vv.length>64) {
//            r = [vv dataUsingEncoding:NSUTF8StringEncoding];
//        }
        [[CMPJSLocalStorageManager shareManager].valsDic setObject:r forKey:key];
        [[CMPJSLocalStorageManager shareManager].dbProvider setItem:r forKey:key];
    }
//    NSLog(@"%s__end",__FUNCTION__);
    return YES;
}

+(NSString *)getItem:(NSString *)key
{
//    NSLog(@"%s__begin__%@",__FUNCTION__,key);
    if ([NSString isNull:key]) {
        return nil;
    }
    @synchronized (self) {
        id val = [[CMPJSLocalStorageManager shareManager].valsDic objectForKey:key];
        if (val && [val isKindOfClass:[NSData class]]) {
            val = [[NSString alloc] initWithData:val encoding:NSUTF8StringEncoding];
        }
        if (![NSString isNull:val]) {
//            NSLog(@"%s__end__%@:%@",__FUNCTION__,key,val);
            return val;
        }
        
        val = [[CMPJSLocalStorageManager shareManager].dbProvider getItem:key];
        if (val && [val isKindOfClass:[NSData class]]) {
            val = [[NSString alloc] initWithData:val encoding:NSUTF8StringEncoding];
        }
        if (![NSString isNull:val]) {
            [[CMPJSLocalStorageManager shareManager].valsDic setObject:val forKey:key];
//            NSLog(@"%s__end__%@:%@",__FUNCTION__,key,val);
            return val;
        }
    }
    return nil;
}

+(BOOL)removeItem:(NSString *)key
{
//    NSLog(@"%s__begin__%@",__FUNCTION__,key);
    if ([NSString isNull:key]) {
        return NO;
    }
    @synchronized (self) {
        [[CMPJSLocalStorageManager shareManager].valsDic removeObjectForKey:key];
        [[CMPJSLocalStorageManager shareManager].dbProvider removeItem:key];
    }
//    NSLog(@"%s__end",__FUNCTION__);
    return YES;
}

+(BOOL)clear
{
//    NSLog(@"%s__begin",__FUNCTION__);
    @synchronized (self) {
        [[CMPJSLocalStorageManager shareManager].valsDic removeAllObjects];
        [[CMPJSLocalStorageManager shareManager].dbProvider clearAllData];
    }
    NSLog(@"%s__end",__FUNCTION__);
    [self allLocalStorageInfo];
    return YES;
}

+(NSDictionary *)allLocalStorageInfo
{
    NSDictionary *result = [[CMPJSLocalStorageManager shareManager].dbProvider allData];
    NSLog(@"ks log --- allLocalStorageInfo所有值：%@",result);
    return result;
}


+ (NSString *)userDefaultsKeyWithIdentifier:(NSString *)identifier isGlobal:(BOOL)isGlobal {
    return [NSString stringWithFormat:@"cmp_%@_",identifier];;
    CMPCore *cmpCore = [CMPCore sharedInstance];
    NSString *userID = [cmpCore userID];
    NSString *serverID = [cmpCore serverID];
    NSString *key  = nil;
    if (isGlobal) {
        key = [NSString stringWithFormat:@"cmp_%@_serverID_%@_",identifier,serverID];
    } else {
        key = [NSString stringWithFormat:@"cmp_%@_serverID_%@_userID_%@_",identifier,serverID,userID];
    }
    return key;
}


static CMPJSLocalStorageManager *_instance;

+(CMPJSLocalStorageManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CMPJSLocalStorageManager alloc] init];
        _instance.dbProvider = [[CMPJSLocalStorageDBProvider alloc] init];
    });
    return _instance;
}

-(NSMutableDictionary *)valsDic
{
    if (!_valsDic) {
        _valsDic = [[NSMutableDictionary alloc] init];
        NSDictionary *currLocalDic = [CMPJSLocalStorageManager allLocalStorageInfo];
        [_valsDic addEntriesFromDictionary:currLocalDic];
//        NSLog(@"ks log --- jslocalstorage valsdic init : %@",_valsDic);
    }
    return _valsDic;
}

+(NSString *)dbPath
{
    return [[CMPJSLocalStorageManager shareManager].dbProvider dbPath];
}

@end
