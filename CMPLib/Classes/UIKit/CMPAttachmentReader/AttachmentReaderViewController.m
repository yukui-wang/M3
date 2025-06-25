//
//  AttachmentReaderViewController.m
//  HelloCordova
//
//  Created by lin on 15/8/20.
//
//

#import "AttachmentReaderViewController.h"
#import "AttachmentReaderView.h"
#import "kZSinglePageViewItem.h"

#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/ZipArchiveUtils.h>
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/CMPCommonDBProvider.h>
#import <CMPLib/CMPGlobleManager.h>
#import <AVFoundation/AVFoundation.h>
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/NSObject+FBKVOController.h>
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPPrintTools.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/NSURL+CMPURL.h>
#import <CMPLib/CMPDownloadFileRecord.h>
#import <QuickLook/QuickLook.h>

@interface AttachmentReaderViewController()<CMPDataProviderDelegate,UIGestureRecognizerDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource>
{
    AttachmentReaderView *_attachmentReaderView;
    kZSinglePageViewItem *_imageReaderView;
}

@property(nonatomic, copy)NSString *requestId;
@property(nonatomic, retain)UIDocumentInteractionController *fileInteractionController;
@property(nonatomic, retain)NSMutableArray *portraitRightItems;
@property(nonatomic, retain)NSMutableArray *landscapeRightItems;
@property(nonatomic, assign)BOOL isShowStatusbar;

@property(nonatomic, assign)BOOL isStartFullScreen;

/* 是否是全屏 */
@property (assign, nonatomic) BOOL isFullScreen;

@property (nonatomic,strong) CMPPrintTools *printTool;

@property (nonatomic,strong) QLPreviewController *previewController;

@end

@implementation AttachmentReaderViewController

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

//loading 加载区域
- (UIView *)loadingShowInView {
    return self.mainView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allowRotation = YES;
    [self initWithNavi];
    self.view.backgroundColor = [UIColor whiteColor];
    _attachmentReaderView = (AttachmentReaderView *)self.mainView;
    if (InterfaceOrientationIsPortrait) {
        self.isShowStatusbar = YES;
    }else{
        self.isShowStatusbar = NO;
    }
    [self setNeedsStatusBarAppearanceUpdate];
    
    
    [self handleAttParam];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(splitVCDidBecomeLandscape) name:CMPSplitViewContrllerDidBecomeLandscapeNoti object:nil];
    if ([CMPFeatureSupportControl isSupportImageLongPress]) {
        [self addLongPressIndentifyImage];
    }
}

//获取到文件才显示按钮
- (void)setupBannerBtns {
    NSMutableArray *rightButton = [NSMutableArray array];
    NSMutableArray *landscapeRightButton = [NSMutableArray array];
    if (self.attReaderParam.isShowShareBtn) {
        [rightButton addObject:[self showShareBtn]];
    }
    else {
        if (self.attReaderParam.canDownload) {
            [rightButton addObject:[self saveButton]];
        }
        if (self.attReaderParam.isShowPrintBtn) {
            [rightButton addObject:[self printButton]];
        }
        if (self.attReaderParam.canShowInThirdApp) {
            [rightButton addObject:[self showInThirdApp]];
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
        [self setPanGesturEnabled:YES];
        [landscapeRightButton addObject:[self closeRotateButton]];
        self.landscapeRightItems = [NSMutableArray arrayWithArray:landscapeRightButton];
        if (InterfaceOrientationIsPortrait) {
            [self showNavBar:YES animated:NO];
            [self.bannerNavigationBar setRightBarButtonItems:self.portraitRightItems];
        } else{
            [self showNavBar:NO animated:NO];
            [self.bannerNavigationBar setRightBarButtonItems:self.landscapeRightItems];
        }
    }else if (INTERFACE_IS_PAD){
        [self.bannerNavigationBar setRightBarButtonItems:self.portraitRightItems];
    }
}

- (void)handleAttParam
{
    // 如果是本地路径
    if (![NSString isNull:self.attReaderParam.filePath]) {
        [self startRead:self.attReaderParam.filePath];
        return;
    }
    if ([self.attReaderParam.url hasPrefix:@"http://"] || [self.attReaderParam.url hasPrefix:@"https://"]) {
        [self downloadFile];
    }
    else {
        [self startRead:self.attReaderParam.url];
    }
}

- (void)startRead:(NSString *)aPath
{
    if ([NSString isNull:aPath]) {
        [self showOpenFileErrorType:CMPOpenFileErrorTypeUnZipFail];
        return;
    }
    
    //是自动保存，需求是只要打开了附件都要记录到我的文件
    if (self.attReaderParam.autoSave) {
        self.attReaderParam.filePath = aPath;
        [self saveToMyFile];
    }
    
    // 更新文件路径
    self.attReaderParam.filePath = aPath;
    self.attReaderParam.fileName = aPath.lastPathComponent.originalFileNameSpecialCharactersAtPath;
    NSInteger attType = [CMPFileManager getFileType:aPath];
    
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
    [self setupBannerBtns];
    
    BOOL aEditMode = self.attReaderParam.editMode;
    NSDictionary *param = @{@"edit":[NSNumber numberWithBool:aEditMode],@"path":aPath};
    if (aEditMode) {
        if (attType == QK_AttchmentType_Image) {
            [self showPreviewController];
        }else if(attType == QK_AttchmentType_Office_Doc){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingWPSNotificationName object:param];
            
        }else if(attType == QK_AttchmentType_Office_Excel){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingExcelNotificationName object:param];
            
        }else if(attType == QK_AttchmentType_Office_PPt){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingPPtNotificationName object:param];
            
        }else if(attType == QK_AttchmentType_Office_Pdf){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingPdfNotificationName object:param];
            
        }else if(attType == QK_AttchmentType_Office_Other || attType == QK_AttchmentType_Gif){
            [self showPreviewController];
            return;
        }else if (attType == QK_AttchmentType_WPS){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingWPSNotificationName object:param];
        }else if(attType == QK_AttchmentType_ET){
            [[NSNotificationCenter defaultCenter] postNotificationName:k_RunKingExcelNotificationName object:param];
        }
        [self performSelector:@selector(backClicked:) withObject:nil afterDelay:1];
    }
    else {
        if (attType == QK_AttchmentType_Image) {
            [self showPreviewController];
        }else if(attType == QK_AttchmentType_Office_Doc
                 ||attType == QK_AttchmentType_Office_Excel
                 ||attType == QK_AttchmentType_Office_PPt
                 ||attType == QK_AttchmentType_Office_Pdf
                 ||attType == QK_AttchmentType_Office_Other
                 ||attType == QK_AttchmentType_Video
                 ||attType == QK_AttchmentType_AUDIO
                 ||attType == QK_AttchmentType_Gif){
            [self showPreviewController];
        }else if (attType == QK_AttchmentType_WPS){
            [self showOpenFileErrorType:CMPOpenFileErrorTypeUnknown]; // WPS格式文件提示不支持打开
        }else if(attType == QK_AttchmentType_ET){
            [self showOpenFileErrorType:CMPOpenFileErrorTypeUnknown]; // ET格式文件提示不支持打开
        }
        else if(attType == QK_AttchmentType_TEXT){
            [self showPreviewController];
        }
        else if (attType == QK_AttchmentType_Unkown || attType == QK_AttchmentType_PRESS) {
            [self showOpenFileErrorType:CMPOpenFileErrorTypeUnknown];
        }
    }
}

- (void)showOpenFileErrorType:(CMPOpenFileErrorType)type {
    NSMutableArray *rightButton = [NSMutableArray array];
    if (type == CMPOpenFileErrorTypeUnknown) {
        if (self.attReaderParam.isShowShareBtn) {
            //OA-210846 M3-iOS端：zip格式数据，保存到我的文件，没有其他应用打开的功能入口
            //特殊需求，如果不支持的格式，只显示第三方打开按钮，不显示分享按钮
            [rightButton addObject:[self showInThirdApp]];
        }
        else if (self.attReaderParam.canShowInThirdApp) {
            [rightButton addObject:[self showInThirdApp]];
        }
    }
    [self.bannerNavigationBar setRightBarButtonItems:rightButton];
    [_attachmentReaderView showOpenFileErrorType:type];
}

- (UIButton *)showInThirdApp
{
    UIButton *button = [UIButton buttonWithImageName:@"banner_more_button" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(showInThirdApp:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)showInThirdApp:(UIButton *)sender
{
    if (self.attReaderParam.filePath) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSURL *file_URL = [NSURL URLWithPathString:self.attReaderParam.filePath];
        if ([fileManager fileExistsAtPath:file_URL.path]) {
            if (!self.fileInteractionController) {
                self.fileInteractionController = [UIDocumentInteractionController interactionControllerWithURL:file_URL];
            }
            else {
                self.fileInteractionController.URL = file_URL;
            }
            self.fileInteractionController.delegate = self;
            [self.fileInteractionController presentOpenInMenuFromRect:sender.frame inView:self.mainView animated:YES];
            [self beginShowInThirdApp];
        }
    }
}

- (void)beginShowInThirdApp {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ThirdAppMenuWillShow object:nil];
}

- (void)endShowInThirdApp {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ThirdAppMenuWillHide object:nil];
}

#pragma mark 分享按钮点击
- (UIButton *)showShareBtn
{
    UIButton *button = [UIButton buttonWithImageName:@"share_component_share_icon" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(showShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)showShareBtn:(UIButton *)sender
{
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
    mfr.lastModify = self.attReaderParam.lastModified.longLongValue;
    mfr.from = self.attReaderParam.from;
    mfr.fromType = self.attReaderParam.fromType;
    mfr.origin = self.attReaderParam.origin;
    mfr.notShowShareIcons = notShowArr;
    mfr.isUc = self.attReaderParam.isUc;
    NSDictionary *obj = @{@"mfr" : mfr,@"pushVC" : self, @"webview" :self.previewController.view};
    [NSNotificationCenter.defaultCenter postNotificationName:CMPAttachReaderShareClickedNoti object:obj];
}

#pragma mark 旋转横屏通知处理方法

- (void)splitVCDidBecomeLandscape {
    if (self.isFullScreen) {
        //当为全屏的时候，就在旋转完后设置成全屏状态
        [self fullScreenAction:nil];
    }
}

#pragma mark - 旋转
- (UIButton *)rotateButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_switch_direction" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(rotateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)closeRotateButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_close_rotate" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(closeRotateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)rotateButtonAction:(UIButton *)button {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
}

- (void)closeRotateButtonAction:(UIButton *)button {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationPortrait] forKey:@"orientation"];
}

#pragma mark - 全屏

- (UIButton *)fullScreenButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_switch_direction" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)closeFullScreenButton  {
    UIButton *button = [UIButton buttonWithImageName:@"banner_close_rotate" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(closeFullScreenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)fullScreenAction:(UIButton *)button {
    [self.splitViewController cmp_switchFullScreen];
    [self.portraitRightItems replaceObjectAtIndex:self.portraitRightItems.count -1  withObject:[self closeFullScreenButton]];
    [self.bannerNavigationBar setRightBarButtonItems:self.portraitRightItems];
    self.isFullScreen = YES;
}

- (void)closeFullScreenButtonAction:(UIButton *)button
{
    [self.splitViewController cmp_switchSplitScreen];
    [self.portraitRightItems replaceObjectAtIndex:self.portraitRightItems.count -1  withObject:[self fullScreenButton]];
    [self.bannerNavigationBar setRightBarButtonItems:self.portraitRightItems];
    self.isFullScreen = NO;
}

#pragma mark - 打印
- (UIButton *)printButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_print" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(printButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)printButtonAction:(UIButton *)button {
    if (!_printTool) {
        _printTool = [[CMPPrintTools alloc] init];
    }
    
    long long fileSize = [CMPFileManager fileSizeAtPath:self.attReaderParam.filePath];
    long long maxFileSize = 15 * 1024 * 1024;
    if (fileSize > maxFileSize) {
        [self showToastWithText:SY_STRING(@"print_more_than_size")];
        return;
    }
    [self.printTool printWithFilePath:self.attReaderParam.filePath webview:self.previewController.view success:^{
        
    } fail:^(NSError *error) {
        
    }];
}

- (void)initWithNavi
{
    if (CMPCore.sharedInstance.serverIsLaterV8_0) {
        [self setTitle:self.attReaderParam.fileName];
    }
    else {
        if (INTERFACE_IS_PAD) {
            [self setTitle:SY_STRING(@"common_read")];
        } else {
            [self setTitle:@""];
        }
    }
}

- (void)backBarButtonAction:(id)sender
{
    if (self.requestId) {
        [[CMPDataProvider sharedInstance] cancelWithRequestId:self.requestId];
    }
    
    if (CMP_IPAD_MODE && [self.splitViewController cmp_isFullScreen] && !self.isStartFullScreen) {
        [self closeFullScreenButtonAction:nil];
        return ;
    }
    
    [super backBarButtonAction:sender];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)backClicked:(UIBarButtonItem *)aSender
{
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark  down file
- (void)downloadFile
{
    if (![NSString isNull:self.attReaderParam.fileId]) {
        // 如果存在fileId，根据文件id查找本地是否存储
        NSString *fileId = self.attReaderParam.fileId;
        NSString *lastModified = self.attReaderParam.lastModified;
        NSString *origin = kCMP_ServerID;//self.attReaderParam.origin;
        CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
        // 本地下载的记录
        __block NSArray *findResult = nil;
        NSString *serverID = [CMPCore sharedInstance].serverID;
        NSString *ownerID = [CMPCore sharedInstance].userID;
        [dbConnection downloadFileRecordsWithFileId:fileId
                                       lastModified:lastModified
                                             origin:origin
                                           serverID:serverID
                                       onCompletion:^(NSArray *result) {
            findResult = [result copy];
        }];
        if (findResult.count > 0) {
            CMPDownloadFileRecord *aDownloadFile = [findResult objectAtIndex:0];
            //判断本地文件是否存在 ，不存在就删除记录再下载
            NSString *localPath = [aDownloadFile fullLocalPath];
            BOOL isDirectory = NO;
            BOOL exist =  [[NSFileManager defaultManager] fileExistsAtPath:localPath isDirectory:&isDirectory];
            if (exist) {
                //解压
                NSString *title = aDownloadFile.localName;
                NSString *filePath = [CMPFileManager unEncryptFile:localPath fileName:title];
                if ([NSString isNotNull:filePath]) {
                    [self startRead:filePath];
                    return;
                } else {
                    [dbConnection deleteOfflineFileRecordsWithFileId:fileId origin:origin serverID:serverID ownerID:ownerID onCompletion:nil];
                }
            } else {
                [dbConnection deleteOfflineFileRecordsWithFileId:fileId origin:origin serverID:serverID ownerID:ownerID onCompletion:nil];
            }
        }
        //离线文档的记录
        [dbConnection offlineFileRecordsWithFileId:fileId
                                      lastModified:lastModified
                                            origin:origin
                                          serverID:serverID
                                           ownerID:ownerID
                                      onCompletion:^(NSArray *result) {
            findResult = [result copy];
        }];
        if (findResult.count > 0) {
            CMPOfflineFileRecord *aDownloadFile = [findResult objectAtIndex:0];
            NSString *localPath = [aDownloadFile fullLocalPath];
            BOOL isDirectory = NO;
            BOOL exist =  [[NSFileManager defaultManager] fileExistsAtPath:localPath isDirectory:&isDirectory];
            if (exist) {
                //解压
                NSString *title = aDownloadFile.fileName;
                NSString *filePath = [CMPFileManager unEncryptFile:localPath fileName:title];
                if ([NSString isNotNull:filePath]) {
                    [self startRead:filePath];
                }else {
                    [self showOpenFileErrorType:CMPOpenFileErrorTypeUnZipFail];
                }
                return;
            }
        }
    }
    // 下载文件
    if (self.requestId) {
        [[CMPDataProvider sharedInstance] cancelWithRequestId:self.requestId];
    }
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.delegate = self;
    if ([self.attReaderParam.header isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableHeader = [[CMPDataProvider headers] mutableCopy];
        [mutableHeader addEntriesFromDictionary:self.attReaderParam.header];
        aDataRequest.headers =  [mutableHeader copy];
    }
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestUrl = self.attReaderParam.url;
    //    NSString *saveFileName = [NSString stringWithFormat:@"%@.%@",NSString.uuid,self.attReaderParam.fileName.pathExtension];
    NSString *handledFileName = [self.attReaderParam.fileName handleFileNameSpecialCharactersAtPath];
    aDataRequest.downloadDestinationPath = [CMPFileManager downloadFileLocalSavedPathWithFileName:handledFileName];
    aDataRequest.requestType = kDataRequestType_FileDownload;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    self.requestId = aDataRequest.requestID;
}

- (void)saveDownloadFile:(NSString *)aPath responseHeaders:(NSDictionary *)aResponseHeaders
{
    NSString *aFileId = self.attReaderParam.fileId;
    if ([NSString isNull:aFileId]) {
        aFileId = [self.attReaderParam.url sha1];
    }
    [CMPFileManager.defaultManager saveDownloadFileRecord:aPath fileId:aFileId fileName:aPath.lastPathComponent.originalFileNameSpecialCharactersAtPath lastModified:self.attReaderParam.lastModified];
}

- (void)callbackDelegateWithSucess:(BOOL)sucess
                           message:(NSString *)message
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(attachmentReaderViewController:sucess:message:)]) {
        [self.delegate attachmentReaderViewController:self sucess:sucess message:message];
    }
}
#pragma -mark CMPDataProviderDelegate

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest
{
    [self showLoadingView];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    NSString *aStr = [CMPFileManager pathForDownloadPath:aResponse.downloadDestinationPath responseHeaders:aResponse.responseHeaders];
    [self saveDownloadFile:aStr responseHeaders:aResponse.responseHeaders];
    self.attReaderParam.filePath = aStr;
    self.attReaderParam.fileName = aStr.lastPathComponent.originalFileNameSpecialCharactersAtPath;
    [self startRead:self.attReaderParam.filePath];
    //自动保存放在startRead中了
    //    if (self.attReaderParam.autoSave) {
    //        [self saveToMyFile];
    //    }
    [self callbackDelegateWithSucess:YES message:aStr];
    [self hideLoadingView];
}

/**
 * 2. 当请求数据出现错误时调用
 *
 * aProvider: 数据访问类
 * anError: 错误信息
 * aRequest: 请求对象
 */
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    [self hideLoadingView];
    if (!self.attReaderParam.autoSave) {
        [self showToastWithText:SY_STRING(@"common_downloadFileFailed")];
    }
    [self callbackDelegateWithSucess:NO message:error.debugDescription];
}

/**
 * 4. 更新进度
 *
 */
- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt
{
    CMPLog(@"----------下载进度:%@-------------",aExt[@"progress"]);
}


- (void)addLongPressIndentifyImage {
    // 实现图片长按识别功能
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

- (void)showImageOptions
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSData *data = [NSData dataWithContentsOfFile:self.attReaderParam.filePath];
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
        
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
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
// 功能：显示图片保存结果
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error){
        [self showToastWithText:SY_STRING(@"common_save_fail")];
    }else {
        // 这一句仅仅是提示保存成功
        [self showToastWithText:SY_STRING(@"common_save_success")];
    }
}

#pragma mark  保存
- (UIButton *)saveButton {
    UIButton *button = [UIButton buttonWithImageName:@"banner_save_button" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [button addTarget:self action:@selector(saveFileAction) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)saveFileAction
{
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
}

// 保存到我的文件
- (void)saveToMyFile
{
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

// 保存到相册
- (void)saveImageToPhotosAlbum:(NSString *)aPath
{
    //保存到相册
    UIImage* image = [UIImage imageWithContentsOfFile:aPath];
    [CMPCommonTool.sharedTool savePhotoWithImage:image target:self action:@selector(image:didFinishSavingWithError:contextInfo1:)];
}

- (void)image:(UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo1:(void *)contextInfo
{
    [self showToastWithText:SY_STRING(@"common_save_success")];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    if (self.viewLoaded) {
        if (INTERFACE_IS_PHONE) {
            [self setPanGesturEnabled:YES];
            if (InterfaceOrientationIsPortrait) {
                [self.bannerNavigationBar setRightBarButtonItems:self.portraitRightItems];
                [self showNavBar:YES animated:NO];
            } else{
                [self.bannerNavigationBar setRightBarButtonItems:self.landscapeRightItems];
                [self showNavBar:NO animated:NO];
            }
        }
    }
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)showNavBar:(BOOL)isShow animated:(BOOL)animated{
    if (INTERFACE_IS_PHONE) {
        if (isShow) {
            if (InterfaceOrientationIsPortrait) {
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

- (BOOL)prefersStatusBarHidden{
    if(INTERFACE_IS_PAD){
        return NO;
    }
    return self.isShowStatusbar ? NO : YES;
}

- (void)showPreviewController {
    NSURL *url = [NSURL URLWithPathString:self.attReaderParam.filePath];
    if (![QLPreviewController canPreviewItem:url]) {
        [self showOpenFileErrorType:CMPOpenFileErrorTypeUnknown];
        return;
    }
    _previewController = [[QLPreviewController alloc] init];
    _previewController.delegate = self;
    _previewController.dataSource = self;
    [self.navigationController pushViewController:_previewController animated:YES];
}

#pragma mark QLPreviewControllerDelegate,QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSURL *url = [NSURL URLWithPathString:self.attReaderParam.filePath];
    return url;
}
@end

