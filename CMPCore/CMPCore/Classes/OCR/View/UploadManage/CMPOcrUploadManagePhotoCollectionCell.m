//
//  CMPOcrUploadManagePhotoCollectionCell.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/5.
//

#import "CMPOcrUploadManagePhotoCollectionCell.h"
@interface CMPOcrUploadManagePhotoCollectionCell()
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@end

@implementation CMPOcrUploadManagePhotoCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _closeBtn.layer.cornerRadius = 10.f;
    _closeBtn.backgroundColor = UIColor.whiteColor;
}
- (IBAction)deleteBtnAction:(id)sender {
    if (_DeleteBtnBlock) {
        _DeleteBtnBlock();
    }
}

@end
