//
//  CMPOcrModulesManageCollectionView.h
//  M3
//
//  Created by Kaku Songu on 12/21/21.
//

#import <CMPLib/CMPBaseView.h>
#import "CMPOcrModulesManageCollectionViewModel.h"
@class KSLabel;
NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrModulesManageCollectionView : CMPBaseView
@property (nonatomic,assign) BOOL edit;
-(void)setItems:(NSArray *)items;
@end


@interface CMPOcrModulesManageCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) KSLabel *titleLb;
@property (nonatomic,assign) NSInteger editType;//0常态 1显示减号 2显示加号
@property (nonatomic,copy) void(^actBlk)(NSInteger act,id ext,NSIndexPath *indexPath);
@property (nonatomic,weak) NSIndexPath *indexPath;

-(void)setTitle:(NSString *)title;
-(void)setIsSelected:(BOOL)isSelected;
-(void)setItem:(CMPOcrModulesManageCollectionItem *)item;
@end

@interface CMPOcrModulesManageCollectionViewCellHeaderView : UICollectionReusableView
-(void)setTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
