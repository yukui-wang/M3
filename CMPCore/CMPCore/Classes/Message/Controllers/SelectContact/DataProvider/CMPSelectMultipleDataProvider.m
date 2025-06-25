//
//  CMPSelectMultipleDataProvider.m
//  M3
//
//  Created by Shoujian Rao on 2023/9/4.
//

#import "CMPSelectMultipleDataProvider.h"
static NSString *const getGroupUrl = @"/rest/uc/rong/groups/mygroups";
static NSString *const searchGroupUrl = @"/rest/uc/rong/groups/searchgroup";

@interface CMPSelectMultipleDataProvider()<CMPDataProviderDelegate>

@end



@implementation CMPSelectMultipleDataProvider

- (void)getGroupByPageNo:(NSInteger)pageNo
                       completion:(void (^)(NSArray *arr,NSError *err))completion{
    NSString *url = [NSString stringWithFormat: @"%@?pageNo=%ld&pageSize=20",getGroupUrl,pageNo];
    NSString *requestUrl = [CMPCore fullUrlPathMapForPath:url];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.userInfo = @{
        @"completion":completion
    };

    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)searchGroupByKeyword:(NSString *)keyword pageNo:(NSInteger)pageNo
                       completion:(void (^)(NSArray *arr,NSError *err))completion{
    NSString *url = [NSString stringWithFormat: @"%@?pageNo=%ld&pageSize=20",searchGroupUrl,pageNo];
    NSString *requestUrl = [CMPCore fullUrlPathMapForPath:url];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.userInfo = @{
        @"completion":completion
    };
    NSDictionary *params = @{@"key":keyword?:@""};
    aDataRequest.requestParam = [params JSONRepresentation];
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error{
    void(^completion)(NSArray *arr,NSError *err) = aRequest.userInfo[@"completion"];
    if (error && completion) {
        completion(nil,error);
    }
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse{
    NSDictionary *dict = [aResponse.responseStr JSONValue];
    NSArray *groups = [dict objectForKey:@"groups"];
    if(groups.count){
        void(^completion)(NSArray *arr,NSError *err) = [aRequest.userInfo objectForKey:@"completion"];
        if (completion) {
            completion(groups,nil);
        }
    }else{
        NSString *msg = dict[@"message"];
        NSError *err = [NSError errorWithDomain:msg code:-1 userInfo:nil];
        void(^completion)(NSArray *arr,NSError *err) = [aRequest.userInfo objectForKey:@"completion"];
        if (completion) {
            completion(nil,err);
        }
    }
}
@end
