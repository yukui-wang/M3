//
//  CMPOcrCreateInvoiceDataProvider.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/13.
//

#import <CMPLib/CMPDataProvider.h>



@interface CMPOcrCreateInvoiceDataProvider : CMPDataProvider

- (void)requestToSubmitFileWithId:(NSString *)fileId andPackageId:(NSString *)packageId successBlock:(void (^)(NSString *fileId))successBlock failedBlock:(void(^)(NSError *error))failedBlock;

//重试，taskStatus = 11的情况
- (void)retryToSubmitWithId:(NSString *)ID successBlock:(void (^)(NSString *taskId))successBlock failedBlock:(void(^)(NSError *error))failedBlock;

@end

