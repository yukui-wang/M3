//
//  XZOpenAppIntent.m
//  M3
//
//  Created by wujiansheng on 2019/3/13.
//

#import "XZOpenAppIntent.h"
#import "SPTools.h"
#import <CMPLib/NSString+CMPString.h>

@implementation XZOpenAppIntent

- (void)dealloc {
    self.intentName = nil;
    self.appId = nil;
    self.openType = nil;
    self.openApi = nil;
    self.paramsDic = nil;
}

- (id)initWithJsonStr:(NSString *)jsonStr {
    if (self = [super init]) {
        NSDictionary *dic = [SPTools dictionaryWithJsonString:jsonStr];
        self.intentName = [SPTools stringValue:dic forKey:@"intentName"];
        self.appId = [SPTools stringValue:dic forKey:@"appId"];
        self.openType = [SPTools stringValue:dic forKey:@"openType"];
        self.openApi = [SPTools stringValue:dic forKey:@"openApi"];
        self.paramsDic = [SPTools dicValue:dic forKey:@"params"];
        if (!self.paramsDic) {
            self.paramsDic = [NSDictionary dictionary];
        }
    }
    return self;
}

- (NSString *)open_url {
    if ([self.openType isEqualToString:@"loadApp"]) {
        return nil;
    }
    NSString *url = self.openApi;
    NSArray *keyArray = self.paramsDic.allKeys;
    for (NSString *key in keyArray) {
        url = [url appendHtmlUrlParam:key value:self.paramsDic[key]];
    }
    return url;
}

- (NSDictionary *)open_params {
    NSDictionary * result = nil;
    if ([self.openType isEqualToString:@"loadApp"]) {
        result = [NSDictionary dictionaryWithObjectsAndKeys:self.openApi,@"openApi",self.appId,@"appId",self.paramsDic,@"params", nil];
    }
    return result;
}


@end
