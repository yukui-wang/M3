//
//  BaiduAppError.m
//  M3
//
//  Created by wujiansheng on 2019/2/27.
//

#import "BaiduAppError.h"
#import "SPTools.h"

@implementation BaiduAppError

- (id)initWithError:(NSDictionary *)error {
    if (self = [super init]) {
        if (error && [error isKindOfClass:[NSDictionary class]]) {
            self.code = [SPTools integerValue:error forKey:@"code"];
            self.message = [SPTools stringValue:error forKey:@"message"];
        }
    }
    return self;
}


@end
