//
//  CMPOcrAssociatedFooterView.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ShowInvoiceBlock)(BOOL isShow);
typedef void(^SureClickBlock)(void);

@interface CMPOcrAssociatedFooterView : UIView

@property (nonatomic ,copy) ShowInvoiceBlock    showBlock;
@property (nonatomic ,copy) SureClickBlock      sureBlcok;

- (void)refreshSelectInvoiceCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
