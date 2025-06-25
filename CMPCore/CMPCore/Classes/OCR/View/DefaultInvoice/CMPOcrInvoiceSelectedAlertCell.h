//
//  CMPOcrInvoiceSelectedAlertCell.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/25.
//

#import <UIKit/UIKit.h>
#import "CMPOcrInvoiceModel.h"

NS_ASSUME_NONNULL_BEGIN


@class CMPOcrInvoiceSelectedAlertItemCell;
@protocol CMPOcrInvoiceSelectedAlertCellDelegate <NSObject>

- (void)invoiceSelectedAlertCellDelete:(CMPOcrInvoiceSelectedAlertItemCell *)cell;

@end

@interface CMPOcrInvoiceSelectedAlertItemCell : UITableViewCell

@property (nonatomic, strong) CMPOcrInvoiceItemModel *item;

@property (nonatomic, weak) id<CMPOcrInvoiceSelectedAlertCellDelegate> delegate;

@end
NS_ASSUME_NONNULL_END
