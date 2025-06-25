//
//  TZPhotoPreviewCell.h
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TZAssetModel;
@interface TZPhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) TZAssetModel *model;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
/** 是否是裁剪模式 **/
@property (assign, nonatomic) BOOL allowCrop;
@property (assign, nonatomic) BOOL popoverSupported;

@property (nonatomic, copy) void (^singleTapGestureBlock)();

- (void)recoverSubviews;

@end
