//
//  CMPOcrPackageViewModel.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/15.
//

#import "CMPOcrPackageViewModel.h"
#import "CMPOcrPackageDataProvider.h"
@interface CMPOcrPackageViewModel()
@property (nonatomic, strong) CMPOcrPackageDataProvider *packageDataProvider;
@end
@implementation CMPOcrPackageViewModel

- (void)getNonUsedPackageListSuccessBlock:(void(^)(NSArray<CMPOcrPackageModel *> *))successBlock errorBlock:(void(^)(NSError *error))errorBlock{
    [self.packageDataProvider getNonUsedPackageListSuccessBlock:^(NSArray *arr) {
        NSArray *resultArr = [NSArray yy_modelArrayWithClass:CMPOcrPackageModel.class json:arr];
        if (successBlock) {
            successBlock(resultArr);
        }
    } failedBlock:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getPackageTipByPackageId:(NSString *)packageId completion:(void(^)(CMPOcrPackageTipModel *tipModel,NSError *err))completion{
    [self.packageDataProvider getTipByPackageId:packageId completion:^(id data, NSError *err) {
        CMPOcrPackageTipModel *tipModel = [CMPOcrPackageTipModel yy_modelWithDictionary:data];
        completion(tipModel,err);
    }];
}

- (void)getPackageClassifyListCompletion:(void (^)(NSArray<CMPOcrPackageClassifyModel *> *classifyArr,NSError *err))completion{
    [self.packageDataProvider getPackageClassifyListCompletion:^(id data, NSError *err) {
        NSArray<CMPOcrPackageClassifyModel *> *resultArr = [NSArray yy_modelArrayWithClass:CMPOcrPackageClassifyModel.class json:data];
        completion(resultArr,err);
    }];
}

- (void)moveInvoice:(NSArray *)invoiceIdArr toPackage:(NSString *)packageId completion:(void (^)(BOOL, NSError *))completion{
    if (!invoiceIdArr.count) {
        return;
    }
    [self.packageDataProvider moveInvoice:invoiceIdArr toPackage:packageId completion:^(id data, NSError *err) {
        completion([data[@"code"] integerValue] == 0,err);
    }];
}

- (CMPOcrPackageDataProvider *)packageDataProvider{
    if (!_packageDataProvider) {
        _packageDataProvider = [[CMPOcrPackageDataProvider alloc]init];
    }
    return _packageDataProvider;
}

@end
