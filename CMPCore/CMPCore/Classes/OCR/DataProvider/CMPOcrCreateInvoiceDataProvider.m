//
//  CMPOcrCreateInvoiceDataProvider.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/13.
//

#import "CMPOcrCreateInvoiceDataProvider.h"
@interface CMPOcrCreateInvoiceDataProvider()<CMPDataProviderDelegate>

@end

@implementation CMPOcrCreateInvoiceDataProvider

- (void)requestToSubmitFileWithId:(NSString *)fileId andPackageId:(NSString *)packageId successBlock:(void (^)(NSString *taskId))successBlock failedBlock:(void(^)(NSError *error))failedBlock {

    NSString *requestUrl = [CMPCore fullUrlForPath:@"/rest/ai/ocr/application/v1/invoice/createInvoice?option.n_a_s=1"];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
//    aDataRequest.httpShouldHandleCookies = NO;
    aDataRequest.userInfo = @{
        @"successBlock":successBlock,
        @"failedBlock":failedBlock
    };
    
    NSDictionary *params = @{
        @"rPackageId":packageId?:@"",
        @"fileId":fileId?:@""
    };

    aDataRequest.requestParam = [params JSONRepresentation];
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}
- (void)retryToSubmitWithId:(NSString *)ID successBlock:(void (^)(NSString *taskId))successBlock failedBlock:(void(^)(NSError *error))failedBlock{

    NSString *requestUrl = [CMPCore fullUrlForPathFormat:@"/rest/ai/ocr/application/v1/ocrtask/retry/%@",ID];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
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
        NSString *taskId = [dict objectForKey:@"data"];//发票识别任务ID
        void (^successBlock)(NSString *taskId) = aRequest.userInfo[@"successBlock"];
        if (successBlock) {
            successBlock(taskId);
        }
    }else{
        NSString *msg = dict[@"message"];
        NSError *err = [NSError errorWithDomain:msg code:[dict[@"code"] integerValue] userInfo:nil];
        void(^failedBlock)(NSError *error) = aRequest.userInfo[@"failedBlock"];
        if (err && failedBlock) {
            failedBlock(err);
        }
    }
}

@end
