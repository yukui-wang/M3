//
//  CMPOcrReimbursementManager.h
//  M3
//
//  Created by Shoujian Rao on 2022/1/14.
//

#import <CMPLib/CMPObject.h>

@interface CMPOcrReimbursementManager : CMPObject

//pc唤醒逻辑
- (void)pcReimbursementWithData:(NSDictionary *)respData templateId:(NSString *)templateId formId:(NSString *)formId packageId:(NSString *)packageId summaryId:(NSString *)summaryId fromVC:(UIViewController *)fromVC wakeUpBlock:(void(^)(void))wakeUpBlock;

//跳转到表单
- (void)jumpToFormFromVC:(UIViewController *)fromVC
           invoiceIdList:(NSArray *)invoiceIdList
              templateId:(NSString *)templateId
               packageId:(NSString *)packageId
                  formId:(NSString *)formId;
//首页列表一键报销
- (void)reimbursementWithData:(NSDictionary *)respData templateId:(NSString *)templateId formId:(NSString *)formId packageId:(NSString *)packageId summaryId:(NSString *)summaryId fromVC:(UIViewController *)fromVC cancelBlock:(void(^)(void))cancelBlock deleteBlock:(void(^)(void))deleteBlock ext:(id)ext;

//默认票夹一键报销
- (void)reimbursementCheckWithData:(NSDictionary *)respData templateId:(NSString *)templateId formId:(NSString *)formId packageId:(NSString *)packageId fromVC:(UIViewController *)fromVC callCreateBlock:(void(^)(NSInteger))callCreateBlock;

//跳转到表单
//- (void)jumpToFormFromVC:(UIViewController *)fromVC
//              templateId:(NSString *)templateId
//                  formId:(NSString *)formId
//               packageId:(NSString *)packageId
//               summaryId:(NSString *)summaryId;

- (void)ks_reimbursementWithData:(NSDictionary *)respData templateId:(NSString *)templateId formId:(NSString *)formId packageId:(NSString *)packageId summaryId:(NSString *)summaryId fromVC:(UIViewController *)fromVC cancelBlock:(void(^)(void))cancelBlock actBlock:(void(^)(NSArray *invoiceIds,NSError *err,id ext, NSInteger from))actBlock ext:(id)ext;

@end
