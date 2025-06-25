//
//  CMPOfflineFilesPlugin.m
//  CMPCore
//
//  Created by wujiansheng on 16/9/7.
//
//

#import "CMPOfflineFilesPlugin.h"
#import "SyOfflineFilesListViewController.h"
#import "SyLocalOfflineFilesListViewController.h"
#import "CMPMyFilesViewController.h"
#import "CMPFileManagementManager.h"
#import "CMPShareManager.h"

#import <CMPLib/CMPQuickLookPreviewController.h>
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/YYModel.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/FCFileManager.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPImageBrowseCellDataModel.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/CMPReviewImagesTool.h>
#import <CMPLib/CMPAVPlayerViewController.h>
#import <CMPLib/NSURL+CMPURL.h>


static int const kMaxSelectCount = 10;

@interface CMPOfflineFilesPlugin()<CMPMyFilesViewControllerDelegate,SyLocalOfflineFilesListViewControllerDelegate>
@property (nonatomic, copy)NSString *callbackId;
/* fileManager */
@property (strong, nonatomic) CMPFileManagementManager *fileManager;
/* 上次存储的title */
@property (copy, nonatomic) NSString *lastTitle;
//@property (assign, nonatomic) NSInteger deleteFileCount;//删除文件的标记;

@end

@implementation CMPOfflineFilesPlugin
- (void)dealloc
{
    self.callbackId = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)openOfflineFilesModule:(CDVInvokedUrlCommand*)command
{
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *aName = [paramDict objectForKey:@"name"];
    //打开离线文档模块
    if (CMPCore.sharedInstance.serverIsLaterV8_0) {
        
        CMPBannerWebViewController *webController = [[CMPBannerWebViewController alloc] init];
        [webController setTitle:aName];
        [webController setHideBannerNavBar:NO];
        webController.startPage = [CMPAppManager appIndexPageWithAppId:@"93" version:@"3.1.0" serverId:kCMP_ServerID];
        if ([self.viewController isKindOfClass:[CMPBannerWebViewController class]]) {
            CMPBannerWebViewController * viewController = (CMPBannerWebViewController *)self.viewController;
            if (viewController.navigationController) {
                //[CMPCommonTool pushInMasterWithViewController:webController in:self.viewController];
                 [viewController pushVc:webController inVc:viewController inDetail:NO clearDetail:YES animate:YES];
            }else {
                [self.viewController presentViewController:webController animated:YES completion:nil];
            }
        }
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }else {
        SyOfflineFilesListViewController *controller = [[SyOfflineFilesListViewController alloc] init];
        if (aName) {
            controller.bannerTitle = aName;
        }
        
        CMPBannerWebViewController *webController = nil;
        UINavigationController *navi = [[CMPNavigationController alloc] initWithRootViewController:controller];
        if ([self.viewController isKindOfClass:[CMPBannerWebViewController class]]) {
            webController = (CMPBannerWebViewController *)self.viewController;
            if (webController.navigationController) {
                [webController pushVc:controller inVc:webController inDetail:NO clearDetail:YES animate:YES];
            }else {
                [self.viewController presentViewController:navi animated:YES completion:nil];
            }
        }else {
            if (self.viewController.navigationController) {
                [self.viewController.navigationController pushViewController:controller animated:YES];
            }else {
                [self.viewController presentViewController:navi animated:YES completion:nil];
            }
        }
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)getLocalOfflineFiles:(CDVInvokedUrlCommand*)command
{
    //选择离线文档  协同公文等调用离线文档
    self.callbackId = command.callbackId;
    
    NSDictionary *param = [[command arguments] firstObject];
    NSString * acceptFormatStr = [param objectForKey:@"typeList"];
    NSArray * acceptFormatArr;
    
    if (acceptFormatStr.length) {
        acceptFormatArr = [acceptFormatStr componentsSeparatedByString:@","];
    }
    
    if (CMPCore.sharedInstance.serverIsLaterV8_0) {
        //打开离线文档模块
        CMPMyFilesViewController *webController = [[CMPMyFilesViewController alloc] init];
        webController.acceptFormatArray = acceptFormatArr;
        webController.maxFileCount = [[param objectForKey:@"maxFileCount"] integerValue];
        webController.maxFileSize = [[param objectForKey:@"maxFileSize"] integerValue];
        webController.delegate = self;
        if ([self.viewController isKindOfClass:[CMPBannerWebViewController class]]) {
            [CMPCommonTool pushInDetailWithViewController:webController in:self.viewController];
        }
    }else {
        SyLocalOfflineFilesListViewController *controller = [[SyLocalOfflineFilesListViewController alloc] init];
        controller.delegate = self;
        //maxFileSize
        if ([[param allKeys]containsObject:@"maxFileSize"]) {
            id maxFileSize = [param objectForKey:@"maxFileSize"];
            if ([maxFileSize isKindOfClass:[NSNumber class]] || ![NSString isNull:maxFileSize]) {
                controller.maxFileSize = [(NSNumber *)maxFileSize integerValue];
            }
        }
        //typeList
        controller.acceptFormatArray = acceptFormatArr;
        controller.maxFileCount = [[param objectForKey:@"maxFileCount"] integerValue];
        
        CMPBannerWebViewController *webController = nil;
        UINavigationController *navi = [[CMPNavigationController alloc] initWithRootViewController:controller];
        if ([self.viewController isKindOfClass:[CMPBannerWebViewController class]]) {
            webController = (CMPBannerWebViewController *)self.viewController;
            if (webController.navigationController) {
                [webController pushVc:controller inVc:webController inDetail:YES clearDetail:NO animate:YES];
            }else {
                [self.viewController presentViewController:navi animated:YES completion:nil];
            }
        }else {
            if (self.viewController.navigationController) {
                [self.viewController.navigationController pushViewController:controller animated:YES];
            }else {
                [self.viewController presentViewController:navi animated:YES completion:nil];
            }
        }
    }
    
}


#pragma mark - CMPMyFilesViewControllerDelegate

- (void)myFilesVCDocumentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSString *> *)urls
{
    static NSInteger i = 0;
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    for (NSString *aPath in urls) {
        long long size = [CMPFileManager fileSizeAtPath:aPath];
        NSString *type = [aPath.pathExtension copy];
        NSNumber *index = [NSNumber numberWithInteger:i];
        NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:[aPath copy], @"filepath", [NSNumber numberWithLongLong:size], @"fileSize",  type, @"type", index, @"index", nil];
        [fileArray addObject:aItem];
        i++;
    }
    NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"success", fileArray, @"files", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
      /*  BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
        if(fileUrlAuthozied){
            NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
            NSError *error;
            [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {

                NSString *filePath = newURL.absoluteString;
                filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                NSString *tmpPath = filePath.stringByRemovingPercentEncoding;
                if (tmpPath) {
                    filePath = tmpPath;
                }
                //拷贝到我们APP。才能进行发送操作
                NSString *newPath = [FCFileManager copyFileToTempWithPath:filePath];
                NSNumber *index = [NSNumber numberWithInteger:i];
                Class cls = NSClassFromString(@"RCFileMessage");
                id message = [cls performSelector:@selector(messageWithFile:) withObject:newPath];
                
                id size = [message valueForKeyPath:@"size"];
                id type = [message valueForKeyPath:@"type"];
                NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:newPath, @"filepath", size, @"fileSize",  type, @"type",index,@"index", nil];
                [fileArray addObject:aItem];
                i++;
            }];
            [url stopAccessingSecurityScopedResource];

            }
    }*/
}


/// 我的文件控制器 发送 按钮点击
/// @param selectedFiles 发送选中的文件
- (void)myFilesVCSendClicked:(NSArray<CMPFileManagementRecord *> *)selectedFiles {
    NSMutableArray *fileArray = [NSMutableArray array];
    NSInteger i = 0;
    for (CMPFileManagementRecord *file in selectedFiles) {
        NSString *aPath = file.filePath;
        NSString* extension = [aPath pathExtension];
        NSNumber *index = [NSNumber numberWithInteger:i];
        NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:aPath, @"filepath", file.fileSize, @"fileSize",  extension, @"type",index,@"index", file.fileName, @"filename", nil];
        [fileArray addObject:aItem];
        i++;
        
    }
    NSMutableDictionary *aDict = [NSMutableDictionary dictionary];
    aDict[@"success"] = @"true";
    aDict[@"files"] = fileArray;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

/// 返回按钮点击
- (void)backBarButtondidClick {
    UIViewController *popViewController = [self.viewController.navigationController popViewControllerAnimated:YES];
    if (!popViewController) {
        if (self.viewController.navigationController) {
            [self.viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - SyLocalOfflineFilesListViewControllerDelegate

- (void)localOfflineFilesListViewController:(id)aLocalOfflineFilesListViewController didFinishedSelected:(NSArray<CMPOfflineFileRecord*> *)result  {
  
    NSMutableArray *fileArray = [NSMutableArray array];
    NSInteger i = 0;
    for (CMPOfflineFileRecord *file in result) {
        NSString *aPath = [CMPFileManager unEncryptFile:file.fullLocalPath fileName:file.localName];
        NSString* extension = [aPath pathExtension];
        NSNumber *index = [NSNumber numberWithInteger:i];
        NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:aPath, @"filepath", file.fileSize, @"fileSize",  extension, @"type",index,@"index", nil];
        [fileArray addObject:aItem];
        i++;
    }
    NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"success", fileArray, @"files", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];

}
- (void)localOfflineFilesListViewController:(id)aLocalOfflineFilesListViewController didPickDocumentsAtURLs:(NSArray<NSString*> *)result {
    NSInteger i = 0;

    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    for (NSString *aPath in result) {
        long long size = [CMPFileManager fileSizeAtPath:aPath];
        NSString *type = [aPath.pathExtension copy];
        NSNumber *index = [NSNumber numberWithInteger:i];
        NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:[aPath copy], @"filepath", [NSNumber numberWithLongLong:size], @"fileSize",  type, @"type", index, @"index", nil];
        [fileArray addObject:aItem];
        i++;
    }
    
    NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"success", fileArray, @"files", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (void)localOfflineFilesListViewControllerDidCancel:(id)aLocalOfflineFilesListViewController {
    NSDictionary *errorDit = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:21002],@"code",@"Cancel choose",@"message",@"",@"detail", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDit];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

#pragma mark - --------- 新文件管理 ----------
- (CMPFileManagementManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [[CMPFileManagementManager alloc] init];
    }
    return _fileManager;
}
#pragma mark  获取页面信息
- (void)getPageInfo:(CDVInvokedUrlCommand *)command {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    if ([self.viewController isKindOfClass: [CMPMyFilesViewController class]]) {
        ret[@"type"] = @1;
    }else {
        ret[@"type"] = @0;
    }
    
    ret[@"maxSelectCount"] = @(kMaxSelectCount);
    ret[@"maxFileSize"] = @(1024*1024*50);//默认50M
    
    if ([self.viewController isKindOfClass:CMPMyFilesViewController.class]) {
        CMPMyFilesViewController *fileVC = (CMPMyFilesViewController *)self.viewController;
        NSString *typeListStr = [fileVC.acceptFormatArray componentsJoinedByString:@","];
        if (typeListStr.length) {
            ret[@"typeList"] = typeListStr;
        }
        if (fileVC.maxFileCount > 0) {
            ret[@"maxSelectCount"] = @(fileVC.maxFileCount);
        }
        if (fileVC.maxFileSize > 0) {
            ret[@"maxFileSize"] = @(fileVC.maxFileSize);
        }
    }else if ([self.viewController isKindOfClass:SyLocalOfflineFilesListViewController.class]){
        SyLocalOfflineFilesListViewController *fileVC = (SyLocalOfflineFilesListViewController *)self.viewController;
        NSString *typeListStr = [fileVC.acceptFormatArray componentsJoinedByString:@","];
        if (typeListStr.length) {
            ret[@"typeList"] = typeListStr;
        }
        if (fileVC.maxFileCount > 0) {
            ret[@"maxSelectCount"] = @(fileVC.maxFileCount);
        }
        if (fileVC.maxFileSize > 0) {
            ret[@"maxFileSize"] = @(fileVC.maxFileSize);
        }
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:ret];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


///  通过类型获取本地文件
- (void)getLocalFilesByType:(CDVInvokedUrlCommand *)command {
    
    CMPBannerWebViewController *webVc = (CMPBannerWebViewController *)self.viewController;
    if ([webVc isKindOfClass:CMPBannerWebViewController.class]) {
        webVc.bannerNavigationBar.bannerTitleView.text = SY_STRING(@"offlineFiles_myfile");
        [webVc.bannerNavigationBar hideBottomLine:YES];
    }

    id params = command.arguments.lastObject;
    if (!params) return;
    
    NSInteger type = [params[@"type"] integerValue];
    NSString *keyword = params[@"keyWord"];
    NSInteger pageIndex = [params[@"pageIndex"] integerValue];
    NSInteger pageCount = [params[@"pageCount"] integerValue];
   
    NSInteger startIndex = (pageIndex -1)*pageCount;
//    if (startIndex == 0) {
//        self.deleteFileCount = 0;
//    }
//    startIndex = startIndex > self.deleteFileCount ? startIndex-self.deleteFileCount : 0;
    
    CMPFileMineType mineType = CMPFileMineTypeAll;
   switch (type) {
       case 1:
           mineType = CMPFileMineTypeFile;
           break;
       case 2:
           mineType = CMPFileMineTypeImage;
           break;
       case 3:
           mineType = CMPFileMineTypeVideo;
           break;
       case 4:
           mineType = CMPFileMineTypeUnknown;
           break;
       default:
           mineType = CMPFileMineTypeAll;
           break;
      }
    NSArray *resultArr = [self.fileManager searchOfflineFilesWithKeyWord:keyword startIndex:startIndex rowCount:pageCount type:mineType];
    //这里这么做是为了防止取到的数据是nil的时候，传到H5端会导致H5端报错的情况，因此就赋值一个空数组
    if (!resultArr) {
        resultArr = [NSArray array];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:resultArr];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}


#pragma mark  删除选中文件
- (void)deleteFile:(CDVInvokedUrlCommand *)command {
    id params = command.arguments.lastObject;
    if (!params) return;
    
    NSMutableArray *mfrs = [NSMutableArray array];
    if ([params isKindOfClass: [NSDictionary class]]) {
        CMPFileManagementRecord *fmr = [CMPFileManagementRecord yy_modelWithDictionary:params];
        [mfrs addObject:fmr];
    }else {
        for (NSDictionary *ofrDic in params) {
            CMPFileManagementRecord *mfr = [CMPFileManagementRecord yy_modelWithDictionary:ofrDic];
            if (mfr) {
                [mfrs addObject:mfr];
            }
        }
    }
    
    if (mfrs.count) {
        BOOL succ = [self.fileManager deleteFilesWithOfflineFiles:mfrs];
//        self.deleteFileCount += mfrs.count;
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:succ];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}


#pragma mark 选中文件
- (void)selectFile:(CDVInvokedUrlCommand *)command {
    id params = command.arguments.lastObject;
    if (!params) return;
    
    CMPMyFilesViewController *myFilesVc = (CMPMyFilesViewController *)self.viewController;
    
    NSMutableArray *mfrs = [NSMutableArray array];
    for (NSDictionary *dic in params) {
        CMPFileManagementRecord *mfr = [CMPFileManagementRecord yy_modelWithDictionary:dic];
        if (mfr) {
            NSString *aZipPath = [NSHomeDirectory() stringByAppendingPathComponent:mfr.fileUrl];
            NSString *aFilePath = [CMPFileManager unEncryptFile:aZipPath fileName:mfr.fileName];
            mfr.filePath = aFilePath;
            [mfrs addObject:mfr];
        }
    }
    
    [self.fileManager addSelectedFiles:mfrs];
    
    //超出选中数量提示
    if (self.fileManager.getCurrentSelectedCount >= kMaxSelectCount || mfrs.count >= kMaxSelectCount) {
        NSString *msg = [NSString stringWithFormat:@"选中文件数大于%d",kMaxSelectCount];
//        CMPBaseWebViewController *vc = (CMPBaseWebViewController *)self.viewController;
//        [vc showToastWithText:msg];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:msg];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        if ([self.viewController isKindOfClass:[CMPMyFilesViewController class]]) {
            [myFilesVc setSelectedCount:self.fileManager.getCurrentSelectedCount];
        }
        return;
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    if (![self.viewController isKindOfClass: [CMPMyFilesViewController class]]) return;
    
    myFilesVc.fileManager = self.fileManager;
    [myFilesVc setSelectedCount:self.fileManager.getCurrentSelectedCount];
    if (self.fileManager.getCurrentSelectedCount > 0 && !myFilesVc.isBottomViewShowing) {
        [myFilesVc showBottomView];
        [myFilesVc disableBtnAtIndex:1 disable:YES];
    }
    
}

/// 取消选中某个文件
- (void)unSelectFile:(CDVInvokedUrlCommand *)command {
    id params = command.arguments.lastObject;
    if (!params) return;
    if ([params isKindOfClass: [NSDictionary class]]) {
        CMPFileManagementRecord *mfr = [CMPFileManagementRecord yy_modelWithDictionary:params];
        [self.fileManager removeSelectedFile:mfr];
    }else {
        NSMutableArray *mfrs = [NSMutableArray array];
        for (NSDictionary *dic in params) {
            CMPFileManagementRecord *mfr = [CMPFileManagementRecord yy_modelWithDictionary:dic];
            if (mfr) {
                [mfrs addObject:mfr];
            }
        }
        
        [self.fileManager removeSelectedFiles:mfrs];
    }
    
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    if (![self.viewController isKindOfClass: [CMPMyFilesViewController class]]) return;
    
    CMPMyFilesViewController *myFilesVc = (CMPMyFilesViewController *)self.viewController;
    myFilesVc.fileManager = self.fileManager;
    [myFilesVc setSelectedCount:self.fileManager.getCurrentSelectedCount];
    if (self.fileManager.getCurrentSelectedCount == 0 && myFilesVc.isBottomViewShowing) {
        [myFilesVc hideBottomView];
        [myFilesVc disableBtnAtIndex:1 disable:NO];
    }
    
}

/// 获取当前选中的文件
- (void)getCurSelectedFiles:(CDVInvokedUrlCommand *)command {
    NSArray *selectedFiles = self.fileManager.getCurrentSelectedFiles;
    CDVPluginResult *pluginResult = nil;
    if (selectedFiles) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:selectedFiles];
    }else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


#pragma mark 改变nav的title
- (void)changeTitle:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = command.arguments.lastObject;
    if (!params || !params.count) return;
    
    //如果type == 0就进行title的设置，否则就还原之前title的状态
    if ([self.viewController isKindOfClass:[CMPMyFilesViewController class]]) {
        CMPMyFilesViewController *controller = (CMPMyFilesViewController *)self.viewController;
        if ([params[@"type"] intValue] == 0) {
            controller.bannerNavigationBar.bannerTitleView.text = params[@"title"];
            controller.bannerNavigationBar.bannerTitleView.hidden = NO;
            [controller setHideSegmentedView:YES];
        }else {
            controller.bannerNavigationBar.bannerTitleView.hidden = YES;
            [controller setHideSegmentedView:NO];
        }
    }
    else if ([self.viewController isKindOfClass:[SyLocalOfflineFilesListViewController class]]) {
        SyLocalOfflineFilesListViewController *controller = (SyLocalOfflineFilesListViewController *)self.viewController;
        if ([params[@"type"] intValue] == 0) {
            controller.bannerNavigationBar.bannerTitleView.text = params[@"title"];
            controller.bannerNavigationBar.bannerTitleView.hidden = NO;
            [controller setHideSegmentedView:YES];
        }else {
            controller.bannerNavigationBar.bannerTitleView.hidden = YES;
            [controller setHideSegmentedView:NO];
        }
        
    }
    else if ([self.viewController isKindOfClass: [CMPBannerWebViewController class]]) {
        CMPBannerWebViewController *webController = (CMPBannerWebViewController *)self.viewController;
        if ([params[@"type"] intValue] == 0) {
            self.lastTitle = webController.bannerNavigationBar.bannerTitleView.text;
            webController.bannerNavigationBar.bannerTitleView.text = params[@"title"];
        }else {
            webController.bannerNavigationBar.bannerTitleView.text = self.lastTitle;
        }
    }else {
        if ([params[@"type"] intValue] == 0) {
            self.lastTitle = self.viewController.navigationItem.title;
            self.viewController.navigationItem.title = params[@"title"];
        }else {
            self.viewController.navigationItem.title = self.lastTitle;
        }
    }
    
    
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark 点击了某个cell
- (void)click:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = command.arguments.lastObject;
    if (!params || !params.count) return;
    if (![params isKindOfClass: [NSDictionary class]]) return;
    
    CMPFileManagementRecord *record = [CMPFileManagementRecord yy_modelWithDictionary:params];
    // 解压后查看
    NSString *aZipPath = [NSHomeDirectory() stringByAppendingPathComponent:record.fileUrl];
    NSString *aFilePath = [CMPFileManager unEncryptFile:aZipPath fileName:record.fileName];
    record.filePath = aFilePath;
    [self showFilePreview:record];
}

#pragma mark 打开点击的文件
- (void)showFilePreview:(CMPFileManagementRecord *)record {
    
    NSInteger fileType = [CMPFileTypeHandler fileMineTypeWithMineType:record.fileType];
    
    if (fileType == CMPFileMineTypeImage) {//图片
        [self showImageBrowserViewWithRecord:record];
    }else if (fileType == CMPFileMineTypeVideo) {//视频
        [self showVideoWithRecord:record];
    }else if (fileType == CMPFileMineTypeAudio) {//音频
        [self showAudioWithRecord:record];
    }else {//其他文件
        [self showFileWithRecord:record];
    }
    
}

/// 打开图片组件展示图片
/// @param record mfr
- (void)showImageBrowserViewWithRecord:(CMPFileManagementRecord *)record {
    NSString *from = record.from;
    
    NSMutableArray *models = [NSMutableArray array];
    
    NSString *url = record.filePath;
    NSString *imgName = record.fileName;
    
    CMPImageBrowseCellDataModel *model = [[CMPImageBrowseCellDataModel alloc] init];
    model.from = from;
    model.filenName = imgName;
    model.fileId = record.fileId;
    
    model.showUrlStr = url;
    model.originUrlStr = url;
    
    model.fromType = record.fromType;
    model.canNotAutoSave = YES;
    [models addObject:model];
    
    CMPBaseWebViewController *controller = nil;
    if ([self.viewController isKindOfClass:[CMPBaseWebViewController class]]) {
        controller = (CMPBaseWebViewController *)self.viewController;
    }
    
    [CMPReviewImagesTool showBrowserForMixedCaseWithDataModelArray:models.copy rcImgModels:nil index:0 fromControllerIsAllowRotation:controller.allowRotation canSave:YES canPrint:YES isShowCheckAllPicsBtn:NO isUC:record.isUc];
}

/// 打开视频组件展示播放是视频
/// @param record mfr
- (void)showVideoWithRecord:(CMPFileManagementRecord *)record {
    CMPAVPlayerViewController *playerVc = CMPAVPlayerViewController.alloc.init;
    NSString *videoLocalPath = record.filePath;
    
    playerVc.from = record.from;
    playerVc.fileName = record.fileName;
    playerVc.fileId = record.fileId;
    playerVc.autoSave = NO;
    playerVc.showAlbumBtn = NO;
    
    playerVc.palyType = CMPAVPlayerPalyTypeVideo;
    playerVc.fromType = record.fromType;
    playerVc.canNotCollect = ![CMPFeatureSupportControl isSupportCollect];

    if ([[NSFileManager defaultManager] fileExistsAtPath:videoLocalPath]) {
       playerVc.url = [NSURL URLWithPathString:videoLocalPath];
       [self.viewController presentViewController:playerVc animated:YES completion:nil];
    }
    
}

/// 打开音频组件展示播放是音频
/// @param record mfr
- (void)showAudioWithRecord:(CMPFileManagementRecord *)record {
    CMPAVPlayerViewController *playerVc = CMPAVPlayerViewController.alloc.init;
    NSString *videoLocalPath = record.filePath;
    
    playerVc.palyType = CMPAVPlayerPalyTypeAudio;
    playerVc.canNotSave = YES;
    playerVc.fileName = record.fileName;
    playerVc.from = record.from;
    playerVc.fileId = record.fileId;
    playerVc.autoSave = NO;
    playerVc.showAlbumBtn = NO;
    
    playerVc.palyType = CMPAVPlayerPalyTypeAudio;
    playerVc.fromType = record.fromType;
    playerVc.canNotCollect = ![CMPFeatureSupportControl isSupportCollect];
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoLocalPath]) {
       playerVc.url = [NSURL URLWithPathString:videoLocalPath];
       [self.viewController presentViewController:playerVc animated:YES completion:nil];
    }
    
}

/// 打开文件预览 查看文件
/// @param record mfr
- (void)showFileWithRecord:(CMPFileManagementRecord *)record {
    AttachmentReaderParam *aParam = [[AttachmentReaderParam alloc] init];
    aParam.filePath = record.filePath;
    aParam.fileId = record.fileId;
    CMPQuickLookPreviewController *aViewController = [[CMPQuickLookPreviewController alloc] init];
    aParam.canDownload = NO;
    aParam.url = record.fileUrl;
    aParam.origin = [CMPCore sharedInstance].serverurlForSeeyon;
    aParam.lastModified = [NSString stringWithFormat:@"%lld", record.lastModify];
    aParam.fileName = record.fileName;
    aParam.fileType = record.fileType;
    aParam.fileSize = record.fileSize;
    aParam.origin = record.origin;
    aParam.isUc = record.isUc;
    aParam.isShowShareBtn = YES;
    aParam.from = record.from;
    aParam.fromType = record.fromType;
    aViewController.attReaderParam = aParam;
    [CMPCommonTool pushInDetailWithViewController:aViewController in:self.viewController];
}


@end
