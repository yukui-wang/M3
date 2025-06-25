//
//  CMPOcrPackageDataProvider.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/15.
//

#import <CMPLib/CMPDataProvider.h>

@interface CMPOcrPackageDataProvider : CMPDataProvider
- (void)getNonUsedPackageListSuccessBlock:(void (^)(NSArray *arr))successBlock failedBlock:(void(^)(NSError *error))failedBlock;
- (void)getTipByPackageId:(NSString *)packageId completion:(void (^)(id data,NSError *err))completion;
- (void)getPackageClassifyListCompletion:(void (^)(id data,NSError *err))completion;
- (void)moveInvoice:(NSArray *)invoiceIdArr toPackage:(NSString *)packageId completion:(void (^)(id data,NSError *err))completion;
@end
