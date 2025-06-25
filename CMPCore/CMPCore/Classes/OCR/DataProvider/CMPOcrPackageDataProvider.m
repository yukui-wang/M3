//
//  CMPOcrPackageDataProvider.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/15.
//

#import "CMPOcrPackageDataProvider.h"

//未报销
static NSString *nonUsedPackageUrl = @"/rest/ai/reimbursement/package/v1/not/reimbursement/list";
//tip 一键报销提示，识别页面红点
static NSString *tipUrl = @"/rest/ai/reimbursement/package/v1/detail/tips/";
//获取分类包信息
static NSString *packageClassifyUrl = @"/rest/ai/reimbursement/package/v1/user/classify";
//移动发票到指定报销包
static NSString *packageMoveUrl = @"/rest/ai/ocr/application/v1/invoice/move/%@?option.n_a_s=1";

@interface CMPOcrPackageDataProvider()<CMPDataProviderDelegate>
@property (copy, nonatomic) void(^successBlock)(NSArray *arr);
@property (copy, nonatomic) void(^failedBlock)(NSError *error);
@end

@implementation CMPOcrPackageDataProvider
- (void)getNonUsedPackageListSuccessBlock:(void (^)(NSArray *arr))successBlock failedBlock:(void(^)(NSError *error))failedBlock {

    NSString *requestUrl = [CMPCore fullUrlForPath:nonUsedPackageUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)getTipByPackageId:(NSString *)packageId completion:(void (^)(id data,NSError *err))completion{
    NSString *requestUrl = [CMPCore fullUrlForPathFormat:@"%@%@",tipUrl,packageId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.userInfo = @{
        @"completion_tip_block":completion
    };
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)getPackageClassifyListCompletion:(void (^)(id data,NSError *err))completion{
    NSString *requestUrl = [CMPCore fullUrlForPath:packageClassifyUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.userInfo = @{
        @"completion_classify_block":completion
    };
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)moveInvoice:(NSArray *)invoiceIdArr toPackage:(NSString *)packageId completion:(void (^)(id data,NSError *err))completion{
    NSString *requestUrl = [CMPCore fullUrlForPathFormat:packageMoveUrl,packageId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.userInfo = @{
        @"completion_move_block":completion
    };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:invoiceIdArr options:0 error:nil];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    aDataRequest.requestParam = strJson;//仅字符串数组的json
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    if (error && self.failedBlock) {
        self.failedBlock(error);
    }
    
    //tip信息
    NSDictionary *userInfo = aRequest.userInfo;
    void(^completion_tip_block)(id respData,NSError *err) = [userInfo objectForKey:@"completion_tip_block"];
    if (error && completion_tip_block) {
        completion_tip_block(nil,error);
    }
    //classify分类信息
    void(^completion_classify_block)(id respData,NSError *err) = [userInfo objectForKey:@"completion_classify_block"];
    if (error && completion_classify_block) {
        completion_classify_block(nil,error);
    }
    //移动到package
    void(^completion_move_block)(id respData,NSError *err) = [userInfo objectForKey:@"completion_move_block"];
    if (error && completion_move_block) {
        completion_move_block(nil,error);
    }
    
    //completion
    void(^completion)(id respData,NSError *err) = [userInfo objectForKey:@"completion"];
    if (error && completion) {
        completion(nil,error);
    }
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    NSDictionary *dict = [aResponse.responseStr JSONValue];
    if ([dict[@"code"] integerValue] == 0) {
        NSArray *arr = [dict objectForKey:@"data"];
        if (self.successBlock) {
            self.successBlock(arr);
        }
        
        //tip信息
        NSDictionary *userInfo = aRequest.userInfo;
        void(^completion_tip_block)(id respData,NSError *err) = [userInfo objectForKey:@"completion_tip_block"];
        if (completion_tip_block) {
            id data = [dict objectForKey:@"data"];
            completion_tip_block(data,nil);
        }
        //classify分类信息
        void(^completion_classify_block)(id respData,NSError *err) = [userInfo objectForKey:@"completion_classify_block"];
        if (completion_classify_block) {
            id data = [dict objectForKey:@"data"];
            completion_classify_block(data,nil);
        }
        
        //移动到package
        void(^completion_move_block)(id respData,NSError *err) = [userInfo objectForKey:@"completion_move_block"];
        if (completion_move_block) {
            completion_move_block(dict,nil);
        }
        //completion
        void(^completion)(id respData,NSError *err) = [userInfo objectForKey:@"completion"];
        if (completion) {
            completion(dict,nil);
        }
    }else{
        NSString *msg = dict[@"message"];
        NSError *err = [NSError errorWithDomain:msg code:[dict[@"code"] integerValue] userInfo:nil];
        if (self.failedBlock) {
            self.failedBlock(err);
        }
        
        //tip信息
        NSDictionary *userInfo = aRequest.userInfo;
        void(^completion_tip_block)(id respData,NSError *err) = [userInfo objectForKey:@"completion_tip_block"];
        if (completion_tip_block) {
            completion_tip_block(nil,err);
        }
        //classify分类信息
        void(^completion_classify_block)(id respData,NSError *err) = [userInfo objectForKey:@"completion_classify_block"];
        if (completion_classify_block) {
            completion_classify_block(nil,err);
        }
        
        //移动到package
        void(^completion_move_block)(id respData,NSError *err) = [userInfo objectForKey:@"completion_move_block"];
        if (completion_move_block) {
            completion_move_block(nil,err);
        }
        
        //completion
        void(^completion)(id respData,NSError *err) = [userInfo objectForKey:@"completion"];
        if (completion) {
            completion(nil,err);
        }
    }
}

@end
