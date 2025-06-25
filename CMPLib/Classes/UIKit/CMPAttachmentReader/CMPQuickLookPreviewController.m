//
//  CMPQuickLookPreviewController.m
//  CMPLib
//
//  Created by 程昆 on 2020/7/7.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPQuickLookPreviewController.h"
#import <CMPLib/AttachmentReaderParam.h>
#import <CMPLib/CMPDownloadAttachmentTool.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/NSURL+CMPURL.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPBannerNavigationBar.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPPrintTools.h>
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPCommonWebViewController.h>
#import <CMPLib/KSSysShareManager.h>
#import <Webkit/WKWebView.h>
#import <CMPLib/UIDevice+TFDevice.h>

typedef NS_ENUM(NSInteger, CMPPreviewOpenFileErrorType) {
    CMPPreviewOpenFileErrorTypeUnknown     = 0,
    CMPPreviewOpenFileErrorTypeUnZipFail   = 1,
};

@interface CMPQuickLookPreviewController ()

@end

@interface CMPQuickLookPreviewController()<QLPreviewControllerDataSource,UIGestureRecognizerDelegate,UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) QLPreviewController *previewController;
@property (nonatomic, strong) UIDocumentInteractionController *fileInteractionController;

@property (nonatomic, strong) CMPDownloadAttachmentTool *downloadTool;
@property (nonatomic, strong) CMPPrintTools *printTool;

@property (nonatomic, strong) NSMutableArray *portraitRightItems;
@property (nonatomic, strong) NSMutableArray *landscapeRightItems;

@property (nonatomic, assign) BOOL isShowStatusbar;
@property (nonatomic, assign) BOOL isStartFullScreen;
@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic,strong)UIPanGestureRecognizer *pPanGesture;
@property (nonatomic,strong) CMPCommonWebViewController *webviewCtrl;
@end

@implementation CMPQuickLookPreviewController

#pragma mark – Life Cycle

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    [self setupRotationAndStatusbarStatus];
    [self setBannerTitle];
    [self setUpPreviewControllerView];
    [self setUpNotificationObserver];
    
    [self handleAttParam];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self setUpPreviewControllerViewFrame];
}

#pragma mark – Override

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    if (self.viewLoaded) {
        if (INTERFACE_IS_PHONE) {
            //[self setPanGesturEnabled:YES];
            if (DeviceInterfaceOrientationIsPortrait()) {
                [self.bannerNavigationBar setRightBarButtonItems:self.portraitRightItems];
                [self showNavBar:YES animated:NO];
            }else{
                [self.bannerNavigationBar setRightBarButtonItems:self.landscapeRightItems];
                [self showNavBar:YES animated:NO];
            }
        }
    }
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)showNavBar:(BOOL)isShow animated:(BOOL)animated{
    if (INTERFACE_IS_PHONE) {
        if (isShow) {
            if (DeviceInterfaceOrientationIsPortrait()) {
                self.isShowStatusbar = YES;
            }else {
                self.isShowStatusbar = NO;
            }
        }else{
            self.isShowStatusbar = NO;
        }
        [self setNeedsStatusBarAppearanceUpdate];
    }
    [super showNavBar:isShow animated:animated];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationSlide;
}
 
#pragma mark - Button Action Events

- (void)thirdAppOpenButtonAction:(UIButton *)sender {
    if (self.attReaderParam.filePath) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSURL *file_URL = [NSURL URLWithPathString:self.attReaderParam.filePath];
        if ([fileManager fileExistsAtPath:file_URL.path]) {
            if (!self.fileInteractionController) {
                self.fileInteractionController = [UIDocumentInteractionController interactionControllerWithURL:file_URL];
            } else {
                self.fileInteractionController.URL = file_URL;
            }
            self.fileInteractionController.delegate = self;
            [self.fileInteractionController presentOpenInMenuFromRect:sender.frame inView:self.view animated:YES];
            [self beginShowInThirdApp];
        }
    }
}

- (void)shareButtonAction:(UIButton *)sender {
    
    NSMutableArray *notShowArr = NSMutableArray.array;
    [notShowArr addObject:CMPShareComponentDownloadString];
    [notShowArr addObject:CMPShareComponentQQString];
    if (!self.attReaderParam.isShowPrintBtn) [notShowArr addObject:CMPShareComponentPrintString];
    if (!self.attReaderParam.canShowInThirdApp) [notShowArr addObject:CMPShareComponentOtherString];
    
    CMPFileManagementRecord *mfr = CMPFileManagementRecord.alloc.init;
    mfr.filePath = self.attReaderParam.filePath;
    mfr.fileSize = self.attReaderParam.fileSize;
    mfr.fileId = self.attReaderParam.fileId;
    mfr.fileName = self.attReaderParam.fileName;
    mfr.fileUrl = self.attReaderParam.url;
    mfr.lastModify = [self.attReaderParam.lastModified respondsToSelector:@selector(longLongValue)]? self.attReaderParam.lastModified.longLongValue:0;
    mfr.from = self.attReaderParam.from;
    mfr.fromType = self.attReaderParam.fromType;
    mfr.origin = self.attReaderParam.origin;
    mfr.notShowShareIcons = notShowArr;
    mfr.isUc = self.attReaderParam.isUc;
//    NSDictionary *obj = @{@"mfr" : mfr,@"pushVC" : self, @"webview" :self.previewController.view};
    NSDictionary *obj = @{@"mfr" : mfr,@"pushVC" : self};
    [NSNotificationCenter.defaultCenter postNotificationName:CMPAttachReaderShareClickedNoti object:obj];
}

- (void)saveButtonAction:(UIButton *)sender {
    void(^blk)(void) = ^{
        NSInteger attType = [CMPFileManager getFileType:self.attReaderParam.filePath];
        if (attType == QK_AttchmentType_Image) {
            //是图片就保存到相册
            [CMPDevicePermissionHelper permissionsForPhotosTrueCompletion:^{
                [self saveImageToPhotosAlbum:self.attReaderParam.filePath];
            } falseCompletion:^{
            } showAlert:YES];
        }
        else {
            [self saveToMyFile];
            [self showToastWithText:SY_STRING(@"common_save_success")];
        }
    };
    if ([NSString isNotNull:self.attReaderParam.filePath] && [[NSFileManager defaultManager] fileExistsAtPath:self.attReaderParam.filePath]) {
        blk();
    }else{
        [self _downloadFile:^(NSString *localPath, NSError *err) {
            if (!err) {
                blk();
            }
        }];
    }
}

- (void)printButtonAction:(UIButton *)button {
    long long fileSize = [CMPFileManager fileSizeAtPath:self.attReaderParam.filePath];
    long long maxFileSize = 15 * 1024 * 1024;
    if (fileSize > maxFileSize) {
        [self showToastWithText:SY_STRING(@"print_more_than_size")];
        return;
    }
    [self.printTool printWithFilePath:self.attReaderParam.filePath webview:nil success:^{
        
    } fail:^(NSError *error) {
        
    }];
}

- (void)rotateButtonAction:(UIButton *)button {
    if (@available(iOS 16.0, *)) {
        SEL ss = NSSelectorFromString(@"setNeedsUpdateOfSupportedInterfaceOrientations");
        if (self && [self respondsToSelector:ss]) {
            [self performSelector:ss];
        }
    }
    [UIDevice newApiForSetOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)closeRotateButtonAction:(UIButton *)button {
    if (@available(iOS 16.0, *)) {
        SEL ss = NSSelectorFromString(@"setNeedsUpdateOfSupportedInterfaceOrientations");
        if (self && [self respondsToSelector:ss]) {
            [self performSelector:ss];
        }
    }
    [UIDevice newApiForSetOrientation:UIInterfaceOrientationPortrait];
}

- (void)fullScreenAction:(UIButton *)button {
    [self.splitViewController cmp_switchFullScreen];
    [self.portraitRightItems replaceObjectAtIndex:self.portraitRightItems.count -1  withObject:[self closeFullScreenButton]];
    [self.bannerNavigationBar setRightBarButtonItems:self.portraitRightItems];
    self.isFullScreen = YES;
}

- (void)closeFullScreenButtonAction:(UIButton *)button {
    [self.splitViewController cmp_switchSplitScreen];
    [self.portraitRightItems replaceObjectAtIndex:self.portraitRightItems.count -1  withObject:[self fullScreenButton]];
    [self.bannerNavigationBar setRightBarButtonItems:self.portraitRightItems];
    self.isFullScreen = NO;
}

- (void)backBarButtonAction:(id)sender {
    [self.downloadTool cancelDownloadWithFileId:self.attReaderParam.fileId];
    
    if (CMP_IPAD_MODE && [self.splitViewController cmp_isFullScreen] && !self.isStartFullScreen) {
        [self closeFullScreenButtonAction:nil];
        return ;
    }
    
    [super backBarButtonAction:sender];
}

#pragma mark - Notification Action Events

//旋转横屏通知处理方法
- (void)splitVCDidBecomeLandscape {
    if (self.isFullScreen) {
        //当为全屏的时候，就在旋转完后设置成全屏状态
        [self fullScreenAction:nil];
    }
}
 
#pragma mark – Private Methods

- (void)setupRotationAndStatusbarStatus {
    self.allowRotation = YES;
    if (DeviceInterfaceOrientationIsPortrait()) {
        self.isShowStatusbar = YES;
    }else{
        self.isShowStatusbar = NO;
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setBannerTitle {
    if (CMPCore.sharedInstance.serverIsLaterV8_0) {
        [self setTitle:self.attReaderParam.fileName];
    } else {
        if (INTERFACE_IS_PAD) {
            [self setTitle:SY_STRING(@"common_read")];
        } else {
            [self setTitle:@""];
        }
    }
}

- (void)setUpPreviewControllerView {
    [self.view addSubview:self.previewController.view];
    [self addChildViewController:self.previewController];
}

- (void)setUpPreviewControllerViewFrame {
    self.previewController.view.frame = self.view.bounds;
    self.previewController.view.cmp_y = self.bannerNavigationBar.cmp_bottom;
    self.previewController.view.cmp_height = self.view.height - self.previewController.view.cmp_y;
}

- (void)setUpNotificationObserver {
     [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(splitVCDidBecomeLandscape) name:CMPSplitViewContrllerDidBecomeLandscapeNoti object:nil];
}

- (void)setUpGestureRecognizer {
     if ([CMPFeatureSupportControl isSupportImageLongPress]) {
         [self addLongPressIndentifyImage];
     }
}

- (void)handleAttParam {
    AttachmentReaderParam *attReaderParam = self.attReaderParam;
    if ([NSString isNotNull:attReaderParam.filePath]
        && [[NSFileManager defaultManager] fileExistsAtPath:attReaderParam.filePath]
        ) {
        [self startRead:attReaderParam.filePath];
        return;
    }
    
    NSString *urlStr = attReaderParam.url;
    NSURL *url = [NSURL URLWithPathString:urlStr];
    if (url.isFileURL) {
        [self startRead:urlStr];
        return;
    }
    
    [self downloadFileAndRead];
}

- (void)downloadFileAndRead {
    AttachmentReaderParam *attReaderParam = self.attReaderParam;
    NSString *handledFileName = [self.attReaderParam.fileName handleFileNameSpecialCharactersAtPath];
    NSString *fileId = attReaderParam.fileId;
    if ([NSString isNull:fileId]) {
         [self showToastWithText:SY_STRING(@"common_downloadFileFailed")];
         return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    void(^blk)(void) = ^{
        [weakSelf.downloadTool cancelDownloadWithFileId:attReaderParam.fileId];
        
        [weakSelf.downloadTool downloadWithFileID:fileId fileName:handledFileName lastModified:attReaderParam.lastModified url:attReaderParam.url start:^{
            [weakSelf showLoadingView];
        } progressUpdateWithExt:^(float progress, NSInteger recieveBytes, NSInteger totalBytes) {
            
        } success:^(NSString *localPath) {
            [weakSelf startRead:localPath];
            [weakSelf callbackDelegateWithSucess:YES message:localPath];
            [weakSelf hideLoadingView];
            [weakSelf actionAfterFileDownload];
        } fail:^(NSError *error) {
            [weakSelf hideLoadingView];
            [weakSelf showToastWithText:SY_STRING(@"common_downloadFileFailed")];
            [weakSelf callbackDelegateWithSucess:NO message:error.debugDescription];
        }];
    };
    
    [self actionBeforeDownloadWithResult:blk];
    
}

//ks add -- 8.1sp2为了在线预览的功能添加的单纯下载方法，用于在线预览点击保存时文件没有下载的情况下使用，没有和以前的逻辑混合
-(void)_downloadFile:(void(^)(NSString *localPath,NSError *err))result
{
    if (!result) {
        return;
    }
    AttachmentReaderParam *attReaderParam = self.attReaderParam;
    NSString *handledFileName = [self.attReaderParam.fileName handleFileNameSpecialCharactersAtPath];
    NSString *fileId = attReaderParam.fileId;
    if ([NSString isNull:fileId]) {
        [self showToastWithText:SY_STRING(@"common_downloadFileFailed")];
        result(nil,[NSError errorWithDomain:SY_STRING(@"common_downloadFileFailed") code:-1001 userInfo:nil]);
         return;
    }
    
    [self.downloadTool cancelDownloadWithFileId:attReaderParam.fileId];
    
    [self.downloadTool downloadWithFileID:fileId fileName:handledFileName lastModified:attReaderParam.lastModified url:attReaderParam.url start:^{
        [self showLoadingView];
    } progressUpdateWithExt:^(float progress, NSInteger recieveBytes, NSInteger totalBytes) {
        
    } success:^(NSString *localPath) {
        [self hideLoadingView];
        self.attReaderParam.filePath = localPath;
        self.attReaderParam.fileName = localPath.lastPathComponent.originalFileNameSpecialCharactersAtPath;
        result(localPath,nil);
    } fail:^(NSError *error) {
        [self hideLoadingView];
        [self showToastWithText:SY_STRING(@"common_downloadFileFailed")];
        result(nil,error);
    }];
}

-(void)actionBeforeDownloadWithResult:(void(^)(void))rslt
{
    if (rslt) {
        rslt();
    }
}

-(void)actionAfterFileDownload
{
    
}

- (void)startRead:(NSString *)aPath {
    if ([NSString isNull:aPath]) {
        [self showOpenFileErrorTypeAndFilterButton:CMPPreviewOpenFileErrorTypeUnZipFail];
        return;
    }
    
    // 更新文件路径
    self.attReaderParam.filePath = aPath;
    self.attReaderParam.fileName = aPath.lastPathComponent.originalFileNameSpecialCharactersAtPath;
    NSInteger attType = [CMPFileManager getFileType:aPath];
    
    [self setBannerTitle];
    
    //是自动保存，需求是只要打开了附件都要记录到我的文件
    if (self.attReaderParam.autoSave) {
        [self saveToMyFile];
    }
    
    //这儿来判断文件是否支持打印，防止下载的文件后缀名改了
    if (self.attReaderParam.isShowPrintBtn) {
        if (attType != QK_AttchmentType_Office_Doc &&
            attType != QK_AttchmentType_Office_Excel &&
            attType != QK_AttchmentType_Office_PPt &&
            attType != QK_AttchmentType_Office_Pdf) {
            self.attReaderParam.isShowPrintBtn = NO;
        }
    }
    //显示导航按钮
    [self customSetupBannerButtons];
    
    if (![QLPreviewController canPreviewItem:[NSURL URLWithPathString:aPath]]) {
        [self showOpenFileErrorTypeAndFilterButton:CMPPreviewOpenFileErrorTypeUnknown];
        return;
    }
    
    BOOL aEditMode = self.attReaderParam.editMode;
    NSDictionary *param = @{@"edit":[NSNumber numberWithBool:aEditMode],@"path":aPath};
    
    if (aEditMode) {
        if (attType == QK_AttchmentType_Image || attType == QK_AttchmentType_Office_Other || attType == QK_AttchmentType_Gif) {
            [self.previewController reloadData];
            return;
        }else if(attType == QK_AttchmentType_Office_Doc){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingWPSNotificationName object:param];
        }else if(attType == QK_AttchmentType_Office_Excel){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingExcelNotificationName object:param];
        }else if(attType == QK_AttchmentType_Office_PPt){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingPPtNotificationName object:param];
        }else if(attType == QK_AttchmentType_Office_Pdf){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingPdfNotificationName object:param];
        }else if (attType == QK_AttchmentType_WPS){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingWPSNotificationName object:param];
        }else if(attType == QK_AttchmentType_ET){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingExcelNotificationName object:param];
        }
        [self performSelector:@selector(backBarButtonAction:) withObject:nil afterDelay:1];
        return;
    }
    
    NSSet *officeSet = [NSSet setWithObjects:
                        @(QK_AttchmentType_WPS),
                        @(QK_AttchmentType_Office_Doc),
                        @(QK_AttchmentType_Office_Excel),
                        @(QK_AttchmentType_Office_PPt),
                        @(QK_AttchmentType_Office_Pdf),
                        @(QK_AttchmentType_Office_Other), nil];
    if ([officeSet containsObject:@(attType)]) {
        NSURL *url = [NSURL fileURLWithPath:aPath];
        [self webviewCtrlLoadUrl:url];
    }
//    else{
        [self.previewController reloadData];
//    }
}

-(void)webviewCtrlLoadUrl:(NSURL *)url
{
    if (url) {
        __weak typeof(self) wSelf = self;
        if (_webviewCtrl) {
            [_webviewCtrl.view removeFromSuperview];
            [_webviewCtrl removeFromParentViewController];
            _webviewCtrl = nil;
        }
        self.webviewCtrl.url = url;
        self.webviewCtrl.loadResultBlk = ^(id  _Nonnull obj, NSError * _Nonnull error, id  _Nonnull ext) {
            if (error) {
                
                UILabel *tipLb = [[UILabel alloc] init];
                tipLb.textColor = [UIColor lightGrayColor];
                tipLb.font = [UIFont systemFontOfSize:22];
                tipLb.numberOfLines = 0;
                tipLb.textAlignment = NSTextAlignmentCenter;
                tipLb.text = @"请通过第三方APP打开文件\n建议使用WPS";
                [tipLb sizeToFit];
                [wSelf.view addSubview:tipLb];
                [tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.offset(0);
                    make.centerY.offset(-80);
                }];
                
                UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [shareBtn setTitle:@"第三方APP打开" forState:UIControlStateNormal];
                [shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                shareBtn.backgroundColor = [UIColor cmp_colorWithName:@"theme-bgc"];
                shareBtn.layer.cornerRadius = 8;
                shareBtn.titleLabel.numberOfLines = 0;
                shareBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
                shareBtn.titleLabel.font = [UIFont systemFontOfSize:20];
                [shareBtn addTarget:wSelf action:@selector(_sysShareAct:) forControlEvents:UIControlEventTouchUpInside];
                [wSelf.view addSubview:shareBtn];
                [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.offset(0);
                    make.centerY.offset(80);
                    make.size.mas_equalTo(CGSizeMake(180, 40));
                }];
                if ([obj isKindOfClass:WKWebView.class]) {
                    [((WKWebView *)obj) removeFromSuperview];
                }
                //ks fix -- V5-39265【Xcode14+ios16】查看大于50M的文件，提示页面文字重叠
                if (wSelf.previewController && wSelf.previewController.parentViewController) {
                    wSelf.previewController.view.hidden = YES;
                }
            }
        };
        [self addChildViewController:self.webviewCtrl];
        [self.view addSubview:self.webviewCtrl.view];
//        [self.webviewCtrl.view mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.offset(0);
//        }];
        self.webviewCtrl.view.frame = CGRectZero;
        [self.view sendSubviewToBack:_webviewCtrl.view];
    }
}

-(void)_sysShareAct:(UIButton *)sender
{
    [[KSSysShareManager shareInstance] presentDocumentInteractionInView:self.view withLocalPath:self.attReaderParam.filePath displayName:self.attReaderParam.fileName];
}

-(CMPCommonWebViewController *)webviewCtrl
{
    if (!_webviewCtrl) {
        _webviewCtrl = [[CMPCommonWebViewController alloc] init];
        _webviewCtrl.needNav = NO;
    }
    return _webviewCtrl;
}

//获取到文件才显示按钮
- (void)customSetupBannerButtons {
    NSMutableArray *rightButton = [NSMutableArray array];
    NSMutableArray *landscapeRightButton = [NSMutableArray array];
    if (self.attReaderParam.isShowShareBtn) {
        [rightButton addObject:[self shareButton]];
    } else {
        if (self.attReaderParam.canDownload) {
            [rightButton addObject:[self saveButton]];
        }
        if (self.attReaderParam.isShowPrintBtn) {
            [rightButton addObject:[self printButton]];
        }
        if (self.attReaderParam.canShowInThirdApp) {
            [rightButton addObject:[self thirdAppOpenButton]];
        }
    }
    
    [landscapeRightButton addObjectsFromArray:rightButton];
    
    if ([CMPCore sharedInstance].allowRotation && INTERFACE_IS_PHONE) {//低版本兼容
        [rightButton addObject:[self rotateButton]];
    }
    
    if (CMP_IPAD_MODE) {
        if ([self.splitViewController cmp_isFullScreen]) {
            self.isStartFullScreen = YES;
            [rightButton addObject:[self closeFullScreenButton]];
        }else {
            self.isStartFullScreen = NO;
            [rightButton addObject:[self fullScreenButton]];
        }
    }
    
    self.bannerNavigationBar.rightViewsMargin = 0;
    
    self.portraitRightItems = [NSMutableArray arrayWithArray:rightButton];
    if (INTERFACE_IS_PHONE) {
        //[self setPanGesturEnabled:YES];
        [landscapeRightButton addObject:[self closeRotateButton]];
        self.landscapeRightItems = [NSMutableArray arrayWithArray:landscapeRightButton];
        if (DeviceInterfaceOrientationIsPortrait()) {
            [self showNavBar:YES animated:NO];
            [self.bannerNavigationBar setRightBarButtonItems:self.portraitRightItems];
        } else{
            [self showNavBar:YES animated:NO];
            [self.bannerNavigationBar setRightBarButtonItems:self.landscapeRightItems];
        }
    }else if (INTERFACE_IS_PAD){
        [self.bannerNavigationBar setRightBarButtonItems:self.portraitRightItems];
    }
}

//创建第三方打开按钮
- (UIButton *)thirdAppOpenButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_more_button" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(thirdAppOpenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//创建分享按钮
- (UIButton *)shareButton {
    UIButton *button = [UIButton buttonWithImageName:@"share_component_share_icon" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//创建保存按钮
- (UIButton *)saveButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_save_button" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//创建打印按钮
- (UIButton *)printButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_print" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(printButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//创建旋转按钮
- (UIButton *)rotateButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_switch_direction" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(rotateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//创建关闭按钮
- (UIButton *)closeRotateButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_close_rotate" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(closeRotateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//创建全屏按钮
- (UIButton *)fullScreenButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_switch_direction" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//创建关闭按钮
- (UIButton *)closeFullScreenButton  {
    UIButton *button = [UIButton buttonWithImageName:@"banner_close_rotate" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(closeFullScreenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

// 保存到我的文件
- (void)saveToMyFile {
    NSString *aFileId = self.attReaderParam.fileId;
    if ([NSString isNull:aFileId]) {// TODO
        aFileId = [self.attReaderParam.url sha1];
    }
    CMPFile *aFile = [[CMPFile alloc] init];
    aFile.fileID = aFileId;
    aFile.fileName = self.attReaderParam.fileName;
    aFile.filePath = self.attReaderParam.filePath;
    aFile.lastModified = self.attReaderParam.lastModified;
    aFile.origin = self.attReaderParam.origin;
    aFile.from = self.attReaderParam.from;
    aFile.fromType = self.attReaderParam.fromType;
    [CMPFileManager.defaultManager saveFile:aFile];
}

 // 实现图片长按识别功能
- (void)addLongPressIndentifyImage {
    UILongPressGestureRecognizer* longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressed.delegate = self;
    [self.view addGestureRecognizer:longPressed];
}

// 长按识别图中二维码
- (void)longPressed:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    NSInteger attType = [CMPFileManager getFileType:self.attReaderParam.filePath];
    if (attType == QK_AttchmentType_Image) {
        [self showImageOptions];
    }
}

- (void)showImageOptions {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *filePath = self.attReaderParam.filePath;
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:data];
    
    NSArray *features = [CMPCommonTool scanQRCodeWithImage:image];
    
    // 识别图中二维码
    UIAlertAction *judgeCode = [UIAlertAction actionWithTitle:SY_STRING(@"review_image_recognizeQRCode_in_pic") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableDictionary *params = NSMutableDictionary.dictionary;
        params[@"vc"] = self;
        params[@"scanImage"] = image;
        [NSNotificationCenter.defaultCenter postNotificationName:CMPShowBlankScanVCNoti object: params];
    }];
    
    // 保存图片到手机
    UIAlertAction *saveImage = [UIAlertAction actionWithTitle:SY_STRING(@"common_save") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveImageToPhotosAlbum:filePath];
    }];
    
    // 取消
    UIAlertAction *cancell = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    
    if (features.count >= 1) {
        [alertController addAction:judgeCode];
    }
    
    [alertController addAction:saveImage];
    [alertController addAction:cancell];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

// 保存到相册
- (void)saveImageToPhotosAlbum:(NSString *)aPath {
    //保存到相册
    UIImage* image = [UIImage imageWithContentsOfFile:aPath];
    if (!image) { //V5-13429【Xcode13 打版】新建自由协同，在协同附件中，选择本地相册中的图片，点击下载时提示保存失败
        NSString *fileName = [aPath componentsSeparatedByString:@"/tmp/"].lastObject;
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:fileName];
        image = [UIImage imageWithContentsOfFile:filePath];
    }
    [CMPCommonTool.sharedTool savePhotoWithImage:image target:self action:@selector(image:didFinishSavingWithError:contextInfo:)];
}

// 功能：显示图片保存结果
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error){
        [self showToastWithText:SY_STRING(@"common_save_fail")];
    }else {
        [self showToastWithText:SY_STRING(@"common_save_success")];
    }
}

- (void)beginShowInThirdApp {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ThirdAppMenuWillShow object:nil];
}

- (void)endShowInThirdApp {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ThirdAppMenuWillHide object:nil];
}

- (void)callbackDelegateWithSucess:(BOOL)sucess
                           message:(NSString *)message {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(quickLookPreviewController:sucess:message:)]) {
        [self.customDelegate quickLookPreviewController:self sucess:sucess message:message];
    }
}

- (void)showLoadingView {
    [self showLoadingViewWithText:SY_STRING(@"common_table_loading")];
}

- (void)showLoadingViewWithText:(NSString *)aStr {
    UIView *view = self.view;
    CGFloat yOffset = (view.height - self.previewController.view.height)/2;
    yOffset = self.bannerNavigationBar.cmp_bottom * 0.5;
    [self cmp_showProgressHUDInView:view yOffset:yOffset];
}

- (void)hideLoadingView {
    [self cmp_hideProgressHUD];
}

- (void)showOpenFileErrorTypeAndFilterButton:(CMPPreviewOpenFileErrorType)type {
    NSMutableArray *rightButton = [NSMutableArray array];
    if (type == CMPPreviewOpenFileErrorTypeUnknown) {
        if (self.attReaderParam.isShowShareBtn) {
            //OA-210846 M3-iOS端：zip格式数据，保存到我的文件，没有其他应用打开的功能入口
            //特殊需求，如果不支持的格式，只显示第三方打开按钮，不显示分享按钮
            [rightButton addObject:[self thirdAppOpenButton]];
        }else if (self.attReaderParam.canShowInThirdApp) {
            [rightButton addObject:[self thirdAppOpenButton]];
        }
    }
    [self.bannerNavigationBar setRightBarButtonItems:rightButton];
    [self showOpenFileErrorType:type];
}

- (void)showOpenFileErrorType:(CMPPreviewOpenFileErrorType)type {
    CGFloat k_unknownLabel_marginEdge = 40;
    CGFloat k_unknownLabel_height = 40;
    
    UIView *unkownFileTypeView = [[UIView alloc] initWithFrame:self.view.bounds];
    unkownFileTypeView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    [self.previewController.view addSubview:unkownFileTypeView];
    
    UILabel *unkownFileTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_unknownLabel_marginEdge, unkownFileTypeView.center.y - 30, unkownFileTypeView.bounds.size.width - k_unknownLabel_marginEdge * 2, k_unknownLabel_height)];
    [unkownFileTypeView addSubview:unkownFileTypeLabel];
    if (type == CMPPreviewOpenFileErrorTypeUnknown) {
        unkownFileTypeLabel.text = SY_STRING(@"offlineFiles_unknownFiles");
    } else if (type == CMPPreviewOpenFileErrorTypeUnZipFail) {
        unkownFileTypeLabel.text = SY_STRING(@"offlineFiles_unzipFail");
    }
    unkownFileTypeLabel.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
    unkownFileTypeLabel.adjustsFontSizeToFitWidth = YES;
    unkownFileTypeLabel.numberOfLines = 2;
    unkownFileTypeLabel.textAlignment = NSTextAlignmentCenter;
    
    [unkownFileTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(k_unknownLabel_marginEdge);
//        make.trailing.mas_equalTo(-k_unknownLabel_marginEdge);
        make.center.equalTo(self.previewController.view);
    }];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSURL *url = nil;
    if (!self.attReaderParam.filePath) {
        url = [[NSBundle mainBundle] URLForResource:@"m3-quick-look-blank-content-page" withExtension:@"txt"];
    } else {
        url = [NSURL URLWithPathString:self.attReaderParam.filePath];
    }
    return url;
}
 
#pragma mark - Custom Delegates
 
#pragma mark – Getters and Setters

- (QLPreviewController *)previewController {
    if (!_previewController) {
        _previewController = [[QLPreviewController alloc] init];
        _previewController.dataSource = self;
    }
    return _previewController;
}

- (CMPDownloadAttachmentTool *)downloadTool {
    if (!_downloadTool) {
        _downloadTool = [[CMPDownloadAttachmentTool alloc] init];
    }
    return _downloadTool;
}

- (CMPPrintTools *)printTool {
    if (!_printTool) {
        _printTool = [[CMPPrintTools alloc] init];
    }
    return _printTool;
}

@end
