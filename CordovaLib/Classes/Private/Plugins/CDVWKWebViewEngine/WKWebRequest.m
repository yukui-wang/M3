//
//  WKWebRequest.m
//  CordovaLib
//
//  Created by wujiansheng on 2020/7/8.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "WKWebRequest.h"
#import "KKJSBridgeURLRequestSerialization.h"
#import "WKJSBridgeManager.h"
#import "CDVJSON_private.h"
#import "WKWebFormData.h"
#import "WKWebConstant.h"
#import "WKWebRequestCacheManager.h"

typedef void (^WKWebRequestCompletionHandlerBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface WKWebRequest()<NSURLSessionDelegate>
{
    id _reqData;
}
@property(nonatomic, strong)NSDictionary *requestHeaders;
@property(nonatomic, assign)BOOL isAsync;//是否异步请求
@property(nonatomic, assign)BOOL isUpload;//是否是上传文件
@property(nonatomic, copy)NSString *method;
@property(nonatomic, strong)NSDictionary *contentBody;
@property(nonatomic, assign)NSInteger total;
@property(nonatomic, assign)NSInteger pageIndex;
@property(nonatomic, copy)NSString  *responseType;



@property(nonatomic, weak) WKWebView *webView;

@property(nonatomic, strong)NSURLSessionTask *dataTask;
@property(nonatomic, strong)NSURLSession *session;
@property(nonatomic, strong)NSMutableData *receiveData;
@property(nonatomic, strong)NSHTTPURLResponse *httpResponse;
@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, assign)long long  totalDataSize;
@property(nonatomic, assign)long long  loadedDataSize;

@property(nonatomic, strong)NSHTTPURLResponse *redirectionResponse;
@property(nonatomic, strong)NSURLRequest *redirectionRequest;

@property(nonatomic,assign) BOOL isDontDecodeUrl;

@end

@implementation WKWebRequest

- (void)dealloc {
    [self abort];
    [self cancelTimer];
    NSLog(@"WKWebRequest dealloc");
}

- (id)initWithBody:(NSDictionary *)body
           webView:(WKWebView *)webView{
    if (self = [super init]) {
        self.callbackID = body[@"id"];
        self.url = [self urlWithUrl:body[@"url"] baseURL:webView.URL userName:body[@"userName"] password:body[@"password"]];
//        self.url = [self.url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  characterSetWithCharactersInString:@"\"#<>[\\]^`{|}+"].invertedSet];
        self.isAsync = [body[@"isAsync"] boolValue];//是否异步请求
        self.method = body[@"method"];
        self.contentBody = body[@"contentBody"];
        self.total = [body[@"total"] integerValue];
        self.pageIndex = [body[@"pageIndex"] integerValue];
        self.webView = webView;
        self.isUpload = [body[@"isUpload"] boolValue];
        self.totalDataSize = 0;
        self.responseType = body[@"responseType"];
        self.needCacheResponse = NO;
        NSMutableDictionary *header = [NSMutableDictionary dictionaryWithDictionary: body[@"headers"]];
        NSString *needCacheResponseKey = @"submitAndJumpPage";
        if ([header.allKeys containsObject:needCacheResponseKey]) {
            self.needCacheResponse = [header[needCacheResponseKey] boolValue];
            [header removeObjectForKey:needCacheResponseKey];
        }
        
        NSString *decodeTag = [NSString stringWithFormat:@"%@",body[@"cantEncodeUrl"]];
        _isDontDecodeUrl = [decodeTag isEqualToString:@"1"];

        self.requestHeaders = header;
        _reqData = [self _contentData];
        
        
    }
    return self;
}

- (void)send {
    NSLog(@"%s__%@",__FUNCTION__,self.url);
    if ([WKJSBridgeManager isSyncCommand:[NSURL URLWithString:self.url]]) {
        // __jsbridge__
        if (self.delegate  && [self.delegate respondsToSelector:@selector(wkWebRequest:didCompletedWithResponse:)]) {
            NSString *requestData = _reqData;
            NSString *responseString = [WKJSBridgeManager excuteSyncCommandWithRequestBody:requestData];
            NSString *result = [WKWebRequest callbackStringWithId:self.callbackID
                                                         httpCode:200
                                                          headers:nil
                                                             data:responseString?:@""
                                                       responseURL:@""
                                                       base64Data:nil];
            [self.delegate wkWebRequest:self didCompletedWithResponse:result];
        }
        return;
    }
    
    BOOL isLoadLocalFile = [self sendLocalFileRequest];
    if (isLoadLocalFile) {
        return;
    }
    
    if (self.isUpload) {
        [self sendUploadRequest];
    }
    else if (self.isAsync) {
        [self sendAsyncRequest];
    }
    else {
        [self sendSyncRequest];
    }
}

- (void)abort {
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    self.dataTask = nil;
}
- (BOOL)responseBase64 {
    return [self.responseType isEqualToString:@"blob"] || [self.responseType isEqualToString:@"arraybuffer"];
}
//同步
- (void)sendSyncRequest {
//    //同步请求返回的参数
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    //建立连接，下载数据，同步请求
//    NSData *data = [NSURLConnection sendSynchronousRequest:[self urlRequest] returningResponse:&response error:&error];
//    [self handleResponseData:data response:response error:error];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSOperationQueue *queue = [NSOperationQueue new];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:queue];

    __block NSData *data = nil;
    __block NSURLResponse *response = nil;
    __block NSError *error = nil;
    [[session dataTaskWithRequest:[self urlRequest]
            completionHandler:^(NSData *taskData,
                                NSURLResponse *taskResponse,
                                NSError *taskError) {
                data = taskData;
                response = taskResponse;
                error = taskError;
                dispatch_semaphore_signal(semaphore);
            }] resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self handleResponseData:data response:response error:error];
}
//异步
- (void)sendAsyncRequest {
    NSOperationQueue *queue = [NSOperationQueue new];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:queue];
    self.dataTask = [session dataTaskWithRequest:[self urlRequest]];
    self.receiveData = [[NSMutableData alloc] init];
    [self.dataTask resume];
}

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wint-conversion"

//加载应用包文件 返回 是否加载本地文件
- (BOOL)sendLocalFileRequest {
    NSURL *URL = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    BOOL isLocalURL = NO;
    Class CMPCachedUrlParser = NSClassFromString(@"CMPCachedUrlParser");
    SEL chacedUrl = NSSelectorFromString(@"chacedUrl:");
    SEL mimeTypeWithSuffix = NSSelectorFromString(@"mimeTypeWithSuffix:");
    SEL cachedDataWithUrl = NSSelectorFromString(@"cachedDataWithUrl:");
    isLocalURL = [CMPCachedUrlParser performSelector:chacedUrl withObject:URL];
    
//    NSURL *url = [NSURL URLWithString:@"xxxx"];
//    Class application = NSClassFromString(@"UIApplication");
//    SEL shareApplication = NSSelectorFromString(@"SharedApplication");
//    SEL openUrl = NSSelectorFromString(@"openURL:options:");
//    id obj = [application performSelector:shareApplication];
//    [obj performSelector:openUrl withObject:url withObject:nil];
    
    if (isLocalURL) {
        NSString *absoluteString = [URL.absoluteString lowercaseString];
        NSString *aStr = [[absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0];
        NSString *mimeType =  [CMPCachedUrlParser performSelector:mimeTypeWithSuffix withObject:[aStr pathExtension]];
        NSData *aData = [CMPCachedUrlParser performSelector:cachedDataWithUrl withObject:request];;
        NSInteger code = 200;
        if (!aData) {
            code = 404;
        }
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:URL statusCode:code HTTPVersion:@"HTTP/1.1" headerFields:@{@"Content-Type" : mimeType , @"Cache-Control" : @"max-age=0"}];
        [self handleResponseData:aData response:response error:nil];
        return YES;
    }
    return NO;
}

#pragma clang diagnostic pop

- (void)sendUploadRequest {
    NSOperationQueue *queue = [NSOperationQueue new];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:queue];
    self.receiveData = [[NSMutableData alloc] init];
    self.dataTask = [session dataTaskWithRequest:[self urlRequest]];
    [self cancelTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [self.dataTask resume];
}

- (NSString *)urlWithUrl:(NSString *)url baseURL:(NSURL *)baseURL userName:(NSString *)userName password:(NSString *)password {
    NSString *urlString = url;
    if (!urlString.length) {
        return nil;
    }
    NSString *scheme = nil;
    if (![urlString containsString:@"://"]) {
        scheme = baseURL.scheme?:@"http";
        if ([urlString hasPrefix:@"//"]) {
            urlString = [NSString stringWithFormat:@"%@:%@", scheme, urlString];
        }
        else if ([urlString hasPrefix:@"/"]) {
            urlString = [NSString stringWithFormat:@"%@://%@%@", scheme, baseURL.host, urlString];
        }
        else {
            urlString = [NSString stringWithFormat:@"%@://%@", scheme, urlString];
        }
    }
    if (![WKWebRequest isNullString:userName] && ![WKWebRequest isNullString:password]) {
        //处理用户名及密码拼成类似：https://1:2@www.baidu.com/server
        if (!scheme) {
            NSURL *aUrl = [NSURL URLWithString:urlString];
            scheme = aUrl.scheme;
        }
        if (scheme) {
            NSMutableString *mutableString = [NSMutableString stringWithString:urlString];
            NSString *insertStr = [NSString stringWithFormat:@"%@:%@@",userName,password];
            [mutableString insertString:insertStr atIndex:scheme.length+3];
            urlString = [NSString stringWithString:mutableString];
        }
    }
    return urlString;
}

-(id)_contentData
{
    NSString *cacheId = self.requestHeaders[@"__bodyCacheId__"];
    if (cacheId) {
        NSArray *cacheArr = [[WKWebRequestCacheManager shareInstance] cacheById:cacheId];
        if (cacheArr && cacheArr.count) {
            //ks add暂时只有1个
            WKWebRequestCache *cache = cacheArr.firstObject;
            if (cache.data) {
                return cache.data;
            }
        }
    }
    return self.contentBody[@"data"];
}

- (NSMutableURLRequest *)urlRequest {
    NSString *aUrl;
    if (_isDontDecodeUrl) {//ks fix --- V5-27213
        aUrl = self.url;
    }else{
        aUrl = [WKWebRequest urlStrSafeHandle:self.url];//ks fix --- jira bug V5-27664
    }
    
    //忽略默认端口号80或443
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:aUrl];
    if (urlComponents) {
        BOOL http_flag = [urlComponents.scheme.lowercaseString containsString:@"http"] &&  urlComponents.port.integerValue == 80;
        BOOL http_s_flag = [urlComponents.scheme.lowercaseString containsString:@"https"] && urlComponents.port.integerValue == 443;
        if (http_flag || http_s_flag) {
            urlComponents.port = nil;
            aUrl = urlComponents.URL.absoluteString;
        }
    }
    
    NSURL *URL = [NSURL URLWithString:aUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    NSString *method = self.method.lowercaseString;
    request.HTTPMethod = method.uppercaseString;
    [request setAllHTTPHeaderFields:self.requestHeaders];
    
    if ([method isEqualToString:@"get"] || [method isEqualToString:@"delete"]) {
        NSLog(@"ks log --- urlRequest get or delete");
        return [self handelRequest:request];
    }
    
    //数据类型,string字符串类型，File文件类型，Blob类型，FormData类型， ArrayBuffer类型， document类型，FormData表单类型
    NSString *dataType = self.contentBody[@"dataType"];
    NSLog(@"ks log --- urlRequest dataType : %@",dataType);
    if (self.isUpload || [dataType isEqualToString:@"FormData"]) {
        NSString *contentType = request.allHTTPHeaderFields[@"Content-Type"];
        NSArray *dataArray = _reqData;
        if ([contentType containsString:@"application/x-www-form-urlencoded"]) {
            NSMutableString *dataString = [NSMutableString string];
            for (NSDictionary *dataDic in dataArray) {
                WKWebFormData *object = [[WKWebFormData alloc] initWithFormData:dataDic];
                [dataString appendFormat:@"%@=%@&",object.name,object.value];
            }
            if (dataArray.count) {
                [dataString deleteCharactersInRange:NSMakeRange(dataString.length - 1, 1)];
            }
            request.HTTPBody = [dataString dataUsingEncoding:[WKWebRequest stringEncodingWithHeaders:self.requestHeaders]];
        } else {
            KKJSBridgeURLRequestSerialization *serializer = [KKJSBridgeURLRequestSerialization urlRequestSerialization];
            request = [serializer multipartFormRequestWithRequest:request parameters:[NSDictionary dictionary] constructingBodyWithBlock:^(id<KKJSBridgeMultipartFormData>  _Nonnull formData) {
                       for (NSDictionary *dataDic in dataArray) {
                           WKWebFormData *object = [[WKWebFormData alloc] initWithFormData:dataDic];
                           if (object.mimeType) {
                               //value 为base64
                               [formData appendPartWithFileData:object.fileData name:object.name fileName:object.fileName mimeType:object.mimeType];
                           }
                           else {
                               //value 为string
                               NSData *byteData = [object.value dataUsingEncoding:[WKWebRequest stringEncodingWithHeaders:self.requestHeaders]];
                               [formData appendPartWithFormData:byteData name:object.name];
                           }
                       }
                   } error:nil];
        }
    }
    else if ([dataType isEqualToString:@"string"]) {
         NSString *data = _reqData ? : @"";
         NSString *contentType = request.allHTTPHeaderFields[@"Content-Type"];
         if (!contentType) {
             id JSONObject = [data cdv_JSONObject];
             if (JSONObject) {
                 [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                 request.HTTPBody = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:nil];
             } else {
                  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                  request.HTTPBody = [data dataUsingEncoding:[WKWebRequest stringEncodingWithHeaders:self.requestHeaders]];
             }
         } else {
             id JSONObject = [data cdv_JSONObject];
             if ([contentType containsString:@"application/json"] && JSONObject) {
                 //BUG_普通_V8.0sp1_OS_嘉宝莉化工集团股份有限公司_调用M3的标准接口,ios端ajax请求得不到返回_BUG2021010829556
//                request.HTTPBody = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:nil];
                 //金山预览发现的问题，多了转义字符\，换成下面方法
                NSData *transData = [data dataUsingEncoding:NSUTF8StringEncoding];
                request.HTTPBody = transData;
             } else {
                request.HTTPBody = [data dataUsingEncoding:[WKWebRequest stringEncodingWithHeaders:self.requestHeaders]];
             }
       }
    }
    else if ([dataType isEqualToString:@"File"]) {
        NSDictionary *data = _reqData;
        WKWebFormData *object = [[WKWebFormData alloc] initWithFileData:data];
        KKJSBridgeURLRequestSerialization *serializer = [KKJSBridgeURLRequestSerialization urlRequestSerialization];
        request = [serializer multipartFormRequestWithRequest:request parameters:[NSDictionary dictionary] constructingBodyWithBlock:^(id<KKJSBridgeMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:object.fileData name:object.name fileName:object.fileName mimeType:object.mimeType];
        } error:nil];
        
    }
    else if ([dataType isEqualToString:@"Blob"]) {
        id data = _reqData;
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSString *base64Str = data[@"base64"] ? : @"";
            if ([base64Str isEqualToString:@"data:"]) {
                request.HTTPBody =  [[NSData alloc] init];
            }else{
                request.HTTPBody =  [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
            }
        }
    }
    else if ([dataType isEqualToString:@"ArrayBuffer"]) {
        NSString *data = _reqData ? : @"";
        request.HTTPBody =  [[NSData alloc] initWithBase64EncodedString:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    else if ([dataType isEqualToString:@"document"]) {
        
    }
    
    NSLog(@"ks log --- urlRequest post...");
    return [self handelRequest:request];
}

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wint-conversion"

- (NSMutableURLRequest *)handelRequest:(NSMutableURLRequest *)request {
    BOOL isCurrentServer = NO;
    Class CMPServerUtils = NSClassFromString(@"CMPServerUtils");
    SEL isCurrentServerSEL = NSSelectorFromString(@"isCurrentServer:");
    isCurrentServer  = [CMPServerUtils performSelector:isCurrentServerSEL withObject:request.URL];
       
    if (isCurrentServer) {
        Class CMPCoreClass = NSClassFromString(@"CMPCore");
        SEL sharedInstance = NSSelectorFromString(@"sharedInstance");
        SEL contentTicketSEL = NSSelectorFromString(@"contentTicket");
        SEL contentExtensionSEL = NSSelectorFromString(@"contentExtension");
        SEL tokenSEL = NSSelectorFromString(@"token");
        
        id CMPCore = [CMPCoreClass performSelector:sharedInstance];
        NSString *aTicket =  [CMPCore performSelector:contentTicketSEL];
        NSString *aExtension = [CMPCore performSelector:contentExtensionSEL];
        NSString *token = [CMPCore performSelector:tokenSEL];
        
        if ([aTicket isKindOfClass:[NSString class]] && aTicket.length > 0) {
            [request setValue:aTicket forHTTPHeaderField:@"Content-Ticket"];
        }
        if ([aExtension isKindOfClass:[NSString class]] && aExtension.length > 0) {
            [request setValue:aExtension forHTTPHeaderField:@"Content-Extension"];
        }
        if ([token isKindOfClass:[NSString class]] && token.length > 0) {
            [request setValue:token forHTTPHeaderField:@"ltoken"];
        }
    }
    NSLog(@"ks log --- urlRequest final result: %@,%@,%@",request.URL,request.allHTTPHeaderFields,request.HTTPBody);
    return request;
}

#pragma clang diagnostic pop

- (void)handleResponseData:(NSData *)data response:(NSURLResponse *)response error :(NSError * )error {
    NSLog(@"ks log --- wkwebrequest handleResponseData : %@,%@,%@",data,response,error);
    NSHTTPURLResponse *httpResponse = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        httpResponse = (id)response;
    }
    NSMutableDictionary *allHeaderFields = [NSMutableDictionary dictionaryWithDictionary:httpResponse.allHeaderFields];
    NSInteger statusCode = httpResponse.statusCode;
    NSString *responseUrl = httpResponse.URL.absoluteString;
    NSLog(@"ks log --- wkwebrequest handleResponseData : %@,%@,%@",allHeaderFields,@(statusCode),responseUrl);
    if (self.needCacheResponse) {
        NSLog(@"ks log --- wkwebrequest handleResponseData need cache");
        //缓存response
        WKWebResponseRecord *record = [[WKWebResponseRecord alloc] init];
        record.data = data;
        record.response = response;
        self.responseRecord = record;
        self.responseUrl = responseUrl;
        //判断是否是重定向
        if (self.redirectionResponse) {
            NSLog(@"ks log --- wkwebrequest handleResponseData need redirect");
            NSMutableDictionary *temp = [allHeaderFields mutableCopy];
            NSMutableDictionary *tempRedirection = [self.redirectionResponse.allHeaderFields mutableCopy];
            [tempRedirection setObject:@(self.redirectionResponse.statusCode) forKey:@"status"];
            [tempRedirection setObject:self.responseUrl forKey:@"Location"];
            [temp setObject:tempRedirection forKey:@"redirectionResponseHeader"];
            allHeaderFields = temp;
            NSLog(@"ks log --- wkwebrequest handleResponseData redirect final headers:%@",allHeaderFields);
        }
    }
   
    NSString *responseString = nil;
    NSString *base64ResponseString;
    if (data && data.length > 0) {
        if (self.responseType) {
            responseString = [self responseBase64] ?[data base64EncodedStringWithOptions:0]: [WKWebRequest responseStringWithData:data headers:allHeaderFields];
        } else {
            responseString = [WKWebRequest responseStringWithData:data headers:allHeaderFields];
            base64ResponseString = [data base64EncodedStringWithOptions:0];
        }
    }
    else if (error){
        responseString = error.localizedDescription;
    }
    
    if (response) {
        //ks fix 有的版本第一次通过NSHTTPCookieStorage拿不到cookie，先手动存储一次
        NSArray *cookiesForCurrentResponse = [NSHTTPCookie cookiesWithResponseHeaderFields:[httpResponse allHeaderFields] forURL:response.URL];
        for (NSHTTPCookie *cookie in cookiesForCurrentResponse) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        
        //ks fix cookie拼接到header 传给js （中建三局）
        NSString *cookieStr = allHeaderFields[@"Set-Cookie"] ? : @"";
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:response.URL];
        for (NSHTTPCookie *cookie in cookies) {
            if (cookieStr.length>0) {
                cookieStr = [cookieStr stringByAppendingFormat:@"; %@=%@",cookie.name,cookie.value];
            }else{
                cookieStr = [cookieStr stringByAppendingFormat:@"%@=%@",cookie.name,cookie.value];
            }
        };
        [allHeaderFields setObject:cookieStr forKey:@"Set-Cookie"];
    }
    
    NSString *aCookies = [allHeaderFields objectForKey:@"Set-Cookie"];
    if (![WKWebRequest isNullString:aCookies]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:knativeCookiesChangesNotification object:responseUrl];
    }
    
    if (self.delegate  && [self.delegate respondsToSelector:@selector(wkWebRequest:didCompletedWithResponse:)]) {
        NSString *result = [WKWebRequest callbackStringWithId:self.callbackID
                                                     httpCode:statusCode
                                                      headers:allHeaderFields
                                                         data:responseString?:@""
                                                  responseURL:responseUrl?:@""
                                                   base64Data:base64ResponseString];
        [self.delegate wkWebRequest:self didCompletedWithResponse:result];
    }
}


+ (BOOL)isNullString:(NSString *)aStr {
    NSString *string = aStr;
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    if ([aStr isEqualToString:@"<null>"]) {
        return YES;
    }
    return NO;
}

+ (NSStringEncoding)stringEncodingWithHeaders:(NSDictionary *)headers{
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    /// 对一些国内常见编码进行支持
    NSString *charset = headers[@"Content-Type"];
    if (charset && ([charset.lowercaseString containsString:@"gb2312"] || [charset.lowercaseString containsString:@"gbk"])) {
        stringEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    }
    return stringEncoding;
}

+ (NSString *)responseStringWithData:(NSData *)data headers:(NSDictionary *)headers {
    if (!data) {
        return @"";
    }
    NSStringEncoding stringEncoding = [WKWebRequest stringEncodingWithHeaders:headers];
    NSString *responseString = [[NSString alloc] initWithData:data encoding:stringEncoding];
    if (!responseString) {
        return @"";
    }
    NSMutableString *tempData = [NSMutableString stringWithString:responseString];
    [tempData replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0,tempData.length)];
    [tempData replaceOccurrencesOfString:@"\r" withString:@"" options:NSLiteralSearch range:NSMakeRange(0,tempData.length)];
    [tempData replaceOccurrencesOfString:@"\r\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0,tempData.length)];
    return responseString;
}

+ (NSString *)callbackStringWithId:(id)requestId
                          httpCode:(NSInteger)httpCode
                           headers:(nullable NSDictionary *)headers
                              data:(NSString *)data
                       responseURL:(NSString *)responseURL
                        base64Data:(nullable NSString *)base64Data {
    return [self callbackStringWithId:requestId
                             httpCode:httpCode
                              headers:headers
                                 data:data
                          responseURL:responseURL
                           base64Data:base64Data
                            totalSize:0
                           loadedSize:0];
}
+ (NSString *)callbackStringWithId:(id)requestId
                          httpCode:(NSInteger)httpCode
                           headers:(nullable NSDictionary *)headers
                              data:(NSString *)data
                       responseURL:(NSString *)responseURL
                        base64Data:(NSString *)base64Data
                         totalSize:(long long)totalSize
                        loadedSize:(long long)loadedSize {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"status"] = @(httpCode);
    dict[@"headers"] = headers;
    dict[@"responseText"] = data;
    dict[@"responseURL"] = responseURL;
    if (base64Data) {
        dict[@"base64ResponseText"] = base64Data;
    }
    if (totalSize  > 0 ) {
        dict[@"uploadProgress"] = @{
            @"loaded":[NSNumber numberWithLongLong:loadedSize],
            @"total":[NSNumber numberWithLongLong:totalSize]
        };
    }
    NSString *jsonString = [dict cdv_JSONString];
    return jsonString;
}

- (void)cancelTimer {
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = nil;
}

- (void)timerAction {
    if (self.loadedDataSize == 0) {
        return;
    }
    if (self.loadedDataSize == self.totalDataSize ) {
        [self cancelTimer];
        return;
    }
    
    if (self.delegate  && [self.delegate respondsToSelector:@selector(wkWebRequest:uploadProgressWithResponse:)]){
        NSString *jsonString = [WKWebRequest callbackStringWithId:self.callbackID
                                                         httpCode:200
                                                          headers:self.httpResponse.allHeaderFields
                                                             data:@""
                                                      responseURL:self.httpResponse.URL
                                                       base64Data:nil
                                                        totalSize:self.totalDataSize
                                                       loadedSize:self.loadedDataSize];
        NSLog(@"!!!!timerAction :%@",jsonString);
        [self.delegate wkWebRequest:self uploadProgressWithResponse:jsonString];
    }
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session
didBecomeInvalidWithError:(nullable NSError *)error {
#ifdef DEBUG
    NSLog(@"WKWebRequest didBecomeInvalidWithError %@", error.localizedDescription);
#endif
}

#pragma mark -- NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                     willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                                     newRequest:(NSURLRequest *)request
                              completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    self.redirectionResponse = response;
    self.redirectionRequest = request;
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    self.httpResponse = (id)response;
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.receiveData appendData:data];
}

#pragma mark -- NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    // error = nil请求完成，否则请求失败，
    [self cancelTimer];
    [self handleResponseData:self.receiveData response:self.httpResponse error:error];
    self.receiveData = nil;
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    self.loadedDataSize = totalBytesSent;
    self.totalDataSize = totalBytesExpectedToSend;
    NSLog(@"totalBytesExpectedToSend :%lld:%lld:%lld",bytesSent,totalBytesSent,totalBytesExpectedToSend);
}


- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    // 1.判断服务器返回的证书类型, 是否是服务器信任
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        /*
         NSURLSessionAuthChallengeUseCredential = 0,                     使用证书
         NSURLSessionAuthChallengePerformDefaultHandling = 1,            忽略证书(默认的处理方式)
         NSURLSessionAuthChallengeCancelAuthenticationChallenge = 2,     忽略书证, 并取消这次请求
         NSURLSessionAuthChallengeRejectProtectionSpace = 3,            拒绝当前这一次, 下一次再询问
         */
//        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
 
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential , card);
    }
}


+(NSString *)urlStrSafeHandle:(NSString *)oriStr
{
    if (![oriStr containsString:@"://"]) {
        return oriStr;
    }
    NSString *aStr = [[NSString alloc] initWithString:oriStr];
    NSString *bStr;
    BOOL goon = YES;
    while (goon) {
        bStr = [aStr stringByRemovingPercentEncoding];
        if (!bStr || [aStr isEqualToString:bStr]) {
            goon = NO;
        }else{
            aStr = bStr;
        }
    };
//    NSArray *arr = [aStr componentsSeparatedByString:@"?"];
//    if (arr.count == 2) {
//        NSString *queryStr = arr.lastObject;
//        if (queryStr.length>0) {
//            queryStr = [queryStr stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
//            aStr = [arr.firstObject stringByAppendingFormat:@"?%@",queryStr];
//        }
//    }
    NSURLComponents *components = [[NSURLComponents alloc]initWithString:aStr];
    if([components.host containsString:@"["] && [components.host containsString:@"["]){
        return [self encodeIPv6:aStr];
    }

    return [aStr stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
}
+ (NSString *)encodeIPv6:(NSString *)ipv6Str{
    NSString *urlString = ipv6Str;
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

    NSString *host = components.host;
    NSString *encodedHost = [host stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    components.host = encodedHost;

    NSString *path = components.path;
    NSString *encodedPath = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    components.path = encodedPath;

    NSString *query = components.query;
    NSString *encodedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    components.query = encodedQuery;

    NSURL *encodedUrl = components.URL;
    
    return encodedUrl.absoluteString;
}

@end
