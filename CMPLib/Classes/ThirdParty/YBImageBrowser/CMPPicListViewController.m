//
//  CMPPicListViewController.m
//  CMPLib
//
//  Created by MacBook on 2019/12/17.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPPicListViewController.h"
#import "CMPPicListCollectionCell.h"
#import "CMPPicListHeaderView.h"
#import "CMPPicListViewLayout.h"
#import "CMPAVPlayerDownloadView.h"
#import "UIView+CMPView.h"
#import "YBIBUtilities.h"
#import "YBImageBrowseCellData.h"
#import "YBVideoBrowseCellData.h"
#import "CMPReviewImagesTool.h"
#import "YBIBUtilities.h"
#import "NSObject+CMPHUDView.h"
#import "CMPStringConst.h"
#import "CMPCommonDataProviderTool.h"
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPAVPlayerViewController.h>
#import <CMPLib/NSURL+CMPURL.h>
#import <CMPLib/CMPDownloadAttachmentTool.h>
#import <CMPLib/YBImageBrowserTipView.h>
#import <CMPLib/CMPImageHelper.h>

static int const kLimitedSelectedNums = 9;
static CGFloat const kBottomViewH = 50.f;
static CGFloat const kAnimTimeInterval = 0.35f;
static CGFloat const kHeaderViewH = 30.f;

typedef enum : NSUInteger {
    CMPPicListVCBottomBtnTypeForward,
    CMPPicListVCBottomBtnTypeCollect,
    CMPPicListVCBottomBtnTypeDownload,
    CMPPicListVCBottomBtnTypeDelete
} CMPPicListVCBottomBtnType;

typedef NS_ENUM(NSInteger, CMPCollectImgsResultType) {
    CMPCollectImgsResultTypeSuccessful = 0,
    CMPCollectImgsResultTypeAlreadyColleced   = 1,
    CMPCollectImgsResultTypeAlreadyFail  = 2,
};

@interface CMPPicListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

/* collectionView */
@property (strong, nonatomic) UICollectionView *collectionView;
/* 是否是选中状态 */
@property (assign, nonatomic) BOOL isSelectedMode;

/* bottomView */
@property (strong, nonatomic) UIView *bottomView;
/* 转发 */
@property (weak, nonatomic) UIButton *forwardBtn;
/* 收藏按钮 */
@property (weak, nonatomic) UIButton *collectBtn;
/* 下载按钮 */
@property (weak, nonatomic) UIButton *downloadBtn;
/* 删除按钮 */
@property (weak, nonatomic) UIButton *deleteBtn;
/* 多选按钮 */
@property (strong, nonatomic) UIButton *multiSelectBtn;

/* 选中data */
@property (strong, nonatomic) NSMutableArray *selectedDatas;
/* 选中的rcImgModel */
@property (strong, nonatomic) NSMutableArray *selectedRCImgModels;
/* 选中的的indexpath，只有在删除的时候才有用 */
@property (strong, nonatomic) NSMutableArray *selectedIndexPaths;
/* 所有的图片数组 */
@property (strong, nonatomic) NSMutableArray *allOriginalImgModels;
/* bottomView是否在显示中 */
@property (assign, nonatomic) BOOL isBottomViewShowing;
/* downloadTool */
@property (strong, nonatomic) CMPDownloadAttachmentTool *downloadTool;
/* 多选收藏请求队列 */
@property (strong, nonatomic) dispatch_group_t collectRequestGroup;
@property (strong, nonatomic) CMPImageHelper *imageHelper;

@end

@implementation CMPPicListViewController
#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CMPPicListViewLayout *layout = [[CMPPicListViewLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
        _collectionView.cmp_y += self.bannerNavigationBar.height;
        _collectionView.cmp_height -= self.bannerNavigationBar.height;
        if (YBIBUtilities.isIphoneX) {
            _collectionView.cmp_y += 44.f;
            _collectionView.cmp_height -= 44.f;
        }
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = YES;
        [_collectionView registerClass:CMPPicListCollectionCell.class forCellWithReuseIdentifier:CMPPicListCollectionCellId];
        [_collectionView registerClass:CMPPicListHeaderView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CMPPicListHeaderViewId];
    }
    return _collectionView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [UIView.alloc initWithFrame:CGRectMake(0, self.view.height, self.view.width, kBottomViewH)];
        if (YBIBUtilities.isIphoneX) {
            _bottomView.cmp_height += 10.f;
        }
        _bottomView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
        
        [self configBottomView];
        
    }
    return _bottomView;
}

- (CMPDownloadAttachmentTool *)downloadTool {
    if (!_downloadTool) {
        _downloadTool = [[CMPDownloadAttachmentTool alloc] init];
    }
    return _downloadTool;
}

- (NSMutableArray *)allOriginalImgModels {
    if (!_allOriginalImgModels) {
        _allOriginalImgModels = NSMutableArray.array;
    }
    return _allOriginalImgModels;
}

-(dispatch_group_t)collectRequestGroup {
    if (!_collectRequestGroup) {
        _collectRequestGroup = dispatch_group_create();
        NSLog(@"清空 _alertGroup");
    }
    return _collectRequestGroup;
}

#pragma mark - life circle

- (void)dealloc {
    CMPFuncLog;
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _selectedDatas = NSMutableArray.array;
        _selectedRCImgModels = NSMutableArray.array;
        _selectedIndexPaths = NSMutableArray.array;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNotis];
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    [self setTitle:SY_STRING(@"picture_check_pics_title")];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    
    //ks fix -- ios16 - V5-39255
    __weak typeof(self) wSelf = self;
    self.baseSafeViewFrameChangedBlock = ^(CGRect safeFrame, UIEdgeInsets safeEdge) {
        wSelf.bottomView.cmp_height = kBottomViewH + safeEdge.bottom;
    };
}
/// view布局
- (void)layoutSubviewsWithFrame:(CGRect)frame {
    
    self.collectionView.cmp_y = 20.f + self.bannerNavigationBar.height;
    if (IS_IPHONE_X_UNIVERSAL) {
        self.collectionView.cmp_y = 88.f;
    }
    self.collectionView.cmp_height = self.view.height - self.collectionView.cmp_y;
    self.multiSelectBtn.cmp_x = self.bannerNavigationBar.width - self.multiSelectBtn.width;
    self.bottomView.cmp_width = self.view.width;
    if (self.isSelectedMode) {
        self.bottomView.cmp_y = self.view.height - self.bottomView.height;
    }else {
        self.bottomView.cmp_y = self.view.height;
    }
    
    NSInteger count = self.bottomView.subviews.count - 1;
    CGFloat bottomBtnW = self.bottomView.width/count;
    
    for (NSInteger i = 0; i < count; i++) {
        UIView *view = self.bottomView.subviews[i];
        view.cmp_x = i*bottomBtnW;
        view.cmp_width = bottomBtnW;
    }
    [super layoutSubviewsWithFrame:frame];
}

/// 设置导航按钮
- (void)setupBannerButtons
{
    self.bannerNavigationBar.leftViewsMargin = 0.0f;
    self.bannerNavigationBar.rightViewsMargin = 10.0f;
    self.bannerNavigationBar.leftMargin = 14.0f;
    self.bannerNavigationBar.rightMargin = 0.0f;
    self.backBarButtonItemHidden = YES;
    UIButton *closeItem = [[UIButton alloc] initWithFrame:CGRectMake(12.f, 0.f, 20.f, 20.f)];
    closeItem.contentMode = UIViewContentModeCenter;
    
    [closeItem setImage:[[UIImage imageNamed:@"login_view_back_btn_icon"] cmp_imageWithTintColor:CMPThemeManager.sharedManager.iconColor] forState:UIControlStateNormal];
    [closeItem addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside];
    self.bannerNavigationBar.leftBarButtonItems = @[closeItem];
    
    UIButton *multiSelectBtn = [UIButton.alloc initWithFrame:CGRectMake(0, 0, 80.f, 20.f)];
    [multiSelectBtn setTitle:SY_STRING(@"picture_multi_select_btn_title") forState:UIControlStateNormal];
    
    [multiSelectBtn setTitleColor:[UIColor cmp_colorWithName:@"main-fc"] forState:UIControlStateNormal];
    multiSelectBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    [multiSelectBtn addTarget:self action:@selector(multiSelectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.multiSelectBtn = multiSelectBtn;
    self.bannerNavigationBar.rightBarButtonItems = @[multiSelectBtn];
}

- (void)configBottomView {
    CGFloat btnW = self.bottomView.width/4.f;
    CGFloat btnH = kBottomViewH;
    NSArray *icons = @[@"picture_share_icon",@"picture_collect_icon",@"picture_download_icon",@"picture_delete_icon"];
    NSInteger count = icons.count;
    for (NSInteger i = 0; i < count; i++) {
        
        UIButton *btn = [UIButton buttonWithImageName:icons[i] frame:CGRectMake(i*btnW, 0.5f, btnW, btnH) buttonImageAlignment:kButtonImageAlignment_Center];
        btn.tag = i;
        [btn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btn];
    }
    
    UIView *separator = [UIView.alloc initWithFrame:CGRectMake(0, 0, _bottomView.width, 0.5f)];
    separator.backgroundColor = [UIColor cmp_colorWithName:@"cmp-bdc"];
    [self.bottomView addSubview:separator];
}

/// 显示隐藏底部操作view
/// @param isShown 是否显示
- (void)showBottomView:(BOOL)isShown {
    
    if ((isShown && self.isBottomViewShowing) ||
        (!isShown && !self.isBottomViewShowing)) {
        //如果在显示中，并且要显示，那么就不执行下面代码
        //如果不在显示中，并且不要显示，那么就不执行下面代码
        return;
    }
    
    
    self.isBottomViewShowing = isShown;
    [UIView animateWithDuration:kAnimTimeInterval animations:^{
        if (isShown) {
            self.bottomView.cmp_y  = self.view.height - self.bottomView.height;
            self.collectionView.cmp_height -= self.bottomView.height;
        }else {
            self.bottomView.cmp_y = self.view.height;
            self.collectionView.cmp_height += self.bottomView.height;
        }
        
    }];
}

#pragma mark 按钮点击

/// 左上角关闭按钮点击
- (void)closeClicked {
    CMPFuncLog;
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// 右上角多选按钮点击
- (void)multiSelectBtnClicked:(UIButton *)btn {
    CMPFuncLog;
    btn.selected = !btn.selected;
    self.isSelectedMode = btn.selected;
    if (btn.selected) {
        [btn setTitle:SY_STRING(@"common_cancel") forState:UIControlStateNormal];
    }else {
        [btn setTitle:SY_STRING(@"picture_multi_select_btn_title") forState:UIControlStateNormal];
        [_selectedDatas removeAllObjects];
        [_selectedRCImgModels removeAllObjects];
        [_selectedIndexPaths removeAllObjects];
        [self showBottomView:NO];
    }
    
    [self.collectionView reloadData];
}

/// 底部操作栏  四个按钮的点击事件
/// @param btn 点击了哪个按钮
- (void)bottomBtnClick:(UIButton *)btn {
    if (!_selectedDatas.count) {
        [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"picture_pic_selected_empty_tips")];
        return;
    }
    switch (btn.tag) {
        case CMPPicListVCBottomBtnTypeForward:
        {
            //转发
            [self forwardMsg];
        }
            break;
        case CMPPicListVCBottomBtnTypeCollect:
        {
            //收藏
            [self collectImgs];
        }
            break;
        case CMPPicListVCBottomBtnTypeDownload:
        {
            //下载
            [self downloadImges];
        }
            break;
        case CMPPicListVCBottomBtnTypeDelete:
        {
            //删除
            [self deleteImgs];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 通知相关

- (void)addNotis {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(imgForwardSucc:) name:@"kDidOneByOneForwardSucess" object:nil];
}

- (void)imgForwardSucc:(NSNotification *)noti {
    [self multiSelectBtnClicked:self.multiSelectBtn];
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

/// 设置组数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return _dataArray.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *itemDic = _dataArray[section];
    NSArray *items = itemDic[@"items"];
    return items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMPPicListCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CMPPicListCollectionCellId forIndexPath:indexPath];
    [cell showSelectView:self.isSelectedMode];
    if (self.isSelectedMode) {
        cell.cellSelected = NO;
    }
    NSArray *dataArr = _dataArray[indexPath.section][@"items"];
    YBImageBrowseCellData *data = dataArr[indexPath.item];
    if ([data isKindOfClass:YBImageBrowseCellData.class]) {
        cell.modelData = data;
    }else {
        cell.videoModelData = (YBVideoBrowseCellData *)data;
    }
    return cell;
}

/// header的size设置
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(collectionView.width, kHeaderViewH);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat wh = collectionView.width/4.f;
    return CGSizeMake(wh, wh);
}


/// header/footer的view设置
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *title = _dataArray[indexPath.section][@"month"];
        CMPPicListHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:CMPPicListHeaderViewId forIndexPath:indexPath];
        header.title = title;
        return header;
    }
    return UICollectionReusableView.new;
}

/// 点击cell方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CMPPicListCollectionCell *cell = (CMPPicListCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //计算当前显示的index
    NSArray *dataArr = _dataArray[indexPath.section][@"items"];
    YBImageBrowseCellData *data = dataArr[indexPath.item];
    NSInteger currentIndex = [self currentIndex:indexPath];
    
    if (self.isSelectedMode) {
        cell.cellSelected = !cell.cellSelected;
        
        id rcImgModel = _rcImgModels[currentIndex];
        if (cell.cellSelected) {
            if (_selectedDatas.count == kLimitedSelectedNums) {
                [self showAlertMessage:[NSString stringWithFormat:SY_STRING(@"photo_countlimit"),kLimitedSelectedNums]];
                return;
            }
            [_selectedDatas addObject:data];
            [_selectedRCImgModels addObject:rcImgModel];
            [_selectedIndexPaths addObject:indexPath.copy];
        }else {
            [_selectedDatas removeObject:data];
            [_selectedRCImgModels removeObject:rcImgModel];
            [_selectedIndexPaths removeObject:indexPath.copy];
        }
        
        
        [self showBottomView:_selectedDatas.count];
        
    }else {
        NSInteger currentImgIndex = [self currentImgIndex:data];
        [self playWithData:data currentIndex:currentImgIndex];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

/// 获取当前index
- (NSInteger)currentIndex:(NSIndexPath *)indexPath {
    NSInteger currentIndex = 0;
    for (NSInteger i = 0; i <= indexPath.section; i++) {
        if (i != indexPath.section) {
            NSArray *items = _dataArray[i][@"items"];
            currentIndex += items.count;
        }else {
            currentIndex += indexPath.item;
        }
    }
    return currentIndex;
}

- (NSInteger)currentImgIndex:(id)cuurentData {
    NSInteger currentIndex = -1;
    for (id data in self.allOriginalImgModels) {
        if ([data isEqual:cuurentData]) {
            currentIndex = [self.allOriginalImgModels indexOfObject:data];
        }
    }
    return currentIndex;
}

- (void)playWithData:(YBImageBrowseCellData *)data currentIndex:(NSInteger)currentIndex {
    if ([data isKindOfClass:YBVideoBrowseCellData.class]) {
        //播放本地视频
        YBVideoBrowseCellData *videoData = (YBVideoBrowseCellData *)data;
        CMPAVPlayerViewController *playerVc = CMPAVPlayerViewController.alloc.init;
        NSString *videoLocalPath = videoData.videoPath;
        playerVc.fileName = videoData.imgName;
        playerVc.from = videoData.from;
        playerVc.fromType = videoData.fromType;
        playerVc.fileId = videoData.fileId;
        playerVc.showAlbumBtn = NO;
        playerVc.autoSave = YES;
        playerVc.isOnlinePlay = NO;
        playerVc.canNotShare = NO;
        playerVc.canNotCollect = ![CMPFeatureSupportControl isSupportCollect];
        playerVc.canNotSave = NO;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoLocalPath]) {
            playerVc.url = [NSURL URLWithPathString:videoLocalPath];
            
            [self presentViewController:playerVc animated:YES completion:nil];
            return;
        }
        //下载视频再播放
        UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
        CMPAVPlayerDownloadView *downloadView = [[CMPAVPlayerDownloadView alloc] initWithFrame:keyWindow.bounds];
        [downloadView setFileSize:videoData.fileSize];
        [keyWindow addSubview:downloadView];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(downloadView) weakDownloadView = downloadView;
        downloadView.closeBtnClicked = ^{
            [weakSelf.downloadTool cancelDownload];
            [weakDownloadView removeFromSuperview];
        };
        
        NSString *downloadFileId = [videoData.fileId stringByAppendingString:@"?ucFlag=yes"];
        [self.downloadTool downloadWithFileID:downloadFileId fileName:videoData.imgName lastModified:@"" start:^{
            [downloadView setProgress:0];
        } progressUpdate:^(float progress) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [downloadView setProgress:progress];
            });
            
            CMPLog(@"---下载进度----%f",progress);
        } success:^(NSString *localPath) {
            [downloadView setProgress:1.f];
            [downloadView removeFromSuperview];
            
            playerVc.url = [NSURL URLWithPathString:localPath];
            [self presentViewController:playerVc animated:YES completion:nil];
        } fail:^(NSError *error) {
            [weakDownloadView removeFromSuperview];
        }];
    }else {
        [CMPReviewImagesTool showBrowserForMixedCaseWithDataModelArray:self.allOriginalImgModels index:currentIndex fromControllerIsAllowRotation:NO canSave:self.canSave isShowCheckAllPicsBtn:NO];
    }
}

#pragma mark - 处理选中后的操作

- (void)downloadImges
{
    if (_selectedDatas.count == 0) {
        return;
    }
    NSMutableArray *aList = [[NSMutableArray alloc] init];
    for (YBImageBrowseCellData *data in _selectedDatas) {
        if ([data isKindOfClass:YBImageBrowseCellData.class]) {
            NSMutableDictionary *aItem = [NSMutableDictionary dictionary];
            YBImageBrowseCellData *imgCellData = (YBImageBrowseCellData *)data;
            if (imgCellData.image && [imgCellData.image respondsToSelector:@selector(animatedImageData)] && imgCellData.image.animatedImageData) {
                aItem[@"value"] = imgCellData.image.animatedImageData;
            }
            else if (imgCellData.image) {
                aItem[@"value"] = imgCellData.image;
            }
            else if (imgCellData.url) {
                aItem[@"url"] = imgCellData.url.absoluteString;
                NSString *aImageName = imgCellData.imgName;
                aItem[@"name"] = aImageName;
            }
            aItem[@"type"] = @"image";
            [aList addObject:aItem];
        }
        else if ([data isKindOfClass:YBVideoBrowseCellData.class]) {
            NSMutableDictionary *aItem = [NSMutableDictionary dictionary];
            YBVideoBrowseCellData *aVideoCellData = (YBVideoBrowseCellData *)data;
            NSString *aUrl = aVideoCellData.url.absoluteString;
            aItem[@"url"] = aUrl;
            aItem[@"name"] = aVideoCellData.imgName;
            aItem[@"type"] = @"video";
            aItem[@"filePath"] = aVideoCellData.videoPath;
            aItem[@"fileID"] = aVideoCellData.fileId;
            [aList addObject:aItem];
        }
    }
    if (aList.count > 0) {
        if (!_imageHelper) {
            _imageHelper = [[CMPImageHelper alloc] init];
        }
        [_imageHelper saveToPhotoAlbum:aList start:^{
            [MBProgressHUD cmp_showProgressHUD];
        } success:^{
            // 所有保存成功
            [[UIApplication sharedApplication].keyWindow yb_showHookTipView:SY_STRING(@"review_image_saveToPhotoAlbumSuccess")];
        } failed:^(NSError * _Nonnull error) {
            // 单个保存失败
            [[UIApplication sharedApplication].keyWindow yb_showForkTipView:SY_STRING(@"review_image_saveToPhotoAlbumFailed")];
        } complete:^{
            [MBProgressHUD cmp_hideProgressHUD];
        }];
    }
}

/// 删除图片
- (void)deleteImgs {
    //如果删除了图片，需要发送通知给chatVC，以便这个界面时，直接退出图片浏览vc
    [NSNotificationCenter.defaultCenter postNotificationName:CMPDelteSelectedRcImgModelsPicNoti object:_selectedRCImgModels.copy];
    
    [self removeData];
    [self.collectionView deleteItemsAtIndexPaths:_selectedIndexPaths];
    [_selectedIndexPaths removeAllObjects];
}


/// 移除collectionView数据源要删除的数据
- (void)removeData {
    for (id data in _selectedDatas) {
        if ([_originalDataArray containsObject:data]) {
            [_originalDataArray removeObject:data];
        }
        
        if ([_allOriginalImgModels containsObject:data]) {
            [_allOriginalImgModels removeObject:data];
        }
        
        for (NSDictionary *dic in _dataArray) {
            NSMutableArray *arr = dic[@"items"];
            if ([arr containsObject:data]) {
                [arr removeObject:data];
                //如果arr为空了的时候，要对dic进行从_dataArray数组中删除
                break;
            }
        }
    }
    
    for (id data in _selectedRCImgModels) {
        if ([_rcImgModels containsObject:data]) {
            [_rcImgModels removeObject:data];
        }
    }
    
    [_selectedRCImgModels removeAllObjects];
    [_selectedDatas removeAllObjects];
}

/// 转发消息
- (void)forwardMsg {
    NSDictionary *dic = @{@"dataArray" : _selectedRCImgModels.copy, @"vc" : self};
    [NSNotificationCenter.defaultCenter postNotificationName:CMPYBImageBrowserForwardNoti object:dic];
    
}

/// 收藏图片
- (void)collectImgs {
    NSMutableArray *selectedRCImgModels = [_selectedRCImgModels copy];
    self.multiSelectBtn.selected = YES;
    [self multiSelectBtnClicked:self.multiSelectBtn];
    [MBProgressHUD cmp_showProgressHUD];
    
    __weak typeof(self) weakSelf = self;
    __block CMPCollectImgsResultType resultType = CMPCollectImgsResultTypeSuccessful;
    __block NSInteger alreadyCollectCount = 0;
    
    for (id cellData in selectedRCImgModels) {
        id imgMsg = [cellData performSelector:@selector(content)];
        NSString *url = [imgMsg performSelector:@selector(remoteUrl)];
        NSString *sourceId = [CMPCommonTool getSourceIdWithUrl:url];
        
        dispatch_group_enter(weakSelf.collectRequestGroup);
        [CMPCommonDataProviderTool.sharedTool requestToCollectWithSourceId:sourceId isUc:YES completionBlock:^(BOOL isSeccessful, NSString * _Nullable responseData, NSError * _Nullable error) {
            if (!isSeccessful) {
                resultType = CMPCollectImgsResultTypeAlreadyFail;
            } else {
                NSDictionary *dic = [CMPCommonTool dictionaryWithJsonString:responseData];
                NSInteger code = [dic[@"code"] integerValue];
                if (code == 1) {
                    alreadyCollectCount += 1;
                }
            }
            dispatch_group_leave(weakSelf.collectRequestGroup);
        }];
    }
    
    dispatch_group_notify(self.collectRequestGroup, dispatch_get_main_queue(), ^{
        if (alreadyCollectCount == selectedRCImgModels.count) {
            resultType = CMPCollectImgsResultTypeAlreadyColleced;
        }
        if (resultType == CMPCollectImgsResultTypeSuccessful) {
            [MBProgressHUD  cmp_showHUDWithText:SY_STRING(@"rc_msg_collection_handel_success")];
        } else if (resultType == CMPCollectImgsResultTypeAlreadyColleced) {
            [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"rc_msg_collection_handel_already_collect")];
        } else {
            [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"rc_msg_collection_handel_fail")];
        }
    });
}
#pragma mark setter
- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray.mutableCopy;
}

- (void)setOriginalDataArray:(NSMutableArray *)originalDataArray {
    _originalDataArray = originalDataArray.mutableCopy;
    
    for (id data in originalDataArray) {
        if ([data isKindOfClass:YBImageBrowseCellData.class]) {
            [self.allOriginalImgModels addObject:data];
        }
    }
}

- (void)setRcImgModels:(NSMutableArray *)rcImgModels {
    _rcImgModels = rcImgModels.mutableCopy;
}

/// 对数据进行按月份分组
+ (NSArray *)groupDataArray:(NSArray *)dataSourceArray {
    NSDateFormatter *formatter = NSDateFormatter.alloc.init;
    formatter.dateFormat = @"yyyy-MM";
    NSString *thisMonth = [formatter stringFromDate:NSDate.date];
    NSString *lastTime = nil;
    NSInteger count = dataSourceArray.count;
    
    NSMutableDictionary *dic = NSMutableDictionary.dictionary;
    NSMutableArray *dataArr = NSMutableArray.array;
    NSMutableArray *tmpArr = NSMutableArray.array;
    
    for (NSInteger i = count - 1; i >= 0; i--) {
        id<YBImageBrowserCellDataProtocol> data = dataSourceArray[i];
        if ([data isKindOfClass: YBImageBrowseCellData.class]) {
            YBImageBrowseCellData *imgData = (YBImageBrowseCellData *)data;
            if (i == 0) {
                dic[@"month"] = [imgData.time isEqualToString:thisMonth] ? @"本月" : imgData.time;
                [tmpArr addObject:imgData];
                dic[@"items"] = tmpArr.mutableCopy;
                [dataArr addObject:dic.copy];
                break;
            }
            
            if (![imgData.time isEqualToString:lastTime]) {
                if (count - 1 != i) {
                    dic[@"items"] = tmpArr.mutableCopy;
                    [dataArr addObject:dic.copy];
                    [tmpArr removeAllObjects];
                }
                
                dic[@"month"] = [imgData.time isEqualToString:thisMonth] ? @"本月" : imgData.time;
                
            }
            
            [tmpArr addObject:imgData];
            lastTime = imgData.time.copy;
        }else {
            YBVideoBrowseCellData *videoData = (YBVideoBrowseCellData *)data;
            if (i == 0) {
                dic[@"month"] = [videoData.time isEqualToString:thisMonth] ? @"本月" : videoData.time;
                [tmpArr addObject:videoData];
                dic[@"items"] = tmpArr.mutableCopy;
                [dataArr addObject:dic.copy];
                break;
            }
            
            if (![videoData.time isEqualToString:lastTime]) {
                if (count - 1 != i) {
                    dic[@"items"] = tmpArr.mutableCopy;
                    [dataArr addObject:dic.copy];
                    [tmpArr removeAllObjects];
                }
                
                dic[@"month"] = [videoData.time isEqualToString:thisMonth] ? @"本月" : videoData.time;
                
            }
            
            [tmpArr addObject:videoData];
            lastTime = videoData.time.copy;
        }
    }
    return dataArr;
}

@end
