//
//  CMPOcrInvoiceDetailDataProvider.h
//  M3
//
//  Created by 张艳 on 2021/12/13.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CMPOcrInvoiceSuccessBlock) (NSDictionary *data);

typedef void(^CMPOcrInvoiceFailBlock) (NSError *error);

@interface CMPOcrInvoiceDetailDataProvider : CMPObject

/// 获取票据详情页列表
/// @param packageID 请求包裹ID
/// @param completion 回调
- (void)fetchInvoiceFiles:(NSString *)packageID
                  success:(CMPOcrInvoiceSuccessBlock)successBlock
                     fail:(CMPOcrInvoiceFailBlock)failBlock;

/// 获取票据详情
/// @param invoiceID 请求票据ID
/// @param completion 回调
- (void)fetchInvoiceDetail:(NSString *)invoiceID
                   success:(CMPOcrInvoiceSuccessBlock)successBlock
                      fail:(CMPOcrInvoiceFailBlock)failBlock;

/// 获取关联发票数据列表
/// @param rPackageId 请求报销包ID
/// @param mainInvoiceId 请求主发票ID
/// @param completion 回调
- (void)fetchAssociatedInvoiceList:(NSString *)rPackageId
                     mainInvoiceId:(NSString*)mainInvoiceId
                        is4History:(BOOL)is4History
                           success:(CMPOcrInvoiceSuccessBlock)successBlock
                              fail:(CMPOcrInvoiceFailBlock)failBlock;

/// 获取发票明细列表
/// @param invoiceId 请求发票ID
/// @param completion 回调
- (void)fetchScheduleInvoiceList:(NSString *)invoiceId
                           success:(CMPOcrInvoiceSuccessBlock)successBlock
                              fail:(CMPOcrInvoiceFailBlock)failBlock;
/// 更新发票主副发票的关联关系
/// @param invoiceId 请求发票ID
/// @param toUpdateRelatedArray 被选中的副发票ID列表
/// @param completion 回调
- (void)updateInvoiceRelationByMainId:(NSString *)mainInvoiceId
                      toUpdateRelated:(NSArray *)toUpdateRelatedArray
                           success:(CMPOcrInvoiceSuccessBlock)successBlock
                              fail:(CMPOcrInvoiceFailBlock)failBlock;

/// 更新票据详情信息
- (void)updateInvoiceDetailsByInvoiceId:(NSString *)invoiceId details:(NSDictionary *)detailsDict success:(CMPOcrInvoiceSuccessBlock)successBlock fail:(CMPOcrInvoiceFailBlock)failBlock;

/**
 获取所有发票类型
 */
- (void)fetchAllInvoiceTypesWithSuccess:(CMPOcrInvoiceSuccessBlock)successBlock
                                   fail:(CMPOcrInvoiceFailBlock)failBlock;

/**
 修改发票类型  modelId invoiceId
 */
- (void)updateInvoiceTypeWithParams:(NSDictionary *)params success:(CMPOcrInvoiceSuccessBlock)successBlock fail:(CMPOcrInvoiceFailBlock)failBlock;

/**
 获取所有发票消费类型
 */
- (void)fetchAllInvoiceConsumeTypesWithSuccess:(CMPOcrInvoiceSuccessBlock)successBlock
                                   fail:(CMPOcrInvoiceFailBlock)failBlock;

@end

NS_ASSUME_NONNULL_END
