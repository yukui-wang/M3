//
//  AttachmentPlugin.m
//  HelloCordova
//
//  Created by lin on 15/8/20.
//
//

#import "AttachmentPlugin.h"
#import <CMPLib/CMPQuickLookPreviewController.h>
#import <CMPLib/AttachmentReaderParam.h>
#import "AppDelegate.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/ZipArchiveUtils.h>
#import <CMPLib/CMPDownloadAttachmentTool.h>
#import "OfficePlugin.h"
#import <CMPLib/CMPDocumentPickerTool.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPNavigationController.h>
#import "CMPKanbanWebViewController.h"

@interface AttachmentPlugin()<CMPDataProviderDelegate,CMPQuickLookPreviewControllerDelegate,UIDocumentInteractionControllerDelegate>
{
    BOOL      _editEnable;
}
@property (copy, nonatomic) NSString *callBackID;
@property(nonatomic, strong)CMPDownloadAttachmentTool *downloadTool;
@property(nonatomic, strong)UIDocumentInteractionController *fileInteractionController;
@property (strong, nonatomic) OfficePlugin *officePlugin;


@end

@implementation AttachmentPlugin

- (void)dealloc
{
    self.downloadTool = nil;
    self.fileInteractionController = nil;
    _callBackID = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 从iCloud读取文件

- (void)iCloudReadFile:(CDVInvokedUrlCommand *)command {
    
    [CMPDocumentPickerTool documentPickerToolPickDocumentfromController:[UIViewController currentViewController] downloadCompleteBlock:^(NSString *filePath, NSString *fileName, NSString *flieExtension) {
        NSDictionary *dic = @{
                              @"filePath":filePath,
                              @"fileName":fileName,
                              @"flieExtension":flieExtension
                              
                              };
        NSString *str =  [dic yy_modelToJSONString];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:str];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } downloadFailedBlock:^(NSError *error) {
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error.userInfo];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
    
}

- (void)readAttachment:(CDVInvokedUrlCommand*)command
{
    self.callBackID = command.callbackId;
    
    NSDictionary *parameter = [command.arguments firstObject];
    NSString *path = [parameter objectForKey:@"path"];
    _editEnable = [[parameter objectForKey:@"edit"] boolValue];
    if ([NSString isNull:path] || [path isEqualToString:@"null"]) {
        NSDictionary *errorDict= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:17001],@"code",SY_STRING(@"attach_path_empty"),@"message",@"",@"detail", nil];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_callBackID];
        return;
    }
    
    NSString *fileName = [parameter objectForKey:@"filename"];
    fileName = [fileName decodeFromPercentEscapeString];
    [parameter setValue:fileName forKey:@"filename"];
    
    [self readAttachmentWithParameter:parameter callbackId:command.callbackId];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editFinished:) name:k_FinishEditKingOfficeNotificationName object:nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:path];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_callBackID];
}

- (void)readAttachmentWithParameter:(NSDictionary *)parameter
                         callbackId:(NSString *)callbackId
{
    CMPQuickLookPreviewController *readerViewController = [[CMPQuickLookPreviewController alloc] init];
    AttachmentReaderParam *aAttReaderParam = [[AttachmentReaderParam alloc] initWithDict:parameter];
    // 如果是v8.0版本需要自动保存
    aAttReaderParam.autoSave = [CMPFeatureSupportControl isAutoSaveFile];
    NSString *isShowPrintBtn = [parameter objectForKey:@"isShowPrintBtn"];
    if ([NSString isNotNull:isShowPrintBtn]) {
        aAttReaderParam.isShowPrintBtn = [isShowPrintBtn boolValue];
    }
    
    readerViewController.attReaderParam = aAttReaderParam;
    readerViewController.customDelegate = self;
    
    CMPBannerWebViewController *webController = nil;
    UINavigationController *navi = [[CMPNavigationController alloc] initWithRootViewController:readerViewController];
    if ([self.viewController isKindOfClass:[CMPBannerWebViewController class]]) {
        webController = (CMPBannerWebViewController *)self.viewController;
        if (webController.navigationController) {
            [webController pushVc:readerViewController inVc:webController inDetail:YES clearDetail:NO animate:YES];
        }else {
            [self.viewController presentViewController:navi animated:YES completion:nil];
        }
    }else {
        if (self.viewController.navigationController) {
            [self.viewController.navigationController pushViewController:readerViewController animated:YES];
        }else {
            [self.viewController presentViewController:navi animated:YES completion:nil];
        }
    }
}

- (void)openFile:(CDVInvokedUrlCommand *)command
{
    self.callBackID = command.callbackId;
    NSDictionary *aParam = [command.arguments firstObject];
    NSString *url = [aParam objectForKey:@"url"];
    url = [url urlEncoding2Times];
    NSDictionary *header = [aParam objectForKey:@"header"];
    NSString *filePath = [aParam objectForKey:@"filePath"];
    NSString *fileId = [aParam objectForKey:@"fileId"];
    NSString *fileName = [aParam objectForKey:@"fileName"];
    NSString *fileType = [aParam objectForKey:@"fileType"];
    NSString *fileSize = [aParam objectForKey:@"fileSize"];
    CMPQuickLookPreviewController *aViewController = [[CMPQuickLookPreviewController alloc] init];
    NSDictionary *extra = [aParam objectForKey:@"extra"];
    AttachmentReaderParam *aReaderParam = [[AttachmentReaderParam alloc] init];
    aReaderParam.fileId = fileId;
    aReaderParam.filePath = filePath;
    aReaderParam.header = header;
    aReaderParam.origin = [extra objectForKey:@"origin"];
    aReaderParam.url = url;
    aReaderParam.fileName = fileName;
    aReaderParam.fileType = fileType;
    aReaderParam.fileSize = fileSize;
    aReaderParam.extra = extra;
    NSString *isShowPrintBtn = [aParam objectForKey:@"isShowPrintBtn"];
    if ([NSString isNotNull:isShowPrintBtn]) {
        aReaderParam.isShowPrintBtn = [isShowPrintBtn boolValue];
    }
    
    NSString *autoSave =[extra objectForKey:@"autoSave"];// ??
    if ([NSString isNotNull:autoSave]) {
        aReaderParam.autoSave = [autoSave boolValue];
    }
    NSString *download = [extra objectForKey:@"download"];
    if ([NSString isNotNull:download]) {
        aReaderParam.canDownload = [download boolValue];
    }
//    aReaderParam.editMode = [extra objectForKey:@"editable"];
    aReaderParam.lastModified = [extra objectForKey:@"lastModified"];
    //来源
    NSString *from = [aParam objectForKey:@"from"];
    aReaderParam.from = [NSString isNull:from]?@"":from;
    if ([url rangeOfString:@"ucFlag=yes"].location != NSNotFound) {
        aReaderParam.fromType = CMPFileFromTypeComeFromUCGroup;
    }

    aViewController.attReaderParam = aReaderParam;
    if ([self.viewController isKindOfClass:NSClassFromString(@"CMPKanbanWebViewController")]) {
        NSDictionary *extDic = ((CMPKanbanWebViewController *)self.viewController).extDic;
        if (extDic[@"targetName"]) {
            NSString *targetName = extDic[@"targetName"];
            id targetType = extDic[@"targetType"];
            NSString *fileName1 = fileName;
            aViewController.attReaderParam.logParams = @{@"targetType":targetType,
                                                         @"targetName":targetName,
                                                         @"fileName":fileName1
                             };
        }
        if (self.viewController.parentViewController) {
            if ([self.viewController.parentViewController isKindOfClass:UINavigationController.class]) {
                [self.viewController.parentViewController.navigationController pushViewController:aViewController animated:YES];
            }else{
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:aViewController];
                [self.viewController presentViewController:nav animated:YES completion:nil];
            }
        }else{
            [self.viewController.navigationController pushViewController:aViewController animated:YES];
        }
    }else{
        [self.viewController.navigationController pushViewController:aViewController animated:YES];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark-
#pragma mark 使用金格插件打开

- (void)openWithWps:(CDVInvokedUrlCommand *)command {
    self.officePlugin.commandDelegate = self.commandDelegate;
    [self.officePlugin openReadonlyDocument:command controller:self.viewController];
}

- (OfficePlugin *)officePlugin {
    if (!_officePlugin) {
        _officePlugin = [[OfficePlugin alloc] init];
    }
    return _officePlugin;
}

#pragma mark - AttachmentReaderViewControllerDelegate

- (void)quickLookPreviewController:(CMPQuickLookPreviewController *)controller
                            sucess:(BOOL)sucess
                           message:(NSString *)message {
    CDVCommandStatus status = sucess ? CDVCommandStatus_OK:CDVCommandStatus_ERROR;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:status messageAsString:message];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callBackID];
    
}

- (void)quickLookPreviewController:(CMPQuickLookPreviewController *)controller openWpsEt:(NSString *)path {
    
}

- (void)editFinished:(NSNotification *)noti
{
    
}

#pragma mark openByThirdApp
//第三方打开
- (void)hasOpenFileByThirdApp:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)openFileByThirdApp:(CDVInvokedUrlCommand *)command
{
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSDictionary *extData = [argumentsMap objectForKey:@"extData"];
    NSString *fileID = [extData objectForKey:@"fileId"];
    NSString *lastModified = [extData objectForKey:@"lastModified"];
    NSString *filePath = [argumentsMap objectForKey:@"path"];
    NSString *fileName = [argumentsMap objectForKey:@"filename"];
    
    if ([filePath hasPrefix:@"http://"] || [filePath hasPrefix:@"https://"]) {
        // 下载文件
        __weak typeof(self) weakself = self;
        [self.downloadTool downloadWithFileID:fileID fileName:fileName lastModified:lastModified url:filePath start:^{
            
        } progressUpdateWithExt:^(float progress, NSInteger recieveBytes, NSInteger totalBytes) {
            
        } success:^(NSString *localPath) {
            [weakself dispatchSyncToMain:^{
                [weakself showInThirdApp:localPath];
            }];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [weakself.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } fail:^(NSError *error) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [weakself.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }
    else{
        filePath = [filePath replaceCharacter:@"file://" withString:@""];
//        [self showInThirdApp:filePath];
        [self dispatchSyncToMain:^{
            [self showInThirdApp:filePath];
        }];

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}


- (CMPDownloadAttachmentTool *)downloadTool {
    if (!_downloadTool) {
        _downloadTool = [[CMPDownloadAttachmentTool alloc] init];
    }
    return _downloadTool;
}

- (void)showInThirdApp:(NSString *)filePath
{
    if (![NSString isNull:filePath]) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSURL *file_URL = [NSURL fileURLWithPath:filePath];
        if ([fileManager fileExistsAtPath:filePath]) {
            if (!self.fileInteractionController) {
                self.fileInteractionController = [UIDocumentInteractionController interactionControllerWithURL:file_URL];
            }
            else {
                self.fileInteractionController.URL = file_URL;
            }
            self.fileInteractionController.delegate = self;
            [self.fileInteractionController presentOpenInMenuFromRect:CGRectMake(self.viewController.view.bounds.size.width - 64, 0, 64, 64) inView:self.viewController.view animated:YES];
            [self beginShowInThirdApp];
        }
        else {
            NSLog(@"分享的文件不存在：%@", filePath);
        }
    }
}
- (void)beginShowInThirdApp {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ThirdAppMenuWillShow object:nil];
}
- (void)endShowInThirdApp {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ThirdAppMenuWillHide object:nil];
}

#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self.viewController;
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller
{
    
    [self endShowInThirdApp];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    [self endShowInThirdApp];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(nullable NSString *)application{
    
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(nullable NSString *)application
{
    
}

- (void)managerDidFinishDownloadFile:(NSDictionary *)info callbackId:(NSString *)callbackId {
    
}
- (void)managerDidFailDownloadFile:(NSDictionary *)info callbackId:(NSString *)callbackId {
    
}

@end
