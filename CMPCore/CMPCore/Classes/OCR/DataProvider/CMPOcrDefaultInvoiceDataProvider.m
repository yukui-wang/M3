//
//  CMPOcrDefaultInvoiceDataProvider.m
//  M3
//
//  Created by 张艳 on 2021/12/18.
//

#import "CMPOcrDefaultInvoiceDataProvider.h"
#import <CMPLib/CMPCommonTool.h>
#import "CMPOcrMainDataProvider.h"

@interface CMPOcrDefaultInvoiceDataProvider ()<CMPDataProviderDelegate>

/// 获取票据详情列表请求ID
@property (nonatomic, copy) NSString *defaultInvoiceModelsRequestID;

/// 获取票据详情请求ID
@property (nonatomic, copy) NSString *defaultInvoiceListRequestID;

@property (nonatomic, copy) NSString *fetchInvoiceListAndTipsRequestID;

@property (nonatomic, copy) NSString *deleteInvoiceRequestID;

@end

@implementation CMPOcrDefaultInvoiceDataProvider


- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

/// 获取默认票夹-发票列表
/// @param groupId 请求包裹ID
/// @param completion 回调
- (void)fetchDefaultInvoiceModels:(NSString *)groupId
                          success:(CMPOcrInvoiceSuccessBlock)successBlock
                             fail:(CMPOcrInvoiceFailBlock)failBlock {
    /// 获取默认票夹-模型列表（分类接口）
    NSString *defaultInvoiceModlesUrl = [NSString stringWithFormat: @"/rest/ai/model/v1/%@/all",groupId];
    NSString *url = [CMPCore fullUrlPathMapForPath:defaultInvoiceModlesUrl];
    if ([NSString isNull:url]) {
        return;
    }
    
    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:self.defaultInvoiceModelsRequestID];
    __weak typeof(self) weakself = self;
    
    self.defaultInvoiceModelsRequestID = [[CMPOcrMainDataProvider sharedInstance] getRequestWithUrl:url params:@{} success:^(NSString *response,NSDictionary* userInfo) {
        
        weakself.defaultInvoiceModelsRequestID = nil;
        
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError *error,NSDictionary* userInfo) {
        weakself.defaultInvoiceModelsRequestID = nil;
        if (failBlock) {
            failBlock(error);
        }
    }];
}

/// 获取默认票夹-模型列表（分类接口）
/// @param packageId 发票包id
/// @param modelId 发票模型id
/// @param condition 输入数字根据发票金额模糊查询，非数字根据发票模型名称模糊查询
/// @param total 发票金额(模糊匹配)
/// @param successBlock 成功回包
/// @param failBlock 失败回包
///
/*
- (void)fetchDefaultInvoiceListWithPackageId:(NSString * __nullable)packageId
                                   modleId:(NSString * __nullable)modelId
                                 condition:(NSString * __nullable)condition
                                     total:(NSString * __nullable)total
                                   success:(CMPOcrInvoiceSuccessBlock)successBlock
                                      fail:(CMPOcrInvoiceFailBlock)failBlock {
        
    NSString *defaultInvoiceModlesUrl = [NSString stringWithFormat: @"/rest/ai/ocr/application/v1/invoice/list/%@?option.n_a_s=1",packageId];
    NSString *url = [CMPCore fullUrlPathMapForPath:defaultInvoiceModlesUrl];
    if ([NSString isNull:url]) {
        return;
    }
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    body[@"total"] = total;
    body[@"modelId"] = modelId;
    body[@"condition"] = condition;

    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:self.defaultInvoiceListRequestID];

    __weak typeof(self) weakself = self;
    self.defaultInvoiceListRequestID = [[CMPOcrMainDataProvider sharedInstance] postRequestWithUrl:url params:body success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.defaultInvoiceListRequestID = nil;
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.defaultInvoiceListRequestID = nil;
        if (failBlock) {
            failBlock(response);
        }
    }];
}
 */
- (void)fetchInvoiceListAndTipsWithPackageId:(NSString * __nullable)packageId
                                   modleId:(NSString * __nullable)modelId
                                 condition:(NSString * __nullable)condition
                                     total:(NSString * __nullable)total
                                    status:(NSArray *)statusArr
                                   success:(CMPOcrInvoiceSuccessBlock)successBlock
                                      fail:(CMPOcrInvoiceFailBlock)failBlock {
        
    NSString *invoiceListAndTipsUrl = [NSString stringWithFormat: @"/rest/ai/reimbursement/package/v1/detail/listAndTips/%@?option.n_a_s=1",packageId];
    NSString *url = [CMPCore fullUrlPathMapForPath:invoiceListAndTipsUrl];
    if ([NSString isNull:url]) {
        return;
    }
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
//    if (total.length) {
//        body[@"total"] = total;//金额
//    }
    if (condition.length) {
        body[@"condition"] = condition;//关键字
    }
    body[@"modelId"] = modelId;
    body[@"invoiceStatus"] = statusArr;//状态

    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:self.fetchInvoiceListAndTipsRequestID];

    __weak typeof(self) weakself = self;
    self.fetchInvoiceListAndTipsRequestID = [[CMPOcrMainDataProvider sharedInstance] postRequestWithUrl:url params:body success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.fetchInvoiceListAndTipsRequestID = nil;
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.fetchInvoiceListAndTipsRequestID = nil;
        if (failBlock) {
            failBlock(response);
        }
    }];
}

//默认票夹-一键报销
- (void)reimbursementWithTemplateId:(NSString * __nullable)templateId
                             formId:(NSString * __nullable)formId
                           invoices:(NSArray * __nullable)invoiceIdArr
                         completion:(void (^)(id data,NSError *err))completion{
    NSString *reimbursementUrl = [NSString stringWithFormat: @"/rest/ai/reimbursement/package/v1/submit/createRPackage/%@/%@",templateId,formId];
    NSString *requestUrl = [CMPCore fullUrlPathMapForPath:reimbursementUrl];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.userInfo = @{
        @"completion":completion
    };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:invoiceIdArr options:0 error:nil];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    aDataRequest.requestParam = strJson;//仅字符串数组的json
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

//check 获取提示语
- (void)reimbursementCheckWithInvoiceIDArr:(NSArray * __nullable)invoiceIdArr
                         completion:(void (^)(id data,NSError *err))completion{
    NSString *requestUrl = [CMPCore fullUrlPathMapForPath:@"/rest/ai/reimbursement/package/v1/submit/createRPackage/check"];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.userInfo = @{
        @"completion":completion
    };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:invoiceIdArr options:0 error:nil];
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

/// 删除发票
/// @param invoiceID 发票id
/// @param successBlock 成功回包
/// @param failBlock 失败回包
- (void)deleteInvoiceWithInvoiceID:(NSString *)invoiceID
                           success:(CMPOcrInvoiceSuccessBlock)successBlock
                              fail:(CMPOcrInvoiceFailBlock)failBlock {
    
    NSString *deleteUrl = [NSString stringWithFormat: @"/rest/ai/ocr/application/v1/invoice/deleteById/%@?option.n_a_s=1",invoiceID];
    NSString *url = [CMPCore fullUrlPathMapForPath:deleteUrl];
    if ([NSString isNull:url]) {
        return;
    }

    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:self.deleteInvoiceRequestID];

    __weak typeof(self) weakself = self;
    
    self.defaultInvoiceModelsRequestID = [[CMPOcrMainDataProvider sharedInstance] getRequestWithUrl:url params:@{} success:^(NSString *response,NSDictionary* userInfo) {
        
        weakself.deleteInvoiceRequestID = nil;
        
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError *error,NSDictionary* userInfo) {
        weakself.deleteInvoiceRequestID = nil;
        if (failBlock) {
            failBlock(error);
        }
    }];
}

@end


