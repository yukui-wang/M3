//
//  CMPFaceDataProvider.m
//  M3
//
//  Created by Shoujian Rao on 2023/9/20.
//

#import "CMPFaceDataProvider.h"
#import "CMPFaceConstant.h"
#import "NSString+SHA256.h"

#define kfaceIdGetResultRequestID @"faceIdGetResultRequestID"
#define kfaceIdCredentialRequestID @"faceIdCredentialRequestID"
#define kfaceIdConfigRequestID @"faceIdConfigRequestID"
#define kfaceIdBizAndQrCodeRequestID @"faceIdBizAndQrCodeRequestID"
#define kfaceIdScanQrCodeRequestID @"kfaceIdScanQrCodeRequestID"

@implementation CMPFaceDataProvider
// get  seeyon/rest/faceId/config
-(void)faceIdConfigCompletion:(CompletionBlock)completionBlock{
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/faceId/config"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"CompletionBlock" : completionBlock};
    aDataRequest.requestID = kfaceIdConfigRequestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

/**
 获取 token 和 qr_code 接口 ：
 GET  /seeyon/rest/faceId/bizAndQrCode/{username}?bn={biz_no}&vtu=false
 */
-(void)bizAndQrCodeByUserName:(NSString *)userName biz_no:(NSString *)biz_no completion:(CompletionBlock)completionBlock{
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/faceId/bizAndQrCode/%@?bn=%@&vtu=false",userName,biz_no];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"CompletionBlock" : completionBlock};
    aDataRequest.requestID = kfaceIdBizAndQrCodeRequestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


- (void)credentialBy:(NSString *)userName isSkip:(BOOL)isSkip completion:(CompletionBlock)completionBlock{
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/faceId/credential/%@?skv=%@",userName,isSkip?@"true":@"false"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"CompletionBlock" : completionBlock};
    aDataRequest.requestID = kfaceIdCredentialRequestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}
//查询人脸识别结果：
//GET  /rest/faceId/bizInfo/{bizNo}/{bizInfoToken}
- (void)getResultWith:(NSString *)bizNo bizInfoToken:(NSString *)bizInfoToken completion:(CompletionBlock)completionBlock{
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/faceId/bizInfo/%@/%@",bizNo,bizInfoToken];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"CompletionBlock" : completionBlock};
    aDataRequest.requestID = kfaceIdGetResultRequestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)scanQrcode:(NSString *)qrCodeId status:(NSInteger)status completion:(CompletionBlock)completionBlock{
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/faceId/qrcode/id"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"CompletionBlock" : completionBlock};
    aDataRequest.requestID = kfaceIdScanQrCodeRequestID;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:qrCodeId forKey:@"qrCodeId"];
    [params setObject:@(status) forKey:@"status"];
    aDataRequest.requestParam = [params JSONRepresentation];
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


//-(void)credentialWithUserName:(NSString *)userName skipVerification:(BOOL)skipVerification success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock
//{
//    if (!userName.length) {
//        return;
//    }
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:userName forKey:@"username"];
//    [params setObject:@(skipVerification) forKey:@"skip_verification"];
//    
//    NSString *url = [NSString stringWithFormat:@"%@/faceee/v1/credential", kFaceEENetworkHost];
//    
//    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
//    aDataRequest.requestUrl = url;
//    aDataRequest.delegate = self;
//    aDataRequest.requestMethod = kRequestMethodType_POST;
//    aDataRequest.requestType = kDataRequestType_Url;
//    aDataRequest.userInfo = @{@"successBlock" : successBlock,@"failureBlock" : failureBlock};
//    aDataRequest.requestParam = [params JSONRepresentation];
//    
//    NSURL *URL = [NSURL URLWithString:url];
//    NSDictionary *header = [self signedHeader:kClientId clientSectet:kClientSecret method:@"POST" path:URL.path query:@"" data:params];
//    
//    NSMutableDictionary *mHeader = [NSMutableDictionary dictionaryWithDictionary:header];
//    NSString *lanString = @"zh-CN";
//    [mHeader setValue:lanString forKey:@"X-FaceEE-LOCALE"];
//    [mHeader setValue:@"application/json; charset=utf-8" forKey:@"Content-Type"];
//    aDataRequest.headers =  mHeader;
//    
//    
////    aDataRequest.requestID = @"";
////    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:invoiceIdList options:0 error:nil];
////    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
////    aDataRequest.requestParam = strJson;//仅字符串数组的json
//    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
//}

//- (void)createBizInfoWithmessage:(NSDictionary *)message success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock
//{
//    
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:message[@"type"] forKey:@"type"];
//    if (message[@"username"]) {
//        [params setObject:message[@"username"] forKey:@"username"];
//        [params setObject:@(YES) forKey:@"visible_to_user"];
//    }
//    
//    NSString *url = [NSString stringWithFormat:@"%@/faceee/v1/biz_info", kFaceEENetworkHost];
//    
//    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
//    aDataRequest.requestUrl = url;
//    aDataRequest.delegate = self;
//    aDataRequest.requestMethod = kRequestMethodType_POST;
//    aDataRequest.requestType = kDataRequestType_Url;
//    aDataRequest.userInfo = @{@"successBlock" : successBlock,@"failureBlock" : failureBlock};
//    aDataRequest.requestParam = [params JSONRepresentation];
//    
//    NSURL *URL = [NSURL URLWithString:url];
//    NSDictionary *header = [self signedHeader:kClientId clientSectet:kClientSecret method:@"POST" path:URL.path query:@"" data:params];
//    
//    NSMutableDictionary *mHeader = [NSMutableDictionary dictionaryWithDictionary:header];
//    NSString *lanString = @"zh-CN";
//    [mHeader setValue:lanString forKey:@"X-FaceEE-LOCALE"];
//    [mHeader setValue:@"application/json; charset=utf-8" forKey:@"Content-Type"];
//    aDataRequest.headers =  mHeader;
//    
//    
////    aDataRequest.requestID = @"";
////    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:invoiceIdList options:0 error:nil];
////    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
////    aDataRequest.requestParam = strJson;//仅字符串数组的json
//    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
//}

//bizNo = @"1234567"
//- (void)createQrCodeWithBizInfoToken:(NSString *)bizInfoToken bizNo:(NSString *)bizNo  success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock{
//    if (!bizInfoToken.length) {
//        return;
//    }
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:bizInfoToken forKey:@"biz_info_token"];
//    [params setObject:bizNo?:@"1234567" forKey:@"biz_no"];
//    
//    NSString *url = [NSString stringWithFormat:@"%@/faceee/v1/qr_code", kFaceEENetworkHost];
//    
//    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
//    aDataRequest.requestUrl = url;
//    aDataRequest.delegate = self;
//    aDataRequest.requestMethod = kRequestMethodType_POST;
//    aDataRequest.requestType = kDataRequestType_Url;
//    aDataRequest.userInfo = @{@"successBlock" : successBlock,@"failureBlock" : failureBlock};
//    aDataRequest.requestParam = [params JSONRepresentation];
//    
//    NSURL *URL = [NSURL URLWithString:url];
//    NSDictionary *header = [self signedHeader:kClientId clientSectet:kClientSecret method:@"POST" path:URL.path query:@"" data:params];
//    
//    NSMutableDictionary *mHeader = [NSMutableDictionary dictionaryWithDictionary:header];
//    NSString *lanString = @"zh-CN";
//    [mHeader setValue:lanString forKey:@"X-FaceEE-LOCALE"];
//    [mHeader setValue:@"application/json; charset=utf-8" forKey:@"Content-Type"];
//    aDataRequest.headers =  mHeader;
//    
//    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
//    
//}
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    
    NSDictionary *userInfo = aRequest.userInfo;
    
    if ([aRequest.requestID isEqual:kfaceIdConfigRequestID]) {
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        NSDictionary *data = [responseObj objectForKey:@"data"];
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        completionBlock(data,nil);
        return;
    }else if ([aRequest.requestID isEqual:kfaceIdBizAndQrCodeRequestID]) {
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        NSDictionary *data = [responseObj objectForKey:@"data"];
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        completionBlock(data,nil);
        return;
    }else if ([aRequest.requestID isEqual:kfaceIdCredentialRequestID]) {
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        NSDictionary *data = [responseObj objectForKey:@"data"];
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        completionBlock(data,nil);
        return;
    }else if ([aRequest.requestID isEqual:kfaceIdScanQrCodeRequestID]) {
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        NSDictionary *data = [responseObj objectForKey:@"data"];
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        completionBlock(data,nil);
        return;
    }else if ([aRequest.requestID isEqual:kfaceIdGetResultRequestID]) {
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        NSDictionary *data = [responseObj objectForKey:@"data"];
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        completionBlock(data,nil);
        return;
    }
    
    RequestSuccess successBlock = userInfo[@"successBlock"];
    
    NSDictionary *responseDict = [aResponse.responseStr JSONValue];
    NSString *errorHint = responseDict[@"error_hint"];
    NSInteger statusCode = aResponse.responseStatusCode;
    if (statusCode != 200 && errorHint.length == 0) {
        if ([responseDict[@"error_code"] integerValue] == 2201 || [responseDict[@"error_code"] integerValue] == 2401) { //BIZ_INFO_ALREADY_FINISHED || AUTH_REQUEST_ALREADY_FINISHED
            errorHint = @"认证流程已结束";
        } else if ([responseDict[@"error_code"] integerValue] == 2116 ||  [responseDict[@"error_code"] integerValue] == 2117) { //AUTH_DEVICE_NOT_FOUND || AUTH_CLIENT_NOT_FOUND
            errorHint = @"设备已失效，请联系管理员";
        }
    }
    if(successBlock){
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(statusCode, responseDict, errorHint);
        });
    }
    
}


- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {

    NSDictionary *userInfo = aRequest.userInfo;
    
    if ([aRequest.requestID isEqual:kfaceIdConfigRequestID]) {
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        completionBlock(nil,error);
        return;
    }else if ([aRequest.requestID isEqual:kfaceIdBizAndQrCodeRequestID]) {
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        completionBlock(nil,error);
        return;
    }else if ([aRequest.requestID isEqual:kfaceIdCredentialRequestID]) {
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        completionBlock(nil,error);
        return;
    }else if ([aRequest.requestID isEqual:kfaceIdScanQrCodeRequestID]) {
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        completionBlock(nil,error);
        return;
    }else if ([aRequest.requestID isEqual:kfaceIdGetResultRequestID]) {
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        completionBlock(nil,error);
        return;
    }
    
    RequestFailure failureBlock = userInfo[@"failureBlock"];
    if(failureBlock){
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock(error.code, error);
        });
    }
    
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

@end
