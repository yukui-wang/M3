//
//  CMPCustomManager.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/12/12.
//

#import "CMPCustomManager.h"
//#if CUSTOM
#import <CMPLib/YYModel.h>
//#endif
#import <CMPLib/CMPBaseDataProvider.h>
#import <CMPLib/CMPServerVersionUtils.h>

@implementation CMPCustomModel

@end

@interface CMPCustomManager()<CMPDataProviderDelegate>
{
    CMPCustomModel *_aCusModel;
    NSDictionary *_aCusDic;
}
@end

@implementation CMPCustomManager

static id cusShareInstance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (cusShareInstance == nil) {
        @synchronized(self) {
            if (cusShareInstance == nil) {
                cusShareInstance = [super allocWithZone:zone];
            }
        }
    }
    return cusShareInstance;
}

+ (instancetype)sharedInstance {
    if (cusShareInstance == nil) {
        @synchronized(self) {
            if (cusShareInstance == nil) {
                cusShareInstance = [[self alloc] init];
                [cusShareInstance _init];
            }
        }
    }
    return cusShareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return cusShareInstance;
}


-(void)_init
{
    NSString *aPath = [[NSBundle mainBundle] pathForResource:@"CusParams" ofType:@"json"];
    NSString *aValue = [NSString stringWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:nil];
    _aCusDic = [CMPCustomManager dictionaryWithJsonString:aValue];
//#if CUSTOM
    if (_aCusDic) {
        _aCusModel = [CMPCustomModel yy_modelWithDictionary:_aCusDic];
        _aCusModel.hasPrivacy = [@"1" isEqualToString:_aCusDic[@"privacyTag"]];
        _aCusModel.privacyPath = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:@"privacy" ofType:@"html"]];
    }
//#endif
    NSLog(@"%s --- dic: %@",__func__,_aCusDic);
}

-(CMPCustomModel *)cusModel
{
    return _aCusModel ? : [[CMPCustomModel alloc] init];
}

//-(NSDictionary *)cusDic
//{
//    return _aCusDic ? : [NSDictionary dictionary];
//}

+(NSString *)safeString:(NSString *)string
{
    if (!string || ![string isKindOfClass:NSString.class]) return @"";
    return string;
}

+(NSString *)matchValueFromOri:(NSString *)ori andCus:(NSString *)cus
{
#if CUSTOM
    return [self safeString:cus];
#else
    return ori;
#endif
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

// from 1:登录后 2:设置里手动检查
-(void)checkVersionFrom:(NSInteger)from
{
#if CUSTOM
    if (![CMPServerVersionUtils serverIsLaterV8_2]) {
        return;
    }
    __weak typeof(self) wSelf = self;
    [self _fetchClientVersionInfoWithResult:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error && respData[@"version"]) {
            NSString *serverVersion = respData[@"version"];
            NSString *localVersion = self.cusModel.bundleVersion;
            NSNumber *typeVal = respData[@"upgradeStrategy"];//1强制更新 2选择更新
            NSString *serverId = [CMPCore sharedInstance].serverID;
            NSString *key = [NSString stringWithFormat:@"%@_%@_%@_%@",serverId,localVersion,serverVersion,typeVal];
            if (from == 1) {
                NSString *tag = [UserDefaults objectForKey:key];
                if ([@"1" isEqualToString:tag]) {
                    return;
                }
            }
            int rslt = [CMPCustomManager versionCompareSecend:serverVersion andVersionSecond:localVersion];
            if (rslt >0 ) {
                NSString *url = respData[@"url"];
                if (url && typeVal) {
                    NSInteger type = typeVal.integerValue;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"发现新版本%@,%@",serverVersion,type==1?@"请更新后使用App\n取消后退出App":@"是否现在更新"] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            if (type == 1) {
                                exit(0);
                            } else {
                                [UserDefaults setObject:@"1" forKey:key];
                                [UserDefaults synchronize];
                            }
                        }];
                        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [wSelf _fetchClientDownloadWebsiteWithResult:^(id  _Nonnull respData2, NSError * _Nonnull error2, id  _Nonnull ext2) {
                                if (!error2) {
                                    NSString *downloadWebsite = respData2[@"downloadPageUrl"];
                                    if (downloadWebsite && downloadWebsite.length) {
                                        NSString *sUrl = [[CMPCore sharedInstance].serverurlForSeeyon stringByAppendingString:downloadWebsite];
                                        if (@available(iOS 10.0,*)){
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sUrl] options:nil completionHandler:^(BOOL success) {
                                                
                                            }];
                                        }else{
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sUrl]];
                                        }
                                        if (type == 1){
                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                exit(0);
                                            });
                                        }
                                        return;
                                    }
                                }else{
                                    
                                }
                            }];
                        }];
//                        if (type != 1) {
                            [ac addAction:cancel];
//                        }
                        [ac addAction:sure];
                        
                        UIViewController *vc = [[UIApplication sharedApplication] keyWindow].rootViewController;
                        [vc presentViewController:ac animated:YES completion:^{
                                
                        }];
                    });
                }
            }
        }
    }];
#endif
}

// 方法调用
+ (int)versionCompareSecend:(NSString *)first andVersionSecond:(NSString *)second
{
    NSArray *versions1 = [first componentsSeparatedByString:@"."];
    NSArray *versions2 = [second componentsSeparatedByString:@"."];
    NSMutableArray *ver1Array = [NSMutableArray arrayWithArray:versions1];
    NSMutableArray *ver2Array = [NSMutableArray arrayWithArray:versions2];
// 确定最大数组
    NSInteger a = (ver1Array.count > ver2Array.count) ? ver1Array.count : ver2Array.count;
// 补成相同位数数组
    if (ver1Array.count < a) {
        for (NSInteger j = ver1Array.count; j < a; j++) {
            [ver1Array addObject:@"0"];
        }
    } else {
        for (NSInteger j = ver2Array.count; j < a; j++) {
            [ver2Array addObject:@"0"];
        }
    }
    // 比较版本号
    int result = [self compareArray1:ver1Array andArray2:ver2Array];
    return result;
}

+ (int)compareArray1:(NSMutableArray *)array1 andArray2:(NSMutableArray *)array2
{
    for (int i = 0; i < array2.count; i++) {
        NSInteger a = [[array1 objectAtIndex:i] integerValue];
        NSInteger b = [[array2 objectAtIndex:i] integerValue];
        if (a > b) {
            return 1;
        } else if (a < b) {
            return -1;
        }
    }
    return 0;
}

-(void)_fetchClientVersionInfoWithResult:(CommonResultBlk)result
{
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/cloudBuild/version/latest?type=2"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)_fetchClientDownloadWebsiteWithResult:(CommonResultBlk)result
{
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/cloudbuild.do?method=getLatestVersionInfo&type=2"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {

    NSDictionary *userInfo = aRequest.userInfo;
    void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
    
    if (!completionBlk) {
        return;
    }
    
    NSDictionary *responseObj = [aResponse.responseStr JSONValue];
    if (responseObj) {
        NSString *code = [NSString stringWithFormat:@"%@",responseObj[@"code"]];
        if ([code isEqualToString:@"0"]) {
            id respData = responseObj[@"data"];
            completionBlk(respData,nil,responseObj);
        }else{
            NSString *msg = [NSString stringWithFormat:@"%@",responseObj[@"message"]];
            NSError *err = [NSError errorWithDomain:msg code:[code integerValue] userInfo:nil];
            completionBlk(nil,err,responseObj);
        }
    }else{
        NSError *err = [NSError errorWithDomain:@"response null" code:-1 userInfo:nil];
        completionBlk(nil,err,responseObj);
    }
}


- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    
    NSDictionary *userInfo = aRequest.userInfo;
    
    void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
    
    if (completionBlk) {
        completionBlk(nil,error,nil);
    }
}

@end
