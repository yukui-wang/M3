//
//  CMPDeviceBindRequest.m
//  M3
//
//  Created by CRMO on 2017/12/6.
//

#import "CMPDeviceBindRequest.h"
#import <CMPLib/SvUDIDTools.h>
#import <CMPLib/CMPURLUtils.h>

@interface CMPDeviceBindRequest ()
@property (copy, nonatomic) NSString *serverUrl;
@property (copy, nonatomic) NSString *serverVersion;
@property (copy, nonatomic) NSString *serverContextPath;

@end

@implementation CMPDeviceBindRequest

- (instancetype)initWithLoginName:(NSString *)loginName phone:(NSString *)phone serverUrl:(NSString *)url serverVersion:(NSString *)serverVersion serverContextPath:(NSString *)contextPath {
    self = [super init];
    if (self) {
        if (![NSString isNull:loginName]) {
            self.loginName = loginName;
        }
        if (![NSString isNull:phone]) {
            self.login_mobliephone = phone;
        }
        self.clientName = [[UIDevice currentDevice] name];
        self.longClientName = [[UIDevice currentDevice] name];
        self.clientNum = [SvUDIDTools UDID];
        if ([CMPFeatureSupportControl isLoginDistinguishDevice:serverVersion]) {
            self.clientType = INTERFACE_IS_PAD ? @"iPad" : @"iPhone";
        }
        else {
            self.clientType = @"iOS";
        }
        self.serverUrl = url;
        self.serverVersion = serverVersion;
        self.serverContextPath = contextPath;
    }
    return self;
}

#pragma mark-
#pragma mark-重载

- (NSString *)requestUrl {
    //硬件绑定申请
    NSString *aPath = [CMPURLUtils urlPathMatch:@"/api/bind/apply" serverVersion:self.serverVersion contextPath:self.serverContextPath];
    NSString *host = [CMPCore serverurlWithUrl:self.serverUrl serverVersion:self.serverVersion];
    NSString *aUrl = [CMPURLUtils requestURLWithHost:host path:aPath];
    return aUrl;
}

- (NSString *)requestMethod {
    return kCMPRequestMethodPost;
}

+ (NSArray *)modelPropertyBlacklist {
    return @[@"serverContextPath"];
}

@end
