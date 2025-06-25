//
//  CMPSelectItemCell.h
//  M3
//
//  Created by MacBook on 2019/11/4.
//

#import <UIKit/UIKit.h>

@class CMPShareCellModel;

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString * const CMPSelectItemCellId;

@interface CMPSelectItemCell : UITableViewCell

/* CMPShareCellModel */
@property (strong, nonatomic) CMPShareCellModel *model;

@end

NS_ASSUME_NONNULL_END
