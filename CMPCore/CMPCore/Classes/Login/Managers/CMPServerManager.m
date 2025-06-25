//
//  CMPServerManager.m
//  M3
//
//  Created by CRMO on 2018/6/12.
//

#import "CMPServerManager.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/NSObject+CMPHUDView.h>

@interface CMPServerManager()<CMPDataProviderDelegate>

@property (copy, nonatomic) CMPServerManagerCheckSuccess successBlock;
@property (copy, nonatomic) CMPServerManagerCheckFail failBlock;
@property (assign, nonatomic) BOOL hasHandleCheckEnvSuccess;  // 是否已经处理了检查成功返回
@property (assign, nonatomic) NSInteger checkEnvFailTimes;  // 检查环境失败次数
@property (strong, nonatomic) NSError *lastError; // 用来记录上一次的错误
@property (strong, nonatomic) NSMutableArray *requestIDs; // 记录请求ID

@end

@implementation CMPServerManager

- (void)checkServerWithHost:(NSString *)aHost
                       port:(NSString *)aPort
                    success:(CMPServerManagerCheckSuccess)success
                       fail:(CMPServerManagerCheckFail)fail {
    _successBlock = success;
    _failBlock = fail;
    self.hasHandleCheckEnvSuccess= NO;
    self.checkEnvFailTimes = 0;
    self.lastError = nil;
    NSString *aServerUrl = [NSString stringWithFormat:@"%@:%@", aHost, aPort];
    // 判断是否指定http或https，如果没有指定自动判断
    if ([aHost hasPrefix:CMPHttpPrefix] || [aHost hasPrefix:CMPHttpsPrefix]) {
        self.checkEnvFailTimes++;
        [self checkEnv:aServerUrl];
    }
    else {
        NSString *aHttpUrl = [NSString stringWithFormat:@"%@://%@:%@", CMPHttpPrefix, aHost, aPort];
        NSString *aHttpsUrl = [NSString stringWithFormat:@"%@://%@:%@", CMPHttpsPrefix, aHost, aPort];
        [self checkEnv:aHttpUrl];
        [self checkEnv:aHttpsUrl];
    }
}

- (void)checkServerWithURL:(NSString *)url
                   success:(CMPServerManagerCheckSuccess)success
                      fail:(CMPServerManagerCheckFail)fail {
    _successBlock = success;
    _failBlock = fail;
    self.hasHandleCheckEnvSuccess= NO;
    self.checkEnvFailTimes = 1;
    self.lastError = nil;
    [self checkEnv:url];
}
- (void)checkServerWithServerModel:(CMPServerModel *)serverModel
                           success:(CMPServerManagerCheckSuccess)success
                              fail:(CMPServerManagerCheckFail)fail {
    NSString *contextPath = serverModel.contextPath;
    if ([NSString isNull:contextPath]) {
        [self checkServerWithURL:serverModel.fullUrl success:success fail:fail];
        return;
    }
    _successBlock = success;
    _failBlock = fail;
    self.hasHandleCheckEnvSuccess= NO;
    self.checkEnvFailTimes = 1;
    self.lastError = nil;
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@/rest/m3/appManager/checkEnv",serverModel.fullUrl,contextPath];
    CMPCheckEnvRequest *request = [[CMPCheckEnvRequest alloc] init];
    request.url = requestUrl;
    request.cmpVersion = [CMPCore clinetVersion];
    request.client = @"iphone";
    request.port = serverModel.port;
           
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = [request yy_modelToJSONString];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    [self.requestIDs addObject:aDataRequest.requestID];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    
}

/**
 检查服务器信息
 */
- (void)checkEnv:(NSString *)serverUrl11
{
    if (![self checkUrlFormat:serverUrl11]) {
        return;
    }
    
    BOOL(^blk)(NSString *) = ^(NSString *oriStr){
        NSArray *arr = [oriStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/:"]];
        if (arr.count==5) {
            NSString *ip = arr[3];
            if (ip.length) {
                NSString *pre = @".*[a-zA-Z]+.*";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pre];
                return [predicate evaluateWithObject:ip];
            }
        }
        return NO;
    };
    
    NSURL *url = [NSURL URLWithString:serverUrl11];
    
    NSString *serverUrl = serverUrl11;
    if([serverUrl11 hasPrefix:CMPHttpPrefix] && [serverUrl11 hasSuffix:@":80"]){
        BOOL needHandle = blk(serverUrl11);
        if (needHandle) {
            serverUrl = [serverUrl11 replaceCharacter:@":80" withString:@""];
        }
    }else if ([serverUrl11 hasPrefix:CMPHttpsPrefix] && [serverUrl11 hasSuffix:@":443"]) {
        BOOL needHandle = blk(serverUrl11);
        if (needHandle) {
            serverUrl = [serverUrl11 replaceCharacter:@":443" withString:@""];
        }
    }
    
    CMPCheckEnvRequest *request = [[CMPCheckEnvRequest alloc] init];
    request.url = [[CMPCore serverurlWithUrl:serverUrl] stringByAppendingString:@"/api/verification/checkEnv"];
    request.cmpVersion = [CMPCore clinetVersion];
    request.client = @"iphone";
    request.port = [NSString stringWithFormat:@"%@",url.port];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [[CMPCore serverurlForMobilePortalWithUrl:serverUrl] stringByAppendingString:@"/api/verification/checkEnv"];;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = [request yy_modelToJSONString];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    
    __weak typeof(self) weakSelf = self;
    void(^againRequestBlock)(void) = ^{
        CMPCheckEnvRequest *request = [[CMPCheckEnvRequest alloc] init];
        request.url = [serverUrl stringByAppendingString:@"/seeyon/rest/m3/appManager/checkEnv"];
        request.cmpVersion = [CMPCore clinetVersion];
        request.client = @"iphone";
        request.port = [NSString stringWithFormat:@"%@",url.port];
        
        CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
        aDataRequest.requestUrl = [serverUrl stringByAppendingString:@"/seeyon/rest/m3/appManager/checkEnv"];;
        aDataRequest.delegate = self;
        aDataRequest.requestMethod = kRequestMethodType_POST;
        aDataRequest.headers = [CMPDataProvider headers];
        aDataRequest.requestParam = [request yy_modelToJSONString];
        aDataRequest.requestType = kDataRequestType_Url;
        aDataRequest.httpShouldHandleCookies = NO;
        [weakSelf.requestIDs addObject:aDataRequest.requestID];
        [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    };
    
    aDataRequest.userInfo = @{@"againRequestBlock" : [againRequestBlock copy]};
    [self.requestIDs addObject:aDataRequest.requestID];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (BOOL)checkUrlFormat:(NSString *)url
{
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *aUrl = [NSURL URLWithString:encodeUrl];
    if (!aUrl) {
        NSError *error = [NSError errorWithDomain:SY_STRING(@"login_server_address_error") code:0 userInfo:nil];
        if (_failBlock) {
            _failBlock(error);
        }
        return NO;
    }
    return YES;
}

- (void)cancel {
    for (NSString *requestID in self.requestIDs) {
        [[CMPDataProvider sharedInstance] cancelWithRequestId:requestID];
    }
    [self.requestIDs removeAllObjects];
}

- (NSMutableArray *)requestIDs {
    if (!_requestIDs) {
        _requestIDs = [NSMutableArray array];
    }
    return _requestIDs;
}

#pragma mark-CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    [self.requestIDs removeObject:aRequest.requestID];
    if (self.hasHandleCheckEnvSuccess) {
        return;
    }
    NSDictionary *responseDic = [aResponse.responseStr JSONValue];
    NSInteger code = [responseDic[@"code"] integerValue];
    NSString *message = responseDic[@"message"];
    //返回code 302 的时候去掉mobile_portal,再次以最新API请求
    if (code == 302) {
        void(^againRequestBlock)(void) = [aRequest.userInfo[@"againRequestBlock"] copy];
        if (againRequestBlock) {
            againRequestBlock();
        }
        return;
    }
    
    CMPCheckEnvResponse *model = [[CMPCheckEnvResponse class] yy_modelWithJSON:aResponse.responseStr];
    BOOL isSuccess = (code == 200 || code == 0);
    if (!model || isSuccess == NO) {
        self.checkEnvFailTimes++;
        if (self.checkEnvFailTimes == 2) {
            
            NSString *errorMessage = [NSString isNotNull:message] ? message:SY_STRING(@"Common_Server_CannotConnect");
            NSError *mError = [NSError errorWithDomain:errorMessage code:0 userInfo:nil];
            if (_failBlock) {
                _failBlock(mError);
            }
        }
        return;
    }
    
    if (![NSString isNull:model.data.identifier]) {
        NSURLComponents *urlComp = [NSURLComponents componentsWithString:aRequest.requestUrl];
        if (!urlComp.port) {
            if ([urlComp.scheme isEqualToString:@"http"]) {
                urlComp.port = @80;
            } else if ([urlComp.scheme isEqualToString:@"https"]) {
                urlComp.port = @443;
            }
        }
        [CMPServerManager showNetworkTipInView:[UIApplication sharedApplication].keyWindow.rootViewController.view port:urlComp.port];
        
        self.hasHandleCheckEnvSuccess = YES;
        if (_successBlock) {
            _successBlock(model, aRequest.requestUrl);
        }
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    [self.requestIDs removeObject:aRequest.requestID];
    
    //ks fix -- qu root
    if (error && error.code == 404) {
        if ([aRequest.requestUrl containsString:@"/mobile_portal/"]) {
            void(^againRequestBlock)(void) = [aRequest.userInfo[@"againRequestBlock"] copy];
            if (againRequestBlock) {
                againRequestBlock();
            }
            return;
        }
    }
    //end
    
    self.checkEnvFailTimes++;
    // 当检查次数为2次时，错误回调
    if (self.checkEnvFailTimes == 2) {
        NSInteger lastErrorCode = _lastError.code;
        NSString *errorDomain = error.domain;
        if (error.code != 500006) {
            errorDomain = [SY_STRING(@"Common_Server_CannotConnect") stringByAppendingFormat:@"[%ld]",error.code];//如果code不是50006，数据请求失败应该给用户提示服务器无法连接;
        }
        if (lastErrorCode == 500006) { // 如果有500006错误码提示，说明该方式的连接被管理员限制了，优先提示
            errorDomain = _lastError.domain;
        }
        NSError *mError = [NSError errorWithDomain:errorDomain code:0 userInfo:nil];
        if (_failBlock) {
            _failBlock(mError);
        }
    } else {
        self.lastError = error;
    }
}

+ (void)showNetworkTipInView:(UIView *)view port:(NSNumber *)port{
    if ([port integerValue]<=8000) {
        [view cmp_showHUDToBottomWithText:SY_STRING(@"Common_Server_Port_Alert")];
    }
}

@end
