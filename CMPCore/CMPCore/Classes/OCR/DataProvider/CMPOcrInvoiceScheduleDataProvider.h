//
//  CMPOcrInvoiceScheduleDataProvider.h
//  M3
//
//  Created by Shoujian Rao on 2022/1/17.
//

#import <CMPLib/CMPDataProvider.h>

@interface CMPOcrInvoiceScheduleDataProvider : CMPDataProvider
- (void)updateScheduleByInvoiceId:(NSString *)invoiceId
                            param:(NSDictionary *)param
                       completion:(void (^)(id data,NSError *err))completion;
@end

