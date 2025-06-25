//
//  XZM3RequestManager.m
//  M3
//
//  Created by wujiansheng on 2019/3/8.
//

#import "XZM3RequestManager.h"
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>
#import "SPTools.h"

@interface XZM3RequestObj : NSObject

@property(nonatomic, copy)void(^successBlock)(NSString *response,NSDictionary* userInfo);
@property(nonatomic, copy)void(^failedBlock)(NSError *error,NSDictionary* userInfo);
@property(nonatomic, retain)NSDictionary *userInfo;

@end

@implementation XZM3RequestObj

- (void)dealloc {
    self.successBlock = nil;
    self.failedBlock = nil;
}

@end

@interface XZM3RequestManager ()<CMPDataProviderDelegate>

@end

@implementation XZM3RequestManager

+ (instancetype)sharedInstance {
    static XZM3RequestManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XZM3RequestManager alloc] init];
    });
    return instance;
}

- (NSString *)getRequestWithUrl:(NSString *)url
                         params:(NSDictionary *)params
                        success:(void(^)(NSString *response,NSDictionary* userInfo))successBlock
                           fail:(void(^)(NSError *error,NSDictionary* userInfo))failedBlock {
    return [self requestWithUrl:url
                         params:params
                       userInfo:nil
                  handleCookies:YES
                         method:@"GET"
                        success:successBlock
                           fail:failedBlock];
}

- (NSString *)postRequestWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                         success:(void(^)(NSString *response,NSDictionary* userInfo))successBlock
                            fail:(void(^)(NSError *error,NSDictionary* userInfo))failedBlock {
    return [self postRequestWithUrl:url
                             params:params
                      handleCookies:YES
                            success:successBlock
                               fail:failedBlock];
}

- (NSString *)postRequestWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                   handleCookies:(BOOL)handleCookies
                         success:(void(^)(NSString *response,NSDictionary* userInfo))successBlock
                            fail:(void(^)(NSError *error,NSDictionary* userInfo))failedBlock {
    return [self requestWithUrl:url
                         params:params
                       userInfo:nil
                  handleCookies:handleCookies
                         method:@"POST"
                        success:successBlock
                           fail:failedBlock];
}

- (NSString *)requestWithUrl:(NSString *)url
                      params:(NSDictionary *)params
                    userInfo:(NSDictionary*)userInfo
               handleCookies:(BOOL)handleCookies
                      method:(NSString *)method
                     success:(void(^)(NSString *response,NSDictionary* userInfo))successBlock
                        fail:(void(^)(NSError *error,NSDictionary* userInfo))failedBlock {
    CMPDataRequest *aRequest = [[CMPDataRequest alloc] init];
    aRequest.requestUrl = url;
    aRequest.delegate = self;
    aRequest.requestMethod = method;
    if (params) {
        aRequest.requestParam = [params JSONRepresentation];
    }
    aRequest.requestType = kDataRequestType_Url;
    if (!handleCookies) {
        //handleCookies 为false 时处理，否则保持原样
        aRequest.httpShouldHandleCookies = handleCookies;
    }
    XZM3RequestObj *obj = [[XZM3RequestObj alloc] init];
    obj.successBlock = successBlock;
    obj.failedBlock = failedBlock;
    obj.userInfo = userInfo;
    aRequest.userInfo = (NSDictionary *)obj;
    [[CMPDataProvider sharedInstance] addRequest:aRequest];
    NSString *requestId = aRequest.requestID;
    return requestId;
}

- (NSString *)downloadFileWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                        localPath:(NSString *)localPath
                          success:(void(^)(NSString *response,NSDictionary* userInfo))successBlock
                             fail:(void(^)(NSError *error,NSDictionary* userInfo))failedBlock {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
    }
    CMPDataRequest *aRequest = [[CMPDataRequest alloc] init];
    aRequest.requestUrl = url;
    aRequest.delegate = self;
    aRequest.requestMethod = @"GET";
    aRequest.requestType = kDataRequestType_FileDownload;
    aRequest.downloadDestinationPath = localPath;
    XZM3RequestObj *obj = [[XZM3RequestObj alloc] init];
    obj.successBlock = successBlock;
    obj.failedBlock = failedBlock;
    aRequest.userInfo = (NSDictionary *)obj;
    [[CMPDataProvider sharedInstance] addRequest:aRequest];
    NSString *requestId = aRequest.requestID;
    return requestId;
}



- (void)cancelAllRequest {
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
}
- (void)cancelWithRequestId:(NSString *)requestId {
    if (requestId) {
        [[CMPDataProvider sharedInstance] cancelWithRequestId:requestId];
    }
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse{
    XZM3RequestObj *obj = (XZM3RequestObj *)aRequest.userInfo;
    NSString *responseStr = [NSString stringFromHtmlStr:aResponse.responseStr];
    NSLog(@"[XZM3RequestManager][sucess] : \n [url] : %@\n [param] : %@\n [response] : %@",aRequest.requestUrl,aRequest.requestParam,responseStr);
    if (obj.successBlock) {
        obj.successBlock(responseStr,obj.userInfo);
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error{
    NSLog(@"[XZM3RequestManager][error] : \n [url] : %@\n [param] : %@\n [error] : %@",aRequest.requestUrl,aRequest.requestParam,error);
    XZM3RequestObj *obj = (XZM3RequestObj *)aRequest.userInfo;
    if (obj.failedBlock) {
        obj.failedBlock(error,obj.userInfo);
    }
}


@end
