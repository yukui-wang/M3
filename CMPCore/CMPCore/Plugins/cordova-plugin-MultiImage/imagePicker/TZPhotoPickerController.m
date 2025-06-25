//
//  TZPhotoPickerController.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZPhotoPickerController.h"
#import "TZImagePickerController.h"
#import "TZPhotoPreviewController.h"
#import "TZAssetCell.h"
#import "TZAssetModel.h"
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/RTL.h>


@interface TZPhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate> {
    NSMutableArray *_models;
    
    UIButton *_previewButton;
    UIButton *_okButton;
    UIImageView *_numberImageView;
    UILabel *_numberLable;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLable;
    
    BOOL _shouldScrollToBottom;
    BOOL _showTakePhotoBtn;
    BOOL _viewFirstAppear;
    UICollectionViewFlowLayout *_layout;
    UIView *_bottomToolBar;
    UIView *_divide;
}
@property CGRect previousPreheatRect;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@end

static CGSize AssetGridThumbnailSize;

@implementation TZPhotoPickerController

- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _model.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SY_STRING(@"common_cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    _viewFirstAppear = YES;
    // [self resetCachedAssets];
}
- (void)viewWillLayoutSubviews {
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    CGFloat safeAreaBottom = [UIView safeAreaBottom];
    if (_collectionView) {
        CGFloat margin = 4;
        if (!_layout) {
            CGFloat itemWH = (self.view.tz_width - 2 * margin - 4) / 4 - margin;
            _layout.itemSize = CGSizeMake(itemWH, itemWH);
        }
        CGFloat top = margin + 44;
        // add by zl 裁剪模式高度适配
        if (tzImagePickerVc.allowCrop) {
            _collectionView.frame = CGRectMake(margin, top, self.view.tz_width - 2 * margin, self.view.tz_height - top-safeAreaBottom);
        } else {
            _collectionView.frame = CGRectMake(margin, top, self.view.tz_width - 2 * margin, self.view.tz_height - 50 - top-safeAreaBottom);
        }
        if (_showTakePhotoBtn && tzImagePickerVc.allowTakePicture ) {
            _collectionView.contentSize = CGSizeMake(self.view.tz_width, ((_model.count + 4) / 4) * self.view.tz_width);
        } else {
            _collectionView.contentSize = CGSizeMake(self.view.tz_width, ((_model.count + 3) / 4) * self.view.tz_width);
        }
        [_collectionView reloadData];
        CGFloat scale = 2.0;
        if ([UIScreen mainScreen].bounds.size.width > 600) {
            scale = 1.0;
        }
        CGSize cellSize = _layout.itemSize;
        AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    }
    if (_bottomToolBar) {
        CGFloat x = 10;
        NSInteger w = 44;
        NSString *preview =SY_STRING(@"Common_Preview");
        UIFont *font = [UIFont systemFontOfSize:16];
        CGSize s = [preview sizeWithFontSize:font defaultSize:CGSizeMake(88, 44)];
        w = s.width >30 ?s.width +1 :30;
        _bottomToolBar.frame = CGRectMake(0, self.view.tz_height - 50-safeAreaBottom, self.view.tz_width, 50);
        _previewButton.frame = CGRectMake(x, 3, w, 44);
        x += _previewButton.frame.size.width;
        _originalPhotoButton.frame = CGRectMake(x, self.view.tz_height - 50-safeAreaBottom, [self originalPhotoButtonW], 50);
        _originalPhotoLable.frame = CGRectMake([self originalPhotoLableX], 0, 60, 50);
        _okButton.frame = CGRectMake(self.view.tz_width - 63 - 12, 3, 63, 44);
        _numberImageView.frame = CGRectMake(self.view.tz_width - 76 - 24, 12, 26, 26);
        _numberLable.frame = _numberImageView.frame;
        _divide.frame = CGRectMake(0, 0, self.view.tz_width, 1);
        
        [_bottomToolBar.subviews makeObjectsPerformSelector:@selector(resetFrameToFitRTL)];
        [_originalPhotoButton resetFrameToFitRTL];
        [_originalPhotoLable resetFrameToFitRTL];
    }
}

- (void)showData
{
    if (!_viewFirstAppear) {
        return;
    }
    _viewFirstAppear = NO;
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    _isSelectOriginalPhoto = tzImagePickerVc.isSelectOriginalPhoto;
    _shouldScrollToBottom = YES;
    _showTakePhotoBtn = (([_model.name isEqualToString:@"相机胶卷"] || [_model.name isEqualToString:@"Camera Roll"] ||  [_model.name isEqualToString:@"所有照片"] || [_model.name isEqualToString:@"All Photos"]) && tzImagePickerVc.allowTakePicture);
    if (!tzImagePickerVc.sortAscendingByModificationDate && _isFirstAppear && iOS8Later) {
        [[TZImageManager manager] getCameraRollAlbum:tzImagePickerVc.allowPickingVideo allowPickingImage:tzImagePickerVc.allowPickingImage completion:^(TZAlbumModel *model) {
            self->_model = model;
            self->_models = [NSMutableArray arrayWithArray:self->_model.models];
            [self initSubviews];
        }];
    } else {
        if (_showTakePhotoBtn || !iOS8Later || _isFirstAppear) {
            [[TZImageManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:tzImagePickerVc.allowPickingVideo allowPickingImage:tzImagePickerVc.allowPickingImage completion:^(NSArray<TZAssetModel *> *models) {
                self->_models = [NSMutableArray arrayWithArray:models];
                [self initSubviews];
            }];
        } else {
            _models = [NSMutableArray arrayWithArray:_model.models];
            [self initSubviews];
        }
    }
}

- (void)initSubviews {
    [self checkSelectedModels];
    [self configCollectionView];
    [self configBottomToolBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    tzImagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    if (self.backButtonClickHandle) {
        self.backButtonClickHandle(_model);
    }
}

- (void)configCollectionView {
    CGFloat margin = 4;
    if (!_layout) {
        CGFloat itemWH = (self.view.tz_width - 2 * margin - 4) / 4 - margin;
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.itemSize = CGSizeMake(itemWH, itemWH);
        _layout.minimumInteritemSpacing = margin;
        _layout.minimumLineSpacing = margin;
    }
    CGFloat top = margin + 44;

    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    
    // add by zl 裁剪模式高度适配
    if (tzImagePickerVc.allowCrop) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(margin, top, self.view.tz_width - 2 * margin, self.view.tz_height - top) collectionViewLayout:_layout];
    } else {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(margin, top, self.view.tz_width - 2 * margin, self.view.tz_height - 50 - top) collectionViewLayout:_layout];
    }
   
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceHorizontal = NO;
    if (iOS7Later) _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 2);
    _collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
    
    if (_showTakePhotoBtn && tzImagePickerVc.allowTakePicture ) {
        _collectionView.contentSize = CGSizeMake(self.view.tz_width, ((_model.count + 4) / 4) * self.view.tz_width);
    } else {
        _collectionView.contentSize = CGSizeMake(self.view.tz_width, ((_model.count + 3) / 4) * self.view.tz_width);
    }
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TZAssetCell class] forCellWithReuseIdentifier:@"TZAssetCell"];
    [_collectionView registerClass:[TZAssetCameraCell class] forCellWithReuseIdentifier:@"TZAssetCameraCell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showData];
    [self scrollCollectionViewToBottom];
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    CGFloat scale = 2.0;
    if ([UIScreen mainScreen].bounds.size.width > 600) {
        scale = 1.0;
    }
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}



- (void)configBottomToolBar {
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    if (tzImagePickerVc.allowCrop) {
        return;
    }
    
    if (!_bottomToolBar) {
        _bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.tz_height - 50, self.view.tz_width, 50)];
    }
    CGFloat rgb = 253 / 255.0;
    _bottomToolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
   
    CGFloat x = 10;
    NSInteger w = 44;
    NSString *preview =SY_STRING(@"Common_Preview");
    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize s = [preview sizeWithFontSize:font defaultSize:CGSizeMake(88, 44)];
    w = s.width >30 ?s.width +1 :30;
    if (!_previewButton) {
        _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.frame = CGRectMake(x, 3, w, 44);
        [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_previewButton setTitle:SY_STRING(@"Common_Preview") forState:UIControlStateNormal];
        [_previewButton setTitle:SY_STRING(@"Common_Preview") forState:UIControlStateDisabled];
        [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _previewButton.enabled = tzImagePickerVc.selectedModels.count;
        x += _previewButton.frame.size.width;
    }


    if (tzImagePickerVc.allowPickingOriginalPhoto && !_originalPhotoButton) {
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.frame = CGRectMake(x, self.view.tz_height - 50, [self originalPhotoButtonW], 50);
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        _originalPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_originalPhotoButton setTitle:SY_STRING(@"photo_original") forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:SY_STRING(@"photo_original") forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:@"photo_original_def.png"] forState:UIControlStateNormal];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:@"photo_original_sel.png"] forState:UIControlStateSelected];
        _originalPhotoButton.selected = _isSelectOriginalPhoto;
        _originalPhotoButton.enabled = tzImagePickerVc.selectedModels.count > 0;
        
        _originalPhotoLable = [[UILabel alloc] init];
        _originalPhotoLable.frame = CGRectMake([self originalPhotoLableX], 0, 60, 50);
        _originalPhotoLable.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLable.font = [UIFont systemFontOfSize:16];
        _originalPhotoLable.textColor = [UIColor blackColor];
        if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
    }
    
    if (!_okButton) {
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.frame = CGRectMake(self.view.tz_width - 63 - 12, 3, 63, 44);
        _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_okButton setTitle:SY_STRING(@"common_ok") forState:UIControlStateNormal];
        [_okButton setTitle:SY_STRING(@"common_ok") forState:UIControlStateDisabled];
        [_okButton setTitleColor:tzImagePickerVc.oKButtonTitleColorNormal forState:UIControlStateNormal];
        [_okButton setTitleColor:tzImagePickerVc.oKButtonTitleColorDisabled forState:UIControlStateDisabled];
    }
    _okButton.enabled = tzImagePickerVc.selectedModels.count;
    
    if (!_numberImageView) {
        _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedFromMyBundle:@"photo_number_icon.png"]];
        _numberImageView.frame = CGRectMake(self.view.tz_width - 76 - 24, 12, 26, 26);
        _numberImageView.hidden = tzImagePickerVc.selectedModels.count <= 0;
        _numberImageView.backgroundColor = [UIColor clearColor];
    }
    
    if (!_numberLable) {
        _numberLable = [[UILabel alloc] init];
        _numberLable.frame = _numberImageView.frame;
        _numberLable.font = [UIFont systemFontOfSize:16];
        _numberLable.textColor = [UIColor whiteColor];
        _numberLable.textAlignment = NSTextAlignmentCenter;
        _numberLable.text = [NSString stringWithFormat:@"%zd",tzImagePickerVc.selectedModels.count];
        _numberLable.hidden = tzImagePickerVc.selectedModels.count <= 0;
        _numberLable.backgroundColor = [UIColor clearColor];
        

    }
    if (!_divide) {
        _divide = [[UIView alloc] init];
        CGFloat rgb2 = 222 / 255.0;
        _divide.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
        _divide.frame = CGRectMake(0, 0, self.view.tz_width, 1);
    }

    [_bottomToolBar addSubview:_divide];
    [_bottomToolBar addSubview:_previewButton];
    [_bottomToolBar addSubview:_okButton];
    [_bottomToolBar addSubview:_numberImageView];
    [_bottomToolBar addSubview:_numberLable];
    [self.view addSubview:_bottomToolBar];
    [self.view addSubview:_originalPhotoButton];
    [_originalPhotoButton addSubview:_originalPhotoLable];
}

- (CGFloat)originalPhotoLableX {
    if ([UIView isRTL]) {
        return 115.f;
    }
    
    return 80.f;
}

- (CGFloat)originalPhotoButtonW {
    if ([UIView isRTL]) {
        return 160.f;
    }
    
    return 130.f;
}

#pragma mark - Click Event

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
        if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
            [imagePickerVc.pickerDelegate imagePickerControllerDidCancel:imagePickerVc];
        }
        if (imagePickerVc.imagePickerControllerDidCancelHandle) {
            imagePickerVc.imagePickerControllerDidCancelHandle();
        }
    }];
    
}

- (void)previewButtonClick {
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
       tzImagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    TZPhotoPreviewController *photoPreviewVc = [[TZPhotoPreviewController alloc] init];
    [self pushPhotoPrevireViewController:photoPreviewVc];
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
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLable.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

/**
 编辑模式点击确定按钮
 */
- (void)okButtonClickCropMode:(NSString *)path {
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    if ([tzImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:)]) {
        [tzImagePickerVc.pickerDelegate imagePickerController:tzImagePickerVc didFinishPickingPhotos:@[path] sourceAssets:nil isSelectOriginalPhoto:_isSelectOriginalPhoto];
    }
    [tzImagePickerVc hideProgressHUD];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)okButtonClick {
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    [tzImagePickerVc showProgressHUD];
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) { [photos addObject:@1];[assets addObject:@1];[infoArr addObject:@1]; }
    
    [TZImageManager manager].shouldFixOrientation = YES;
    
    for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) {
        TZAssetModel *model = tzImagePickerVc.selectedModels[i];
        
        // 如果照片没有从iCloud下载，提示用户
        if (model.imageDataSize == 0) {
            [tzImagePickerVc hideProgressHUD];
            [tzImagePickerVc showAlertWithTitle:SY_STRING(@"photo_download_iCloud")];
            return;
        }
        
        void (^getPhotoBlock)(NSString *photoPath, NSDictionary *info) = ^(NSString *photoPath, NSDictionary *info) {
            if (photoPath) {
                [photos replaceObjectAtIndex:i withObject:photoPath];
            }
            if (info)  [infoArr replaceObjectAtIndex:i withObject:info];
            [assets replaceObjectAtIndex:i withObject:model.asset];
            
            for (id item in photos) { if ([item isKindOfClass:[NSNumber class]]) return; }
            
            if ([tzImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:)]) {
                [tzImagePickerVc.pickerDelegate imagePickerController:tzImagePickerVc didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto];
            }
            if ([tzImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos:)]) {
                [tzImagePickerVc.pickerDelegate imagePickerController:tzImagePickerVc didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto infos:infoArr];
            }
            if (tzImagePickerVc.didFinishPickingPhotosHandle) {
                tzImagePickerVc.didFinishPickingPhotosHandle(photos,assets,_isSelectOriginalPhoto);
            }
            if (tzImagePickerVc.didFinishPickingPhotosWithInfosHandle) {
                tzImagePickerVc.didFinishPickingPhotosWithInfosHandle(photos,assets,_isSelectOriginalPhoto,infoArr);
            }
            [tzImagePickerVc hideProgressHUD];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        };
        
        if (_isSelectOriginalPhoto) { // 选择原图
            [[TZImageManager manager] getOriginalPhotoPathWithAsset:model.asset completion:^(NSString *photoPath, NSDictionary *info) {
                getPhotoBlock(photoPath, info);
            }];
        } else {
            [[TZImageManager manager] getPhotoTemPathWithAsset:model.asset targetSize:self.view.frame.size completion:^(NSString *photoPath, NSDictionary *info, BOOL isDegraded) {
                if (isDegraded) {
                    return;
                }
               getPhotoBlock(photoPath, info);
            }];
        }
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_showTakePhotoBtn) {
        TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
        if (tzImagePickerVc.allowPickingImage && tzImagePickerVc.allowTakePicture) {
            return _models.count + 1;
        }
    }
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // the cell lead to take a picture / 去拍照的cell
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    if (((tzImagePickerVc.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!tzImagePickerVc.sortAscendingByModificationDate && indexPath.row == 0)) && _showTakePhotoBtn) {
        TZAssetCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZAssetCameraCell" forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamedFromMyBundle:@"takePicture.png"];
        return cell;
    }
    // the cell dipaly photo or video / 展示照片或视频的cell
    TZAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZAssetCell" forIndexPath:indexPath];
    TZAssetModel *model;
    if (tzImagePickerVc.sortAscendingByModificationDate || !_showTakePhotoBtn) {
        model = _models[indexPath.row];
    } else {
        model = _models[indexPath.row - 1];
    }
    cell.model = model;
    cell.showSelectBtn = !tzImagePickerVc.allowCrop;
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_numberImageView.layer) weakLayer = _numberImageView.layer;
    cell.disAbleSelectPhotoBlock = ^(void){
//        TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)weakSelf.navigationController;
//        NSInteger f = tzImagePickerVc.maxFileSize/1024/1024;
//        NSString *title =[NSString stringWithFormat:SY_STRING(@"photo_limit"),f] ;
    };
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
      
        TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)weakSelf.navigationController;
        if (_isSelectOriginalPhoto && !weakCell.selectPhotoButton.isSelected && model.imageDataSize > tzImagePickerVc.maxFileSize) {
            NSInteger f = tzImagePickerVc.maxFileSize/1024/1024;
            NSString *title =[NSString stringWithFormat:SY_STRING(@"photo_limit"),f] ;
            [tzImagePickerVc showAlertWithTitle:title];
            return;
        }

        
        // 1. cancel select / 取消选择
        if (isSelected) {
            weakCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            NSArray *selectedModels = [NSArray arrayWithArray:tzImagePickerVc.selectedModels];
            for (TZAssetModel *model_item in selectedModels) {
                if ([[[TZImageManager manager] getAssetIdentifier:model.asset] isEqualToString:[[TZImageManager manager] getAssetIdentifier:model_item.asset]]) {
                    [tzImagePickerVc.selectedModels removeObject:model_item];
                    break;
                }
            }
            [weakSelf refreshBottomToolBarStatus];
        } else {
            // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
            if (tzImagePickerVc.selectedModels.count < tzImagePickerVc.maxImagesCount ||tzImagePickerVc.maxImagesCount == 1) {
                if (tzImagePickerVc.maxImagesCount == 1) {
                    [tzImagePickerVc.selectedModels removeAllObjects];
                }
                weakCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [tzImagePickerVc.selectedModels addObject:model];
                [weakSelf refreshBottomToolBarStatus];
                if (tzImagePickerVc.maxImagesCount == 1) {
                    [self checkSelectedModels];
                    [self.collectionView reloadData];
                }
            } else {
                [tzImagePickerVc showAlertWithTitle:[NSString stringWithFormat:SY_STRING(@"photo_countlimit"),tzImagePickerVc.maxImagesCount]];
            }
        }
        [UIView showOscillatoryAnimationWithLayer:weakLayer type:TZOscillatoryAnimationToSmaller];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // take a photo / 去拍照
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    if (((tzImagePickerVc.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!tzImagePickerVc.sortAscendingByModificationDate && indexPath.row == 0)) && _showTakePhotoBtn)  {
        [self takePhoto]; return;
    }
    // preview phote or video / 预览照片或视频
    NSInteger index = indexPath.row;
    if (!tzImagePickerVc.sortAscendingByModificationDate && _showTakePhotoBtn) {
        index = indexPath.row - 1;
    }
    TZAssetModel *model = _models[index];
    if (model.type == TZAssetModelMediaTypeVideo) {
        if (tzImagePickerVc.selectedModels.count > 0) {
            TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
            [imagePickerVc showAlertWithTitle:@"选择照片时不能选择视频"];
        } else {
            TZVideoPlayerController *videoPlayerVc = [[TZVideoPlayerController alloc] init];
            videoPlayerVc.model = model;
            [self.navigationController pushViewController:videoPlayerVc animated:YES];
        }
    } else {
        TZPhotoPreviewController *photoPreviewVc = [[TZPhotoPreviewController alloc] init];
        photoPreviewVc.currentIndex = index;
        photoPreviewVc.models = _models;
        [self pushPhotoPrevireViewController:photoPreviewVc];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (iOS8Later) {
        // [self updateCachedAssets];
    }
}

#pragma mark - Private Method

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) && iOS8Later) {
        // 无权限 做一个友好的提示
        NSString *boundName = [[NSBundle mainBundle]
                               objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:SY_STRING(@"common_nocameraalert"),boundName];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:SY_STRING(@"common_noPermissionCamera") message:message delegate:self cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@"设置", nil];
        [alert show];
    } else { // 调用相机
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerVc.sourceType = sourceType;
            if(iOS8Later) {
                _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            [self presentViewController:_imagePickerVc animated:YES completion:nil];
        } else {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }
}

- (void)refreshBottomToolBarStatus {
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    
    _previewButton.enabled = imagePickerVc.selectedModels.count > 0;
    _okButton.enabled = imagePickerVc.selectedModels.count > 0;
    
    _numberImageView.hidden = imagePickerVc.selectedModels.count <= 0;
    _numberLable.hidden = imagePickerVc.selectedModels.count <= 0;
    _numberLable.text = [NSString stringWithFormat:@"%zd",imagePickerVc.selectedModels.count];
    
    _originalPhotoButton.enabled = imagePickerVc.selectedModels.count > 0;
    _originalPhotoButton.selected = (_isSelectOriginalPhoto && _originalPhotoButton.enabled);
    _originalPhotoLable.hidden = (!_originalPhotoButton.isSelected);
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

- (void)pushPhotoPrevireViewController:(TZPhotoPreviewController *)photoPreviewVc {
    __weak typeof(self) weakSelf = self;
    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    photoPreviewVc.backButtonClickBlock = ^(BOOL isSelectOriginalPhoto) {
        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf checkSelectedModels];
        [weakSelf.collectionView reloadData];
        [weakSelf refreshBottomToolBarStatus];
    };
    photoPreviewVc.okButtonClickBlock = ^(BOOL isSelectOriginalPhoto){
        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf okButtonClick];
    };
    photoPreviewVc.doneButtonClickBlockCropMode = ^(NSString *path) {
        [weakSelf okButtonClickCropMode:path];
    };
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

- (void)getSelectedPhotoBytes {
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    [[TZImageManager manager] getPhotosBytesWithArray:imagePickerVc.selectedModels completion:^(NSString *totalBytes) {
        _originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

/// Scale image / 缩放图片
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width < size.width) {
        return image;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)scrollCollectionViewToBottom {
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    if (_shouldScrollToBottom && _models.count > 0 && tzImagePickerVc.sortAscendingByModificationDate) {
        NSInteger item = _models.count - 1;
        if (_showTakePhotoBtn) {
            TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
            if (tzImagePickerVc.allowPickingImage && tzImagePickerVc.allowTakePicture) {
                item += 1;
            }
        }
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        _shouldScrollToBottom = NO;
    }
}

- (void)checkSelectedModels {
    for (TZAssetModel *model in _models) {
        model.isSelected = NO;
        NSMutableArray *selectedAssets = [NSMutableArray array];
        TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
        for (TZAssetModel *model in tzImagePickerVc.selectedModels) {
            [selectedAssets addObject:model.asset];
        }
        if ([[TZImageManager manager] isAssetsArray:selectedAssets containAsset:model.asset]) {
            model.isSelected = YES;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=Photos"]];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
        [imagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [[TZImageManager manager] savePhotoWithImage:image completion:^{
            [self reloadPhotoArray];
        }];
    }
}

- (void)reloadPhotoArray {
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    [[TZImageManager manager] getCameraRollAlbum:tzImagePickerVc.allowPickingVideo allowPickingImage:tzImagePickerVc.allowPickingImage completion:^(TZAlbumModel *model) {
        _model = model;
        [[TZImageManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:tzImagePickerVc.allowPickingVideo allowPickingImage:tzImagePickerVc.allowPickingImage completion:^(NSArray<TZAssetModel *> *models) {
            [tzImagePickerVc hideProgressHUD];
            
            TZAssetModel *assetModel;
            if (tzImagePickerVc.sortAscendingByModificationDate) {
                assetModel = [models lastObject];
                [_models addObject:assetModel];
            } else {
                assetModel = [models firstObject];
                [_models insertObject:assetModel atIndex:0];
            }
            if (tzImagePickerVc.selectedModels.count < tzImagePickerVc.maxImagesCount) {
                assetModel.isSelected = YES;
                [tzImagePickerVc.selectedModels addObject:assetModel];
                [self refreshBottomToolBarStatus];
            }
            [_collectionView reloadData];
            
            _shouldScrollToBottom = YES;
            [self scrollCollectionViewToBottom];
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [[TZImageManager manager].cachingImageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = _collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(_collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [[TZImageManager manager].cachingImageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [[TZImageManager manager].cachingImageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.item < _models.count) {
            TZAssetModel *model = _models[indexPath.item];
            [assets addObject:model.asset];
        }
    }
    
    return assets;
}

- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [_collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

@end
