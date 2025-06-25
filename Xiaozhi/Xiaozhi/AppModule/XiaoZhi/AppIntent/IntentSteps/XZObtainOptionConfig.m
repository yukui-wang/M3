//
//  XZObtainOptionConfig.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/10/24.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZObtainOptionConfig.h"
#import "SPTools.h"
#import "XZCore.h"
@implementation XZObtainOptionConfigParam

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        self.key = [SPTools stringValue:dic forKey:@"key"];
        self.required = [SPTools boolValue:dic forKey:@"required"];
    }
    return self;
}

@end

@implementation XZObtainOptionConfig

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        self.obtainUrl = [SPTools stringValue:dic forKey:@"obtainUrl"];
        self.obtainUrlType = [SPTools stringValue:dic forKey:@"obtainUrlType"];
        self.obtainLoadUrl = [SPTools stringValue:dic forKey:@"obtainLoadUrl"];
        self.obtainRenderType = [SPTools stringValue:dic forKey:@"obtainRenderType"];
        self.obtainExtData = [SPTools dicValue:dic forKey:@"obtainExtData"];
        NSArray *obtainParams = [SPTools arrayValue:dic forKey:@"obtainParams"];
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in obtainParams) {
            XZObtainOptionConfigParam *param = [[XZObtainOptionConfigParam alloc] initWithDic:dict];
            [array addObject:param];
        }
        self.obtainParams = array;
    }
    return self;
}

- (NSString *)requestUrl {
    NSString *url = [self.obtainUrlType isEqualToString:KXZIntentUrlType_Rest] ? [XZCore fullUrlForPath:self.obtainUrl] : self.obtainUrl;
    return url;
}

- (NSString *)loadUrl {
    return self.obtainLoadUrl;
}
@end
