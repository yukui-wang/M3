//
//  CMPOcrInvoiceSelectedAlertView.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CMPOcrInvoiceItemModel;

typedef void(^CMPOcrInvoiceSelectedAlertViewDelete)(CMPOcrInvoiceItemModel *_Nullable item);

@interface CMPOcrInvoiceSelectedAlertView : UIView

@property (nonatomic, copy) CMPOcrInvoiceSelectedAlertViewDelete deleteCompletion;

- (void)show:(NSArray *)items;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
