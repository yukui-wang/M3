//
//  CMPShareCollectionView.h
//  M3
//
//  Created by MacBook on 2019/10/29.
//

#import <UIKit/UIKit.h>
@class CMPShareCollectionView,CMPShareCellModel,CMPShareBtnModel;

//一屏显示的个数
UIKIT_EXTERN NSInteger const kRowCount;

NS_ASSUME_NONNULL_BEGIN

@protocol CMPShareCollectionViewDelegate <NSObject>

@optional
- (void)shareCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath shareCellModel:(CMPShareCellModel *)shareCellModel shareBtnModel:(CMPShareBtnModel *)shareBtnModel;

@end

@interface CMPShareCollectionView : UIView

/* 是否是默认列表 */
@property (assign, nonatomic) BOOL isDefaultList;
/* topDataArray */
@property (copy, nonatomic) NSArray *dataArray;
/* delegate */
@property (weak, nonatomic) id<CMPShareCollectionViewDelegate> delegate;


- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
