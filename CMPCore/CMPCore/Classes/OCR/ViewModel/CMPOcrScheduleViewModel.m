//
//  CMPOcrScheduleViewModel.m
//  M3
//
//  Created by Shoujian Rao on 2022/1/17.
//

#import "CMPOcrScheduleViewModel.h"
#import "CMPOcrInvoiceScheduleDataProvider.h"
@interface CMPOcrScheduleViewModel()
@property (nonatomic, strong) CMPOcrInvoiceScheduleDataProvider *dataProvider;
@end

@implementation CMPOcrScheduleViewModel

- (void)updateScheduleByInvoiceId:(NSString *)invoiceId
                            param:(NSDictionary *)param
                       completion:(void (^)(NSError *err))completion{
    [self.dataProvider updateScheduleByInvoiceId:invoiceId param:param completion:^(id data, NSError *err) {
        if (completion) {
            completion(err);
        }
    }];
}


- (CMPOcrInvoiceScheduleDataProvider *)dataProvider{
    if (!_dataProvider) {
        _dataProvider = [CMPOcrInvoiceScheduleDataProvider new];
    }
    return _dataProvider;
}


@end
