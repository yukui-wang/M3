//
//  CMPOcrDeleteInvoiceDataProvider.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/18.
//

#import "CMPOcrDeleteInvoiceDataProvider.h"
@interface CMPOcrDeleteInvoiceDataProvider()<CMPDataProviderDelegate>


@end
@implementation CMPOcrDeleteInvoiceDataProvider
- (void)deleteInvoiceListByArr:(NSArray *)invoiceIdArr completion:(void (^)(NSError *error))completionBlock {
    
    NSString *lastPath = [NSString stringWithFormat:@"/rest/ai/ocr/application/v1/invoice/delete"];
    NSString *requestUrl = [CMPCore fullUrlForPath:lastPath];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    
//    NSDictionary *params = @{@"invoiceIds":invoiceIdArr?:@""};
//    aDataRequest.requestParam = [params JSONRepresentation];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:invoiceIdArr options:0 error:nil];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    aDataRequest.requestParam = strJson;//仅字符串数组的json
    
    aDataRequest.userInfo = @{
        @"completionBlock":completionBlock,
    };
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}
//删除ocrtask
- (void)deleteInvoiceByIdArr:(NSArray *)invoiceIdArr completion:(void (^)(NSError *error))completionBlock {
    
    NSString *lastPath = [NSString stringWithFormat:@"/rest/ai/ocr/application/v1/ocrtask/delete"];
    NSString *requestUrl = [CMPCore fullUrlForPath:lastPath];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    
//    NSDictionary *params = @{@"invoiceIds":invoiceIdArr?:@""};
//    aDataRequest.requestParam = [params JSONRepresentation];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:invoiceIdArr options:0 error:nil];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    aDataRequest.requestParam = strJson;//仅字符串数组的json
    
    aDataRequest.userInfo = @{
        @"completionBlock":completionBlock,
    };
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}
//删除ocrtask
- (void)deleteInvoiceById:(NSString *)invoiceId completion:(void (^)(NSError *error))completionBlock {
    
    NSString *lastPath = [NSString stringWithFormat:@"/rest/ai/ocr/application/v1/ocrtask/deleteByInvoiceId/%@?option.n_a_s=1",invoiceId];
    NSString *requestUrl = [CMPCore fullUrlForPath:lastPath];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    
    aDataRequest.userInfo = @{
        @"completionBlock":completionBlock,
    };
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)updateTaskStatusByTaskId:(NSString *)taskId
                      taskStatus:(NSNumber *)taskStatus
                       completion:(void (^)(NSError *error))completionBlock{
    NSString *url = [NSString stringWithFormat: @"/rest/ai/ocr/application/v1/ocrtask/updatestatus/%@?option.n_a_s=1",taskId];
    NSString *requestUrl = [CMPCore fullUrlPathMapForPath:url];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.userInfo = @{
        @"completionBlock":completionBlock,
    };
    NSDictionary *params = @{@"taskStatus":taskStatus?:@""};
    aDataRequest.requestParam = [params JSONRepresentation];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    NSDictionary *userInfo = aRequest.userInfo;
    void(^completionBlock)(NSError *err) = [userInfo objectForKey:@"completionBlock"];
    if (completionBlock) {
        completionBlock(error);
    }
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    NSDictionary *dict = [aResponse.responseStr JSONValue];
    NSDictionary *userInfo = aRequest.userInfo;
    void(^completionBlock)(NSError *err) = [userInfo objectForKey:@"completionBlock"];
    
    if ([dict[@"code"] integerValue] == 0) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }else{
        NSString *msg = dict[@"message"];
        NSError *err = [NSError errorWithDomain:msg code:[dict[@"code"] integerValue] userInfo:nil];
        if (completionBlock) {
            completionBlock(err);
        }
    }
}

@end
