//
//  CMPOcrScheduleViewModel.h
//  M3
//
//  Created by Shoujian Rao on 2022/1/17.
//

#import <CMPLib/CMPBaseViewModel.h>

@interface CMPOcrScheduleViewModel : CMPBaseViewModel

//更新明细表
- (void)updateScheduleByInvoiceId:(NSString *)invoiceId
                            param:(NSDictionary *)param
                       completion:(void (^)(NSError *err))completion;
@end

