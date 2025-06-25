//
//  CMPServerModel.m
//  M3
//
//  Created by CRMO on 2017/11/1.
//

#import "CMPServerModel.h"
#import "NSString+CMPString.h"
#import "NSObject+YYModel.h"
#import <CMPLib/CMPFeatureSupportControlHeader.h>
#import <CMPLib/CMPCore.h>

@implementation CMPServerModel

- (instancetype)initWithHost:(NSString *)host
                        port:(NSString *)port
                      isSafe:(BOOL)isSafe
                      scheme:(NSString *)aScheme
                        note:(NSString *)note
                      inUsed:(BOOL)inUsed
                    serverID:(NSString *)serverID
               serverVersion:(NSString *)aServerVersion
                updateServer:(NSString *)aUpdateServer
{
    if (self = [super init]) {
        self.host = host;
        self.port = port;
        self.isSafe = isSafe;
        self.scheme = aScheme;
        self.note = note;
        self.inUsed = inUsed;
        self.serverID = serverID;
        self.serverVersion = aServerVersion;
        self.updateServer = aUpdateServer;
        self.fullUrl = [NSString stringWithFormat:@"%@://%@:%@", aScheme, host, port];
        self.uniqueID = [NSString md5:self.fullUrl];
    }
    return self;
}

- (BOOL)isEqualWithHost:(NSString *)host port:(NSString *)port isSafe:(BOOL)isSafe {
    if ([host.lowercaseString isEqual:self.host.lowercaseString] &&
        [port isEqual:self.port] &&
        isSafe == self.isSafe) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isEqual:(id)object {
    if (!object ||
        ![object isKindOfClass:[CMPServerModel class]]) {
        return NO;
    }
    CMPServerModel *comparedObject = (CMPServerModel *)object;
    return [self isEqualWithHost:comparedObject.host port:comparedObject.port isSafe:comparedObject.isSafe];
}

- (BOOL)isMainAssAccount {
    NSString *assAccountFlag = self.extend1;
    if (!assAccountFlag ||
        [NSString isNull:assAccountFlag] ||
        ![assAccountFlag isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isCloudServer {
    NSString *assAccountFlag = self.extend1;
    if (![NSString isNull:assAccountFlag] &&
        [assAccountFlag isEqualToString:@"2"]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)serverVersionNumber {
    if (_serverVersionNumber == 0) {
        _serverVersionNumber = [self intValueOfServerVersion:self.serverVersion];
    }
    return _serverVersionNumber;
}

- (NSInteger)intValueOfServerVersion:(NSString *)serverVersion {
    if ([NSString isNull:serverVersion]) {
        return 0;
    }
    NSArray *list = [serverVersion componentsSeparatedByString:@"."];
    NSInteger value = 0;
    for (NSString *str in list) {
        NSInteger num = [str integerValue];
        value = value * 10 + num;
    }
    return value;
}

- (NSString *)extend10 {
    if (!_extend10) {
        _extend10 = [[[CMPServerExtradDataModel alloc] init] yy_modelToJSONString];
    }
    return _extend10;
}

- (CMPServerExtradDataModel *)extradDataModel {
    return [CMPServerExtradDataModel yy_modelWithJSON:self.extend10];
}
//多租户
- (void)setupOrgCode:(NSString *)orgCode path:(NSString *)path {
    self.extend5 = path;
    self.extend6 = orgCode;
}
- (NSString *)orgCode {
    return self.extend6;
}

- (NSString *)contextPath {
    return self.extend5;
}
// 服务器信息到H5缓存Local Storage
- (NSDictionary *)h5CacheDic {
    if (!self.scheme || !self.scheme.length) {
        self.scheme = [CMPCore sharedInstance].currentServer.scheme;
    }
    if (!self.host || !self.host.length) {
        self.host = [CMPCore sharedInstance].currentServer.host;
    }
    if (!self.port || !self.port.length) {
        self.port = [CMPCore sharedInstance].currentServer.port;
    }
    NSDictionary *h5CacheDic = @{@"ip" : self.host ?: @"",
                                 @"port": self.port ?: @"",
                                 @"model" : self.scheme ?: @"",
                                 @"identifier" : self.serverID ?: @"",
                                 @"updateServer" : self.updateServer ?: @"",
                                 @"serverVersion" : self.serverVersion ?: @"",
                                 @"contextPath":self.contextPath?:@"",
                                 @"orgCode":self.orgCode?:@""};
    return h5CacheDic;
}


@end

@implementation CMPServerExtradDataModel

- (instancetype)init {
    if (self = [super init]) {
        self.isZhixinServerAvailable = YES;
    }
    return self;
}

@end


@implementation CMPServerVpnModel

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"vpnSPA" : @"extend1"};
}

@end
