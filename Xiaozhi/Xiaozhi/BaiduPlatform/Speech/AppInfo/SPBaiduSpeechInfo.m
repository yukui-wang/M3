//
//  SPBaiduSpeechInfo.m
//  M3
//
//  Created by wujiansheng on 2018/4/25.
//

#import "SPBaiduSpeechInfo.h"
#import "SPConstant.h"
#import "SPTools.h"
#import <CMPLib/CMPCore.h>


@implementation SPBaiduSpeechInfo


- (id)initWithResult:(NSDictionary *)result {
    if (self = [super init]) {
       NSInteger xiaozhiCode = [result[@"code"] integerValue];
        /*code: //是1000:正常/2001:未开通/2002:已停用 /2003:已过期*/
        NSDictionary *info = result[@"data"];
        if (info && [info isKindOfClass:[NSDictionary class]]) {
            NSDictionary *idDic = info[@"id"];
            if ([idDic isKindOfClass:[NSDictionary class]]) {
                self.baiduSpeechAppId = idDic[@"iphoneAppID"];
                self.baiduSpeechApiKey = idDic[@"iphoneAPIKey"];
                self.baiduSpeechSecretKey = idDic[@"iphoneSecretKey"];
            }
            _baiduAppError = [[BaiduAppError alloc] init];
            _baiduAppError.code = xiaozhiCode;
            if (_baiduAppError.code == 1000 && ![self canUseXiaoZhi]) {
                _baiduAppError.code = 2001;
            }
        }
    }
    return self;

}

- (id)initWithBaiduIphoneVoiceApp:(NSDictionary *)dic {
    if (self = [super init]) {
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            self.baiduSpeechAppId = [SPTools stringValue:dic forKey:@"iphoneAppID"];
            self.baiduSpeechApiKey = [SPTools stringValue:dic forKey:@"iphoneAPIKey"];
            self.baiduSpeechSecretKey = [SPTools stringValue:dic forKey:@"iphoneSecretKey"];
            _baiduAppError = [[BaiduAppError alloc] initWithError:[SPTools dicValue:dic forKey:@"baiduAppError"]];
            if (_baiduAppError.code == 0) {
                _baiduAppError.code = 1000;
            }
        }
    }
    return self;
}


- (BOOL)canUseXiaoZhi {
//    return YES;
    if (_baiduAppError.code != 1000) {
        return NO;
    }
    if ([NSString isNull:self.baiduSpeechAppId]) {
        return NO;
    }
    if ([NSString isNull:self.baiduSpeechApiKey]) {
        return NO;
    }
    if ([NSString isNull:self.baiduSpeechSecretKey]) {
        return NO;
    }
    return YES;
}

- (BOOL)isUnavailableCode{
//    return NO;

    if (_baiduAppError.code == 1000) {
        //是1000:正常
        return NO;
    }
    if (_baiduAppError.code == 2001) {
        //2001:未开通
        return NO;
    }
    if (_baiduAppError.code == 2002) {
        //2002:已停用
        return NO;
    }
    if (_baiduAppError.code == 2003) {
        //2003:已过期
        return NO;
    }
    return YES;
}
+ (SPBaiduSpeechInfo *)defaultInfo {
    SPBaiduSpeechInfo *info = [[SPBaiduSpeechInfo alloc] init];
    info.baiduSpeechAppId = kBaiduSpeechAppId;
    info.baiduSpeechApiKey = kBaiduSpeechApiKey;
    info.baiduSpeechSecretKey = kBaiduSpeechSecretKey;
    // ;-测试unit //kBUnitSceneID;
    BaiduAppError *error = [[BaiduAppError alloc] init] ;
    info.baiduAppError = error;
    info.baiduAppError.code = 1000;

    return info;
}

//- (NSString *)baiduSpeechAppId {
//    return @"10495027";
//}
//- (NSString *)baiduSpeechApiKey {
//    return @"CWUDUKRj0At2hfGejuMZbdGQ";
//}
//- (NSString *)baiduSpeechSecretKey {
//    return @"2e7f6a024a50f4cde8035b61611173bb";
//}
@end


