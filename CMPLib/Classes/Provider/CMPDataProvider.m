//
//  CMPDataProvider.m
//  CMPCore
//
//  Created by youlin guo on 14-10-30.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//
#define kRequestObj @"requestObj"
#define kUrlRequestTimeOutSeconds 30
#define kFileDownloadRequestTimeOutSeconds 200
#define kFileUploadRequestTimeOutSeconds 200

#import "CMPDataProvider.h"
#import "JSON.h"
#import "CMPDataUtil.h"
#import "AFNetworking.h"
#import "CMPThreadSafeMutableDictionary.h"
#import "CMPAppDelegate.h"
#import "CMPServerUtils.h"
#import "KSRequestLogManager.h"
#import "KSLogManager.h"
#import "CMPURLUtils.h"

@interface CMPDataProvider ()

@property (nonatomic, strong)AFHTTPSessionManager *httpSessionManager;
@property (nonatomic, strong)AFHTTPSessionManager *updownloadSessionManager;
@property (nonatomic, strong)AFHTTPSessionManager *h5AppSessionManager;
@property (nonatomic, strong)CMPThreadSafeMutableDictionary *requestMap;
@property (nonatomic, strong)CMPThreadSafeMutableDictionary *requestObjMap;
@property (strong, nonatomic) AFJSONRequestSerializer *jsonRequestSerialize;
@property (strong, nonatomic) AFHTTPRequestSerializer *httpRequestSerialize;

@end

@implementation CMPDataProvider

#pragma mark-
#pragma mark Init

static CMPDataProvider* _instance;

+ (CMPDataProvider *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

- (void)dealloc {
    [_httpSessionManager invalidateSessionCancelingTasks:YES];
    _httpSessionManager = nil;
    [_updownloadSessionManager invalidateSessionCancelingTasks:YES];
    _updownloadSessionManager = nil;
    [_h5AppSessionManager invalidateSessionCancelingTasks:YES];
    _h5AppSessionManager = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (AFSecurityPolicy *)createCertificate
{
    return nil;
}

- (void)setup {
    if (!_requestMap) {
        _requestMap = [[CMPThreadSafeMutableDictionary alloc] init];
    }
    if (!_requestObjMap) {
        _requestObjMap = [[CMPThreadSafeMutableDictionary alloc] init];
    }
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
#if !DEBUG
    // 禁止抓包
    //    sessionConfig.connectionProxyDictionary = @{};
#endif
    self.httpSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfig];
    self.httpSessionManager.securityPolicy.allowInvalidCertificates = YES;
    self.httpSessionManager.securityPolicy.validatesDomainName = NO;
    self.httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self.httpSessionManager setDataTaskWillCacheResponseBlock:nil];
    
    self.updownloadSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfig];
    self.updownloadSessionManager.securityPolicy.allowInvalidCertificates = YES;
    self.updownloadSessionManager.securityPolicy.validatesDomainName = NO;
    [self.updownloadSessionManager setDataTaskWillCacheResponseBlock:nil];
    // 获取自定义证书
    AFSecurityPolicy *aSecurityPolicy = [self createCertificate];
    if (aSecurityPolicy) {
        self.httpSessionManager.securityPolicy.allowInvalidCertificates = NO;
        self.httpSessionManager.securityPolicy.validatesDomainName = YES;
        self.httpSessionManager.securityPolicy = aSecurityPolicy;
        //
        self.updownloadSessionManager.securityPolicy.allowInvalidCertificates = NO;
        self.updownloadSessionManager.securityPolicy.validatesDomainName = YES;
        self.updownloadSessionManager.securityPolicy = aSecurityPolicy;
    }
}

- (AFHTTPSessionManager *)h5AppSessionManager{
    if (!_h5AppSessionManager) {
        NSURLSessionConfiguration *sessionConfig1 = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig1.HTTPCookieStorage = nil;
        sessionConfig1.HTTPShouldSetCookies = NO;
        
        _h5AppSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfig1];
        _h5AppSessionManager.securityPolicy.allowInvalidCertificates = YES;
        _h5AppSessionManager.securityPolicy.validatesDomainName = NO;
        [_h5AppSessionManager setDataTaskWillCacheResponseBlock:nil];
        
        _h5AppSessionManager.requestSerializer.timeoutInterval = kFileDownloadRequestTimeOutSeconds;
        _h5AppSessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        AFSecurityPolicy *aSecurityPolicy = [self createCertificate];
        if (aSecurityPolicy) {
            _h5AppSessionManager.securityPolicy.allowInvalidCertificates = NO;
            _h5AppSessionManager.securityPolicy.validatesDomainName = YES;
            _h5AppSessionManager.securityPolicy = aSecurityPolicy;
        }
    }
    return _h5AppSessionManager;
}

- (NSURL *)URLFromStr:(NSString *)aStr
{
    if (!aStr) {
        return nil;
    }
//    NSString *aURL = [aStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //ks fix
    NSString *aURL = [aStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  characterSetWithCharactersInString:@"\"#%<>[\\]^`{|}+"].invertedSet];
    return [NSURL URLWithString:aURL];
}

- (void)handleRequestSuccess:(NSURLSessionDataTask *)task responseObject:(id)responseObject request:(CMPDataRequest *)aRequest
{
    NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    CMPDataResponse *aResponse = [[CMPDataResponse alloc] init];
    aResponse.responseStr = responseStr;
    NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)task.response;
    aResponse.responseHeaders = httpUrlResponse.allHeaderFields;
    aResponse.responseStatusCode = httpUrlResponse.statusCode;
    
    //ks add
    NSLog(@"ks log --- ***** CMPDataProvider ***** handleRequestSuccess:\nUrl:%@\nResponse:%@",aRequest.requestUrl,responseStr);
    [[KSRequestLogManager shareManager] handleResponse:aRequest.requestUrl reqid:aRequest.requestID];
    //
    SEL didFinishSelector = aRequest.requestDidFinishSelector;
    if (didFinishSelector && [aRequest.delegate respondsToSelector:didFinishSelector]) {
        [aRequest.delegate performSelector:didFinishSelector withObject:aRequest withObject:aResponse];
    }
    else if ([aRequest.delegate respondsToSelector:@selector(providerDidFinishLoad:request:response:)]) {
        [aRequest.delegate providerDidFinishLoad:self request:aRequest response:aResponse];
    }
    [self cancelWithRequestId:aRequest.requestID];
}

- (void)handleRequestFailure:(NSURLSessionDataTask *)task error:(NSError *)error request:(CMPDataRequest *)aRequest response:(NSURLResponse *)aResponse
{
    NSError *customError = nil;
    NSData *errorData = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
    NSDictionary *aUserInfo = nil;
    NSInteger errorCode = error.code;
    NSString *errorMsg = nil;
    NSString *newServerCode=@"ksnull";
    
    // 先判断是否有服务器的错误方式值
    if (errorData && errorData.length != 0) {
        NSString *aResult = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        aUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:aResult, @"responseString", nil];
        id obj = [aResult JSONValue];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic =  (NSDictionary *)obj;
            NSString *code = [resultDic objectForKey:@"code"];
            NSString *message = [resultDic objectForKey:@"message"];
            NSInteger aCode = [code integerValue];
            if (aCode > 0) {
                errorCode = aCode;
            }
            if (![NSString isNull:message]) {
                errorMsg = message;
            }
            if ([NSString isNotNull:code]) {
                newServerCode = code;
            }
        }
    }
    // 如果errorMsg为空
    if (!errorMsg) {
        // errorCode
        // -1001，请求超时,连接不上服务器
        // -1004, 不能链接到主机
        // -1005, 网络连接丢失
        // -1009，当前设备无网络
        // -1011, Request failed: not found (404)、 500内部错误 BadServerResponse
        if (errorCode == -1001 || errorCode == -1004 || errorCode == -1005/* || errorCode == -1011*/) {
            errorCode = -1001;
            errorMsg = [SY_STRING(@"Common_Server_CannotConnect") stringByAppendingFormat:@"[%ld]",errorCode];
        }
        else if (errorCode == -1009) {
            errorMsg = SY_STRING(@"Common_Network_Unavailable");
        }
        else {
            // 设置httpReponseHeader stutas code
            if (aResponse && [aResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)aResponse;
                errorCode = httpUrlResponse.statusCode;
            }
            // add end
            errorMsg = SY_STRING(@"Common_Server_DataError");
        }
    }
    
    customError = [NSError errorWithDomain:errorMsg code:errorCode userInfo:aUserInfo];
    
    //ks add
    NSLog(@"ks log --- ***** CMPDataProvider ***** handleRequestFailure:\nUrl:%@\nError:%@",aRequest.requestUrl,customError);
    
    // 所有当前服务器请求返回401都提示掉线
    NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    NSLog(@"response:statuscode:%ld\n%@",response.statusCode,response);
    // 如果请求reponse为401 并且为当前m3服务器地址，避免处理其他第三方服务器地址的401
    if (response.statusCode == 401 && [NSString isNotNull:aRequest.requestUrl] && [CMPServerUtils isCurrentServer:[NSURL URLWithString:aRequest.requestUrl]]) {
        CMPAppDelegate *appDelegate = (CMPAppDelegate *)[UIApplication sharedApplication].delegate;
        NSDictionary *userInfo = @{@"serverErrorCode" : @(errorCode),@"newServerErrorCode":newServerCode };
        NSError *error = [NSError errorWithDomain:customError.domain code:401 userInfo:userInfo];
        BOOL isHandled = [appDelegate handleError:error];
        if (isHandled) {
            [self cancelWithRequestId:aRequest.requestID];
            return;
        }
    }
    
    if ([aRequest.delegate respondsToSelector:@selector(provider:request:didFailLoadWithError:)]) {
        [aRequest.delegate provider:self request:aRequest didFailLoadWithError:customError];
    }
    if ([aRequest.delegate respondsToSelector:@selector(provider:request:didFailLoadWithOriginalError:errorMsg:)]) {
        [aRequest.delegate provider:self request:aRequest didFailLoadWithOriginalError:error errorMsg:customError];
    }
    [self cancelWithRequestId:aRequest.requestID];
}

- (void)handleFileUpdownloadProgress:(NSProgress *)aProgress request:(CMPDataRequest *)aRequest
{
    if ([aRequest.delegate respondsToSelector:@selector(providerProgessUpdate:request:ext:)]) {
        float currentValue = (float)aProgress.completedUnitCount/(float)aProgress.totalUnitCount;
        NSNumber *progress = [NSNumber numberWithFloat:currentValue];
        NSNumber *receiveBytes = [NSNumber numberWithLongLong:(long long)aProgress.completedUnitCount];
        NSNumber *totalBytes = [NSNumber numberWithLongLong:(long long)aProgress.totalUnitCount];
        NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:receiveBytes, @"receiveBytes", totalBytes, @"totalBytes", progress, @"progress", nil];
        [aRequest.delegate providerProgessUpdate:self request:aRequest ext:aDict];
    }
}

- (void)handleFileDownloadCompletion:(CMPDataRequest *)aRequest urlResponse:(NSURLResponse *)urlResponse error:(NSError *)error
{
    // 判断下载文件是否存在
    NSString *aStr = aRequest.downloadDestinationPath;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:aStr];
    if (!fileExists || error) {
        [self handleRequestFailure:nil error:error request:aRequest response:urlResponse];
        return;
    }
    CMPDataResponse *aResponse = [[CMPDataResponse alloc] init];
    aResponse.downloadDestinationPath = aRequest.downloadDestinationPath;
    NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)urlResponse;
    aResponse.responseHeaders = httpUrlResponse.allHeaderFields;
    
    //ks add
    NSLog(@"ks log --- ***** CMPDataProvider ***** handleFileDownloadCompletion:\nUrl:%@\nResponse:%@",aRequest.requestUrl,aResponse);
    [[KSRequestLogManager shareManager] handleResponse:aRequest.requestUrl reqid:aRequest.requestID];
    //
    SEL didFinishSelector = aRequest.requestDidFinishSelector;
    if (didFinishSelector && [aRequest.delegate respondsToSelector:didFinishSelector]) {
        [aRequest.delegate performSelector:didFinishSelector withObject:aRequest withObject:aResponse];
    }
    else if ([aRequest.delegate respondsToSelector:@selector(providerDidFinishLoad:request:response:)]) {
        [aRequest.delegate providerDidFinishLoad:self request:aRequest response:aResponse];
    }
    [self cancelWithRequestId:aRequest.requestID];
}

- (void)requestDidStart:(CMPDataRequest *)aRequest
{
    if ([aRequest.delegate respondsToSelector:@selector(providerDidStartLoad:request:)]) {
        [aRequest.delegate providerDidStartLoad:self request:aRequest];
    }
}

- (void)handleFormDataWithRequest:(CMPDataRequest *)aRequest
{
    NSString *url = aRequest.requestUrl;
    // add by guoyl for afnetworking
    NSDictionary *headers = aRequest.headers;
    if (![headers isKindOfClass:[NSDictionary class]]) {
        headers = nil;
    }
    id paramObj = aRequest.requestParam;
    NSString *aContentType = [headers objectForKey:@"Content-type"]; // 兼容低版本Content-type拼写错误
    if (!aContentType) {
        aContentType = [headers objectForKey:@"Content-Type"];
    }
    AFHTTPRequestSerializer *aAFHTTPRequestSerializer = nil;
    if ([aContentType containsString:@"application/json"]) {
        aAFHTTPRequestSerializer = [self jsonRequestSerializeWithHeaders:headers];
        NSString *aParamStr = (NSString *)aRequest.requestParam;
        if ([NSString isNotNull:aParamStr]) {
            paramObj = [aParamStr JSONValue];
        }
        else {
            paramObj = nil;
        }
    }
    else {
        aAFHTTPRequestSerializer = self.httpRequestSerialize;
    }
    NSInteger aTimeout = aRequest.timeout;
    if (aTimeout <= 0 || aTimeout >= kUrlRequestTimeOutSeconds) {
        aTimeout = kUrlRequestTimeOutSeconds;
    }
    if (aTimeout != aAFHTTPRequestSerializer.timeoutInterval) {
        aAFHTTPRequestSerializer.timeoutInterval = aTimeout;
    }
    
    NSString *method = aRequest.requestMethod;
    [self requestDidStart:aRequest];
    NSURLSessionDataTask *aTask = nil;
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(aRequest) aWeakRequest = aRequest;
    
    if ([method isEqualToString:kRequestMethodType_POST]) {
        aTask = [self.httpSessionManager POST:url parameters:paramObj requestSerializer:aAFHTTPRequestSerializer progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakSelf handleRequestSuccess:task responseObject:responseObject request:aWeakRequest];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf handleRequestFailure:task error:error request:aWeakRequest response:task.response];
        }];
    }
    else {
        aTask = [self.httpSessionManager GET:url parameters:paramObj requestSerializer:aAFHTTPRequestSerializer progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakSelf handleRequestSuccess:task responseObject:responseObject request:aWeakRequest];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf handleRequestFailure:task error:error request:aWeakRequest response:task.response];
        }];
    }
    if (aTask) {
        [_requestMap setObject:aTask forKey:aRequest.requestID];
    }
}

- (void)handleFileUploadWithRequest:(CMPDataRequest *)aRequest
{
    NSString *url = aRequest.requestUrl;
    self.updownloadSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.updownloadSessionManager.requestSerializer.timeoutInterval = kFileUploadRequestTimeOutSeconds;
    // 设置headers 开始
    NSDictionary *headers = aRequest.headers;
    if ([headers isKindOfClass:[NSDictionary class]]) {
        NSArray *aHeaderKeys = [headers allKeys];
        for (NSString *aKey in aHeaderKeys) {
            if ([aKey isEqualToString:@"token"]/* || [aKey isEqualToString:@"Cookie"]*/) {
                continue;
            }
            NSString *aValue = [headers objectForKey:aKey];
            [self.updownloadSessionManager.requestSerializer setValue:aValue forHTTPHeaderField:aKey];
        }
    }
    self.updownloadSessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    // 设置headers 结束
    NSURL *aFileUrl = [NSURL fileURLWithPath:aRequest.uploadFilePath];
    [self requestDidStart:aRequest];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(aRequest) aWeakRequest = aRequest;
    
    NSURLSessionDataTask *aTask = [self.updownloadSessionManager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:aFileUrl name:@"file" error:nil];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        [weakSelf handleFileUpdownloadProgress:uploadProgress request:aWeakRequest];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf handleRequestSuccess:task responseObject:responseObject request:aWeakRequest];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf handleRequestFailure:task error:error request:aWeakRequest response:task.response];
    }];
    [_requestMap setObject:aTask forKey:aRequest.requestID];
}

- (NSURLRequest *)downloadRequestWithUrl:(NSString *)aUrl headers:(NSDictionary *)aHeaders
{
    // 设置headers 开始
    NSURL *url = [NSURL URLWithString:aUrl];
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    mutableRequest.HTTPMethod = kRequestMethodType_GET;
    if ([aHeaders isKindOfClass:[NSDictionary class]]) {
        NSArray *aHeaderKeys = [aHeaders allKeys];
        for (NSString *aKey in aHeaderKeys) {
            if ([aKey isEqualToString:@"token"] /*|| [aKey isEqualToString:@"Cookie"] */|| [aKey isEqualToString:@"Content-Type"]) {
                continue;
            }
            NSString *aValue = [aHeaders objectForKey:aKey];
            [mutableRequest addValue:aValue forHTTPHeaderField:aKey];
        }
    }
    return mutableRequest;
}

- (void)handleFileDownloadWithRequest:(CMPDataRequest *)aRequest
{
    // 判断下载地址是否为空
    if (!aRequest.downloadDestinationPath) {
        [self handleRequestFailure:nil error:nil request:aRequest response:nil];
        return;
    }
    NSURLRequest *mutableRequest = [self downloadRequestWithUrl:aRequest.requestUrl headers:aRequest.headers];
    // 删除已经存在文件
    [[NSFileManager defaultManager] removeItemAtPath:aRequest.downloadDestinationPath error:nil];
    [self requestDidStart:aRequest];
        
    // 如果是下载h5应用的包
    if ([mutableRequest.URL.absoluteString containsString:@"m3/appManager/download/"]
        ||[mutableRequest.URL.absoluteString containsString:@"api/mobile/app/download/"]) {
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(aRequest) aWeakRequest = aRequest;
        NSURLSessionDownloadTask *aTask = [self.h5AppSessionManager downloadTaskWithRequest:mutableRequest progress:^(NSProgress * _Nonnull downloadProgress) {
            [weakSelf handleFileUpdownloadProgress:downloadProgress request:aWeakRequest];
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            __strong typeof(aRequest) aStrongRequest = aWeakRequest;
            NSString *aFilePath = aStrongRequest.downloadDestinationPath;
            if ([NSString isNull:aFilePath]) {
                aFilePath = @"";
            }
            return [NSURL fileURLWithPath:aFilePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [weakSelf handleFileDownloadCompletion:aWeakRequest urlResponse:response error:error];
        }];
        [aTask resume];
        [_requestMap setObject:aTask forKey:aRequest.requestID];
    }else{
        
        self.updownloadSessionManager.requestSerializer.timeoutInterval = kFileDownloadRequestTimeOutSeconds;
        self.updownloadSessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(aRequest) aWeakRequest = aRequest;
        NSURLSessionDownloadTask *aTask = [self.updownloadSessionManager downloadTaskWithRequest:mutableRequest progress:^(NSProgress * _Nonnull downloadProgress) {
            [weakSelf handleFileUpdownloadProgress:downloadProgress request:aWeakRequest];
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            __strong typeof(aRequest) aStrongRequest = aWeakRequest;
            NSString *aFilePath = aStrongRequest.downloadDestinationPath;
            if ([NSString isNull:aFilePath]) {
                aFilePath = @"";
            }
            return [NSURL fileURLWithPath:aFilePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [weakSelf handleFileDownloadCompletion:aWeakRequest urlResponse:response error:error];
        }];
        [aTask resume];
        [_requestMap setObject:aTask forKey:aRequest.requestID];
    }
    
    
}

- (void)addRequest:(CMPDataRequest *)aRequest isEncodeUrl:(BOOL)encode{
    NSString *url = aRequest.requestUrl;
    if (!encode) {
        aRequest.requestUrl = [url urlStrSafeHandle];
    }
    [_requestObjMap setObject:aRequest forKey:aRequest.requestID];
    NSInteger aRequestType = aRequest.requestType;
    
    NSDictionary *headers = aRequest.headers;
    if (!headers || ![headers isKindOfClass:[NSDictionary class]] || !headers.count) {
        headers = [CMPDataProvider headers];
    }
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
    NSURL *requestUrl = [NSURL URLWithString:aRequest.requestUrl];
    NSString *scheme = requestUrl.scheme;
    if (![NSString isNull:scheme]) {
        [mutableHeaders setObject:scheme forKey:@"accessm3-scheme"];
    }
    aRequest.headers = mutableHeaders;
    
    //ks add
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:aRequest.requestUrl]];
    NSLog(@"ks log --- ***** CMPDataProvider ***** addRequest:\nUrl:%@\nParams:%@\nHeaders:%@\nCookies:%@",aRequest.requestUrl,aRequest.requestParam,mutableHeaders,cookies);
    [[KSRequestLogManager shareManager] filterRequest:aRequest.requestUrl reqid:aRequest.requestID];
    
    switch (aRequestType) {
        case kDataRequestType_Url:
            [self handleFormDataWithRequest:aRequest];
            break;
        case kDataRequestType_FileDownload:
            [self handleFileDownloadWithRequest:aRequest];
            break;
        case kDataRequestType_FileUpload:
            [self handleFileUploadWithRequest:aRequest];
            break;
        default:
            break;
    }

}
- (void)addRequest:(CMPDataRequest *)aRequest
{
    NSString *url = aRequest.requestUrl;
    
    //忽略默认端口号80或443
    url = [CMPURLUtils ignoreDefaultPort:url];
    
    aRequest.requestUrl = [url urlStrSafeHandle];//ks fix --- 优化方案
    // 统一url编码
//    if ([NSURL URLWithString:url]) {//ks fix --- jira bug V5-26514 iOS端M3，无法通过搜索群文件名称查询群文件
//        aRequest.requestUrl = url;
//        NSLog(@"ks log --- %s -- url not encode",__func__);
//    }else{
//        aRequest.requestUrl = [url urlEncodingNew];
//        NSLog(@"ks log --- %s -- url encoded",__func__);
//    }
    [_requestObjMap setObject:aRequest forKey:aRequest.requestID];
    NSInteger aRequestType = aRequest.requestType;

    //添加accessm3-scheme server用以判断http、https,避免代理服务器的影响
    NSDictionary *headers = aRequest.headers;
    if (!headers || ![headers isKindOfClass:[NSDictionary class]] || !headers.count) {
        headers = [CMPDataProvider headers];
    }
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
    NSURL *requestUrl = [NSURL URLWithString:aRequest.requestUrl];
    NSString *scheme = requestUrl.scheme;
    if (![NSString isNull:scheme]) {
        [mutableHeaders setObject:scheme forKey:@"accessm3-scheme"];
    }
    aRequest.headers = mutableHeaders;
    
    //ks add
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:aRequest.requestUrl]];
    NSLog(@"ks log --- ***** CMPDataProvider ***** addRequest:\nUrl:%@\nParams:%@\nHeaders:%@\nCookies:%@",aRequest.requestUrl,aRequest.requestParam,mutableHeaders,cookies);
    [[KSRequestLogManager shareManager] filterRequest:aRequest.requestUrl reqid:aRequest.requestID];
    
    if ([KSLogManager shareManager].isDev && cookies && cookies.count && [CMPCore sharedInstance].jsessionId) {
        for (NSHTTPCookie *cookie in cookies) {
            if ([CMPCore sharedInstance].currentServer.host && [cookie.domain isEqualToString:[CMPCore sharedInstance].currentServer.host]) {
                if ([cookie.name isEqualToString:@"JSESSIONID"]) {
                    if (cookie.value && [cookie.value isEqualToString:[CMPCore sharedInstance].jsessionId]){
                        
                    }else{
                        NSLog(@"update http cookie");
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:cookie.properties];
                        [dic setValue:[CMPCore sharedInstance].jsessionId forKey:@"value"];
                        NSHTTPCookie *_ac = [NSHTTPCookie cookieWithProperties:dic];
                        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:_ac];
                        
                        NSLog(@"ks log --- ***** CMPDataProvider ***** addRequest:newCookies:%@",[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:aRequest.requestUrl]]);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"nativeCookiesChanges" object:nil];
                        });
                    }
                    break;
                }
            }
        }
    }
    
    switch (aRequestType) {
        case kDataRequestType_Url:
            [self handleFormDataWithRequest:aRequest];
            break;
        case kDataRequestType_FileDownload:
            [self handleFileDownloadWithRequest:aRequest];
            break;
        case kDataRequestType_FileUpload:
            [self handleFileUploadWithRequest:aRequest];
            break;
        default:
            break;
    }
}

- (void)cancelWithRequestId:(NSString *)aRequestId
{
    if (!aRequestId) {
        return;
    }
    if (!_requestMap || ![_requestMap isKindOfClass:[NSMutableDictionary class]] ||
        !_requestObjMap || ![_requestObjMap isKindOfClass:[NSMutableDictionary class]]) {
        return;
    }
    aRequestId = [aRequestId copy];
    NSURLSessionTask *req = [_requestMap objectForKey:aRequestId];
    [req cancel];
    [_requestMap removeObjectForKey:aRequestId];
    CMPDataRequest *aRequestObj = [_requestObjMap objectForKey:aRequestId];
    aRequestObj.delegate = nil;
    [_requestObjMap removeObjectForKey:aRequestId];
}

- (void)cancelAllRequestsWithCompleteBlock:(void(^)(void))block
{
    NSArray *aRequests = [_requestMap allValues];
    for (NSURLSessionTask *req in aRequests) {
        [req cancel];
    }
    [_requestMap removeAllObjects];
    [_requestObjMap removeAllObjects];
    if (block) {
        block();
    }
    NSLog(@"CMPDataProvider cancelAllRequests alertGroup");
}

- (void)cancelRequestsWithDelegate:(id)aDelegate
{
    if (!_requestObjMap) return;
    // 查找需要删除的delegate request对象
    NSMutableArray *aList = nil;
    for (NSString *aRequestId in _requestObjMap.allKeys) {
        if (_requestObjMap && _requestObjMap[aRequestId]) {
            CMPDataRequest *aRequest = [_requestObjMap objectForKey:aRequestId];
            if (!aRequest || ![aRequest isKindOfClass:[CMPDataRequest class]]) {
                continue;
            }
            if (!aRequest.delegate || aRequest.delegate == aDelegate) {
                NSString *aRequestId = aRequest.requestID;
                aRequest.delegate = nil;
                NSURLSessionTask *req = [_requestMap objectForKey:aRequestId];
                if (req) {
                    [req cancel];
                }
                if (_requestMap && _requestMap[aRequestId]){
                    [_requestMap removeObjectForKey:aRequestId];
                }
                if (!aList) {
                    aList = [[NSMutableArray alloc] init];
                }
                [aList addObject:aRequestId];
            }
        }
    }
    if (aList && _requestObjMap) {
        NSLog(@"%s___alist:%@____requestObjMap:%@",__func__,aList,_requestObjMap);
        [_requestObjMap removeObjectsForKeys:aList];
    }
}

+ (NSDictionary *)headers
{
    NSDictionary *dic = @{
        @"Accept" : @"application/json,text/html,application/xhtml+xml,application/xml,image/webp,image/apng,*/*; charset=utf-8",
        @"Accept-Language" : [CMPCore languageCode],
        @"Content-Type" : @"application/json; charset=utf-8",
        @"User-Agent" : [NSString stringWithFormat:@"seeyon-m3/%@",[CMPCore clinetVersion]],
        @"cmp-plugins" : @"cmp/faceid"
    };
    NSMutableDictionary *mDict = [dic mutableCopy];
    NSString *aTicket = [CMPCore sharedInstance].contentTicket;
    NSString *aExtension = [CMPCore sharedInstance].contentExtension;
    if (![NSString isNull:aTicket]) {
        [mDict setObject:aTicket forKey:@"Content-Ticket"];
    }
    if (![NSString isNull:aExtension]) {
        [mDict setObject:aExtension forKey:@"Content-Extension"];
    }
    
    NSString *token = [CMPCore sharedInstance].token;
    if (![NSString isNull:token]) {
        [mDict setObject:token forKey:@"ltoken"];
    }
    //    mDict[@"token"] = @"2LjjLY2zFy7";
    [mDict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"sendtime"];
    return mDict;
}

- (NSURLSessionTask *)getTaskByUrl:(NSString *)url{
    CMPDataRequest *urlReq;
    for (CMPDataRequest *req in _requestObjMap.allValues) {
        if ([req.requestUrl isEqualToString:url]) {
            urlReq = req;
            break;
        }
    }
    if (urlReq && urlReq.requestID) {
        NSURLSessionTask *task = [_requestMap objectForKey:urlReq.requestID];
        return task;
    }
    return nil;
}

#pragma mark-
#pragma mark Serializer 管理
- (AFJSONRequestSerializer *)jsonRequestSerializeWithHeaders:(NSDictionary *)aHeader  {
    AFJSONRequestSerializer *aJsonRequestSerialize = [AFJSONRequestSerializer serializer];
    aJsonRequestSerialize.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    aJsonRequestSerialize.HTTPShouldUsePipelining = YES;
    [self setHeadersForSerializer:aJsonRequestSerialize withHeaders:aHeader];
    return aJsonRequestSerialize;
}

- (AFHTTPRequestSerializer *)httpRequestSerialize {
    if (!_httpRequestSerialize) {
        _httpRequestSerialize = [AFHTTPRequestSerializer serializer];
        _httpRequestSerialize.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _httpRequestSerialize.HTTPShouldUsePipelining = YES;
    }
    //以下两句代码从if中移出来,解决再次发起非json请求时使用上一次header信息的问题
    NSDictionary *headers = [CMPDataProvider headers];
    [self setHeadersForSerializer:_httpRequestSerialize withHeaders:headers];
    return _httpRequestSerialize;
}

- (void)setHeadersForSerializer:(AFHTTPRequestSerializer *)serializer withHeaders:(NSDictionary *)headers {
    if ([headers isKindOfClass:[NSDictionary class]]) {
        NSArray *aHeaderKeys = [headers allKeys];
        for (NSString *aKey in aHeaderKeys) {
            if ([aKey isEqualToString:@"token"] /*|| [aKey isEqualToString:@"Cookie"]*/) {
                continue;
            }
            NSString *aValue = [headers objectForKey:aKey];
            [serializer setValue:aValue forHTTPHeaderField:aKey];
        }
    }
}

- (void)resetRequestSerialize {
    _jsonRequestSerialize = nil;
    _httpRequestSerialize = nil;
}

@end
