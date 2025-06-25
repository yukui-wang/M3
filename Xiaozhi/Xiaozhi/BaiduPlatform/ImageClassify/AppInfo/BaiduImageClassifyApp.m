//
//  BaiduImageClassifyApp.m
//  M3
//
//  Created by wujiansheng on 2019/2/27.
//

#import "BaiduImageClassifyApp.h"
#import "SPTools.h"

@implementation BaiduImageClassifyApp
- (id)initWithBaiduImageClassifyApp:(NSDictionary *)dic {
    if (self = [super init]) {
        self.imageClassifyAppID = [SPTools stringValue:dic forKey:@"imageClassifyAppID"];
        self.imageClassifyAPIKey = [SPTools stringValue:dic forKey:@"imageClassifyAPIKey"];
        self.imageClassifySecretKey = [SPTools stringValue:dic forKey:@"imageClassifySecretKey"];
        NSDictionary *error = [SPTools dicValue:dic forKey:@"baiduAppError"];
        if (error) {
            _baiduAppError = [[BaiduAppError alloc] initWithError:error];
        }
    }
    return self;
}

@end
