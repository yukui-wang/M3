//
//  CMPShareCollectionViewCell.h
//  M3
//
//  Created by MacBook on 2019/10/28.
//

#import <UIKit/UIKit.h>
@class CMPShareCellModel,CMPShareBtnModel;

UIKIT_EXTERN NSString * _Nullable const CMPShareCollectionViewCellId;

NS_ASSUME_NONNULL_BEGIN

@interface CMPShareCollectionViewCell : UICollectionViewCell

/* CMPShareCellModel */
@property (strong, nonatomic) CMPShareCellModel *shareModel;
/* CMPShareBtnModel */
@property (strong, nonatomic) CMPShareBtnModel *shareBtnModel;

@end

NS_ASSUME_NONNULL_END
