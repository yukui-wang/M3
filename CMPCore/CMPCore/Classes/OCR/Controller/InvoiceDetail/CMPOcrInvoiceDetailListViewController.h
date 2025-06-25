//
//  CMPOcrInvoiceDetailListViewController.h
//  M3
//
//  Created by Shoujian Rao on 2022/1/13.
//

#import <UIKit/UIKit.h>
#import "CMPOcrInvoiceDetailModel.h"

@interface CMPOcrInvoiceDetailListViewController : UIViewController

@property (nonatomic ,strong) CMPOcrInvoiceDetailItemModel *itemModel;
@property (nonatomic, copy) NSString *packageId;
@property (nonatomic,copy) NSArray* (^allInvoiceTypesBlk)(id obj);
@property (nonatomic,copy) NSArray* (^allInvoiceConsumeTypesBlk)(id obj);

- (void)comfirmActionCompletion:(void(^)(void))completion;
- (BOOL)compareIfChanged;
- (void)restoreChange;

@end

