//
//  CMPPicListCollectionCell.m
//  CMPLib
//
//  Created by MacBook on 2019/12/17.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPPicListCollectionCell.h"
#import "SDWebImage/SDWebImageDownloader.h"
#import "UIView+CMPView.h"
#import "YBImageBrowseCellData.h"
#import "YBVideoBrowseCellData.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/CMPCommonTool.h>


NSString * const CMPPicListCollectionCellId = @"CMPPicListCollectionCellId";

@interface CMPPicListCollectionCell()

/* imgView */
@property (strong, nonatomic) UIImageView *imgView;
/* 选中按钮 */
@property (strong, nonatomic) UIButton *selectBtn;
/* 播放按钮，用于区分视频和图片 */
@property (strong, nonatomic) UIButton *playBtn;

@end

@implementation CMPPicListCollectionCell
#pragma mark 懒加载
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView.alloc initWithFrame:self.bounds];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
        _imgView.layer.masksToBounds = YES;
    }
    return _imgView;
}

/// 选择按钮
- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [UIButton.alloc initWithFrame:CGRectMake(self.width - 20.f, 4.f, 16.f, 16.f)];
        [_selectBtn setImage:[[CMPThemeManager sharedManager] skinColorImageWithName:@"picture_unselect_radio_icon"] forState:UIControlStateNormal];
        [_selectBtn setImage:[[CMPThemeManager sharedManager] skinColorImageWithName:@"login_view_btn_icon_selected"] forState:UIControlStateSelected];
        _selectBtn.hidden = YES;
        _selectBtn.userInteractionEnabled = NO;
    }
    return _selectBtn;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton.alloc initWithFrame:CGRectMake(0, 0, 24.f, 24.f)];
        _playBtn.center = CGPointMake(self.width/2.f, self.height/2.f);
        [_playBtn setImage:[UIImage imageNamed:@"share_icon_play"] forState:UIControlStateNormal];
        _playBtn.userInteractionEnabled = NO;
        
    }
    return _playBtn;
}

#pragma mark 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.imgView];
        [self addSubview:self.selectBtn];
        [self addSubview:self.playBtn];
    }
    return self;
}

#pragma mark - 外部方法
- (void)showSelectView:(BOOL)isShown {
    self.selectBtn.hidden = !isShown;
}

- (void)setCellSelected:(BOOL)cellSelected {
    _cellSelected = cellSelected;
    self.selectBtn.selected = cellSelected;
}

- (void)setModelData:(YBImageBrowseCellData *)modelData {
    _modelData = modelData;
    
    self.playBtn.hidden = YES;
    if (modelData.thumbImage) {
        self.imgView.image = modelData.thumbImage;
        return;
    }
    
    if ([NSString isNotNull:modelData.thumbUrl.absoluteString]) {
        //有缩略图就用缩略图，图片的话都是有缩略图的base64
        self.imgView.image = [CMPCommonTool base64StringToImage:modelData.thumbUrl.absoluteString];
        return;
    }
    
    [modelData queryImageCache];
    __weak typeof(self) weakSelf = self;
    __weak typeof(modelData) weakModelData = modelData;
    modelData.loadLocalImageFinishBlock = ^(YBImage * _Nonnull image) {
        weakSelf.imgView.image = image;
        weakModelData.thumbImage = image;
    };
}

- (void)setVideoModelData:(YBVideoBrowseCellData *)videoModelData {
    _videoModelData = videoModelData;
    [self.imgView setImage:videoModelData.thumbImg];
    self.playBtn.hidden = NO;
}

@end
