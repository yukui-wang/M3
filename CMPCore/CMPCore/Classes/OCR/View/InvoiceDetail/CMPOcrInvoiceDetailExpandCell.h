//
//  CMPOcrInvoiceDetailExpandCell.h
//  M3
//
//  Created by Shoujian Rao on 2022/1/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrInvoiceDetailExpandCell : UITableViewCell

@property (nonatomic, assign) BOOL expand;
- (void)updateOffsetYConstraint:(CGFloat)offsetY;

@end

NS_ASSUME_NONNULL_END
