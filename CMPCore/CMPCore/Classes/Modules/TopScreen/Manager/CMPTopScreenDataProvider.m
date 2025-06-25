//
//  CMPTopScreenDataProvider.m
//  M3
//
//  Created by Shoujian Rao on 2024/1/10.
//

#import "CMPTopScreenDataProvider.h"

#define kTopScreenCheckRequestID @"topScreenCheckRequestID"
#define kTopScreenSaveRequestID @"topScreenSaveRequestID"
#define kTopScreenDelRequestID @"topScreenDelRequestID"
#define kTopScreenGetAllRequestID @"topScreenGetAllRequestID"

@interface CMPTopScreenDataProvider()<CMPDataProviderDelegate>

@end

@implementation CMPTopScreenDataProvider

//检查是否添加负二楼
-(void)topScreenCheckById:(NSString *)iid completion:(CompletionBlock)completionBlock{
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/m3/topScreen/check/%@",iid];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"CompletionBlock" : completionBlock};
    aDataRequest.requestID = kTopScreenCheckRequestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

//获取用户所有负二楼数据
- (void)topScreenGetAllCompletion:(CompletionBlock)completionBlock{
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/m3/topScreen/%@",CMP_USERID];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"CompletionBlock" : completionBlock};
    aDataRequest.requestID = kTopScreenGetAllRequestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

//添加到负二楼
- (void)topScreenSaveByParam:(NSDictionary *)param completion:(CompletionBlock)completionBlock{
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/m3/topScreen/save"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"CompletionBlock" : completionBlock};
    aDataRequest.requestID = kTopScreenSaveRequestID;
    
    aDataRequest.requestParam = [param JSONRepresentation];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

//从负二楼删除
- (void)topScreenDelById:(NSString *)iid completion:(CompletionBlock)completionBlock{
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/m3/topScreen/del"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"CompletionBlock" : completionBlock};
    aDataRequest.requestID = kTopScreenDelRequestID;
    
    aDataRequest.requestParam = [@{@"id":iid} JSONRepresentation];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    
    NSDictionary *userInfo = aRequest.userInfo;
    
    if ([aRequest.requestID isEqualToString:kTopScreenCheckRequestID]) {
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        id data = [responseObj objectForKey:@"data"];
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        if (completionBlock) {
            completionBlock(data,nil);
        }
        return;
    }else if ([aRequest.requestID isEqualToString:kTopScreenSaveRequestID]){
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        NSDictionary *data = [responseObj objectForKey:@"data"];
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        if (completionBlock) {
            completionBlock(data,nil);
        }
        return;
    }else if ([aRequest.requestID isEqualToString:kTopScreenDelRequestID]){
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        NSDictionary *data = [responseObj objectForKey:@"data"];
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        if (completionBlock) {
            completionBlock(data,nil);
        }
        return;
    }else if ([aRequest.requestID isEqualToString:kTopScreenGetAllRequestID]){
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        NSDictionary *data = [responseObj objectForKey:@"data"];
        CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
        if (completionBlock) {
            completionBlock(data,nil);
        }
        return;
    }
    
    
    CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
    NSDictionary *responseObj = [aResponse.responseStr JSONValue];
    NSDictionary *data = [responseObj objectForKey:@"data"];
    if (completionBlock) {
        completionBlock(data,nil);
    }
    
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    NSDictionary *userInfo = aRequest.userInfo;
    CompletionBlock completionBlock = userInfo[@"CompletionBlock"];
    completionBlock(nil,error);
}
@end
