//
//  CMPOcrDeleteInvoiceDataProvider.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/18.
//

#import <CMPLib/CMPDataProvider.h>


@interface CMPOcrDeleteInvoiceDataProvider : CMPDataProvider
- (void)deleteInvoiceById:(NSString *)invoiceId completion:(void (^)(NSError *error))completionBlock;
//批量删除ocrtask
- (void)deleteInvoiceByIdArr:(NSArray *)invoiceIdArr completion:(void (^)(NSError *error))completionBlock;
//修改ocr task状态
- (void)updateTaskStatusByTaskId:(NSString *)taskId
                      taskStatus:(NSNumber *)taskStatus
                      completion:(void (^)(NSError *error))completionBlock;
//批量删除发票
- (void)deleteInvoiceListByArr:(NSArray *)invoiceIdArr completion:(void (^)(NSError *error))completionBlock;
@end

