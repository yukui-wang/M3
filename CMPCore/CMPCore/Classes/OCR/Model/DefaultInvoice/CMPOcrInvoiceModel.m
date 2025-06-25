//
//  CMPOcrInvoiceModel.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/25.
//

#import "CMPOcrInvoiceModel.h"

@implementation CMPOcrInvoiceModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"deputyInvoiceList" : [CMPOcrInvoiceItemModel class],
    };
}

@end

@implementation CMPOcrInvoiceItemModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"invoiceID" : @"id"
    };
}

@end

@implementation CMPOcrDefaultInvoiceCategoryModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"modelID" : @"id"
    };
}

- (NSInteger)invoiceCount{
    NSInteger total = 0;
    for (CMPOcrInvoiceGroupListModel *group in self.invoiceGroupArray) {
        total += group.invoiceItemArray.count;
    }
    return total;
}

- (NSString *)modelName{
    if (_modelName.length <= 0) {
        return _name;
    }
    return _modelName;
}

@end

@implementation CMPOcrInvoiceGroupListModel

@end

