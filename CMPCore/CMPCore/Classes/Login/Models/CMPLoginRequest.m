//
//  CMPLoginRequest.m
//  M3
//
//  Created by youlin on 2020/3/3.
//

#import "CMPLoginRequest.h"
#import <CMPLib/CMPURLUtils.h>

NSString *const kRequestUrlLoginPath = @"/api/verification/login";

@interface CMPLoginRequest ()
@property(nonatomic, copy)NSString *contextPath;
@end

@implementation CMPLoginRequest

- (id)initWithDelegate:(id)deleagte param:(NSString *)aParam host:(NSString *)aHost serverVersion:(NSString *)aVersion serverContextPath:(NSString *)contextPath
{
    self = [super initWithRequestID:nil];
    if (self) {
        self.delegate = deleagte;
        self.requestUrl = [self loginUrl:aVersion host:aHost serverContextPath:contextPath];
        self.requestMethod = kRequestMethodType_POST;
        self.httpShouldHandleCookies = YES;
        self.requestParam = aParam;
        self.requestType = kDataRequestType_Url;
        self.contextPath = contextPath;
    }
    return self;
}

- (id)initWithDelegate:(id)deleagte param:(NSString *)aParam
{
    return [self initWithDelegate:deleagte param:aParam host:CMP_SERVER_URL serverVersion:CMP_SERVER_VERSION serverContextPath:CMPCore.sharedInstance.currentServer.contextPath];
}

- (NSString *)loginUrl:(NSString *)version host:(NSString *)aHost serverContextPath:(NSString *)contextPath
{
    NSString *aPath = [CMPURLUtils urlPathMatch:kRequestUrlLoginPath serverVersion:version contextPath:contextPath];
    NSString *aUrl = [CMPURLUtils requestURLWithHost:aHost path:aPath];
    return aUrl;
}

@end
