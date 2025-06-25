//
//  CMPOcrDefaultInvoiceDataProvider.h
//  M3
//
//  Created by 张艳 on 2021/12/18.
//

#import <CMPLib/CMPDataProvider.h>
#import "CMPOcrInvoiceDetailDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrDefaultInvoiceDataProvider : CMPDataProvider

/// 获取默认票夹-模型列表（分类接口）
/// @param groupId 组ID
/// @param completion 回调
- (void)fetchDefaultInvoiceModels:(NSString *)groupId
                          success:(CMPOcrInvoiceSuccessBlock)successBlock
                             fail:(CMPOcrInvoiceFailBlock)failBlock;


/// 获取默认票夹-模型列表、搜索列表（分类接口）
/// @param modelId 发票模型id（必传）
/// @param condition 输入数字根据发票金额模糊查询，非数字根据发票模型名称模糊查询（非必传模糊匹配）
/// @param total 发票金额（非必传模糊匹配）
/// @param successBlock 成功回包
/// @param failBlock 失败回包
//- (void)fetchDefaultInvoiceListWithPackageId:(NSString * __nullable)packageId
//                                   modleId:(NSString * __nullable)modelId
//                                 condition:(NSString * __nullable)condition
//                                     total:(NSString * __nullable)total
//                                   success:(CMPOcrInvoiceSuccessBlock)successBlock
//                                      fail:(CMPOcrInvoiceFailBlock)failBlock;

//获取列表和提示
///
///@param condition  发票类型名称模糊查询
///@param total 金额
///
- (void)fetchInvoiceListAndTipsWithPackageId:(NSString * __nullable)packageId
                                   modleId:(NSString * __nullable)modelId
                                 condition:(NSString * __nullable)condition
                                     total:(NSString * __nullable)total
                                    status:(NSArray *)statusArr
                                   success:(CMPOcrInvoiceSuccessBlock)successBlock
                                      fail:(CMPOcrInvoiceFailBlock)failBlock;
/// 删除发票
/// @param invoiceID 发票id
/// @param successBlock 成功回包
/// @param failBlock 失败回包
- (void)deleteInvoiceWithInvoiceID:(NSString *)invoiceID
                           success:(CMPOcrInvoiceSuccessBlock)successBlock
                              fail:(CMPOcrInvoiceFailBlock)failBlock;

//默认票夹 发起一键报销
- (void)reimbursementWithTemplateId:(NSString * __nullable)templateId
                             formId:(NSString * __nullable)formId
                           invoices:(NSArray * __nullable)invoiceIdArr
                         completion:(void (^)(id data,NSError *err))completion;
//默认详情发起一键报销
- (void)reimbursementCheckWithInvoiceIDArr:(NSArray * __nullable)invoiceIdArr
                                completion:(void (^)(id data,NSError *err))completion;
@end

NS_ASSUME_NONNULL_END
