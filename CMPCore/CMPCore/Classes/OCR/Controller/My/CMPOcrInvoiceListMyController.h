//
//  CMPOcrInvoiceListMyController.h
//  M3
//
//  Created by Shoujian Rao on 2022/7/25.
//

#import "CMPOcrBaseViewController.h"
#import <CMPLib/CMPBannerViewController.h>
#import "CMPOcrInvoiceModel.h"

@class CMPOcrDefaultInvoiceCategoryModel;

@interface CMPOcrInvoiceListMyController : CMPBannerViewController

@property (nonatomic, copy) void(^ScrollViewWillBeginDraggingBlock)(void);

@property (nonatomic, strong) NSArray<CMPOcrInvoiceGroupListModel *> *datas;

@property (nonatomic, copy) NSString *packageId;

@property (nonatomic, copy) void(^RefreshActionBlock)(void);


@end

