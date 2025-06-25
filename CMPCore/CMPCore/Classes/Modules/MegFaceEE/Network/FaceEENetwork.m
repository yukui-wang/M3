//
//  FaceEENetwork.m
//  FaceIDFaceAuth
//
//  Created by Megvii on 2021/11/23.
//

#import "FaceEENetwork.h"
#import "NSString+SHA256.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "CMPFaceConstant.h"

#define kFaceEENetworkTimeout 30


@interface FaceEENetwork() <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, copy) NSString* TWITTERFON_FORM_BOUNDARY;
@property (nonatomic, copy) NSString* MPboundary;
@property (nonatomic, copy) NSString* endMPboundary;
@property (nonatomic, copy) NSURLSession* session;
@end

@implementation FaceEENetwork

static FaceEENetwork *network = nil;
+ (instancetype)singleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        network = [[FaceEENetwork alloc] init];
    });
    return network;
}

- (void)dealloc {
    [self.session invalidateAndCancel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:kFaceEENotifyId]) {
            _pushClientId = [defaults objectForKey:kFaceEENotifyId];
        }
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.networkServiceType = NSURLNetworkServiceTypeResponsiveData;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    }
    return self;
}

#pragma mark - setter
- (void)setPushClientId:(NSString *)pushClientId {
    if (_pushClientId != pushClientId) {
        _pushClientId = pushClientId;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:pushClientId forKey:kFaceEENotifyId];
        [defaults synchronize];
    }
}
/**
 
 Printing description of responseObject:
 {
     list =     (
                 {
             "has_image" = 1;
             "is_exist" = 1;
             "is_forbid" = 0;
             username = raosj;
         }
     );
     "request_id" = "1695882838,474a1820-7dd3-4a68-af0d-e33387efd98f";
     "time_used" = 16;
 }
 
 */

- (void)check_usernames:(NSArray *)userNameStrArr clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret endpoint:(NSString *)endpoint success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock {
    if (!userNameStrArr.count) {
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userNameStrArr forKey:@"usernames"];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/faceee/console/api/v1/open/check_username", endpoint]];
    NSMutableURLRequest *request = [self getRequest:URL method:@"POST"];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingFragmentsAllowed error:NULL];

    NSDictionary *header = [self signedHeader:clientId clientSectet:clientSecret method:@"POST" path:URL.path query:@"" data:params];
    [self requestAppendHeaderFieldWithRequest:request content:header];

    [self sendAsynchronousRequest:request success:successBlock failure:failureBlock];
}


- (void)credentialWithUserName:(NSString *)userName skipVerification:(BOOL)skipVerification clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret endpoint:(NSString *)endpoint success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userName forKey:@"username"];
    [params setObject:@(skipVerification) forKey:@"skip_verification"];

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/faceee/v1/credential", endpoint]];
    NSMutableURLRequest *request = [self getRequest:URL method:@"POST"];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingFragmentsAllowed error:NULL];

    NSDictionary *header = [self signedHeader:clientId clientSectet:clientSecret method:@"POST" path:URL.path query:@"" data:params];
    [self requestAppendHeaderFieldWithRequest:request content:header];

    [self sendAsynchronousRequest:request success:successBlock failure:failureBlock];
}

- (void)createBizInfoWithmessage:(NSDictionary *)message clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret endpoint:(NSString *)endpoint success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:message[@"type"] forKey:@"type"];
    if (message[@"username"]) {
        [params setObject:message[@"username"] forKey:@"username"];
        [params setObject:@(YES) forKey:@"visible_to_user"];
    }
        
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/faceee/v1/biz_info", endpoint]];
    NSMutableURLRequest *request = [self getRequest:URL method:@"POST"];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingFragmentsAllowed error:NULL];

    NSDictionary *header = [self signedHeader:clientId clientSectet:clientSecret method:@"POST" path:URL.path query:@"" data:params];
    
    [self requestAppendHeaderFieldWithRequest:request content:header];
    
    [self sendAsynchronousRequest:request success:successBlock failure:failureBlock];
}

- (void)createQrCodeWithBizInfoToken:(NSString *)bizInfoToken clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret endpoint:(NSString *)endpoint success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:bizInfoToken forKey:@"biz_info_token"];
    [params setObject:kFaceEEBizNo forKey:@"biz_no"];
        
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/faceee/v1/qr_code", endpoint]];
    NSMutableURLRequest *request = [self getRequest:URL method:@"POST"];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingFragmentsAllowed error:NULL];

    NSDictionary *header = [self signedHeader:clientId clientSectet:clientSecret method:@"POST" path:URL.path query:@"" data:params];
    
    [self requestAppendHeaderFieldWithRequest:request content:header];
    
    [self sendAsynchronousRequest:request success:successBlock failure:failureBlock];
}

- (void)getEnterpriseMessageWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret endpoint:(NSString *)endpoint success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/faceee/v1/enterprise", endpoint];
    NSURL *URL = NSURLByAppendingQueryParameters([NSURL URLWithString:urlStr], params);
    NSMutableURLRequest *request = [self getRequest:URL method:@"GET"];
    NSLog(@"url: %@", urlStr);
    
    NSDictionary *header = [self signedHeader:clientId clientSectet:clientSecret method:@"GET" path:URL.path query:URL.query data:nil];
    [self requestAppendHeaderFieldWithRequest:request content:header];
    
    [self sendAsynchronousRequest:request success:successBlock failure:failureBlock];
}

#pragma mark - signature
- (NSDictionary *)signedHeader:(NSString *)clientId clientSectet:(NSString *)clientSecret method:(NSString *)method path:(NSString *)path query:(NSString *)query data:(NSDictionary *)params {
    NSString *payloadStr = @"";
    if (params) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingFragmentsAllowed error:NULL];
        payloadStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSInteger timeInterval = [[NSDate date] timeIntervalSince1970];
//    NSInteger timeInterval = 1644988879;
//    DLog(@"========data: %@, path: %@, query: %@, interval: %zd", payloadStr, path, query, timeInterval);
    NSString *payloadHash = [payloadStr sha256];
//    DLog(@"========payloadHash: %@", payloadHash);
    NSString *canonicalRequest = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",method,path,query?query:@"",@"",@"",payloadHash];
//    DLog(@"========canonicalRequest: %@", canonicalRequest);
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%zd\n%@",kFaceEEAlgorithm,timeInterval,[canonicalRequest sha256]];
//    DLog(@"========stringToSign: %@", stringToSign);
    NSString *signature = [stringToSign hmacForSecret:clientSecret];
//    DLog(@"========signature: %@", signature);
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"X-FaceEE-ClientId"] = clientId;
    dict[@"X-FaceEE-Algorithm"] = kFaceEEAlgorithm;
    dict[@"X-FaceEE-Timestamp"] = [NSString stringWithFormat:@"%zd", timeInterval];
    dict[@"Authorization"] = signature;
    
    return dict;
}

- (NSString *)signedQuery:(NSString *)clientId clientSectet:(NSString *)clientSecret method:(NSString *)method path:(NSString *)path query:(NSString *)query data:(NSDictionary *)params {
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingFragmentsAllowed error:NULL];
    NSString *payloadHash = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSInteger timeInterval = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *canonicalQuery = [NSString stringWithFormat:@"%@&X-FaceEE-ClientId=%@&X-FaceEE-Algorithm=%@&X-FaceEE-Timestamp=%zd", NULL,clientId,kFaceEEAlgorithm,timeInterval];
    NSString *canonicalRequest = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",method    ,path,canonicalQuery,@"",@"",[payloadHash sha256]];
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%zd\n%@",kFaceEEAlgorithm,timeInterval,[canonicalRequest sha256]];
    NSString *signature = [stringToSign hmacForSecret:clientSecret];
    [canonicalQuery stringByAppendingFormat:@"&Authorization=%@",signature];
    return canonicalQuery;;
}

#pragma mark - request
- (NSMutableURLRequest *)getRequest:(NSURL *)url method:(NSString *)method {
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:kFaceEENetworkTimeout];
    [urlRequest setHTTPMethod:method];
    return urlRequest;
}

- (void)request:(NSMutableURLRequest *)request appendParameter:(NSDictionary *)dic {
    NSMutableString *tempString = [NSMutableString stringWithString:@""];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [tempString appendFormat:@"%@\r\n", self.MPboundary];
        [tempString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [tempString appendFormat:@"%@\r\n",obj];
    }];
    
    NSData *dicData = [tempString dataUsingEncoding:NSUTF8StringEncoding];
    [self requestUpdata:request updata:dicData];
}

- (void)request:(NSMutableURLRequest *)request appendFile:(NSData *)fileData fileName:(NSString *)fileName contentType:(NSString *)type {
    if (fileData) {
        NSMutableString *tempString = [NSMutableString stringWithString:@""];
        [tempString appendFormat:@"%@\r\n", self.MPboundary];
        [tempString appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileName, fileName];
        [tempString appendFormat:@"Content-Type: %@\r\n\r\n", type];
        NSData *tempData = [tempString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData *resultData = [NSMutableData dataWithData:tempData];
        [resultData appendData:fileData];
        NSData *tempData2 = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        [resultData appendData:tempData2];
        
        [self requestUpdata:request updata:resultData];
    }
}

- (void)requestAppendHeaderFieldWithRequest:(NSMutableURLRequest *)request content:(NSDictionary *)content {
    [content enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    NSString *lanString = @"zh-CN";
    [request setValue:lanString forHTTPHeaderField:@"X-FaceEE-LOCALE"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
}

- (void)requestAppendHeaderFieldWithJson:(NSMutableURLRequest *)request {
    NSString *lanString = @"zh-CN";
    [request setValue:lanString forHTTPHeaderField:@"X-FaceEE-LOCALE"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
}

- (void)requestAppendHeaderField:(NSMutableURLRequest *)request {
    NSString *lanString = @"zh-CN";
    [request setValue:lanString forHTTPHeaderField:@"X-FaceEE-LOCALE"];
    NSString *content = [[NSString alloc] initWithFormat:@"multipart/form-data; boundary=%@", self.TWITTERFON_FORM_BOUNDARY];
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
}

- (void)requestAppendEND:(NSMutableURLRequest *)requset {
    NSString *end = [[NSString alloc] initWithFormat:@"%@", self.endMPboundary];
    NSData *endData = [end dataUsingEncoding:NSUTF8StringEncoding];
    [self requestUpdata:requset updata:endData];
}

- (void)requestUpdata:(NSMutableURLRequest *)request updata:(NSData *)data {
    NSData *body = request.HTTPBody;
    NSMutableData *resultData = [NSMutableData dataWithData:body];
    [resultData appendData:data];
    [request setHTTPBody:resultData];
}

- (void)sendAsynchronousRequest:(NSURLRequest *)request success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock {
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *_data, NSURLResponse *_response, NSError *_error) {
        if (_error == nil) {
            if (successBlock) {
                NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:_data
                                                                             options:NSJSONReadingMutableLeaves
                                                                               error:nil];
                NSString *errorHint = responseDict[@"error_hint"];
                NSInteger statusCode = [(NSHTTPURLResponse *)_response statusCode];
                if (statusCode != 200 && errorHint.length == 0) {
                    if ([responseDict[@"error_code"] integerValue] == 2201 || [responseDict[@"error_code"] integerValue] == 2401) { //BIZ_INFO_ALREADY_FINISHED || AUTH_REQUEST_ALREADY_FINISHED
                        errorHint = @"认证流程已结束";
                    } else if ([responseDict[@"error_code"] integerValue] == 2116 ||  [responseDict[@"error_code"] integerValue] == 2117) { //AUTH_DEVICE_NOT_FOUND || AUTH_CLIENT_NOT_FOUND
                        errorHint = @"设备已失效，请联系管理员";
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock(statusCode, responseDict, errorHint);
                });
            }
        } else {
            if (failureBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock([(NSHTTPURLResponse *)_response statusCode], _error);
                });
            }
        }
    }];
    [task resume];
}

- (void)sendAsynchronousRequest:(NSURLRequest *)request response:(NSURLResponse **)response error:(NSError **)error {
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *_data, NSURLResponse *_response, NSError *_error) {
        *response = _response;
        *error = _error;
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request response:(NSURLResponse **)response error:(NSError **)error {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSData* resultData;
    __block NSError* requestError = NULL;
    __block NSURLResponse* requestResponse;
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *_data, NSURLResponse *_response, NSError *_error) {
        if (_error == nil) {
            resultData = _data;
            requestResponse = _response;
            dispatch_semaphore_signal(semaphore);
        } else {
            requestError = _error;
            dispatch_semaphore_signal(semaphore);
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    *response = requestResponse;
    *error = requestError;
    return resultData;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
    newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler{
    DLog(@"******%s", __FUNCTION__);
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics {
//    DLog(@"******%s", __FUNCTION__);
//    DLog(@"taskInterval duration:%f, strat: %@, end: %@", metrics.taskInterval.duration, metrics.taskInterval.startDate, metrics.taskInterval.endDate);
//    for (NSURLSessionTaskTransactionMetrics * metric in metrics.transactionMetrics) {
//        DLog(@"fetchStartDate: %@", metric.fetchStartDate);
//        DLog(@"domainLookupStartDate: %@", metric.domainLookupStartDate);
//        DLog(@"domainLookupEndDate: %@", metric.domainLookupEndDate);
//        DLog(@"connectStartDate: %@", metric.connectStartDate);
//        DLog(@"secureConnectionStartDate: %@", metric.secureConnectionStartDate);
//        DLog(@"secureConnectionEndDate: %@", metric.secureConnectionEndDate);
//        DLog(@"connectEndDate: %@", metric.connectEndDate);
//        DLog(@"requestStartDate: %@", metric.requestStartDate);
//        DLog(@"requestEndDate: %@", metric.requestEndDate);
//        DLog(@"responseStartDate: %@", metric.responseStartDate);
//        DLog(@"responseEndDate: %@", metric.responseEndDate);
//    }
}

#pragma mark - Getter
- (NSString *)TWITTERFON_FORM_BOUNDARY {
    if (!_TWITTERFON_FORM_BOUNDARY) {
        _TWITTERFON_FORM_BOUNDARY = @"lei2beedoo4peinoz1auva5hieXi9Ieghiawo2zaeZaikujuoNoo3ahphahr6oDi";
    }
    return _TWITTERFON_FORM_BOUNDARY;
}

- (NSString *)MPboundary {
    if (!_MPboundary) {
        _MPboundary = [[NSString alloc]initWithFormat:@"--%@", self.TWITTERFON_FORM_BOUNDARY];
    }
    return _MPboundary;
}

- (NSString *)endMPboundary {
    if (!_endMPboundary) {
        _endMPboundary = [[NSString alloc]initWithFormat:@"%@--", self.MPboundary];
    }
    return _endMPboundary;
}

static NSString* NSStringFromQueryParameters(NSDictionary* queryParameters) {
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
            [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<>"].invertedSet],
            [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<>"].invertedSet]
        ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

static NSURL* NSURLByAppendingQueryParameters(NSURL* URL, NSDictionary* queryParameters) {
    NSString* URLString = [NSString stringWithFormat:@"%@?%@",
        [URL absoluteString],
        NSStringFromQueryParameters(queryParameters)
    ];
    return [NSURL URLWithString:URLString];
}

static NSString *NSStringByAppendingQueryParameters(NSString *urlStr, NSDictionary* queryParameters) {
    NSString* URLString = [NSString stringWithFormat:@"%@?%@", urlStr, NSStringFromQueryParameters(queryParameters)
    ];
    return URLString;
}


- (NSString *)urlencode:(NSString *)urlString {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[urlString UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
