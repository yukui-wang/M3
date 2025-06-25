//
//  CMPShareToInnerCell.h
//  M3
//
//  Created by MacBook on 2019/10/29.
//

#import <UIKit/UIKit.h>
@class CMPShareCellModel;

UIKIT_EXTERN NSString * _Nullable const CMPShareToInnerCellId;

NS_ASSUME_NONNULL_BEGIN

@interface CMPShareToInnerCell : UITableViewCell

/* CMPShareCellModel */
@property (strong, nonatomic) CMPShareCellModel *model;

@end

NS_ASSUME_NONNULL_END
