//
//  CMPOcrMainViewDataProvider.h
//  M3
//
//  Created by Kaku Songu on 11/23/21.
//

#import <CMPLib/CMPDataProvider.h>

NS_ASSUME_NONNULL_BEGIN
//请求网络数据
@interface CMPOcrMainViewDataProvider : CMPDataProvider<CMPDataProviderDelegate>

-(void)fetchCommonModulesWithParams:(NSDictionary *)params
                         completion:(void(^)(id respData,NSError *error,id ext))completion;

-(void)fetchAllModulesWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion;

/**
 pageSize    number
 必须
 每页数据量
 pageNo    number
 必须
 页码
 templateId    number
 必须
 分类数据关联的模板id
 formId    number
 必须
 分类数据关联的表单id
 */
-(void)fetchPackageListWithParams:(NSDictionary *)params
                       completion:(void(^)(id respData,NSError *error,id ext))completion;

//唤醒PC
-(void)wakeupPC:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion;

-(void)checkWakeUpIfCanCommitWithPackageId:(NSString *)packageId completion:(void(^)(id respData,NSError *error,id ext))completion;

-(void)checkWakeUpIfCanCommitWithInvoiceIdList:(NSArray *)invoiceIdList completion:(void(^)(id respData,NSError *error,id ext))completion;
/**
 code值枚举
 0：可以一键报销   //不弹框
 1：有重复发票不能报销
 2：报销包中的发票未全部识别完成，不能报销
 3：报销包中的发票识别完了，但是有发票没有识别到内容，不能报销
 4：报销包中的发票都识别完成了，但是没有识别出来发票编码和发票代码，不能报销

 message
 除了0 其他的都在前端弹出提示
 */
-(void)checkPackageIfCanCommitWithParams:(NSDictionary *)params
                              completion:(void(^)(id respData,NSError *error,id ext))completion;

//包详情页面发起一键报销check
-(void)checkPackageIfCanCommitWithInvoiceIds:(NSArray *)invoiceIds
                                  templateId:(NSString *)templateId
                                      formId:(NSString *)formId
                                  completion:(void(^)(id respData,NSError *error,id ext))completion;

-(void)deleteRepeatWithInvoiceIdList:(NSArray *)invoiceIdList completion:(void(^)(id respData,NSError *error,id ext))completion;

-(void)deletePackageWithParams:(NSDictionary *)params
                              completion:(void(^)(id respData,NSError *error,id ext))completion;

-(void)fetchDefaultPackageIdWithParams:(NSDictionary *)params
                            completion:(void(^)(id respData,NSError *error,id ext))completion;

-(void)updateModulesListWithParams:(NSArray *)params completion:(void(^)(id respData,NSError *error,id ext))completion;

@end

NS_ASSUME_NONNULL_END
