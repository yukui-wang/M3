//
//  TZAssetCell.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZAssetCell.h"
#import "TZAssetModel.h"
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import "TZImagePickerController.h"
#import <CMPLib/RTL.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/Masonry.h>

@interface TZAssetCell ()
@property (weak, nonatomic) UIImageView *imageView;       // The photo / 照片
@property (weak, nonatomic) UIImageView *selectImageView;
@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UILabel *timeLength;

@property (nonatomic, weak) UIImageView *viewImgView;

@end

@implementation TZAssetCell

// Now we use code to create subViews for improve performance
// 现在我们用代码来创建TZAssetCell和TZAlbumCell的子控件，以提高性能

/*
- (void)awakeFromNib {
    self.timeLength.font = [UIFont boldSystemFontOfSize:11];
}
*/
- (void)dealloc
{
    [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    _model = nil;
    self.representedAssetIdentifier = nil;
    _imageView = nil;
    _selectPhotoButton = nil;
    _selectImageView = nil;
    _bottomView = nil;
    _viewImgView = nil;
    _timeLength = nil;
}

- (void)setModel:(TZAssetModel *)model {
    if (_model == model) {
        // 修复bug，当cell复用时，model没有改变，只是是否选中状态改变了。
        // 导致在预览界面选择了图片返回Thumbnail界面却没有选中。
        self.selectPhotoButton.selected = model.isSelected;
        self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamedFromMyBundle:@"photo_sel_photoPickerVc.png"] : [UIImage imageNamedFromMyBundle:@"photo_def_photoPickerVc.png"];
        return;
    }
    _model = model;
    [_model requestImageDataSize];
    if (iOS8Later) {
        self.representedAssetIdentifier = [[TZImageManager manager] getAssetIdentifier:model.asset];
    }
    PHImageRequestID imageRequestID = [[TZImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.tz_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        // Set the cell's thumbnail image if it's still showing the same asset.
        if (!iOS8Later) {
            self.imageView.image = photo; return;
        }
        if ([self.representedAssetIdentifier isEqualToString:[[TZImageManager manager] getAssetIdentifier:model.asset]]) {
            self.imageView.image = photo;
        } else {
            // NSLog(@"this cell is showing other asset");
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    }];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        // NSLog(@"cancelImageRequest %d",self.imageRequestID);
    }
    self.imageRequestID = imageRequestID;
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamedFromMyBundle:@"photo_sel_photoPickerVc.png"] : [UIImage imageNamedFromMyBundle:@"photo_def_photoPickerVc.png"];
    self.type = TZAssetCellTypePhoto;
    if (model.type == TZAssetModelMediaTypeLivePhoto)      self.type = TZAssetCellTypeLivePhoto;
    else if (model.type == TZAssetModelMediaTypeAudio)     self.type = TZAssetCellTypeAudio;
    else if (model.type == TZAssetModelMediaTypeVideo) {
        self.type = TZAssetCellTypeVideo;
        self.timeLength.text = model.timeLength;
    }
}

- (void)setType:(TZAssetCellType)type {
    _type = type;
    if (type == TZAssetCellTypePhoto || type == TZAssetCellTypeLivePhoto) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else {
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _bottomView.hidden = NO;
    }
}

- (void)selectPhotoButtonClick:(UIButton *)sender {
//    if (_model.imageDataSize > kImageLimitSize) {
////        NSString *title = @"上传的图片不能大于50M。";
////        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil] show];
//        if (self.disAbleSelectPhotoBlock) {
//            self.disAbleSelectPhotoBlock();
//        }
//        return;
//    }
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamedFromMyBundle:@"photo_sel_photoPickerVc.png"] : [UIImage imageNamedFromMyBundle:@"photo_def_photoPickerVc.png"];
    if (sender.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:_selectImageView.layer type:TZOscillatoryAnimationToBigger];
    }
}

#pragma mark - Lazy load 

- (UIButton *)selectPhotoButton {
    if (_selectPhotoButton == nil) {
        UIButton *selectPhotoButton = [[UIButton alloc] init];
        selectPhotoButton.frame = CGRectMake(self.tz_width - 44, 0, 44, 44);
        [selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectPhotoButton];
        _selectPhotoButton = selectPhotoButton;
    }
    return _selectPhotoButton;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.tz_width, self.tz_height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
        
        [self.contentView bringSubviewToFront:_selectImageView];
        [self.contentView bringSubviewToFront:_bottomView];
    }
    return _imageView;
}

- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.frame = CGRectMake(self.tz_width - 27, 0, 27, 27);
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.frame = CGRectMake(0, self.tz_height - 17, self.tz_width, 17);
        bottomView.backgroundColor = [UIColor blackColor];
        bottomView.alpha = 0.8;
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIImageView *)viewImgView {
    if (_viewImgView == nil) {
        UIImageView *viewImgView = [[UIImageView alloc] init];
        viewImgView.frame = CGRectMake(8, 0, 17, 17);
        [viewImgView setImage:[UIImage imageNamedFromMyBundle:@"VideoSendIcon.png"]];
        [self.bottomView addSubview:viewImgView];
        _viewImgView = viewImgView;
    }
    return _viewImgView;
}

- (UILabel *)timeLength {
    if (_timeLength == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        timeLength.frame = CGRectMake(self.viewImgView.tz_right, 0, self.tz_width - self.viewImgView.tz_right - 5, 17);
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        [self.bottomView addSubview:timeLength];
        _timeLength = timeLength;
    }
    return _timeLength;
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    if (!self.selectPhotoButton.hidden) {
        self.selectPhotoButton.hidden = !showSelectBtn;
    }
    if (!self.selectImageView.hidden) {
        self.selectImageView.hidden = !showSelectBtn;
    }
}

@end

@interface TZAlbumCell ()
@property (strong, nonatomic) UIImageView *posterImageView;
@property (strong, nonatomic) UILabel *titleLable;
@property (strong, nonatomic) UILabel *photoCountLable;
@property (strong, nonatomic) UIImageView *arrowImageView;
@property (strong, nonatomic) UIView *lineView;

@end

@implementation TZAlbumCell

/*
- (void)awakeFromNib {
    self.posterImageView.clipsToBounds = YES;
}
 */

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
        [self setupUI];
        [self setupUIConstraints];
    }
    return self;
}

- (void)setupUI{
     [self.contentView addSubview:self.posterImageView];
     [self.contentView addSubview:self.titleLable];
     [self.contentView addSubview:self.photoCountLable];
     [self.contentView addSubview:self.arrowImageView];
     [self.contentView addSubview:self.selectedCountButton];
     [self.contentView addSubview:self.lineView];
}

- (void)setupUIConstraints{
    [self.posterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(14);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(46, 46));
    }];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.posterImageView.mas_trailing).offset(10);
        make.top.mas_equalTo(self.posterImageView);
    }];
    [self.photoCountLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLable);
        make.bottom.mas_equalTo(self.posterImageView);
    }];
    [self.photoCountLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLable);
        make.bottom.mas_equalTo(self.posterImageView);
    }];
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView).offset(-14);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [self.selectedCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.arrowImageView.mas_leading).offset(-14);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(70);
        make.trailing.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
    
}

- (void)setModel:(TZAlbumModel *)model {
    _model = model;
    
    self.titleLable.text = model.name;
    self.photoCountLable.text = [NSString stringWithLongLong:model.count];
    [[TZImageManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.posterImageView.image = postImage;
    }];
    if (model.selectedCount) {
        self.selectedCountButton.hidden = NO;
        [self.selectedCountButton setTitle:[NSString stringWithFormat:@"%zd",model.selectedCount] forState:UIControlStateNormal];
    } else {
        self.selectedCountButton.hidden = YES;
    }
}

/// For fitting iOS6
- (void)layoutSubviews {
    if (iOS7Later) [super layoutSubviews];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (iOS7Later) [super layoutSublayersOfLayer:layer];
}

#pragma mark - Lazy load

- (UIImageView *)posterImageView {
    if (_posterImageView == nil) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        _posterImageView = posterImageView;
    }
    return _posterImageView;
}

- (UILabel *)titleLable {
    if (_titleLable == nil) {
        UILabel *titleLable = [[UILabel alloc] init];
        titleLable.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        titleLable.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        titleLable.textAlignment = NSTextAlignmentLeft;
        _titleLable = titleLable;
    }
    return _titleLable;
}

- (UILabel *)photoCountLable {
    if (_photoCountLable == nil) {
        UILabel *photoCountLable = [[UILabel alloc] init];
        photoCountLable.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        photoCountLable.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        photoCountLable.textAlignment = NSTextAlignmentLeft;
        photoCountLable.text = @"100";
        _photoCountLable = photoCountLable;
    }
    return _photoCountLable;
}

- (UIImageView *)arrowImageView {
    if (_arrowImageView == nil) {
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        [arrowImageView setImage:[[UIImage imageNamedFromMyBundle:@"TableViewArrow.png"] rtl_imageFlippedForRightToLeftLayoutDirection]];
        _arrowImageView = arrowImageView;
    }
    return _arrowImageView;
}

- (UIButton *)selectedCountButton {
    if (_selectedCountButton == nil) {
        UIButton *selectedCountButton = [[UIButton alloc] init];
        selectedCountButton.layer.cornerRadius = 12;
        selectedCountButton.clipsToBounds = YES;
        [selectedCountButton setTitleColor:[UIColor cmp_colorWithName:@"reverse-fc"] forState:UIControlStateNormal];
        selectedCountButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _selectedCountButton = selectedCountButton;
    }
    return _selectedCountButton;
}

- (UIView *)lineView {
    if (_lineView == nil) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
        _lineView = lineView;
    }
    return _lineView;
}

@end



@implementation TZAssetCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

@end
