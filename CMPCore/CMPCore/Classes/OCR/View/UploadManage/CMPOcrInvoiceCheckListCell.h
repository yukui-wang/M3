//
//  CMPOcrInvoiceCheckListCell.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/14.
//

#import <UIKit/UIKit.h>
#import "CMPOcrItemModel.h"
@interface CMPOcrInvoiceCheckListCell : UITableViewCell
@property (nonatomic, strong) CMPOcrItemModel *itemModel;
@property (nonatomic, copy) void(^ActionBtnBlock)(CMPOcrItemModel *itemModel);
@end

