//
//  CMPCheckEnvRequest.m
//  M3
//
//  Created by CRMO on 2017/12/6.
//

#import "CMPCheckEnvRequest.h"

@implementation CMPCheckEnvRequest

- (instancetype)init {
    self = [super init];
    if (self) {
//        self.cmpVersion = @"v1.0";
//        self.client = @"iphone";
//        self.identifier = @"";
    }
    return self;
}

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"url"];
}

#pragma mark-
#pragma mark-重载

- (NSString *)requestUrl {
    return _url;
}

- (NSString *)requestMethod {
    return kCMPRequestMethodPost;
}

- (BOOL)handleCookie {
    return NO;
}

@end
