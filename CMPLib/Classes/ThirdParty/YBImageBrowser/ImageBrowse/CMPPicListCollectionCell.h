//
//  CMPPicListCollectionCell.h
//  CMPLib
//
//  Created by MacBook on 2019/12/17.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YBImageBrowseCellData,YBVideoBrowseCellData;


NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString * const CMPPicListCollectionCellId;

@interface CMPPicListCollectionCell : UICollectionViewCell


/// 设置是否显示选择框
/// @param isShown 是否显示
- (void)showSelectView:(BOOL)isShown;

/* 设置是否显示 */
@property (assign, nonatomic) BOOL cellSelected;
/* 模型数据YBImageBrowseCellData */
@property (strong, nonatomic) YBImageBrowseCellData *modelData;
/* 模型数据YBVideoBrowseCellData */
@property (strong, nonatomic) YBVideoBrowseCellData *videoModelData;

@end

NS_ASSUME_NONNULL_END
