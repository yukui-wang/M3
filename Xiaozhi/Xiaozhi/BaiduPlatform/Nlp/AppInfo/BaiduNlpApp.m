//
//  BaiduNlpApp.m
//  M3
//
//  Created by wujiansheng on 2019/2/27.
//

#import "BaiduNlpApp.h"
#import "SPTools.h"

@implementation BaiduNlpApp
- (id)initWithBaiduNlpApp:(NSDictionary *)dic {
    if (self = [super init]) {
        self.nlpAppID = [SPTools stringValue:dic forKey:@"nlpAppID"];
        self.nlpAPIKey = [SPTools stringValue:dic forKey:@"nlpAPIKey"];
        self.nlpSecretKey = [SPTools stringValue:dic forKey:@"nlpSecretKey"];
        NSDictionary *error = [SPTools dicValue:dic forKey:@"baiduAppError"];
        if (error) {
            _baiduAppError = [[BaiduAppError alloc] initWithError:error];
        }
    }
    return self;
}

@end
