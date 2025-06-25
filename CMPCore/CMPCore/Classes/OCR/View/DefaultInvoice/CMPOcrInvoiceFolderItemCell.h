//
//  CMPOcrInvoiceFolderItemCell.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrInvoiceFolderItemCell : UICollectionViewCell

@property (nonatomic, assign) BOOL createFolder;

@property (nonatomic, copy) NSString *title;

@end


@interface CMPOcrInvoiceFolderHeaderCell : UICollectionReusableView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UILabel       *descLabel;
- (void)remakeTitleConstraint;

@end

NS_ASSUME_NONNULL_END
