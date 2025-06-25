//
//  CMPOcrUploadManagePhotoCollectionCell.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/5.
//

#import <UIKit/UIKit.h>


@interface CMPOcrUploadManagePhotoCollectionCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) void(^DeleteBtnBlock)(void);

@end

