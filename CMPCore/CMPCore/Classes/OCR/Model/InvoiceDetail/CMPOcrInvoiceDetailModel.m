//
//  CMPOcrInvoiceDetailModel.m
//  M3
//
//  Created by 张艳 on 2021/12/14.
//

#import "CMPOcrInvoiceDetailModel.h"

@implementation CMPOcrInvoiceDetailModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"invoiceID" : @"id"};
}

@end

@implementation CMPOcrInvoiceDetailListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"data" : [CMPOcrInvoiceDetailItemModel class],
    };
}
@end

@implementation CMPOcrInvoiceDetailItemModel

@end



