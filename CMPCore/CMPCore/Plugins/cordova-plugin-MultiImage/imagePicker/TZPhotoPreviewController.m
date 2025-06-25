//
//  TZPhotoPreviewController.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZPhotoPreviewController.h"
#import "TZPhotoPreviewCell.h"
#import "TZAssetModel.h"
#import "UIView+Layout.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/YBIBUtilities.h>
#import "TZImageCropManager.h"
#import "TZCamera.h"
#import <CMPLib/NSString+CMPString.h>


@interface TZPhotoPreviewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate> {
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_layout;
    BOOL _isHideNaviBar;
    NSArray *_photosTemp;
    NSArray *_assetsTemp;
    
    UIView *_naviBar;
    UIButton *_backButton;
    UIButton *_selectButton;
    UILabel *_titleLabel;
    
    UIView *_toolBar;
    UIButton *_okButton;
    UIImageView *_numberImageView;
    UILabel *_numberLable;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLable;
    UIView *_cropBgView;
    UIView *_cropView;
    CALayer *_cropLayer;
    
    CGFloat _minimumLineSpacing;
    BOOL _viewFirstAppear;
    
    BOOL _isDraging;
}
@end

@implementation TZPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    __weak typeof(self) weakSelf = self;
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)weakSelf.navigationController;
    if (!self.models.count) {
        self.models = [NSMutableArray arrayWithArray:_tzImagePickerVc.selectedModels];
        _assetsTemp = [NSMutableArray arrayWithArray:_tzImagePickerVc.selectedAssets];
        self.isSelectOriginalPhoto = _tzImagePickerVc.isSelectOriginalPhoto;
    }
    _minimumLineSpacing = 20;
    _viewFirstAppear = YES;
    
    [self configCollectionView];
    [self configCustomNaviBar];
    [self configBottomToolBar];
}


- (void)viewWillLayoutSubviews{
    if (_naviBar) {
        //ks fix -- ios16 - V5-39259
        CGFloat h = 20;
        if (@available(iOS 11.0, *)) {
            h = self.view.safeAreaInsets.top;
        }
        [_naviBar setFrame:CGRectMake(0, h-20, self.view.tz_width, 64)];
        [_backButton setFrame:CGRectMake(0, 34, 50, 16)];
//        if (YBIBUtilities.isIphoneX) {
//            _naviBar.cmp_height = 88;
//            _backButton.cmp_y = 58;
//        }
        _titleLabel.cmp_centerX = _naviBar.width/2;
        _titleLabel.cmp_centerY = _backButton.cmp_centerY;
    }
    
    if (_toolBar) {
        NSString *okButtonTitle = SY_STRING(@"common_finshed");
        CGFloat okButtonW = [okButtonTitle sizeWithFontSize:[UIFont systemFontOfSize:16] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
        
        [_okButton setFrame:CGRectMake(self.view.tz_width - okButtonW - 20, 0, okButtonW, 44) ];
        [_numberImageView setFrame:CGRectMake(self.view.tz_width - 56 - 24 - 16, 9, 26, 26) ];
        [_numberLable setFrame:_numberImageView.frame ];
        CGFloat toolBarY = self.view.tz_height - 44 - 20;
        [_toolBar setFrame:CGRectMake(0, toolBarY, self.view.tz_width, 64)];
    }
    
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    if (_tzImagePickerVc.allowCrop && _cropBgView) {
        _cropBgView.frame = self.view.bounds;
        CGFloat cropWidth = MIN(self.view.width, self.view.height);
        if (CMP_SCREEN_WIDTH > CMP_SCREEN_HEIGHT) {
            cropWidth -= 2*_naviBar.height;
        }
        CGFloat cropHeight = cropWidth;
        CGRect cropRect = CGRectMake(0, 0, cropWidth, cropHeight);
        
        _cropView.frame = cropRect;
        _cropView.cmp_centerX = self.view.width/2;
        _cropView.cmp_centerY = self.view.height/2;
        
        [_cropLayer removeFromSuperlayer];
        
        _cropLayer = [TZImageCropManager overlayClippingWithView:_cropBgView cropRect:_cropView.frame containerView:self.view needCircleCrop:NO];
        
    }
    
    
    if (_collectionView) {
        [_collectionView setFrame:CGRectMake(0, 0, self.view.tz_width , self.view.tz_height)];
        _collectionView.contentSize = CGSizeMake(self.view.tz_width * _models.count, self.view.tz_height);
        _layout.itemSize = CGSizeMake(self.view.tz_width, self.view.tz_height);
//        [_collectionView setCollectionViewLayout:_layout animated:NO];
        [_collectionView reloadData];
        if (_currentIndex) {
            [_collectionView setContentOffset:CGPointMake((self.view.tz_width + _minimumLineSpacing) * _currentIndex, 0) animated:NO];
        }
    }
}

- (void)configCropView {
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    if (_tzImagePickerVc.allowCrop) {
        [_cropView removeFromSuperview];
        [_cropBgView removeFromSuperview];
        
        _cropBgView = [UIView new];
        _cropBgView.userInteractionEnabled = NO;
        _cropBgView.frame = self.view.bounds;
        _cropBgView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_cropBgView];
        
        CGFloat cropWidth = CGRectGetWidth(self.view.frame)+2;
        CGFloat cropHeight = cropWidth;
        CGFloat cropY = (CGRectGetHeight(self.view.frame) - cropHeight) / 2;
        CGRect cropRect = CGRectMake(-1, cropY, cropWidth, cropHeight);
        
        _cropLayer = [TZImageCropManager overlayClippingWithView:_cropBgView cropRect:cropRect containerView:self.view needCircleCrop:NO];
        
        _cropView = [UIView new];
        _cropView.userInteractionEnabled = NO;
        _cropView.frame = cropRect;
        _cropView.backgroundColor = [UIColor clearColor];
        _cropView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropView.layer.borderWidth = 1.0;
        _cropView.layer.masksToBounds = YES;
//        if (_tzImagePickerVc.needCircleCrop) {
//            _cropView.layer.cornerRadius = cropRect.size.width / 2;
//            _cropView.clipsToBounds = YES;
//        }
        [self.view addSubview:_cropView];
//        if (_tzImagePickerVc.cropViewSettingBlock) {
//            _tzImagePickerVc.cropViewSettingBlock(_cropView);
//        }
    
        [self.view bringSubviewToFront:_naviBar];
        [self.view bringSubviewToFront:_toolBar];
    }
}

- (void)setPhotos:(NSMutableArray *)photos {
    _photos = photos;
    _photosTemp = [NSArray arrayWithArray:photos];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_viewFirstAppear) {
        [self laoutSubViewFrame];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self configCropView];
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = YES;
    
    _viewFirstAppear = NO;
    if (_currentIndex) [_collectionView setContentOffset:CGPointMake((self.view.tz_width + _minimumLineSpacing) * _currentIndex, 0) animated:NO];
    [self refreshNaviBarAndBottomBarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)configCustomNaviBar {
    
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
        [_backButton setImage:[UIImage imageNamedFromMyBundle:@"navi_back.png"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_selectButton) {
        _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.tz_width - 54, 10, 42, 42)];
        [_selectButton setImage:[UIImage imageNamedFromMyBundle:@"photo_def_photoPickerVc.png"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamedFromMyBundle:@"photo_sel_photoPickerVc.png"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.text = SY_STRING(@"photo_preview_nav_title");
        _titleLabel.cmp_centerX = _naviBar.width/2;
        _titleLabel.cmp_centerY = _backButton.cmp_centerY;
    }
    
    if (!_naviBar) {
        _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.tz_width, 64)];
        
        _naviBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//        [_naviBar addSubview:_selectButton];
        [_naviBar addSubview:_backButton];
        [_naviBar addSubview:_titleLabel];
        [self.view addSubview:_naviBar];
    }
}

- (void)configBottomToolBar {
    
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    if (_tzImagePickerVc.allowPickingOriginalPhoto) {
        if (!_originalPhotoButton) {
            NSString *originalPhotoButtonTitle = SY_STRING(@"photo_original");
            CGFloat originalPhotoButtonW = [originalPhotoButtonTitle sizeWithFontSize:[UIFont systemFontOfSize:16] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 20;
            _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _originalPhotoButton.frame = CGRectMake(20, 0, originalPhotoButtonW, 44);
//            _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
//            _originalPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(0, -50, 0, 0);
            _originalPhotoButton.backgroundColor = [UIColor clearColor];
            [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
            _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [_originalPhotoButton setTitle:originalPhotoButtonTitle forState:UIControlStateNormal];
            [_originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:@"preview_original_def.png"] forState:UIControlStateNormal];
            [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:@"photo_original_sel.png"] forState:UIControlStateSelected];
            
                    }
        if (!_originalPhotoLable) {
            _originalPhotoLable = [[UILabel alloc] init];
            _originalPhotoLable.frame = CGRectMake(CGRectGetMaxX(_originalPhotoButton.frame) - 14, 0, 100, 44);
            _originalPhotoLable.textAlignment = NSTextAlignmentLeft;
            _originalPhotoLable.font = [UIFont systemFontOfSize:16];
            _originalPhotoLable.textColor = [UIColor whiteColor];
            _originalPhotoLable.backgroundColor = [UIColor clearColor];

        }
        if (_isSelectOriginalPhoto) [self showPhotoBytes];
    }
    
    if (!_okButton) {
        NSString *okButtonTitle = SY_STRING(@"common_finshed");
        CGFloat okButtonW = [okButtonTitle sizeWithFontSize:[UIFont systemFontOfSize:16] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
        
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.frame = CGRectMake(self.view.tz_width - okButtonW - 20, 0, okButtonW, 44);
        _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_okButton setTitle:SY_STRING(@"common_finshed") forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    if (!_numberImageView) {
        _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedFromMyBundle:@"photo_number_icon.png"]];
        _numberImageView.backgroundColor = [UIColor clearColor];
        _numberImageView.frame = CGRectMake(self.view.tz_width - 56 - 24 - 16, 9, 26, 26);
        _numberImageView.hidden = _tzImagePickerVc.selectedModels.count <= 0;
    }
    if (!_numberLable) {
        _numberLable = [[UILabel alloc] init];
        _numberLable.frame = _numberImageView.frame;
        _numberLable.font = [UIFont systemFontOfSize:16];
        _numberLable.textColor = [UIColor clearColor];
        _numberLable.textAlignment = NSTextAlignmentCenter;
        _numberLable.text = [NSString stringWithFormat:@"%zd",_tzImagePickerVc.selectedModels.count];
        _numberLable.hidden = _tzImagePickerVc.selectedModels.count <= 0;
        _numberLable.backgroundColor = [UIColor clearColor];
    }
    if (!_toolBar) {
        CGFloat toolBarY = self.view.tz_height - 44 - 20;
        _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, toolBarY, self.view.tz_width, 64)];
        _toolBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [_originalPhotoButton addSubview:_originalPhotoLable];
        [_toolBar addSubview:_okButton];
        [_toolBar addSubview:_originalPhotoButton];
        [_toolBar addSubview:_numberLable];
        [self.view addSubview:_toolBar];
    }
    [self showPhotoBytes];
}

- (void)configCollectionView {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize = CGSizeMake(self.view.tz_width, self.view.tz_height);
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = _minimumLineSpacing;
    }
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.tz_width , self.view.tz_height) collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.contentOffset = CGPointMake(0, 0);
        _collectionView.contentSize = CGSizeMake(self.view.tz_width * _models.count, self.view.tz_height);
        _collectionView.scrollEnabled = NO;
        [self.view addSubview:_collectionView];
        [_collectionView registerClass:[TZPhotoPreviewCell class] forCellWithReuseIdentifier:@"TZPhotoPreviewCell"];
    }
    if (_currentIndex) [_collectionView setContentOffset:CGPointMake((self.view.tz_width + _minimumLineSpacing) * _currentIndex, 0) animated:NO];
}

- (void)laoutSubViewFrame
{
    NSString *originalPhotoButtonTitle = SY_STRING(@"photo_original");
    CGFloat originalPhotoButtonW = [originalPhotoButtonTitle sizeWithFontSize:[UIFont systemFontOfSize:16] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 20;
    
    NSString *okButtonTitle = SY_STRING(@"common_finshed");
    CGFloat okButtonW = [okButtonTitle sizeWithFontSize:[UIFont systemFontOfSize:16] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
    
    _backButton.frame = CGRectMake(10, 10, 44, 44);
    _selectButton.frame = CGRectMake(self.view.tz_width - 54, 10, 42, 42);
    _naviBar.frame = CGRectMake(0, 0, self.view.tz_width, 64);
    _originalPhotoButton.frame = CGRectMake(20, 0, originalPhotoButtonW, 44);
    _originalPhotoLable.frame = CGRectMake(CGRectGetMaxX(_originalPhotoButton.frame) - 14, 0, 70, 44);
    _okButton.frame = CGRectMake(self.view.tz_width - okButtonW - 20, 0, okButtonW, 44);
    _numberImageView.frame = CGRectMake(self.view.tz_width - 56 - 24 - 16, 9, 26, 26);
    _numberLable.frame = _numberImageView.frame;
    _toolBar.frame = CGRectMake(0, self.view.tz_height - 44, self.view.tz_width, 64);
    _layout.itemSize = CGSizeMake(self.view.tz_width, self.view.tz_height);
    _collectionView.frame = CGRectMake(0, 0, self.view.tz_width , self.view.tz_height);
    _collectionView.contentSize = CGSizeMake(self.view.tz_width * _models.count, self.view.tz_height);

}

#pragma mark - Click Event

- (void)select:(UIButton *)selectButton {
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    TZAssetModel *model = _models[_currentIndex];
    if (_isSelectOriginalPhoto && !selectButton.isSelected && model.imageDataSize > _tzImagePickerVc.maxFileSize) {
        NSInteger f = _tzImagePickerVc.maxFileSize/1024/1024;
        NSString *title =[NSString stringWithFormat:SY_STRING(@"photo_limit"),f] ;
        [_tzImagePickerVc showAlertWithTitle:title];
        return;
    }
    if (!selectButton.isSelected) {
        // 1. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
        if (_tzImagePickerVc.selectedModels.count >= _tzImagePickerVc.maxImagesCount && _tzImagePickerVc.maxImagesCount != 1) {
            [_tzImagePickerVc showAlertWithTitle:[NSString stringWithFormat:SY_STRING(@"photo_countlimit"),_tzImagePickerVc.maxImagesCount]];
            return;
        // 2. if not over the maxImagesCount / 如果没有超过最大个数限制
        } else {
            if ( _tzImagePickerVc.maxImagesCount == 1) {
                [_tzImagePickerVc.selectedModels removeAllObjects];
            }
            [_tzImagePickerVc.selectedModels addObject:model];
            if (self.photos) {
                [_tzImagePickerVc.selectedAssets addObject:_assetsTemp[_currentIndex]];
                [self.photos addObject:_photosTemp[_currentIndex]];
            }
            if (model.type == TZAssetModelMediaTypeVideo) {
                [_tzImagePickerVc showAlertWithTitle:@"多选状态下选择视频，默认将视频当图片发送"];
            }
        }
    } else {
        NSArray *selectedModels = [NSArray arrayWithArray:_tzImagePickerVc.selectedModels];
        for (TZAssetModel *model_item in selectedModels) {
            if ([[[TZImageManager manager] getAssetIdentifier:model.asset] isEqualToString:[[TZImageManager manager] getAssetIdentifier:model_item.asset]]) {
                [_tzImagePickerVc.selectedModels removeObject:model_item];
                if (self.photos) {
                    [_tzImagePickerVc.selectedAssets removeObject:_assetsTemp[_currentIndex]];
                    [self.photos removeObject:_photosTemp[_currentIndex]];
                }
                break;
            }
        }
    }
    model.isSelected = !selectButton.isSelected;
    [self refreshNaviBarAndBottomBarState];
    if (model.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:selectButton.imageView.layer type:TZOscillatoryAnimationToBigger];
    }
    [UIView showOscillatoryAnimationWithLayer:_numberImageView.layer type:TZOscillatoryAnimationToSmaller];
}

- (void)back {
    if (self.navigationController.childViewControllers.count < 2) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (self.backButtonClickBlock) {
        self.backButtonClickBlock(_isSelectOriginalPhoto);
    }
}

- (void)okButtonClick {
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    if (tzImagePickerVc.allowCrop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
        TZPhotoPreviewCell *cell = (TZPhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        UIImage *cropedImage = [TZImageCropManager cropImageView:cell.imageView toRect:_cropView.frame zoomScale:cell.scrollView.zoomScale containerView:self.view];
        NSString *path = [[TZImageManager manager] writeToTempImagePath:cropedImage];
        if (self.doneButtonClickBlockCropMode) {
            self.doneButtonClickBlockCropMode(path);
        }
    } else {
        TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
        if (_tzImagePickerVc.selectedModels.count == 0) {
            TZAssetModel *model = _models[_currentIndex];
            [_tzImagePickerVc.selectedModels addObject:model];
        }
        
        if (self.okButtonClickBlock) {
            self.okButtonClickBlock(_isSelectOriginalPhoto);
        }
        if (self.okButtonClickBlockWithPreviewType) {            self.okButtonClickBlockWithPreviewType(self.photos,_tzImagePickerVc.selectedAssets,self.isSelectOriginalPhoto);
        }
    }
}

- (void)originalPhotoButtonClick {
    BOOL limit = NO;
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    for (TZAssetModel *modle in _tzImagePickerVc.selectedModels ) {
        if (modle.imageDataSize > _tzImagePickerVc.maxFileSize) {
            limit = YES;
            break;
        }
    }
    if (limit) {
        NSInteger f = _tzImagePickerVc.maxFileSize/1024/1024;
        NSString *title =[NSString stringWithFormat:SY_STRING(@"photo_limit"),f] ;
        [_tzImagePickerVc showAlertWithTitle:title];
        return;
    }
    if (!_originalPhotoButton.selected) {
        TZAssetModel *model = _models[_currentIndex];
        if ( model.imageDataSize > _tzImagePickerVc.maxFileSize) {
            NSInteger f = _tzImagePickerVc.maxFileSize/1024/1024;
            NSString *title =[NSString stringWithFormat:SY_STRING(@"photo_limit"),f] ;
            [_tzImagePickerVc showAlertWithTitle:title];
            return;
        }
    }
    
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLable.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self showPhotoBytes];
        if (!_selectButton.isSelected) [self select:_selectButton];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_viewFirstAppear) {
        return;
    }
    if (!_isDraging) {
        return;
    }
    CGPoint offSet = scrollView.contentOffset;
    CGFloat offSetWidth = offSet.x;
    if ((offSetWidth + ((self.view.tz_width + _minimumLineSpacing) * 0.5)) < scrollView.contentSize.width + _minimumLineSpacing) {
        offSetWidth = offSetWidth +  ((self.view.tz_width + _minimumLineSpacing) * 0.5);
    }
    
    NSInteger currentIndex = offSetWidth / (self.view.tz_width + _minimumLineSpacing);
    
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self refreshNaviBarAndBottomBarState];
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TZPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZPhotoPreviewCell" forIndexPath:indexPath];
    // 设置裁剪模式
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    cell.allowCrop = _tzImagePickerVc.allowCrop;
    cell.popoverSupported = ((TZCameraPicker *)_tzImagePickerVc).pictureOptions.popoverSupported;
    cell.model = _models[indexPath.row];
    
//    __block BOOL _weakIsHideNaviBar = _isHideNaviBar;
//    __weak typeof(_naviBar) weakNaviBar = _naviBar;
//    __weak typeof(_toolBar) weakToolBar = _toolBar;
//    if (!cell.singleTapGestureBlock) {
//        cell.singleTapGestureBlock = ^(){
//            // show or hide naviBar / 显示或隐藏导航栏
//            _weakIsHideNaviBar = !_weakIsHideNaviBar;
//            weakNaviBar.hidden = _weakIsHideNaviBar;
//            weakToolBar.hidden = _weakIsHideNaviBar;
//        };
//    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TZPhotoPreviewCell class]]) {
        [(TZPhotoPreviewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TZPhotoPreviewCell class]]) {
        [(TZPhotoPreviewCell *)cell recoverSubviews];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isDraging = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    NSInteger MAX_INDEX = (scrollView.contentSize.width + _minimumLineSpacing)/(self.view.tz_width + _minimumLineSpacing) - 1;
    NSInteger MIN_INDEX = 0;
    
    NSInteger index = contentOffsetX/(self.view.tz_width + _minimumLineSpacing);
    
    if (velocity.x > 0.4 && contentOffsetX < (*targetContentOffset).x) {
        index = index + 1;
    }
    else if (velocity.x < -0.4 && contentOffsetX > (*targetContentOffset).x) {
        index = index;
    }
    else if (contentOffsetX > (index + 0.5) * (self.view.tz_width + _minimumLineSpacing)) {
        index = index + 1;
    }
    
    if (index > MAX_INDEX) index = MAX_INDEX;
    if (index < MIN_INDEX) index = MIN_INDEX;
    
    CGPoint newTargetContentOffset= CGPointMake(index * (self.view.tz_width + _minimumLineSpacing), 0);
    *targetContentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    [scrollView setContentOffset:newTargetContentOffset animated:YES];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _isDraging = NO;
}

#pragma mark - Private Method

- (void)refreshNaviBarAndBottomBarState {
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    TZAssetModel *model = _models[_currentIndex];
    _selectButton.selected = model.isSelected;
    if (!_selectButton.selected && _tzImagePickerVc.maxImagesCount == 1) {
        [self select:_selectButton];
    }
    _numberLable.text = [NSString stringWithFormat:@"%zd",_tzImagePickerVc.selectedModels.count];
    _numberImageView.hidden = (_tzImagePickerVc.selectedModels.count <= 0 || _isHideNaviBar);
    _numberLable.hidden = (_tzImagePickerVc.selectedModels.count <= 0 || _isHideNaviBar);
    
    _originalPhotoButton.selected = _isSelectOriginalPhoto;
    _originalPhotoLable.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) [self showPhotoBytes];
    
    // If is previewing video, hide original photo button
    // 如果正在预览的是视频，隐藏原图按钮
    if (_isHideNaviBar) return;
    if (model.type == TZAssetModelMediaTypeVideo) {
        _originalPhotoButton.hidden = YES;
        _originalPhotoLable.hidden = YES;
    } else {
        _originalPhotoButton.hidden = NO;
        if (_isSelectOriginalPhoto)  _originalPhotoLable.hidden = NO;
    }
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

- (void)showPhotoBytes {
//    [[TZImageManager manager] getPhotosBytesWithArray:@[_models[_currentIndex]] completion:^(NSString *totalBytes) {
//        _originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
//    }];
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];

}

- (void)getSelectedPhotoBytes {
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    if (imagePickerVc.selectedModels.count == 0) {
        _originalPhotoLable.text = @"";
        return;
    }
    [[TZImageManager manager] getPhotosBytesWithArray:imagePickerVc.selectedModels completion:^(NSString *totalBytes) {
        _originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}


@end
