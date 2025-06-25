//
//  CMPOcrPackageViewModel.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/15.
//

#import <CMPLib/CMPBaseViewModel.h>
#import "CMPOcrPackageModel.h"

@interface CMPOcrPackageViewModel : CMPBaseViewModel

//获取未报销包list
- (void)getNonUsedPackageListSuccessBlock:(void(^)(NSArray<CMPOcrPackageModel *> *))successBlock errorBlock:(void(^)(NSError *error))errorBlock;
//包详情页面获取提示和页面识别count信息
- (void)getPackageTipByPackageId:(NSString *)packageId completion:(void(^)(CMPOcrPackageTipModel *tipModel,NSError *err))completion;
//获取包分类列表
- (void)getPackageClassifyListCompletion:(void (^)(NSArray<CMPOcrPackageClassifyModel *> *classifyArr,NSError *err))completion;

//移动invoiceList to package
- (void)moveInvoice:(NSArray *)invoiceIdArr toPackage:(NSString *)packageId completion:(void (^)(BOOL success, NSError *err))completion;
@end
