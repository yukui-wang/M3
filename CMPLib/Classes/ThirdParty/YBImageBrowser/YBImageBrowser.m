//
//  YBImageBrowser.m
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/8/24.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "YBImageBrowser.h"
#import "YBImageBrowserViewLayout.h"
#import "YBImageBrowserView.h"
#import "YBImageBrowser+Internal.h"
#import "YBIBUtilities.h"
#import "YBIBWebImageManager.h"
#import "YBIBTransitionManager.h"
#import "YBIBLayoutDirectionManager.h"
#import "YBIBCopywriter.h"
#import "YBImageBrowserPageControlToolBar.h"
#import "CMPAppDelegate.h"
#import "CMPPrintTools.h"
#import "NSObject+CMPHUDView.h"
#import "CMPFileManager.h"
#import "UIColor+Hex.h"
#import "CMPPicListViewController.h"
#import "NSArray+CMPArray.h"
#import "CMPStringConst.h"
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPCommonDataProviderTool.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/CMPUploadFileTool.h>
#import <CMPLib/SyFileManager.h>
#import <CMPLib/SDWebImageDownloader.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPReviewImagesTool.h>


@interface YBImageBrowser () <UIViewControllerTransitioningDelegate, YBImageBrowserViewDelegate, YBImageBrowserDataSource> {
    BOOL _isFirstViewDidAppear;
    YBImageBrowserLayoutDirection _layoutDirection;
    CGSize _containerSize;
    BOOL _isRestoringDeviceOrientation;
    UIInterfaceOrientation _statusBarOrientationBefore;
    UIWindowLevel _windowLevelByDefault;
}

@property (nonatomic, strong) YBIBTransitionManager *transitionManager;

@property (nonatomic, strong) CMPPrintTools *printTool;
@property (nonatomic, strong) YBImageBrowserSheetView *customSheetView;

@property (nonatomic, strong) YBImageBrowserSheetAction *forwardAction;
@property (nonatomic, strong) YBImageBrowserSheetAction *collectPhotoAction;
@property (nonatomic, strong) YBImageBrowserSheetAction *saveAction;
//识别二维码
@property (nonatomic, strong) YBImageBrowserSheetAction *qrCodeAction;

//7.1SP1
@property (nonatomic, strong) YBImageBrowserSheetAction *viewOriginalPhotoAction;
@property (nonatomic, strong) YBImageBrowserSheetAction *printPhotoAction;

/* 查看原图按钮 */
@property (weak, nonatomic) UIButton *checkoutOriginalPic;
/* 查看所有图片按钮 */
@property (weak, nonatomic) UIButton *checkAllPicsBtn;

/* 是否在图片/视频页面进行了删除操作 */
@property (assign, nonatomic) BOOL hasDoneDelted;

@end

@implementation YBImageBrowser

#pragma mark - life cycle

- (void)dealloc {
    NSLog(@"%s",__func__);
    // If the current instance is released (possibly uncontrollable release), we need to restore the changes to external business.
    self.hiddenSourceObject = nil;
    [self setStatusBarHide:NO];
    [self removeObserverForSystem];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.showCheckAllPicsBtn = YES;
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.hasDoneDelted = NO;
        [self initVars];
        [self addNotis];
    }
    return self;
}

- (void)initVars {
    self->_isFirstViewDidAppear = NO;
    self->_isRestoringDeviceOrientation = NO;
    
    self->_currentIndex = 0;
    self->_supportedOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
    self->_backgroundColor = [UIColor blackColor];
    self->_enterTransitionType = YBImageBrowserTransitionTypeCoherent;
    self->_outTransitionType = YBImageBrowserTransitionTypeCoherent;
    self->_transitionDuration = 0.25;
    self->_autoHideSourceObject = YES;
    
    self.shouldPreload = YES;
    
    YBImageBrowserToolBar *toolBar = [YBImageBrowserToolBar new];
    self->_defaultToolBar = toolBar;
    YBImageBrowserPageControlToolBar *pageControlToolBar = [[YBImageBrowserPageControlToolBar alloc] initWithPageType:YBImageBrowserPageTypepageLable];
    self->_toolBars = @[pageControlToolBar];
    
    self.customSheetView = [YBImageBrowserSheetView new];
    
    __weak typeof(self) weakSelf = self;
    //分享点击
    self.forwardAction = [YBImageBrowserSheetAction actionWithName:[YBIBCopywriter shareCopywriter].forwardPhoto identity:nil action:^(id<YBImageBrowserCellDataProtocol>  _Nonnull data) {
        if ([data isMemberOfClass:[YBImageBrowseCellData class]]) {
            
            YBImageBrowseCellData *cellData = (YBImageBrowseCellData *)data;
            NSString *url = cellData.url.absoluteString;
            NSString *fileId = cellData.fileId;
            if (!fileId.length) {
                fileId = [CMPCommonTool getSourceIdWithUrl:url];
            }
            NSData *imgData = NSData.data;
            NSString *imgName = cellData.imgName;
            NSString *pathExtension = @".png";
            if (cellData.image.animatedImageType == YYImageTypeGIF) {
                pathExtension = @".gif";
                //ks fix -- V5-39047【Xcode14+ios16】合并转发消息中的动图，分享到聊天中变为图片
                if ([imgName containsString:@"."]) {
                    NSArray *ar = [imgName componentsSeparatedByString:@"."];
                    NSMutableArray *mAr = ar.mutableCopy;
                    [mAr replaceObjectAtIndex:ar.count-1 withObject:@"gif"];
                    imgName = [mAr componentsJoinedByString:@"."];
                }
                //end
            }
            imgData = cellData.image.imageData;
            
            
            if (!imgName.length) {
                imgName = [[CMPCommonTool getSourceIdWithUrl:url] stringByAppendingString:pathExtension];
            }
            
            NSString *filePath = [SyFileManager.fileTempPath stringByAppendingPathComponent:imgName];
            [imgData writeToFile:filePath atomically:YES];
            CMPFileManagementRecord *mfr = CMPFileManagementRecord.alloc.init;
            mfr.filePath = filePath;
            mfr.fileSize = [NSString stringWithFormat:@"%lu",(unsigned long)imgData.length];
            mfr.fileId = fileId;
            mfr.fileName = imgName;
            mfr.fileUrl = url;
            mfr.lastModify = [NSDate.date timeIntervalSince1970]*1000;
            mfr.from = cellData.from;
            mfr.fromType = cellData.fromType;
            mfr.origin = cellData.fileId;
            mfr.isUc = weakSelf.showCheckAllPicsBtn;
            //分享不显示下载了
            mfr.notShowShareIcons = [NSArray  arrayWithObjects:CMPShareComponentDownloadString, nil];

            NSDictionary *obj = @{@"mfr" : mfr,@"pushVC" : weakSelf ,@"isUc" : @1};
            [NSNotificationCenter.defaultCenter postNotificationName:CMPAttachReaderShareClickedNoti object:obj];
            
        }
    }];
    
    //收藏点击
    self.collectPhotoAction = [YBImageBrowserSheetAction actionWithName:[YBIBCopywriter shareCopywriter].collectPhoto identity:nil action:^(id<YBImageBrowserCellDataProtocol>  _Nonnull data) {
        if ([data isMemberOfClass:[YBImageBrowseCellData class]] && self.rcImgModels) {
            id cellData = weakSelf.rcImgModels[weakSelf.currentIndex];
            id imgMsg = [cellData performSelector:@selector(content)];
            NSString *url = [imgMsg performSelector:@selector(remoteUrl)];
            NSString *localPath = [imgMsg performSelector:@selector(localPath)];
            NSString *sourceId = [CMPCommonTool getSourceIdWithUrl:url];
            
            [CMPCommonDataProviderTool.sharedTool requestToCollectWithSourceId:sourceId isUc:weakSelf.isFromUC filePath:localPath];
        }else {
            YBImageBrowseCellData *cellData = (YBImageBrowseCellData *)data;
            NSString *sourceId = nil;
            if (cellData.fileId.length) {
                sourceId = cellData.fileId;
                
            }
            else {
                NSString *url = cellData.url.absoluteString;
                sourceId = [CMPCommonTool getSourceIdWithUrl:url];
                
            }
            
            NSString *filePath = cellData.url.absoluteString;
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
                NSString *fileName = cellData.imgName;
                NSString *aFilePath = [[CMPFileManager fileTempPath] stringByAppendingPathComponent:fileName];
                NSData *data = UIImagePNGRepresentation(cellData.image);
                [data writeToFile:aFilePath atomically:YES];
                filePath = aFilePath;
            }
            if (!sourceId.justContainsNumber) {
                
                [CMPUploadFileTool.sharedTool requestToUploadFileWithFilePath:filePath startBlock:^{
                   [MBProgressHUD cmp_showHUDWithText:@""];
                } successBlock:^(NSString * _Nonnull fileId) {
                    [CMPCommonDataProviderTool.sharedTool requestToCollectWithSourceId:fileId isUc:weakSelf.isFromUC filePath:nil];
                } failedBlock:nil];
                
            }else {
                [CMPCommonDataProviderTool.sharedTool requestToCollectWithSourceId:sourceId isUc:weakSelf.isFromUC filePath:filePath];
            }
            
            
        }
    }];
    //保存图片
    self.saveAction = [YBImageBrowserSheetAction actionWithName:[YBIBCopywriter shareCopywriter].saveToPhotoAlbum identity:kYBImageBrowserSheetActionIdentitySaveToPhotoAlbum action:nil];
    
    //识别图中的二维码
    self.qrCodeAction = [YBImageBrowserSheetAction actionWithName:YBIBCopywriter.shareCopywriter.indentifyQRCode identity:nil action:^(id<YBImageBrowserCellDataProtocol>  _Nonnull data) {
        if ([data isMemberOfClass:[YBImageBrowseCellData class]]) {
            YBImageBrowseCellData *cellData = (YBImageBrowseCellData *)data;
            NSMutableDictionary *params = NSMutableDictionary.dictionary;
            params[@"vc"] = weakSelf;
            params[@"scanImage"] = cellData.image;
            [NSNotificationCenter.defaultCenter postNotificationName:CMPShowBlankScanVCNoti object:params];
            
        }
    }];
    
    
    self->_shouldHideStatusBar = YES;
    self.allowRotation = YES;
}



//显示原图
- (YBImageBrowserSheetAction *)viewOriginalPhotoAction {
    if (!_viewOriginalPhotoAction) {
        __weak typeof(self) weakSelf = self;
        _viewOriginalPhotoAction = [YBImageBrowserSheetAction actionWithName:[YBIBCopywriter shareCopywriter].viewOriginalPhoto identity:nil action:^(id<YBImageBrowserCellDataProtocol>  _Nonnull data) {
            if ([data isMemberOfClass:[YBImageBrowseCellData class]]) {
                YBImageBrowseCellData *cellData = (YBImageBrowseCellData *)data;
                [cellData setValue:nil forKey:@"image"];
                cellData.url = (NSURL *)cellData.extraData[@"originImageURL"];
                [cellData yb_preload];
                cellData.extraData[@"isOriginImage"] = [NSNumber numberWithBool:YES];
                [weakSelf cmp_showHUDWithText:SY_STRING(@"review_image_viewOriginalPhoto_tip")];
                //保存原图
                if ([CMPFeatureSupportControl isAutoSaveFile]) {
                    [weakSelf saveImageToLocalWithUrl:cellData.url cellData:cellData];
                }
            }
        }];
    }
    return _viewOriginalPhotoAction;
}
//打印
- (YBImageBrowserSheetAction *)printPhotoAction {
    if (!_printPhotoAction) {
        __weak typeof(self) weakSelf = self;
        _printPhotoAction = [YBImageBrowserSheetAction actionWithName:[YBIBCopywriter shareCopywriter].printPhoto identity:nil action:^(id<YBImageBrowserCellDataProtocol>  _Nonnull data) {
            if ([data isMemberOfClass:[YBImageBrowseCellData class]]) {
                YBImageBrowseCellData *cellData = (YBImageBrowseCellData *)data;
                if (cellData.image) {
                    NSData *data = cellData.image.imageData;
                    [weakSelf hide];
                    long long fileSize = data.length;
                    long long maxFileSize = 15 * 1024 * 1024;
                    if (fileSize > maxFileSize) {
                        [weakSelf cmp_showHUDWithText:SY_STRING(@"print_more_than_size")];
                        return;
                    }
                    [weakSelf.printTool printWithData:data success:^{
                    } fail:^(NSError *error) {
                    }];
                }
            }
        }];
    }
    return _printPhotoAction;
}


- (void)addNotis {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(delteSelectedRcImgModelsPicNoti:) name:CMPDelteSelectedRcImgModelsPicNoti object:nil];
}

- (void)delteSelectedRcImgModelsPicNoti:(NSNotification *)noti {
    self.hasDoneDelted = YES;
}

- (void)initCustomViews {
    NSString *viewOrignalPhotoText = SY_STRING(@"review_image_viewOriginalPhoto");
    CGFloat viewOrignalPhotoW = [viewOrignalPhotoText sizeWithFontSize:[UIFont systemFontOfSize:14.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 6.f;
    UIButton *checkoutOrinalPic = [UIButton.alloc initWithFrame:CGRectMake(0, 0, viewOrignalPhotoW, 30.f)];
    checkoutOrinalPic.cmp_centerX = self.view.width/2.f;
    checkoutOrinalPic.cmp_y = 300.f;
    checkoutOrinalPic.backgroundColor = [UIColor colorWithHexString:@"#3b3b3b"];
    checkoutOrinalPic.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [checkoutOrinalPic setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [checkoutOrinalPic setTitle:viewOrignalPhotoText forState:UIControlStateNormal];
    [checkoutOrinalPic addTarget:self action:@selector(checkoutOriginalPicClicked) forControlEvents:UIControlEventTouchUpInside];
    [checkoutOrinalPic cmp_setCornerRadius:4.f];
    [self.view addSubview:checkoutOrinalPic];
    self.checkoutOriginalPic = checkoutOrinalPic;
    self.checkoutOriginalPic.hidden = YES;
    
    if (self.showCheckAllPicsBtn) {
        UIButton *checkAllPicsBtn = [UIButton.alloc initWithFrame:CGRectMake(0, 0, 30.f, 30.f)];
        [checkAllPicsBtn setImage:[UIImage imageNamed:@"picture_list_check_icon"] forState:UIControlStateNormal];
        [checkAllPicsBtn addTarget:self action:@selector(checkAllPicsClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:checkAllPicsBtn];
        self.checkAllPicsBtn = checkAllPicsBtn;
    }
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.checkoutOriginalPic.cmp_centerX = self.view.width/2.f;
    self.checkoutOriginalPic.cmp_y = self.view.height - 80.f;
    
    self.checkAllPicsBtn.cmp_x = self.view.width - 50.f;
    self.checkAllPicsBtn.cmp_y = 60.f;
    
}

- (CMPPrintTools *)printTool {
    if (!_printTool) {
        _printTool = [[CMPPrintTools alloc] init];
    }
    return _printTool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self->_backgroundColor;
    [self addGesture];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(closeCurrentView:) name:CMPCloseCurrentViewAfterScanFinishedNoti object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateRotaion];
    
    
    if (self.hasDoneDelted) {
        [self hide];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self->_windowLevelByDefault = self.view.window.windowLevel;
    [self setStatusBarHide:YES];
    
    if (!self->_isFirstViewDidAppear) {
        
        [self updateLayoutOfSubViewsWithLayoutDirection:[YBIBLayoutDirectionManager getLayoutDirectionByStatusBar]];
        
        [self addSubViews];
        
        [self.browserView scrollToPageWithIndex:self->_currentIndex];
 
        self->_isFirstViewDidAppear = YES;

        [self addObserverForSystem];
    }
    
    id<YBImageBrowserCellDataProtocol> data = [self currentData];
    if ([data isMemberOfClass:[YBImageBrowseCellData class]]) {
        YBImageBrowseCellData *cellData = (YBImageBrowseCellData *)data;
        NSURL *url = cellData.extraData[@"originImageURL"];
        self.checkoutOriginalPic.hidden = [url.absoluteString isEqualToString:cellData.url.absoluteString];
        if (!cellData.url && !url) {
            self.checkoutOriginalPic.hidden = YES;
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setStatusBarHide:NO];
    self.allowRotation = self.isFromControllerAllowRotation;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.supportedOrientations;
}

- (void)setStatusBarHide:(BOOL)hide {
    if (self.shouldHideStatusBar) {
        self.view.window.windowLevel = hide ? UIWindowLevelStatusBar + 1 : _windowLevelByDefault;
    }
}

#pragma mark - gesture

- (void)addGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToLongPress:)];
    [self.view addGestureRecognizer:longPress];
}

- (void)respondsToLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self addActionSheet];
        if (self.delegate && [self.delegate respondsToSelector:@selector(yb_imageBrowser:respondsToLongPress:)]) {
            [self.delegate yb_imageBrowser:self respondsToLongPress:sender];
            return;
        }
        
        if (self.sheetView && (![[self currentData] respondsToSelector:@selector(yb_browserAllowShowSheetView)] || [[self currentData] yb_browserAllowShowSheetView])) {
            [self.view addSubview:self.sheetView];
            [self.sheetView yb_browserShowSheetViewWithData:[self currentData] layoutDirection:self->_layoutDirection containerSize:self->_containerSize];
        }
    }
}

- (void)addActionSheet {
    id data = [self currentData];
    NSMutableArray *sheetViewActions = [NSMutableArray array];
        
    if ([data isMemberOfClass:[YBImageBrowseCellData class]]) {
        YBImageBrowseCellData *cellData = (YBImageBrowseCellData *)data;
        if (cellData.extraData && [cellData.extraData isKindOfClass:[NSDictionary class]]) {
            if ([CMPFeatureSupportControl isShowFileShareButton]) {
                [sheetViewActions addObject:self.forwardAction];
            }
            if ([CMPFeatureSupportControl isSupportCollect]) {
                [sheetViewActions addObject:self.collectPhotoAction];
            }
            if (CMPCore.sharedInstance.serverIsLaterV8_0 && [CMPCommonTool detectQRCodeWithImage:cellData.image]) {
                [sheetViewActions addObject:self.qrCodeAction];
            }
            if ([CMPFeatureSupportControl imageBrowserShowOriginImg]) {
                if (![cellData.extraData[@"isOriginImage"] boolValue]) {
                    [sheetViewActions addObject:self.viewOriginalPhotoAction];
                }
            }
            if (self.canPrint && CMPFeatureSupportControl.isImageBrowserShowPrintPhoto) {
                [sheetViewActions addObject:self.printPhotoAction];
            }

            if (self.canSave) {
                [sheetViewActions addObject:self.saveAction];
            }
            self.customSheetView.actions = [sheetViewActions copy];
            self->_defaultSheetView = self.customSheetView;
            self->_sheetView = self.customSheetView;
        }
    }
}

#pragma mark - observe

- (void)removeObserverForSystem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)addObserverForSystem {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)didChangeStatusBarFrame {
    //ks fix -- ios16适配。注释掉，不然旋转有问题
//    if ([UIApplication sharedApplication].statusBarFrame.size.height > YBIB_HEIGHT_STATUSBAR) {
//        self.view.frame = CGRectMake(0, 0, self->_containerSize.width, self->_containerSize.height);
//    }
}

- (void)closeCurrentView:(NSNotification *)noti {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - private

- (void)addSubViews {
    [self.view addSubview:self.browserView];
    __weak typeof(self) wSelf = self;
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [wSelf.view addSubview:obj];
        if ([obj respondsToSelector:@selector(setYb_browserShowSheetViewBlock:)]) {
            [obj setYb_browserShowSheetViewBlock:^(id<YBImageBrowserCellDataProtocol> _Nonnull data) {
                if (wSelf.sheetView) {
                    [wSelf.view addSubview:wSelf.sheetView];
//                    __strong typeof(wSelf) sSelf = wSelf;
//                    [wSelf.sheetView yb_browserShowSheetViewWithData:data layoutDirection:self->_layoutDirection containerSize:self->_containerSize];
                }
            }];
        }
    }];
    [self initCustomViews];
}

- (void)updateLayoutOfSubViewsWithLayoutDirection:(YBImageBrowserLayoutDirection)layoutDirection {
    self->_layoutDirection = layoutDirection;
    CGSize containerSize = layoutDirection == YBImageBrowserLayoutDirectionHorizontal ? CGSizeMake(YBIMAGEBROWSER_HEIGHT, YBIMAGEBROWSER_WIDTH) : CGSizeMake(YBIMAGEBROWSER_WIDTH, YBIMAGEBROWSER_HEIGHT);
    self->_containerSize = containerSize;
    
    if (self.sheetView && self.sheetView.superview) {
        [self.sheetView yb_browserHideSheetViewWithAnimation:NO];
    }
    
    [self.browserView updateLayoutWithDirection:layoutDirection containerSize:containerSize];
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj yb_browserUpdateLayoutWithDirection:layoutDirection containerSize:containerSize];
    }];
}

- (void)pageIndexChanged:(NSUInteger)index {
    self->_currentIndex = index;
    
    id<YBImageBrowserCellDataProtocol> data = [self currentData];
    if ([data isMemberOfClass:[YBImageBrowseCellData class]]) {
        YBImageBrowseCellData *cellData = (YBImageBrowseCellData *)data;
        NSURL *url = cellData.extraData[@"originImageURL"];
        BOOL canNotAutoSave = [cellData.extraData[@"canNotAutoSave"] boolValue];
        self.checkoutOriginalPic.hidden = [url.absoluteString isEqualToString:cellData.url.absoluteString];
        if (self.checkoutOriginalPic.hidden && [CMPFeatureSupportControl isAutoSaveFile] && !canNotAutoSave) {
            [self saveImageToLocalWithUrl:url cellData:cellData];
        }
    }
    
    id sourceObj = nil;
    if ([data respondsToSelector:@selector(yb_browserCellSourceObject)]) {
        sourceObj = data.yb_browserCellSourceObject;
    }
    self.hiddenSourceObject = sourceObj;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(yb_imageBrowser:pageIndexChanged:data:)]) {
        [self.delegate yb_imageBrowser:self pageIndexChanged:index data:data];
    }
    
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (self.defaultToolBar && self.sheetView && [self.sheetView yb_browserActionsCount] >= 2) {
            self.defaultToolBar.operationType = YBImageBrowserToolBarOperationTypeMore;
        }
        
        if ([obj respondsToSelector:@selector(yb_browserPageIndexChanged:totalPage:data:)]) {
            [obj yb_browserPageIndexChanged:index totalPage:[self.dataSource yb_numberOfCellForImageBrowserView:self.browserView] data:data];
        }
    }];
}

- (void)saveImageToLocalWithUrl:(NSURL *)url cellData:(YBImageBrowseCellData *)cellData {
    return;//不自动保存了
    if (!self.canSave || cellData.isSavedToMyFile) return;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSData *imgData = [NSData dataWithContentsOfURL:url];
//        YBImage *img = [YBImage imageWithData:imgData];
        __weak typeof(cellData) weakCellData = cellData;
        cellData.loadLocalImageFinishBlock = ^(YBImage * _Nonnull image) {
            weakCellData.isSavedToMyFile = YES;
            YBImage *img = image;
            NSString *urlStr = url.absoluteString;
            NSString *sourceId = [NSString isNull:weakCellData.fileId]? [CMPCommonTool getSourceIdWithUrl:urlStr]:weakCellData.fileId;
            [CMPCommonTool.sharedTool saveImageToLocalWithImage:img imageData:img.imageData imgName:weakCellData.imgName from:weakCellData.from fromType:weakCellData.fromType fileId:sourceId isShowSavedTips:NO];
        };
    });
    
}

#pragma mark - public

- (void)setDataSource:(id<YBImageBrowserDataSource>)dataSource {
    self.browserView.yb_dataSource = dataSource;
}

- (id<YBImageBrowserDataSource>)dataSource {
    return self.browserView.yb_dataSource;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    if (currentIndex + 1 > [self.browserView.yb_dataSource yb_numberOfCellForImageBrowserView:self.browserView]) {
        YBIBLOG_ERROR(@"The index out of range.");
    } else {
        _currentIndex = currentIndex;
        if (self.browserView.superview) {
            [self.browserView scrollToPageWithIndex:currentIndex];
        }
    }
}

- (void)reloadData {
    [self.browserView yb_reloadData];
    [self.browserView scrollToPageWithIndex:self->_currentIndex];
    [self pageIndexChanged:self.browserView.currentIndex];
}

- (id<YBImageBrowserCellDataProtocol>)currentData {
    
    id<YBImageBrowserCellDataProtocol> data = [self.browserView currentData];
    
    return data;
}

- (void)show {
    if ([self.browserView.yb_dataSource yb_numberOfCellForImageBrowserView:self.browserView] <= 0) {
        YBIBLOG_ERROR(@"The data sources is invalid.");
        return;
    }
    [self showFromController:YBIBGetTopController()];
}

- (void)showFromController:(UIViewController *)fromController {
    //Preload current data.
    if (self.shouldPreload) {
        id<YBImageBrowserCellDataProtocol> needPreloadData = [self.browserView dataAtIndex:self.currentIndex];
        if ([needPreloadData respondsToSelector:@selector(yb_preload)]) {
            [needPreloadData yb_preload];
        }
        
        if (self.currentIndex == 0) {
            [self.browserView preloadWithCurrentIndex:self.currentIndex];
        }
    }
    
    self->_statusBarOrientationBefore = [UIApplication sharedApplication].statusBarOrientation;
    self.browserView.statusBarOrientationBefore = self->_statusBarOrientationBefore;
    [fromController presentViewController:self animated:YES completion:nil];

}

- (void)hide {
    [self dismissViewControllerAnimated:YES completion:^{
        self.rcImgModels = @[];
        self.dataSourceArray = @[];
        self.allRcImgModels = @[];
        self.allDataSourceArray = @[];
        self.delegate = nil;
        self.dataSource = nil;
        self.toolBars = @[];
        self.transitionManager = nil;
        self.forwardAction = nil;
        self.collectPhotoAction = nil;
        self.saveAction = nil;
        self.qrCodeAction = nil;
        [self.browserView removeAllSubviews];
        self.browserView.yb_delegate = nil;
        self.browserView.yb_dataSource = nil;
        [self.browserView removeFromSuperview];
        self.browserView = nil;
        NSLog(@"");
    }];
}

- (void)setDistanceBetweenPages:(CGFloat)distanceBetweenPages {
    _distanceBetweenPages = distanceBetweenPages;
    ((YBImageBrowserViewLayout *)self.browserView.collectionViewLayout).distanceBetweenPages = distanceBetweenPages;
}

- (BOOL)transitioning {
    return self.transitionManager.transitioning;
}

- (void)setGiProfile:(YBIBGestureInteractionProfile *)giProfile {
    _giProfile = giProfile;
    self.browserView.giProfile = giProfile;
}

- (void)setDataCacheCountLimit:(NSUInteger)dataCacheCountLimit {
    _dataCacheCountLimit = dataCacheCountLimit;
    self.browserView.cacheCountLimit = dataCacheCountLimit;
}

- (void)setShouldPreload:(BOOL)shouldPreload {
    _shouldPreload = shouldPreload;
    self.browserView.shouldPreload = shouldPreload;
}


#pragma mark - internal

- (void)setHiddenSourceObject:(id)hiddenSourceObject {
    if (!self->_autoHideSourceObject) return;
    if (_hiddenSourceObject && [_hiddenSourceObject respondsToSelector:@selector(setHidden:)]) {
        [_hiddenSourceObject setValue:@(NO) forKey:@"hidden"];
    }
    if (hiddenSourceObject && [hiddenSourceObject respondsToSelector:@selector(setHidden:)]) {
        [hiddenSourceObject setValue:@(YES) forKey:@"hidden"];
    }
    _hiddenSourceObject = hiddenSourceObject;
}

#pragma mark <UIViewControllerTransitioningDelegate>

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.transitionManager;
}

#pragma mark - <YBImageBrowserViewDelegate>

- (void)yb_imageBrowserViewDismiss:(YBImageBrowserView *)browserView {
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    if ([UIApplication sharedApplication].statusBarOrientation != self->_statusBarOrientationBefore && [[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        NSInteger val = self->_statusBarOrientationBefore;
        [invocation setArgument:&val atIndex:2];
        self->_isRestoringDeviceOrientation = YES;
        //[invocation invoke];
    }
    
    [self hide];
}

- (void)yb_imageBrowserView:(YBImageBrowserView *)browserView changeAlpha:(CGFloat)alpha duration:(NSTimeInterval)duration {
    void (^animationsBlock)(void) = ^{
        self.view.backgroundColor = [self->_backgroundColor colorWithAlphaComponent:alpha];
    };
    void (^completionBlock)(BOOL) = ^(BOOL x){
        if (alpha == 1) [self setStatusBarHide:YES];
        if (alpha < 1) [self setStatusBarHide:NO];
    };
    if (duration <= 0) {
        animationsBlock();
        completionBlock(YES);
    } else {
        [UIView animateWithDuration:duration animations:animationsBlock completion:completionBlock];
    }
}

- (void)yb_imageBrowserView:(YBImageBrowserView *)browserView pageIndexChanged:(NSUInteger)index {
    [self pageIndexChanged:index];
}

- (void)yb_imageBrowserView:(YBImageBrowserView *)browserView hideTooBar:(BOOL)hidden {
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = hidden;
    }];
    if (self.sheetView && self.sheetView.superview && hidden) {
        [self.sheetView yb_browserHideSheetViewWithAnimation:YES];
    }
}

#pragma mark - <YBImageBrowserDataSource>

- (NSUInteger)yb_numberOfCellForImageBrowserView:(YBImageBrowserView *)imageBrowserView {
    return self.dataSourceArray.count;
}

- (id<YBImageBrowserCellDataProtocol>)yb_imageBrowserView:(YBImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
    return self.dataSourceArray[index];
}

#pragma mark - getter

- (YBImageBrowserView *)browserView {
    if (!_browserView) {
        _browserView = [YBImageBrowserView new];
        _browserView.yb_delegate = self;
        _browserView.yb_dataSource = self;
        _browserView.giProfile = [YBIBGestureInteractionProfile new];
    }
    return _browserView;
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
     __weak typeof(self) wSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        __strong typeof(self) sSelf = wSelf;
        YBImageBrowserLayoutDirection layoutDirection = [YBIBLayoutDirectionManager getLayoutDirectionByStatusBar];
        if (layoutDirection == YBImageBrowserLayoutDirectionUnknown || sSelf.transitionManager.transitioning || sSelf->_isRestoringDeviceOrientation) return;
        [sSelf updateLayoutOfSubViewsWithLayoutDirection:layoutDirection];
    } completion:nil];
    
}

- (YBIBTransitionManager *)transitionManager {
    if (!_transitionManager) {
        _transitionManager = [YBIBTransitionManager new];
        _transitionManager.imageBrowser = self;
    }
    return _transitionManager;
}

- (void)setAllowRotation:(BOOL)allowRotation
{
    _allowRotation = allowRotation;
    [self updateRotaion];
}

- (void)updateRotaion
{
    
    CMPAppDelegate *aAppDelegate = (CMPAppDelegate *)[UIApplication sharedApplication].delegate;
    aAppDelegate.allowRotation = _allowRotation;
    if (!aAppDelegate.allowRotation) {
        [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    }
}

#pragma mark - 按钮点击

/// 查看原图按钮点击
- (void)checkoutOriginalPicClicked {
    CMPFuncLog;
    id<YBImageBrowserCellDataProtocol> data = [self currentData];
    if ([data isMemberOfClass:[YBImageBrowseCellData class]]) {
        YBImageBrowseCellData *cellData = (YBImageBrowseCellData *)data;
        [cellData setValue:nil forKey:@"image"];
        cellData.url = (NSURL *)cellData.extraData[@"originImageURL"];
        [cellData yb_preload];
        self.checkoutOriginalPic.hidden = YES;
        [self cmp_showHUDWithText:SY_STRING(@"review_image_viewOriginalPhoto_tip")];

        //保存原图
        if ([CMPFeatureSupportControl isAutoSaveFile]) {
            [self saveImageToLocalWithUrl:cellData.url cellData:cellData];
        }
    }
}

/// 查看所有图片按钮点击
- (void)checkAllPicsClicked {
    CMPFuncLog;
    NSArray *dataArr = [CMPPicListViewController groupDataArray:self.allDataSourceArray];
    CMPPicListViewController *picListVc = CMPPicListViewController.alloc.init;
    picListVc.originalDataArray = [self.allDataSourceArray.cmp_convertArrar mutableCopy];
    picListVc.dataArray = [dataArr mutableCopy];
    picListVc.canSave = self.canSave;
    picListVc.rcImgModels = [self.allRcImgModels.cmp_convertArrar mutableCopy];
    [self presentViewController:picListVc animated:YES completion:nil];
    
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    return SY_STRING(@"screeenshot_page_title_image_browser");
}

@end
