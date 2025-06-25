//
//  CMPOcrInvoiceItemCell.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import <UIKit/UIKit.h>
#import "CMPOcrInvoiceModel.h"
#import <CMPLib/Masonry.h>
NS_ASSUME_NONNULL_BEGIN

@class CMPOcrInvoiceNewItemCell;
@protocol CMPOcrInvoiceNewItemCellDelegate <NSObject>

- (void)invoiceNewItemCellSelect:(CMPOcrInvoiceNewItemCell *)cell;
- (void)invoiceNewItemCellBack:(CMPOcrInvoiceNewItemCell *)cell;

@end

@interface CMPOcrInvoiceNewItemCell : UITableViewCell

@property (nonatomic, strong) CMPOcrInvoiceItemModel *item;
@property (nonatomic, strong) UIView *backView;

@property (nonatomic, weak) id<CMPOcrInvoiceNewItemCellDelegate>delegate;

@property (nonatomic, strong) UIButton *selectButton;

//1默认票夹、2包详情、3关联发票
- (void)setItem:(CMPOcrInvoiceItemModel * )item from:(NSInteger)fromPage;

//ext==2来自关联发票页面
- (void)remakeConstraintForMainDeputy:(BOOL)mainDeputy canSelect:(BOOL)canSelect position:(NSInteger)position ext:(NSInteger)ext;

//隐藏确认状态
- (void)hideStatus;

//获取titleLabel的高度
+ (CGFloat)getTitleLabelHeight:(CMPOcrInvoiceItemModel *)item canSelect:(BOOL)canSelect;

//置灰
- (void)setCellEnable:(BOOL)enable;
@end

NS_ASSUME_NONNULL_END
