//
//  KSRequestLogManager.m
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2022/5/19.
//  Copyright © 2022 crmo. All rights reserved.
//

#import "KSRequestLogManager.h"
#import "KSLogManager.h"

@interface KSRequestLogManager()
{
    NSDictionary *_requestInLogDic;
    __block NSMutableDictionary *_reqBeginDic;
    __block NSMutableDictionary *_reqEndDic;
    __block NSMutableDictionary *_reqSpaceDic;
    NSString *_currentFilePath;
    NSString *_currentFileParentPath;
}
@end

@implementation KSRequestLogManager

static KSRequestLogManager *_instance;

+(KSRequestLogManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[KSRequestLogManager alloc] init];
    });
    return _instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _requestInLogDic = @{@"/rest/m3/login/verification":@"登录",
                             @"/rest/m3/appManager/getAppList":@"更新应用包",
                             @"/rest/m3/appManager/getCurrentUserAppList":@"登录",
                             @"/rest/m3/common/getConfigInfo":@"登录",
                             @"/rest/m3/config/uc":@"登录",
                             @"/rest/m3/common/locales":@"登录",
                             @"/rest/m3/common/fastPunchSetting":@"登录",
                             @"/rest/xiaozhi/getXiaozhiMessage":@"登录",
                             @"/rest/xiaozhi/aiApp":@"登录",
                             @"/rest/pns/device/register":@"登录",
                             @"/rest/m3/config/user/message/setting/list":@"登录",
                             @"/rest/shareRecord/settings":@"登录",
                             @"/rest/m3/theme/homeSkin":@"登录",
                             @"/rest/m3/message/classification":@"登录",
                             @"/rest/m3/startPage/getCustom":@"登录",
                             @"/rest/m3/config/user/new/message/settings":@"登录",
                             @"/rest/m3/individual/concurrent/account":@"登录",
                             @"/rest/contacts2/frequentContacts":@"登录",
                             @"/rest/m3/contacts/offline/accountSet":@"登录",
                             @"/rest/m3/contacts/offline/prepare":@"登录",
                             @"/rest/m3/contacts/offline/download":@"登录"
        };
        _reqBeginDic = [NSMutableDictionary dictionary];
        _reqEndDic = [NSMutableDictionary dictionary];
        _reqSpaceDic = [NSMutableDictionary dictionary];
        
        [self _initFilePath];
        
        NSLog(@"ks log --- %s -- currentFileParentPath: %@",__func__,_currentFileParentPath);
        [[KSLogManager shareManager] addObjLocalPath:_currentFileParentPath newNameWithType:nil];
        [[KSLogManager shareManager] addObjLocalPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0] stringByAppendingPathComponent:@"LoadLog"] newNameWithType:nil];

    }
    return self;
}

-(void)_initFilePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_currentFilePath]) return;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *docPath = paths[0];
    if (docPath) {
        _currentFileParentPath = [docPath stringByAppendingPathComponent:@"ReqLog"];
        
        BOOL isDir = NO;
        BOOL existed = [fileManager fileExistsAtPath:_currentFileParentPath isDirectory:&isDir];
        if (existed && !isDir) {
            [fileManager removeItemAtPath:_currentFileParentPath error:nil];
            existed = NO;
        }
        if (!existed) {
            [fileManager createDirectoryAtPath:_currentFileParentPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *fileName = @"req_log.txt";// [NSString stringWithFormat:@"req_%5f.json",[[NSDate date] timeIntervalSinceNow]*1000];
        _currentFilePath = [_currentFileParentPath stringByAppendingPathComponent:fileName];
        if (![fileManager fileExistsAtPath:_currentFilePath]) {
            BOOL su = [fileManager createFileAtPath:_currentFilePath contents:nil attributes:nil];
            if (!su) {
                
            }
        }
    }
}

-(BOOL)filterRequest:(NSString *)url reqid:(NSString *)reqid
{
    if (![KSLogManager shareManager].isDev) {
        return NO;
    }
    if (!url || url.length==0) {
        return NO;
    }
    __block BOOL contain = NO;
    [_requestInLogDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([url containsString:key]) {
            contain = YES;
            NSDate *datenow = [NSDate date];
            NSTimeInterval timeInterval = [datenow timeIntervalSince1970]*1000;
            [_reqBeginDic setValue:@(timeInterval) forKey:[NSString stringWithFormat:@"%@___%@",url,reqid]];
            if (_blk) {
                _blk(url,1,nil);
            }
            *stop = YES;
        }
    }];
    return contain;
}

-(BOOL)handleResponse:(NSString *)url reqid:(NSString *)reqid
{
    if (![KSLogManager shareManager].isDev) {
        return NO;
    }
    if (!url || url.length==0) {
        return NO;
    }
    BOOL contain = NO;
    NSString *key = [NSString stringWithFormat:@"%@___%@",url,reqid];
    NSNumber *obj1 = _reqBeginDic[key];
    if (obj1) {
        NSDate *datenow = [NSDate date];
        NSTimeInterval timeInterval = [datenow timeIntervalSince1970]*1000;
        [_reqEndDic setValue:@(timeInterval) forKey:key];
        
        long long time1 = obj1.longLongValue;
        long long space = timeInterval-time1;
        [_reqSpaceDic setValue:@(space) forKey:key];
        
        NSLog(@"ks log --- loginopt_reqSpace : %@ ~ 【%lld ms】",key,space);
        if (_blk) {
            _blk(url,2,nil);
        }
        contain = YES;
        
        [self _initFilePath];
        NSString *str = [NSString stringWithFormat:@"\n%@ *** %lld",key,space];
        NSData *da = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData *oldData = [NSMutableData dataWithContentsOfFile:_currentFilePath];
        [oldData appendData:da];
        [oldData writeToFile:_currentFilePath atomically:YES];
    }
    return contain;
}
@end
