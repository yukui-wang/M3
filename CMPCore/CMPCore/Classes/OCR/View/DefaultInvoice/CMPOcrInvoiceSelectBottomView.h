//
//  CMPOcrInvoiceSelectBottomView.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import <UIKit/UIKit.h>

@protocol CMPOcrInvoiceSelectBottomViewDelegate <NSObject>

- (void)invoiceSelectBottomViewShowInfo;
- (void)invoiceSelectBottomViewReimburse;
- (void)invoiceSelectBottomViewMore;
//- (void)invoiceSelectBottomViewAdd;

@end

@interface CMPOcrInvoiceSelectBottomView : UIView

@property (nonatomic, weak) id<CMPOcrInvoiceSelectBottomViewDelegate> delegate;

- (void)setInvoiceNumber:(NSInteger)number money:(CGFloat)money;

//修改按钮显示文字
- (void)setExtStatus:(NSInteger)ext;

@end
