//
//  TZImagePickerController.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZImagePickerController.h"
#import "TZPhotoPickerController.h"
#import "TZPhotoPreviewController.h"
#import "TZAssetModel.h"
#import "TZAssetCell.h"
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import <CMPLib/CMPConstant.h>
#import <pthread.h>
#import <CMPLib/CMPThemeManager.h>


@interface TZImagePickerController () {
    NSTimer *_timer;
    UILabel *_tipLable;
    BOOL _pushToPhotoPickerVc;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLable;
    
    UIStatusBarStyle _originStatusBarStyle;
    BOOL _needUseTimer;
}
@end

@implementation TZImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    [TZImageManager manager].shouldFixOrientation = NO;

    // Default appearance, you can reset these after this method
    // 默认的外观，你可以在这个方法后重置
    self.oKButtonTitleColorNormal   = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0];
    self.oKButtonTitleColorDisabled = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:0.5];
    
    if (iOS7Later) {
        self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
        
    UIBarButtonItem *barItem;
    if (iOS9Later) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
    }
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    if (self.maxFileSize <= 0) {
        self.maxFileSize = kImageLimitSize;
    }
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        // 背景色
        appearance.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        // 去掉半透明效果
        appearance.backgroundEffect = nil;
        // 标题字体颜色及大小
        appearance.titleTextAttributes = textAttrs;
        // 设置导航栏下边界分割线透明
        appearance.shadowImage = [[UIImage alloc] init];
        // 去除导航栏阴影（如果不设置clear，导航栏底下会有一条阴影线）
        appearance.shadowColor = [UIColor clearColor];
        // standardAppearance：常规状态, 标准外观，iOS15之后不设置的时候，导航栏背景透明
        self.navigationBar.standardAppearance = appearance;
        // scrollEdgeAppearance：被scrollview向下拉的状态, 滚动时外观，不设置的时候，使用标准外观
        self.navigationBar.scrollEdgeAppearance = appearance;
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_needUseTimer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:YES];
        [_timer fire];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = iOS7Later ? UIStatusBarStyleLightContent : UIStatusBarStyleBlackOpaque;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
    [self hideProgressHUD];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<TZImagePickerControllerDelegate>)delegate {
    
    //默认可以选取照片
    NSString *tz_allowPickingImage = [[NSUserDefaults standardUserDefaults] objectForKey:@"tz_allowPickingImage"];
    if ([NSString isNull:tz_allowPickingImage]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"tz_allowPickingImage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    TZAlbumPickerController *albumPickerVc = [[TZAlbumPickerController alloc] init];
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];
        
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = NO;
        self.allowPickingImage = YES;
        self.allowTakePicture = NO;
        self.timeout = 15;
        self.photoWidth = 828.0;
        self.photoPreviewMaxWidth = 600;
        self.sortAscendingByModificationDate = YES;
        _needUseTimer = NO;
        if (![[TZImageManager manager] authorizationStatusAuthorized]) {
            _tipLable = [[UILabel alloc] init];
            _tipLable.frame = CGRectMake(8, 0, self.view.tz_width - 16, 300);
            _tipLable.textAlignment = NSTextAlignmentCenter;
            _tipLable.numberOfLines = 0;
            _tipLable.font = [UIFont systemFontOfSize:16];
            _tipLable.textColor = [UIColor blackColor];
            NSString *appName =[[NSBundle mainBundle]
                                objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
            _tipLable.text = [NSString stringWithFormat:SY_STRING(@"photo_setting"),appName];
            [self.view addSubview:_tipLable];
            if (![[TZImageManager manager] authorizationStatusDenied]) {
                //如果被拒绝了，没必要了
                _needUseTimer = YES;
            }
        } else {
            [self pushToPhotoPickerVc];
        }
    }
    return self;
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount moreParam:(NSDictionary *)param delegate:(id<TZImagePickerControllerDelegate>)delegate {
    
    //默认可以选取照片
    NSString *tz_allowPickingImage = [[NSUserDefaults standardUserDefaults] objectForKey:@"tz_allowPickingImage"];
    if ([NSString isNull:tz_allowPickingImage]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"tz_allowPickingImage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    TZAlbumPickerController *albumPickerVc = [[TZAlbumPickerController alloc] initWithParam:param];
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];
        
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = NO;
        self.allowPickingImage = YES;
        self.allowTakePicture = NO;
        self.timeout = 15;
        self.photoWidth = 828.0;
        self.photoPreviewMaxWidth = 600;
        self.sortAscendingByModificationDate = YES;
        _needUseTimer = NO;
        if (![[TZImageManager manager] authorizationStatusAuthorized]) {
            _tipLable = [[UILabel alloc] init];
            _tipLable.frame = CGRectMake(8, 0, self.view.tz_width - 16, 300);
            _tipLable.textAlignment = NSTextAlignmentCenter;
            _tipLable.numberOfLines = 0;
            _tipLable.font = [UIFont systemFontOfSize:16];
            _tipLable.textColor = [UIColor blackColor];
            NSString *appName =[[NSBundle mainBundle]
                                objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
            _tipLable.text = [NSString stringWithFormat:SY_STRING(@"photo_setting"),appName];
            [self.view addSubview:_tipLable];
            if (![[TZImageManager manager] authorizationStatusDenied]) {
                //如果被拒绝了，没必要了
                _needUseTimer = YES;
            }
        } else {
            [self pushToPhotoPickerVc];
        }
    }
    return self;
}
/// This init method just for previewing photos / 用这个初始化方法以预览图片
- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index{
    TZPhotoPreviewController *previewVc = [[TZPhotoPreviewController alloc] init];
    self = [super initWithRootViewController:previewVc];
    if (self) {
        self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
        self.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
        self.timeout = 15;
        self.photoWidth = 828.0;
        self.maxImagesCount = selectedAssets.count;
        self.photoPreviewMaxWidth = 600;
        
        previewVc.photos = [NSMutableArray arrayWithArray:selectedPhotos];
        previewVc.currentIndex = index;
        __weak typeof(self) weakSelf = self;
        [previewVc setOkButtonClickBlockWithPreviewType:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            if (weakSelf.didFinishPickingPhotosHandle) {
                weakSelf.didFinishPickingPhotosHandle(photos,assets,isSelectOriginalPhoto);
            }
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return self;
}

- (void)observeAuthrizationStatusChange {
    if ([[TZImageManager manager] authorizationStatusAuthorized]) {
        [_timer invalidate];
        _timer = nil;
        [self pushToPhotoPickerVc];
        [_tipLable removeFromSuperview];
    }
    if ([[TZImageManager manager] authorizationStatusDenied]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)pushToPhotoPickerVc {
    _pushToPhotoPickerVc = YES;
    //加锁保证安全
    NSLock *lock = [[NSLock alloc] init];
    [lock lock];
    if (_pushToPhotoPickerVc) {
        TZPhotoPickerController *photoPickerVc = [[TZPhotoPickerController alloc] init];
        photoPickerVc.isFirstAppear = YES;
        
        [[TZImageManager manager] getCameraRollAlbum:self.allowPickingVideo allowPickingImage:self.allowPickingImage completion:^(TZAlbumModel *model) {
            photoPickerVc.model = model;
            [self pushViewController:photoPickerVc animated:YES];
            self->_pushToPhotoPickerVc = NO;
            [lock unlock];
        }];
    }
}

- (void)showAlertWithTitle:(NSString *)title {
    if (iOS8Later) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:SY_STRING(@"common_isee") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:SY_STRING(@"common_isee") otherButtonTitles:nil, nil] show];
    }
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];

        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.frame = CGRectMake((self.view.tz_width - 120) / 2, (self.view.tz_height - 90) / 2, 120, 90);
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
        
        _HUDLable = [[UILabel alloc] init];
        _HUDLable.frame = CGRectMake(0,40, 120, 50);
        _HUDLable.textAlignment = NSTextAlignmentCenter;
        _HUDLable.text = SY_STRING(@"pic_handling");
        _HUDLable.font = [UIFont systemFontOfSize:15];
        _HUDLable.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLable];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    [self.view addSubview:_progressHUD];
    
    // if over time, dismiss HUD automatic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideProgressHUD];
    });
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

- (void)setTimeout:(NSInteger)timeout {
    _timeout = timeout;
    if (timeout < 5) {
        _timeout = 5;
    } else if (_timeout > 60) {
        _timeout = 60;
    }
}

- (void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth {
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
    if (photoPreviewMaxWidth > 800) {
        _photoPreviewMaxWidth = 800;
    } else if (photoPreviewMaxWidth < 500) {
        _photoPreviewMaxWidth = 500;
    }
    [TZImageManager manager].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}

- (void)setSelectedAssets:(NSMutableArray *)selectedAssets {
    _selectedAssets = selectedAssets;
    _selectedModels = [NSMutableArray array];
    for (id asset in selectedAssets) {
        TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypePhoto];
        model.isSelected = YES;
        [_selectedModels addObject:model];
    }
}

- (void)setAllowPickingImage:(BOOL)allowPickingImage {
    _allowPickingImage = allowPickingImage;
    NSString *allowPickingImageStr = _allowPickingImage ? @"1" : @"0";
    [[NSUserDefaults standardUserDefaults] setObject:allowPickingImageStr forKey:@"tz_allowPickingImage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    _allowPickingVideo = allowPickingVideo;
    NSString *allowPickingVideoStr = _allowPickingVideo ? @"1" : @"0";
    [[NSUserDefaults standardUserDefaults] setObject:allowPickingVideoStr forKey:@"tz_allowPickingVideo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate {
    _sortAscendingByModificationDate = sortAscendingByModificationDate;
    [TZImageManager manager].sortAscendingByModificationDate = sortAscendingByModificationDate;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (iOS7Later) viewController.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.childViewControllers.count > 0) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(3, 0, 50, 44)];
        [backButton setImage:[UIImage imageNamedFromMyBundle:@"navi_back.png"] forState:UIControlStateNormal];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        [backButton setTitle:SY_STRING(@"common_return") forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [backButton addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        backButtonItem.style = UIBarButtonItemStyleBordered;
        self.topViewController.navigationItem.backBarButtonItem = backButtonItem;
        
        /**
         另外一种只有箭头的返回键
         
         UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
         self.topViewController.navigationItem.backBarButtonItem = backItem;
         
        */
    }
    
    [super pushViewController:viewController animated:animated];
}

@end


@interface TZAlbumPickerController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_tableView;
    BOOL _viewAppear;
    BOOL _loadFinished;
}
@property (nonatomic, strong) NSMutableArray *albumArr;
/// 存放更多的参数，例如显示相册的图片格式过滤
@property (nonatomic, strong) NSDictionary *moreParam;
@end

@implementation TZAlbumPickerController

- (instancetype)initWithParam:(NSDictionary *)param{
    if (self = [super init]) {
        self.moreParam = param;
        [self loadData];
    }
    return self;
}
- (id)init
{
    if (self = [super init]) {
        [self loadData];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    self.navigationItem.title = SY_STRING(@"photo");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SY_STRING(@"common_cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
}

- (void)viewWillLayoutSubviews {
    if (_tableView) {
        CGFloat top = 44;
        [_tableView setFrame:CGRectMake(0, top, self.view.tz_width, self.view.tz_height - top)];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _viewAppear = YES;
    [self reloadData];
}

-(void)reloadData
{
    if (!_viewAppear || !_loadFinished) {
        return;
    }
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    [imagePickerVc hideProgressHUD];
    for (TZAlbumModel *albumModel in _albumArr) {
        albumModel.selectedModels = imagePickerVc.selectedModels;
    }
    if (!_tableView) {
        CGFloat top = 44;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, self.view.tz_width, self.view.tz_height - top) style:UITableViewStylePlain];
        _tableView.rowHeight = 74;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
        [_tableView registerClass:[TZAlbumCell class] forCellReuseIdentifier:@"TZAlbumCell"];
        [self.view addSubview:_tableView];
    } else {
        [_tableView reloadData];
    }
}

- (void)loadData {
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    __weak typeof(self) weakSelf = self;
    [[TZImageManager manager] getAllAlbums:NO allowPickingImage:YES completion:^(NSArray<TZAlbumModel *> *models) {
        weakSelf.albumArr = [NSMutableArray arrayWithArray:models];
        
        //过滤格式
        id typeListStr = weakSelf.moreParam[@"type"];
        NSArray *typeList;
        if ([typeListStr isKindOfClass:NSString.class] && [typeListStr stringValue].length && ![typeListStr isEqualToString:@"*"]) {
            typeList = [[typeListStr lowercaseString] componentsSeparatedByString:@","];
        }
        if (typeList.count) {
            for (TZAlbumModel *albumModel in weakSelf.albumArr) {
                NSMutableArray *addArr = [NSMutableArray new];
                for (TZAssetModel *model in albumModel.models) {
    //                NSArray *resources = [PHAssetResource assetResourcesForAsset:model.asset];
    //                NSString *path = [(PHAssetResource*)resources[0] valueForKey:@"privateFileURL"];
    //                if (!path) {
    //                    path = [(PHAssetResource*)resources[0] valueForKey:@"fileURL"];
    //                }
                    NSString *fileName = [model.asset valueForKey:@"filename"];
                    NSString *type = [[fileName pathExtension] lowercaseString];
                    if ([typeList containsObject:type]) {
                        [addArr addObject:model];
                    }
                }
                albumModel.models = addArr;
                albumModel.count = addArr.count;
            }
        }
        for (TZAlbumModel *albumModel in weakSelf.albumArr) {
            albumModel.selectedModels = imagePickerVc.selectedModels;
        }
        self->_loadFinished = YES;
        [weakSelf reloadData];
    }];
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

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TZAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TZAlbumCell"];
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    cell.selectedCountButton.backgroundColor = imagePickerVc.oKButtonTitleColorNormal;
    cell.model = _albumArr[indexPath.row];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TZPhotoPickerController *photoPickerVc = [[TZPhotoPickerController alloc] init];
    TZAlbumModel *model = _albumArr[indexPath.row];
    photoPickerVc.model = model;
    __weak typeof(self) weakSelf = self;
    [photoPickerVc setBackButtonClickHandle:^(TZAlbumModel *model) {
        [weakSelf.albumArr replaceObjectAtIndex:indexPath.row withObject:model];
    }];
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end


@implementation UIImage (MyBundle)

+ (UIImage *)imageNamedFromMyBundle:(NSString *)name {
    UIImage *image = [UIImage imageNamed:[@"TZImagePickerController.bundle" stringByAppendingPathComponent:name]];
    if (image) {
        return image;
    } else {
        image = [UIImage imageNamed:[@"Frameworks/TZImagePickerController.framework/TZImagePickerController.bundle" stringByAppendingPathComponent:name]];
        return image;
    }
}

@end
