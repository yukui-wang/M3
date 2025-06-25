//
//  SPBaiduUnitInfo.m
//  M3
//
//  Created by wujiansheng on 2019/2/27.
//

#import "SPBaiduUnitInfo.h"
#import "SPConstant.h"
#import "SPTools.h"
#import "XZCore.h"

@implementation SPBaiduUnitInfo


- (id)initWithResult:(NSDictionary *)result {
    if (self = [super init]) {
        NSDictionary *info = result[@"data"];
        if (info && [info isKindOfClass:[NSDictionary class]]) {
            self.endTime = [info[@"end_time"] longLongValue];//ms
            NSDictionary *idDic = info[@"id"];
            if ([idDic isKindOfClass:[NSDictionary class]]) {
                self.baiduUnitSceneID = [SPTools stringValue:idDic forKey:@"unitSceneID"];
                self.baiduUnitAppId = [SPTools stringValue:idDic forKey:@"unitAppID"];
                self.baiduUnitApiKey = [SPTools stringValue:idDic forKey:@"unitAPIKey"];
                self.baiduUnitSecretKey =[SPTools stringValue:idDic forKey:@"unitSecretKey"];
                if ([idDic.allKeys containsObject:@"unitVersion"]) {
                    self.unitVersion = [SPTools stringValue:idDic forKey:@"unitVersion"];
                }
                else {
                    self.unitVersion = @"1.0";
                }
                self.unitUrl = idDic[@"unitUrl"];
            }
        }
    }
    return self;
    
}
- (id)initWithQAResult:(NSDictionary *)result {
    if (self = [super init]) {
        self.baiduUnitSceneID = [SPTools stringValue:result forKey:@"unitSceneID"];
        self.baiduUnitAppId = @"";
        self.baiduUnitApiKey = [SPTools stringValue:result forKey:@"unitApiKey"];
        self.baiduUnitSecretKey = [SPTools stringValue:result forKey:@"unitSecretKey"];
        self.unitVersion = @"2.0";
        self.unitUrl = nil;
    }
    return self;
}
- (id)initWithBaiduUnitApp:(NSDictionary *)dic {
    if (self = [super init]) {
        self.baiduUnitSceneID = [SPTools stringValue:dic forKey:@"unitSceneID"];
        self.baiduUnitAppId = [SPTools stringValue:dic forKey:@"unitAppID"];
        self.baiduUnitApiKey = [SPTools stringValue:dic forKey:@"unitAPIKey"];
        self.baiduUnitSecretKey = [SPTools stringValue:dic forKey:@"unitSecretKey"];
        self.unitVersion = [SPTools stringValue:dic forKey:@"unitVersion"];
        self.unitUrl = [SPTools stringValue:dic forKey:@"unitUrl"];
        NSDictionary *error = [SPTools dicValue:dic forKey:@"baiduAppError"];
        if (error) {
            _baiduAppError = [[BaiduAppError alloc] initWithError:error];
        }
        self.endTime = [SPTools longLongValue:dic forKey:@"endTime"];//ms
        //float 可能不准确 ！！！！！！！！
        self.xiaozVersion = [SPTools stringValue:dic forKey:@"xiaozVersion"];
    }
    return self;
}

- (NSString *)logId {
    return [XZCore serverID];
}
- (NSString *)userId {
    return [XZCore userID]; //[SvUDIDTools UDID];
}

+ (SPBaiduUnitInfo *)defaultInfo {
    SPBaiduUnitInfo *info = [[SPBaiduUnitInfo alloc] init];
    // ;-测试unit //kBUnitSceneID;
    info.baiduUnitAppId = kBUnitAppId;
    info.baiduUnitApiKey = kBUnitApiKey;
    info.baiduUnitSecretKey = kBUnitSecretKey;
    info.unitVersion = @"2.0";
    info.baiduUnitSceneID = @"17395";
    info.endTime = 1587636997176;
    return info;
}

//- (NSString *)baiduUnitSceneID {
//    return @"17395";
//}
//- (NSString *)baiduUnitApiKey {
//    return @"Zd3lQ5E1uW8bkWEBprgij1tC";
//}
//- (NSString *)baiduUnitSecretKey {
//    return @"Iub4ajOGbIGGVG631AGUBXo0DZVhusZW";
//}

@end

