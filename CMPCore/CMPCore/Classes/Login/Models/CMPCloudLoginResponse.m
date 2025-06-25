//
//  CMPCloudLoginResponse.m
//  M3
//
//  Created by CRMO on 2018/9/11.
//

#import "CMPCloudLoginResponse.h"

@implementation CMPCloudLoginResponseData
- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"addr_m3:%@，addr_oa:%@，corpid:%@", self.addr_m3, self.addr_oa, self.corpid];
    return description;
}
@end

@implementation CMPCloudLoginResponse

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : [CMPCloudLoginResponseData class]};
}

- (NSString *)errorDetail {
    switch (self.code) {
        case 2001:
            _errorDetail = SY_STRING(@"login_cloud_error_2001");
            break;
        case 2002:
            _errorDetail = SY_STRING(@"login_cloud_error_2002");
            break;
        case 2003:
            _errorDetail = SY_STRING(@"login_cloud_error_2003");
            break;
        default:
            _errorDetail = SY_STRING(@"login_cloud_error_default");
            break;
    }
    return _errorDetail;
}

- (BOOL)success {
    if (self.code >= 1000 && self.code < 2000) {
        return YES;
    }
    return NO;
}

@end
