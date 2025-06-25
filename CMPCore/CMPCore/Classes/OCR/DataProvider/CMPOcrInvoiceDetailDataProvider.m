//
//  CMPOcrInvoiceDetailDataProvider.m
//  M3
//
//  Created by 张艳 on 2021/12/13.
//

#import "CMPOcrInvoiceDetailDataProvider.h"
#import <CMPLib/CMPCommonTool.h>
#import "CMPOcrMainDataProvider.h"

static NSString *const kInvoiceFilesUrl = @"/rest/ai/ocr/application/v1/invoiceFiles/";

static NSString *const kInvoiceDetailUrl = @"/rest/ai/ocr/application/v1/invoice/details/";

static NSString *const kAssociatedInvoiceUrl = @"/rest/ai/ocr/application/v1/invoice/relation/list/";
static NSString *const kAssociatedInvoice4HistoryUrl = @"/rest/ai/ocr/application/v1/invoice/relation/list4History/";
static NSString *const kScheduleInvoiceUrl = @"/rest/ai/ocr/application/v1/invoice/schedule/";

static NSString *const kUpdateInvoiceRelationUrl = @"/rest/ai/ocr/application/v1/invoice/relation/update";

static NSString *const kUpdateInvoiceDetailsUrl = @"/rest/ai/ocr/application/v1/invoice/details/update/";

@interface CMPOcrInvoiceDetailDataProvider ()

/// 获取票据详情列表请求ID
@property (nonatomic, copy) NSString *invoiceFilesRequestID;

/// 获取票据详情请求ID
@property (nonatomic, copy) NSString *invoiceDetailRequestID;

/// 获取票据关联发票请求ID
@property (nonatomic, copy) NSString *associatedInvoiceListRequestID;

/// 获取票据关联发票请求ID
@property (nonatomic, copy) NSString *scheduleInvoiceListRequestID;

/// 更新 发票 关系
@property (nonatomic, copy) NSString *updateInvoiceRelationRequestID;

//更新发票详情
@property (nonatomic, copy) NSString *updateInvoiceDetailsRequestID;

//获取所有发票类型
@property (nonatomic, copy) NSString *fetchAllInvoiceTypesRequestID;

//获取所有发票消费类型
@property (nonatomic, copy) NSString *fetchAllInvoiceConsumeTypesRequestID;

@end

@implementation CMPOcrInvoiceDetailDataProvider


- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

/// 获取票据详情列表
/// @param packageID 请求包裹ID
/// @param completion 回调
- (void)fetchInvoiceFiles:(NSString *)packageID
                  success:(CMPOcrInvoiceSuccessBlock)successBlock
                     fail:(CMPOcrInvoiceFailBlock)failBlock {
   
    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:self.invoiceFilesRequestID];
    
    __weak typeof(self) weakself = self;

    NSString *url = [CMPCore fullUrlPathMapForPath:kInvoiceFilesUrl];
    if ([NSString isNull:url]) {
        return;
    }
    url = [url stringByAppendingFormat:@"%@?option.n_a_s=1",packageID];
    self.invoiceFilesRequestID = [[CMPOcrMainDataProvider sharedInstance] getRequestWithUrl:url params:@{} success:^(NSString *response,NSDictionary* userInfo) {
        weakself.invoiceFilesRequestID = nil;
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError *error,NSDictionary* userInfo) {
        weakself.invoiceFilesRequestID = nil;
        if (failBlock) {
            failBlock(error);
        }
    }];
}


/// 获取票据详情
/// @param invoiceID 请求票据ID
/// @param completion 回调
- (void)fetchInvoiceDetail:(NSString *)invoiceID
                   success:(CMPOcrInvoiceSuccessBlock)successBlock
                      fail:(CMPOcrInvoiceFailBlock)failBlock {
    
    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:self.invoiceDetailRequestID];
    
    __weak typeof(self) weakself = self;

    NSString *url = [CMPCore fullUrlPathMapForPath:kInvoiceDetailUrl];
    if ([NSString isNull:url]) {
        return;
    }
    url = [url stringByAppendingFormat:@"%@",invoiceID];
    
    self.invoiceDetailRequestID = [[CMPOcrMainDataProvider sharedInstance] getRequestWithUrl:url params:@{} success:^(NSString *response,NSDictionary* userInfo) {
        weakself.invoiceDetailRequestID = nil;
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError *error,NSDictionary* userInfo) {
        weakself.invoiceDetailRequestID = nil;
        if (failBlock) {
            failBlock(error);
        }
    }];
}
/// 获取关联发票数据列表
/// @param rPackageId 请求报销包ID
/// @param mainInvoiceId 请求主发票ID
/// @param completion 回调
- (void)fetchAssociatedInvoiceList:(NSString *)rPackageId
                     mainInvoiceId:(NSString*)mainInvoiceId
                        is4History:(BOOL)is4History
                           success:(CMPOcrInvoiceSuccessBlock)successBlock
                              fail:(CMPOcrInvoiceFailBlock)failBlock{
     
    NSString *url = [CMPCore fullUrlPathMapForPath:is4History?kAssociatedInvoice4HistoryUrl:kAssociatedInvoiceUrl];
    if ([NSString isNull:url]) {
        return;
    }
    url = [url stringByAppendingFormat:@"%@/%@",rPackageId,mainInvoiceId];
    
    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:self.associatedInvoiceListRequestID];
    
    __weak typeof(self) weakself = self;
    self.associatedInvoiceListRequestID = [[CMPOcrMainDataProvider sharedInstance] getRequestWithUrl:url params:@{} success:^(NSString *response,NSDictionary* userInfo) {
        weakself.associatedInvoiceListRequestID = nil;
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError *error,NSDictionary* userInfo) {
        weakself.associatedInvoiceListRequestID = nil;
        if (failBlock) {
            failBlock(error);
        }
    }];
}

/// 获取发票明细列表
/// @param invoiceId 请求发票ID
/// @param completion 回调
- (void)fetchScheduleInvoiceList:(NSString *)invoiceId
                           success:(CMPOcrInvoiceSuccessBlock)successBlock
                            fail:(CMPOcrInvoiceFailBlock)failBlock{
    NSString *url = [CMPCore fullUrlPathMapForPath:kScheduleInvoiceUrl];
    if ([NSString isNull:url]) {
        return;
    }
    url = [url stringByAppendingFormat:@"%@",invoiceId];
    
    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:self.scheduleInvoiceListRequestID];
    
    __weak typeof(self) weakself = self;
    self.scheduleInvoiceListRequestID = [[CMPOcrMainDataProvider sharedInstance] getRequestWithUrl:url params:@{} success:^(NSString *response,NSDictionary* userInfo) {
        weakself.scheduleInvoiceListRequestID = nil;
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError *error,NSDictionary* userInfo) {
        weakself.scheduleInvoiceListRequestID = nil;
        if (failBlock) {
            failBlock(error);
        }
    }];

}

- (void)updateInvoiceRelationByMainId:(NSString *)mainInvoiceId toUpdateRelated:(NSArray *)toUpdateRelatedArray success:(CMPOcrInvoiceSuccessBlock)successBlock fail:(CMPOcrInvoiceFailBlock)failBlock{
    NSString *url = [CMPCore fullUrlPathMapForPath:kUpdateInvoiceRelationUrl];
    if ([NSString isNull:url]) {
        return;
    }

    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    body[@"mainInvoiceId"] = mainInvoiceId;
    body[@"toUpdateRelated"] = toUpdateRelatedArray;

    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:self.updateInvoiceRelationRequestID];

    __weak typeof(self) weakself = self;
    self.updateInvoiceRelationRequestID = [[CMPOcrMainDataProvider sharedInstance] postRequestWithUrl:url params:body success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.updateInvoiceRelationRequestID = nil;
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.updateInvoiceRelationRequestID = nil;
        if (failBlock) {
            failBlock(response);
        }
    }];
}

- (void)updateInvoiceDetailsByInvoiceId:(NSString *)invoiceId details:(NSDictionary *)detailsDict success:(CMPOcrInvoiceSuccessBlock)successBlock fail:(CMPOcrInvoiceFailBlock)failBlock{
    NSString *url = [CMPCore fullUrlPathMapForPath:[kUpdateInvoiceDetailsUrl stringByAppendingString:invoiceId]];
    if ([NSString isNull:url]) {
        return;
    }

    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:self.updateInvoiceDetailsRequestID];

    __weak typeof(self) weakself = self;
    self.updateInvoiceDetailsRequestID = [[CMPOcrMainDataProvider sharedInstance] postRequestWithUrl:url params:detailsDict success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.updateInvoiceDetailsRequestID = nil;
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.updateInvoiceDetailsRequestID = nil;
        if (failBlock) {
            failBlock(response);
        }
    }];
}

- (void)fetchAllInvoiceTypesWithSuccess:(CMPOcrInvoiceSuccessBlock)successBlock fail:(CMPOcrInvoiceFailBlock)failBlock{
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/ai/ocr/application/v1/invoice/type/all"];
    if ([NSString isNull:url]) {
        return;
    }

    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:_fetchAllInvoiceTypesRequestID];

    __weak typeof(self) weakself = self;
    _fetchAllInvoiceTypesRequestID = [[CMPOcrMainDataProvider sharedInstance] getRequestWithUrl:url params:nil success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.fetchAllInvoiceTypesRequestID = nil;
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.fetchAllInvoiceTypesRequestID = nil;
        if (failBlock) {
            failBlock(response);
        }
    }];
}

- (void)updateInvoiceTypeWithParams:(NSDictionary *)params success:(CMPOcrInvoiceSuccessBlock)successBlock fail:(CMPOcrInvoiceFailBlock)failBlock{
    if (!params) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/ai/ocr/application/v1/invoice/model/change"];
    if ([NSString isNull:url]) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[CMPOcrMainDataProvider sharedInstance] postRequestWithUrl:url params:params success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.updateInvoiceDetailsRequestID = nil;
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.updateInvoiceDetailsRequestID = nil;
        if (failBlock) {
            failBlock(response);
        }
    }];
}


- (void)fetchAllInvoiceConsumeTypesWithSuccess:(CMPOcrInvoiceSuccessBlock)successBlock fail:(CMPOcrInvoiceFailBlock)failBlock{
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/ai/model/v1/consumer/type"];
    if ([NSString isNull:url]) {
        return;
    }

    [[CMPOcrMainDataProvider sharedInstance] cancelWithRequestId:_fetchAllInvoiceConsumeTypesRequestID];

    __weak typeof(self) weakself = self;
    _fetchAllInvoiceConsumeTypesRequestID = [[CMPOcrMainDataProvider sharedInstance] getRequestWithUrl:url params:nil success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.fetchAllInvoiceConsumeTypesRequestID = nil;
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (successBlock) {
            successBlock(dict);
        }
        
    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        weakself.fetchAllInvoiceConsumeTypesRequestID = nil;
        if (failBlock) {
            failBlock(response);
        }
    }];
}

@end
