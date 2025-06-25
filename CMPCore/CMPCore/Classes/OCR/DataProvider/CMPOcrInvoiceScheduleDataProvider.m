//
//  CMPOcrInvoiceScheduleDataProvider.m
//  M3
//
//  Created by Shoujian Rao on 2022/1/17.
//

#import "CMPOcrInvoiceScheduleDataProvider.h"

static NSString *const kUpdateScheduleInvoiceUrl = @"/rest/ai/ocr/application/v1/invoice/schedule/update/";

@interface CMPOcrInvoiceScheduleDataProvider()<CMPDataProviderDelegate>
@property (nonatomic, copy) NSString *updateScheduleRequestID;
@end

@implementation CMPOcrInvoiceScheduleDataProvider
- (void)updateScheduleByInvoiceId:(NSString *)invoiceId
                            param:(NSDictionary *)param
                       completion:(void (^)(id data,NSError *err))completion{
    NSString *url = [NSString stringWithFormat: @"%@%@",kUpdateScheduleInvoiceUrl,invoiceId];
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
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    aDataRequest.requestParam = strJson;//仅字符串数组的json
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error{
    void(^completion)(id data,NSError *err) = aRequest.userInfo[@"completion"];
    if (error && completion) {
        completion(nil,error);
    }
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse{
    NSDictionary *dict = [aResponse.responseStr JSONValue];
    if ([dict[@"code"] integerValue] == 0) {
        id obj = [dict objectForKey:@"data"];
        void(^completion)(id respData,NSError *err) = [aRequest.userInfo objectForKey:@"completion"];
        if (completion) {
            completion(obj,nil);
        }
    }else{
        NSString *msg = dict[@"message"];
        NSError *err = [NSError errorWithDomain:msg code:[dict[@"code"] integerValue] userInfo:nil];
        void(^completion)(id respData,NSError *err) = [aRequest.userInfo objectForKey:@"completion"];
        if (completion) {
            completion(nil,err);
        }
    }
}
@end
