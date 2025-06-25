//
//  CMPURLProtocol.m
//  CMPCore
//
//  Created by youlin on 16/5/17.
//
//

#import "CMPURLProtocol.h"
#import "CMPCachedUrlParser.h"
#import "CMPCore.h"
#import "CMPJSBridgeManager.h"
#import "CMPServerUtils.h"
#import "CMPURLCacheUtil.h"
#import <CordovaLib/WKWebConstant.h>
#import <CordovaLib/WKWebRequestManager.h>
#define URLProtocolHandledKey @"URLProtocolHandledKey"
#import "CMPURLProtocolManager.h"

#import <CordovaLib/WKWebRequestCacheManager.h>
#import <CordovaLib/WKWebFormData.h>
#import <CordovaLib/KKJSBridgeURLRequestSerialization.h>
#import <CordovaLib/WKWebRequest.h>
#import <CordovaLib/CDVJSON_private.h>
#import "NSString+CMPString.h"
#import "CMPURLUtils.h"

@interface CMPURLProtocol()<NSURLSessionDataDelegate>
@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
@property (nonatomic, readwrite, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfig;
@property (nonatomic, readwrite, strong) NSURLSessionDataTask *dataTask;
- (void)appendData:(NSData *)newData;

@end

@implementation CMPURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest*)theRequest
{
    NSURL *url = [theRequest URL];
    NSLog(@"ks log --- %s -- url : %@",__func__,url);
    if ([CMPCachedUrlParser chacedUrl:url]) {
        return YES;
    }
    if ([CMPJSBridgeManager isSyncCommand:url]) {
        return YES;
    }
    if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:theRequest]) {
        return NO;
    }
    // 如果是M3的服务器地址
    if ([CMPServerUtils isCurrentServer:url]) {
        return YES;
    }
    if (url.scheme && [url.scheme hasPrefix:@"http"]) {
        
        //ks add 发版前先注释掉
//        NSDictionary *headers = theRequest.allHTTPHeaderFields;
//        NSString *reqHeadsStr = headers[@"User-Agent"];
//        if (reqHeadsStr && [reqHeadsStr containsString:@"cmpignore=1"]) {
//            return NO;
//        }
        __block BOOL containIgnore = NO;
        
        NSString *queryStr = url.query;
        NSArray *ignoreQueryArr = [CMPURLProtocolManager sharedInstance].ignoreQueryArr;
        [ignoreQueryArr enumerateObjectsUsingBlock:^(NSString  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([queryStr containsString:obj]){
                containIgnore = YES;
                *stop = YES;
            }
        }];
        if (!containIgnore) {
            NSString *hostStr = url.host;
            NSArray *ignoreHostArr = [CMPURLProtocolManager sharedInstance].ignoreHostArr;
            [ignoreHostArr enumerateObjectsUsingBlock:^(NSString  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([hostStr containsString:obj]){
                    containIgnore = YES;
                    *stop = YES;
                }
            }];
        }
        return !containIgnore;
    }
    
    return [super canInitWithRequest:theRequest];
}

- (void)startLoading
{
    NSURL *url = [[self request] URL];
    
    //ks add -- 下载更新优化，检查加载资源是否更新完毕
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        Class CMPCheckUpdateManager = NSClassFromString(@"CMPCheckUpdateManager");
        SEL sharedManager = NSSelectorFromString(@"sharedManager");
        SEL checkUrlState = NSSelectorFromString(@"checkUrlState:");
        [[CMPCheckUpdateManager performSelector:sharedManager] performSelector:checkUrlState withObject:url];
    });
    //end
    
    //ks add --- tmd为了兼容业务的不按规矩办事的逻辑
    NSString *host = url.host;
    if ([host isEqualToString:@"seeyonbase.v5.cmp"]) {
        NSString *urlStr = url.absoluteString;
        NSString *currentServer = [CMPCore sharedInstance].serverurl;
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"seeyonbase.v5.cmp" withString:currentServer];
        url = [NSURL URLWithString:urlStr];
    }
    //ks end
    
    if ([CMPJSBridgeManager isSyncCommand:url]) { // js同步调用方法
        NSData *reponseData = [CMPJSBridgeManager excuteSyncCommand:[self request]];
        [self sendResponseWithResponseCode:200 data:reponseData mimeType:nil];
    }
    else if ([CMPCachedUrlParser chacedUrl:url]) {
        NSString *absoluteString = [url.absoluteString lowercaseString];
        NSString *aStr = [[absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0];
        NSString *mimeType = [CMPCachedUrlParser mimeTypeWithSuffix:[aStr pathExtension]];
        NSData *aData = [CMPCachedUrlParser cachedDataWithUrl:[self request]];
        NSInteger code = 200;
        if (!aData) {
            code = 404;
        }
        [self sendResponseWithResponseCode:code data:aData mimeType:mimeType];
    }
    else {
        if ([[self request].HTTPMethod.lowercaseString isEqualToString:@"get"]) {
            WKWebResponseRecord *record = [WKWebRequestManager cacheResponseForUrl:url.absoluteString];
            if (record && record.response) {
                [[self client] URLProtocol:self didReceiveResponse:record.response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                if (record.data != nil) {
                    [[self client] URLProtocol:self didLoadData:record.data];
                }
                [[self client] URLProtocolDidFinishLoading:self];
                return;
            }
        }
        
        
        // 根据request获取CMPCachedData
       CMPCachedData *aCachedData = [CMPURLCacheUtil cachedDataWithRequest:[self request]];
        if ([CMPURLCacheUtil isValid:aCachedData]) {
            NSData *data = [aCachedData data];
            NSURLResponse *response = [aCachedData response];
            NSURLRequest *redirectRequest = [aCachedData redirectRequest];
            if (redirectRequest) {
              [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
            } else {
              [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed]; // we handle caching ourselves.
              [[self client] URLProtocol:self didLoadData:data];
              [[self client] URLProtocolDidFinishLoading:self];
            }
        }
        else if (url.scheme && [url.scheme hasPrefix:@"http"]) {
            NSMutableURLRequest *mutableReqeust = [self handleRequest:[self request]];
            mutableReqeust.allHTTPHeaderFields = self.request.allHTTPHeaderFields;
            mutableReqeust.cachePolicy = NSURLRequestUseProtocolCachePolicy;
            mutableReqeust.HTTPShouldHandleCookies = YES;
            
            //ks add 解决body丢失问题
            NSDictionary *headers = self.request.allHTTPHeaderFields;
            NSString *bodycacheid  = headers[@"__bodyCacheId__"];
            
            if (bodycacheid) {
                NSArray<WKWebRequestCache *> *cacheArr = [[WKWebRequestCacheManager shareInstance] cacheById:bodycacheid];
                if (cacheArr && cacheArr.count) {
                    WKWebRequestCache *aCache = cacheArr.firstObject;
                    NSString *dataType = aCache.type;
                    
                    if ([dataType isEqualToString:@"FormData"]) {
                        NSString *contentType = self.request.allHTTPHeaderFields[@"Content-Type"];
                        NSArray *dataArray = aCache.data;
                        if ([contentType containsString:@"application/x-www-form-urlencoded"]) {
                            NSMutableString *dataString = [NSMutableString string];
                            for (NSDictionary *dataDic in dataArray) {
                                WKWebFormData *object = [[WKWebFormData alloc] initWithFormData:dataDic];
                                [dataString appendFormat:@"%@=%@&",object.name,object.value];
                            }
                            if (dataArray.count) {
                                [dataString deleteCharactersInRange:NSMakeRange(dataString.length - 1, 1)];
                            }
                            mutableReqeust.HTTPBody = [dataString dataUsingEncoding:[WKWebRequest stringEncodingWithHeaders:self.request.allHTTPHeaderFields]];
                        } else {
                            KKJSBridgeURLRequestSerialization *serializer = [KKJSBridgeURLRequestSerialization urlRequestSerialization];
                            mutableReqeust = [serializer multipartFormRequestWithRequest:mutableReqeust parameters:[NSDictionary dictionary] constructingBodyWithBlock:^(id<KKJSBridgeMultipartFormData>  _Nonnull formData) {
                                       for (NSDictionary *dataDic in dataArray) {
                                           WKWebFormData *object = [[WKWebFormData alloc] initWithFormData:dataDic];
                                           if (object.mimeType) {
                                               //value 为base64
                                               [formData appendPartWithFileData:object.fileData name:object.name fileName:object.fileName mimeType:object.mimeType];
                                           }
                                           else {
                                               //value 为string
                                               NSData *byteData = [object.value dataUsingEncoding:[WKWebRequest stringEncodingWithHeaders:self.request.allHTTPHeaderFields]];
                                               [formData appendPartWithFormData:byteData name:object.name];
                                           }
                                       }
                                   } error:nil];
                        }
                    }else if ([dataType isEqualToString:@"string"]) {
                        NSString *data = aCache.data ? : @"";
                        NSString *contentType = mutableReqeust.allHTTPHeaderFields[@"Content-Type"];
                        if (!contentType) {
                            id JSONObject = [data cdv_JSONObject];
                            if (JSONObject) {
                                [mutableReqeust setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                                mutableReqeust.HTTPBody = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:nil];
                            } else {
                                 [mutableReqeust setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                                mutableReqeust.HTTPBody = [data dataUsingEncoding:[WKWebRequest stringEncodingWithHeaders:self.request.allHTTPHeaderFields]];
                            }
                        } else {
                            id JSONObject = [data cdv_JSONObject];
                            if ([contentType containsString:@"application/json"] && JSONObject) {
                                //BUG_普通_V8.0sp1_OS_嘉宝莉化工集团股份有限公司_调用M3的标准接口,ios端ajax请求得不到返回_BUG2021010829556
                                mutableReqeust.HTTPBody = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:nil];
                            } else {
                                mutableReqeust.HTTPBody = [data dataUsingEncoding:[WKWebRequest stringEncodingWithHeaders:self.request.allHTTPHeaderFields]];
                            }
                      }
                   }else if ([dataType isEqualToString:@"File"]) {
                       NSDictionary *data = aCache.data;
                       WKWebFormData *object = [[WKWebFormData alloc] initWithFileData:data];
                       KKJSBridgeURLRequestSerialization *serializer = [KKJSBridgeURLRequestSerialization urlRequestSerialization];
                       mutableReqeust = [serializer multipartFormRequestWithRequest:mutableReqeust parameters:[NSDictionary dictionary] constructingBodyWithBlock:^(id<KKJSBridgeMultipartFormData>  _Nonnull formData) {
                           [formData appendPartWithFileData:object.fileData name:object.name fileName:object.fileName mimeType:object.mimeType];
                       } error:nil];
                       
                   }else if ([dataType isEqualToString:@"Blob"]) {
                        id data = aCache.data;
                        if (data && [data isKindOfClass:[NSDictionary class]]) {
                            NSString *base64Str = data[@"base64"] ? : @"";
                            NSData *basedata = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
                            mutableReqeust.HTTPBody = basedata;
                        }
                    }else if ([dataType isEqualToString:@"ArrayBuffer"]) {
                        NSString *data = aCache.data ? : @"";
                        mutableReqeust.HTTPBody =  [[NSData alloc] initWithBase64EncodedString:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    }
                }
                [[WKWebRequestCacheManager shareInstance] removeCacheById:bodycacheid];
            }
            //ks end
            
            // 标示改request已经处理过了，防止无限循环
            [NSURLProtocol setProperty:@(YES) forKey:URLProtocolHandledKey inRequest:mutableReqeust];
            self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
            
//            [_dataTask cancel];
//            _dataTask = nil;
//            _dataTask = [self.session dataTaskWithRequest:mutableReqeust];
//            [_dataTask resume];
            
        }
        else {
            [super startLoading];
        }
    }
}

-(NSURLSessionConfiguration *)sessionConfig
{
    if (!_sessionConfig) {
        _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return _sessionConfig;
}

-(NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:self.sessionConfig delegate:self delegateQueue:nil];
    }
    return _session;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return [super canonicalRequestForRequest:request];
}


+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}


- (void)stopLoading
{
    [self cancelConnection];
    [_dataTask cancel];
    _dataTask = nil;
}



- (NSMutableURLRequest *)handleRequest:(NSURLRequest*)request
{
    if ([request.URL host].length == 0) {
        return request.mutableCopy;
    }

    NSMutableURLRequest *newRequest = [self handlePostRequestBodyWithRequest:request];
//    newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
//    newRequest.URL = [NSURL URLWithString:[request.URL.absoluteString urlStrSafeHandle]];
    
    //忽略默认端口号80或443
    newRequest.URL = [NSURL URLWithString:[CMPURLUtils ignoreDefaultPort:newRequest.URL.absoluteString]];
    
    // 如果是M3服务器地址，适配集群、token登录 start
    if ([CMPServerUtils isCurrentServer:newRequest.URL]) {
        NSString *aTicket = [CMPCore sharedInstance].contentTicket;
        NSString *aExtension = [CMPCore sharedInstance].contentExtension;
        NSString *token = [CMPCore sharedInstance].token;
        if (![NSString isNull:aTicket]) {
            [newRequest setValue:aTicket forHTTPHeaderField:@"Content-Ticket"];
        }
        if (![NSString isNull:aExtension]) {
            [newRequest setValue:aExtension forHTTPHeaderField:@"Content-Extension"];
        }
        if (![NSString isNull:token]) {
            [newRequest setValue:token forHTTPHeaderField:@"ltoken"];
        }
    }
    // 设置集群环境参数 end
    
    //ks fix --- gaode js api 1.3版本停用
    NSString *oriUrl = request.URL.absoluteString;
    NSArray *arr = @[@"https://webapi.amap.com/maps",
                    @"https://restapi.amap.com"];
    for (NSString *matchStr in arr) {
        if ([oriUrl hasPrefix:matchStr]) {
            NSString *query = request.URL.query;
            if (query && query.length) {
                if (![query containsString:@"4b512cb717611e27858b479be8faadf3"]) {
                    if ([query containsString:@"dced395ba47d88fd4dcf8ed6d846cbc7"]
                        ||[query containsString:@"1c0c86c589a5e16cf5ded4bd15c985ba"]
                        ||[query containsString:@"87f1027d40011d0f19c094e4bfe7db1d"]
                        ||[query containsString:@"51e644b4d193536092a37dea04f5db8b"]) {
                        NSString *str = [self updateUrl:oriUrl key:@"key" value:@"4b512cb717611e27858b479be8faadf3"];
                        newRequest.URL = [NSURL URLWithString:str];
                    }
                }
            }
            break;
        }
    }
    //ks end
    
    return newRequest;
}

-(NSString *)updateUrl: (NSString *) url key: (NSString *) key value: (NSString *)value
{
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    NSMutableArray*tmpQueryItems = [NSMutableArray arrayWithArray:components.queryItems];
    [tmpQueryItems enumerateObjectsUsingBlock: ^ (NSURLQueryItem *obj, NSUInteger idx, BOOL * _Nonnull stop){
        if ([obj.name isEqualToString: key]){
            NSURLQueryItem *tmpQueryItem = [[NSURLQueryItem alloc] initWithName: key value: value];
            [tmpQueryItems replaceObjectAtIndex: idx withObject: tmpQueryItem];
        }
    }];
    components.queryItems = tmpQueryItems;
    return components.string;
}

- (NSMutableURLRequest *)handlePostRequestBodyWithRequest:(NSURLRequest *)request {
    NSMutableURLRequest * req = [request mutableCopy];
    if ([request.HTTPMethod.lowercaseString isEqualToString:@"post"]) {
        if (!request.HTTPBody) {
            uint8_t d[1024] = {0};
            NSInputStream *stream = request.HTTPBodyStream;
            NSMutableData *data = [[NSMutableData alloc] init];
            [stream open];
            while ([stream hasBytesAvailable]) {
                NSInteger len = [stream read:d maxLength:1024];
                if (len > 0 && stream.streamError == nil) {
                    [data appendBytes:(void *)d length:len];
                }
            }
            req.HTTPBody = [data copy];
            [stream close];
        }
    }
    return req;
}



- (void)sendResponseWithResponseCode:(NSInteger)statusCode data:(NSData*)data mimeType:(NSString*)mimeType
{
    if (!mimeType) {
        mimeType = @"text/plain";
    }
    // 判断当前是否已经登陆
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[[self request] URL] statusCode:statusCode HTTPVersion:@"HTTP/1.1" headerFields:@{@"Content-Type" : mimeType , @"Cache-Control" : @"max-age=0"}];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    if (data != nil) {
        [[self client] URLProtocol:self didLoadData:data];
    }
    [[self client] URLProtocolDidFinishLoading:self];
}


#pragma mark --NSURLProtocol Delegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
//    if (response) {
//        NSMutableURLRequest *redirectableRequest = [request mutableCopy];
//        if (![CMPServerUtils isCurrentServer:request.URL]) {
//            [redirectableRequest setValue:@"" forHTTPHeaderField:@"Content-Ticket"];
//            [redirectableRequest setValue:@"" forHTTPHeaderField:@"Content-Extension"];
//            [redirectableRequest setValue:@"" forHTTPHeaderField:@"ltoken"];
//        }
//        if ([response isKindOfClass:NSHTTPURLResponse.class]) {
//            NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
//
//            NSMutableDictionary *responseAllHeaderFields = [NSMutableDictionary dictionaryWithDictionary:HTTPResponse.allHeaderFields];
//            NSString *cookieStr = responseAllHeaderFields[@"Cookie"] ? : @"";
//            NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:responseAllHeaderFields forURL:response.URL];
//            for (NSHTTPCookie *cookie in cookies) {
//                if (cookieStr.length>0) {
//                    cookieStr = [cookieStr stringByAppendingFormat:@"; %@=%@",cookie.name,cookie.value];
//                }else{
//                    cookieStr = [cookieStr stringByAppendingFormat:@"%@=%@",cookie.name,cookie.value];
//                }
//            };
//
//            if (cookieStr.length) {
//                NSMutableDictionary *requestAllHeaderFields = [NSMutableDictionary dictionaryWithDictionary:redirectableRequest.allHTTPHeaderFields];
//                NSString *reqCookieStr = requestAllHeaderFields[@"Cookie"] ? : @"";
//                if (reqCookieStr.length>0) {
//                    reqCookieStr = [reqCookieStr stringByAppendingFormat:@"; %@",cookieStr];
//                }else{
//                    reqCookieStr = cookieStr;
//                }
//                [redirectableRequest.allHTTPHeaderFields setValue:reqCookieStr forKey:@"Set-Cookie"];
//            }
//
//            if ([HTTPResponse statusCode] == 301 || [HTTPResponse statusCode] == 302)
//            {
//                NSString *redirectUrl = [[HTTPResponse allHeaderFields] objectForKey:@"Location"];
//                if (redirectUrl) {
//                    NSURL *u = [NSURL URLWithString:redirectUrl];
//                    [redirectableRequest setURL:u];
//                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:u mainDocumentURL:u];
//                }
//                [[self client] URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
//                [NSURLProtocol removePropertyForKey:URLProtocolHandledKey inRequest:redirectableRequest];
////                [NSURLProtocol setProperty:@(YES) forKey:URLProtocolHandledKey inRequest:redirectableRequest];
//                return nil;
//            }
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:redirectableRequest.URL mainDocumentURL:redirectableRequest.URL];
//        }
//        [[self client] URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
//        [NSURLProtocol removePropertyForKey:URLProtocolHandledKey inRequest:redirectableRequest];
////        [NSURLProtocol setProperty:@(YES) forKey:URLProtocolHandledKey inRequest:redirectableRequest];
//        return nil;
//    }
//    return request;
    if (response != nil) {
        NSMutableURLRequest *redirectableRequest = [request mutableCopy];
        if (![CMPServerUtils isCurrentServer:request.URL]) {
            [redirectableRequest setValue:@"" forHTTPHeaderField:@"Content-Ticket"];
            [redirectableRequest setValue:@"" forHTTPHeaderField:@"Content-Extension"];
            [redirectableRequest setValue:@"" forHTTPHeaderField:@"ltoken"];
        }
        // 暂时不对重定向请求做处理
        //标示改request已经处理过了，防止无限循环
        [NSURLProtocol setProperty:@(YES) forKey:URLProtocolHandledKey inRequest:redirectableRequest];
        [[self client] URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
        return nil;
    } else {
        return request;
    }
}

//判断urlStr是否包含指定字符串集合中的任一字符串
- (BOOL)urlStr:(NSString *)urlStr containStringInArray:(NSArray *)strArr{
    __block BOOL flag = NO;
    [strArr enumerateObjectsUsingBlock:^(NSString* arrStr, NSUInteger idx, BOOL * _Nonnull stop) {
        if([urlStr containsString:arrStr]){
            flag = YES;
            *stop = YES;
        }
    }];
    return flag;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(@available(iOS 13.0, *)){
        BOOL handleFlag = NO;
        if ([CMPCore sharedInstance].serverID) {
            NSString *key = [@"cmp_conndidresp_" stringByAppendingString:[CMPCore sharedInstance].serverID];
            NSDictionary *body = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            NSString *val = body[@"action"];
            NSString *contentBody = body[@"contentBody"];
            if (contentBody.length>0 && val && val.length && [val isEqualToString:@"2"]) {
                NSArray *arr = [contentBody componentsSeparatedByString:@","];
                handleFlag = [self urlStr:response.URL.absoluteString containStringInArray:arr];
            }
        }
        //单独针对客户接入的三方做兼容
        if(handleFlag
           || [response.URL.absoluteString containsString:@"index.jsp"]
           || [response.URL.absoluteString containsString:@"jsp.do"]
           || [response.URL.absoluteString containsString:@"apply_enter.jsp"]
           || [response.URL.absoluteString containsString:@"apply_enter_forward.jsp"]){
            [self setResponse:response];
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            return;
        }
    }
//    NSString *requestUrl = connection.currentRequest.URL.absoluteString;
//    NSDictionary *urlParams = [requestUrl urlPropertyValue];
//    NSString *webviewId = urlParams[@"webviewId"];
//    if (@available(iOS 13.0, *)) {
//    }else{
        if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            NSMutableDictionary *allHeaderFields = [NSMutableDictionary dictionaryWithDictionary:res.allHeaderFields];

            //ks fix 有的版本第一次通过NSHTTPCookieStorage拿不到cookie，先手动存储一次
            NSArray *cookiesForCurrentResponse = [NSHTTPCookie cookiesWithResponseHeaderFields:[res allHeaderFields] forURL:response.URL];
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

            NSString *aCookies = [allHeaderFields objectForKey:@"Set-Cookie"];
            if ([NSString isNotNull:aCookies]) {
                //h5 cookie 还没更新，通知WKWebview更新cookie
                NSLog(@"通知更新webview的Cookies");
                NSString *responseUrl = response.URL.absoluteString;
                [[NSNotificationCenter defaultCenter] postNotificationName:knativeCookiesChangesNotification object:responseUrl];
            }
        }
//    }
    
    [self setResponse:response];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    //fix-begin 魔学院视频缓存导致内存得不到释放，最后app崩溃
    NSString *reqUrl = connection.currentRequest.URL.absoluteString;
    if([reqUrl containsString:@"moxueyuan"] && [reqUrl containsString:@".mp4"]){
        return;
    }
    //fix-end
    [self appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    // 根据response的缓存时间去控制是否需要缓存
    NSDictionary *allHeaders = self.request.allHTTPHeaderFields;
    NSString *rangeStr = allHeaders[@"Range"];
    if (!rangeStr) {
        BOOL aCachedResult = [CMPURLCacheUtil storeCachedResponse:[self response]
                                                                data:[self data]
                                                          forRequest:[self request]
                                                     redirectRequest:nil];
        if (aCachedResult) {
            // 缓存成功
        }
    }
    
    [self cancelConnection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
    [self cancelConnection];
    [self setConnection:nil];
    [self setData:nil];
    [self setResponse:nil];
}

// 忽略安全链接认证
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}



- (void)cancelConnection {
    [_connection cancel];
    _connection = nil;
}


- (void)appendData:(NSData *)newData
{
  if ([self data] == nil) {
    [self setData:[newData mutableCopy]];
  }
  else {
    [[self data] appendData:newData];
  }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                     willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                                     newRequest:(NSURLRequest *)request
                              completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    if (response != nil) {
        NSMutableURLRequest *redirectableRequest = [request mutableCopy];
        if (![CMPServerUtils isCurrentServer:request.URL]) {
            [redirectableRequest setValue:@"" forHTTPHeaderField:@"Content-Ticket"];
            [redirectableRequest setValue:@"" forHTTPHeaderField:@"Content-Extension"];
            [redirectableRequest setValue:@"" forHTTPHeaderField:@"ltoken"];
        }
        // 暂时不对重定向请求做处理
        //标示改request已经处理过了，防止无限循环
        [NSURLProtocol setProperty:@(YES) forKey:URLProtocolHandledKey inRequest:redirectableRequest];
        [[self client] URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
        completionHandler(redirectableRequest);
        return;
    }
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
                                             completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
//    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    if(![challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]){
        return;
    }
    NSLog(@"%@",challenge.protectionSpace);
    NSURLCredential *credential = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        NSMutableDictionary *allHeaderFields = [NSMutableDictionary dictionaryWithDictionary:res.allHeaderFields];
        if (response) {
            //ks fix 有的版本第一次通过NSHTTPCookieStorage拿不到cookie，先手动存储一次
            NSArray *cookiesForCurrentResponse = [NSHTTPCookie cookiesWithResponseHeaderFields:[res allHeaderFields] forURL:response.URL];
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
        if ([NSString isNotNull:aCookies]) {
            //h5 cookie 还没更新，通知WKWebview更新cookie
            NSLog(@"通知更新webview的Cookies");
            [[NSNotificationCenter defaultCenter] postNotificationName:knativeCookiesChangesNotification object:nil];
        }
    }
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self setResponse:response];
    completionHandler(NSURLSessionResponseAllow);
}
 
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 打印返回数据
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (dataStr) {
        NSLog(@"***截取数据***: %@", dataStr);
    }
    [self.client URLProtocol:self didLoadData:data];
    [self appendData:data];
}
 
 
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
        
    } else {

        [self.client URLProtocolDidFinishLoading:self];

        
        NSDictionary *allHeaders = task.currentRequest.allHTTPHeaderFields;
        NSString *rangeStr = allHeaders[@"Range"];
        if (!rangeStr) {
            BOOL aCachedResult = [CMPURLCacheUtil storeCachedResponse:task.response
                                                                    data:[self data]
                                                              forRequest:task.currentRequest
                                                         redirectRequest:nil];
            if (aCachedResult) {
                // 缓存成功
            }
        }
    }
    
    [self setData:nil];
    [self setResponse:nil];
}

@end

@implementation NSURLRequest(DataController)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}

@end
