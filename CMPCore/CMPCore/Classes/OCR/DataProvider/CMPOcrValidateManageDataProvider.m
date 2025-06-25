//
//  CMPOcrValidateManageDataProvider.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/10.
//

#import "CMPOcrValidateManageDataProvider.h"
@interface CMPOcrValidateManageDataProvider()<CMPDataProviderDelegate>

@end

@implementation CMPOcrValidateManageDataProvider
- (void)requestOcrTaskWithPackageId:(NSString *)packageId successBlock:(nullable void (^)(NSArray *arr))successBlock failedBlock:(nullable void(^)(NSError *error))failedBlock {

    [[CMPDataProvider sharedInstance]cancelRequestsWithDelegate:self];
    
    NSString *requestUrl = [CMPCore fullUrlForPath:@"/rest/ai/ocr/application/v1/ocrtask/list/"];
    requestUrl = [requestUrl stringByAppendingFormat:@"%@",packageId];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.userInfo = @{
        @"successBlock":successBlock,
        @"failedBlock":failedBlock
    };
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    void(^failedBlock)(NSError *error) = aRequest.userInfo[@"failedBlock"];
    if (error && failedBlock) {
        failedBlock(error);
    }
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    NSDictionary *dict = [aResponse.responseStr JSONValue];
    if ([dict[@"code"] integerValue] == 0) {
        NSArray *arr = [dict objectForKey:@"data"];//发票识别任务ID
        void(^successBlock)(NSArray *arr) = aRequest.userInfo[@"successBlock"];
        if (successBlock) {
            successBlock(arr);
        }
    }else{
        NSString *msg = dict[@"message"];
        NSError *err = [NSError errorWithDomain:msg code:[dict[@"code"] integerValue] userInfo:nil];
        void(^failedBlock)(NSError *error) = aRequest.userInfo[@"failedBlock"];
        if (failedBlock) {
            failedBlock(err);
        }
    }
}

@end
