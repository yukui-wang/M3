//
//  CMPOcrMainDataProvider.m
//  M3
//
//  Created by 张艳 on 2021/12/13.
//

#import "CMPOcrMainDataProvider.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>


@interface CMPOcrBaseRequestObj : NSObject

@property(nonatomic, copy) CMPOcrBaseSuccessBlock successBlock;

@property(nonatomic, copy) CMPOcrBaseFailBlock failedBlock;

@property(nonatomic, retain) NSDictionary *userInfo;

@end

@implementation CMPOcrBaseRequestObj

- (void)dealloc {
    self.successBlock = nil;
    self.failedBlock = nil;
}

@end

@interface CMPOcrMainDataProvider ()<CMPDataProviderDelegate>


@end

@implementation CMPOcrMainDataProvider

+ (instancetype)sharedInstance {
    static CMPOcrMainDataProvider *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CMPOcrMainDataProvider alloc] init];
    });
    return instance;
}

- (NSString *)getRequestWithUrl:(NSString *)url
                         params:(NSDictionary *)params
                        success:(CMPOcrBaseSuccessBlock)successBlock
                           fail:(CMPOcrBaseFailBlock)failedBlock {
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
                         success:(CMPOcrBaseSuccessBlock)successBlock
                            fail:(CMPOcrBaseFailBlock)failedBlock {
    return [self postRequestWithUrl:url
                             params:params
                      handleCookies:YES
                            success:successBlock
                               fail:failedBlock];
}

- (NSString *)postRequestWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                   handleCookies:(BOOL)handleCookies
                         success:(CMPOcrBaseSuccessBlock)successBlock
                            fail:(CMPOcrBaseFailBlock)failedBlock {
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
                     success:(CMPOcrBaseSuccessBlock)successBlock
                        fail:(CMPOcrBaseFailBlock)failedBlock {
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
    CMPOcrBaseRequestObj *obj = [[CMPOcrBaseRequestObj alloc] init];
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
                          success:(CMPOcrBaseSuccessBlock)successBlock
                             fail:(CMPOcrBaseFailBlock)failedBlock {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
    }
    CMPDataRequest *aRequest = [[CMPDataRequest alloc] init];
    aRequest.requestUrl = url;
    aRequest.delegate = self;
    aRequest.requestMethod = @"GET";
    aRequest.requestType = kDataRequestType_FileDownload;
    aRequest.downloadDestinationPath = localPath;
    CMPOcrBaseRequestObj *obj = [[CMPOcrBaseRequestObj alloc] init];
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
    CMPOcrBaseRequestObj *obj = (CMPOcrBaseRequestObj *)aRequest.userInfo;
    NSString *responseStr = [NSString stringFromHtmlStr:aResponse.responseStr];
    NSLog(@"[CMPOcrMainDataProvider][sucess] : \n [url] : %@\n [param] : %@\n [response] : %@",aRequest.requestUrl,aRequest.requestParam,responseStr);
    if (obj.successBlock) {
        obj.successBlock(responseStr,obj.userInfo);
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error{
    NSLog(@"[CMPOcrMainDataProvider][error] : \n [url] : %@\n [param] : %@\n [error] : %@",aRequest.requestUrl,aRequest.requestParam,error);
    CMPOcrBaseRequestObj *obj = (CMPOcrBaseRequestObj *)aRequest.userInfo;
    if (obj.failedBlock) {
        obj.failedBlock(error, obj.userInfo);
    }
}

@end
