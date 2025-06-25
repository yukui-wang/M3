//
//  OfficePlugin.m
//  M3
//
//  Created by CRMO on 2017/12/14.
//

#import "OfficePlugin.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPDownloadAttachmentTool.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPCommonDBProvider.h>
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/ZipArchiveUtils.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPCommonTool.h>
#import "KWOfficeApi.h"
#import <CMPLib/CMPDownloadFileRecord.h>
#import <CMPLib/NSDate+CMPDate.h>

@interface OfficePlugin()<CMPDataProviderDelegate, KWOfficeApiDelegate>
@property (strong, nonatomic) NSString *callbackID;
@property (strong, nonatomic) NSString *fileID;
@property (strong, nonatomic) NSString *lastModified;
@property (strong, nonatomic) NSString *origin;
/** 文件存储路径 **/
@property (strong, nonatomic) NSString *filePath;
/** 文件全名，包含后缀名 **/
@property (strong, nonatomic) NSString *fullFileName;
@property (strong, nonatomic) CMPDownloadAttachmentTool *downloadTool;
@property (strong, nonatomic) NSDictionary *wpsConfig;
@property (weak, nonatomic) UIViewController *hudViewController;

@end

@implementation OfficePlugin

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pluginInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetKWOfficeApiService) name:kNotificationName_ResetKWOfficeService object:nil];
}

- (void)resetKWOfficeApiService {
    [[KWOfficeApi sharedInstance] resetKWOfficeApiServiceWithDelegate:self];
}

#pragma mark-
#pragma mark 插件方法

- (void)openDocument:(CDVInvokedUrlCommand *)command {
    self.callbackID = command.callbackId;
    
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *fileName = [argumentsMap objectForKey:@"filename"];
    NSString *fileType = [argumentsMap objectForKey:@"fileType"];
    NSDictionary *headers = [argumentsMap objectForKey:@"headers"];
    self.fullFileName = [fileName stringByAppendingString:fileType];
    
    NSDictionary *extData = [argumentsMap objectForKey:@"extData"];
    NSString *fileID = [extData objectForKey:@"fileId"];
    NSString *lastModified = [extData objectForKey:@"lastModified"];
    NSString *wpsKey = [extData objectForKey:@"iOSWpsKey"];
    NSDictionary *wpsConfig = [extData objectForKey:@"iOSWpsConfig"];
    self.fileID = fileID;
    self.lastModified = lastModified;

    // WPS不可用
    if (![self _checkWpsReadyWithWpsKey:wpsKey]) {
        return;
    }
    
    NSString *firstTag = argumentsMap[@"isFirstOpen"];
    if (firstTag && [NSString isNotNull:firstTag]) {
        NSInteger isFirstOpen = [firstTag integerValue];
        if (isFirstOpen == 1) {
            lastModified = [[NSDate date] cmp_secondStr];
            NSLog(@"isFirstOpen - rsj更新时间%@",lastModified);
        }
    }
    
    __weak typeof(self) weakself = self;
    // 下载文件
    [self.downloadTool downloadWithFileID:fileID
                                 fileName:fileName
                             lastModified:lastModified
                                  headers:headers
                                    start:^{
                                        [weakself.viewController cmp_showProgressHUD];
                                    }
                           progressUpdate:nil
                                  success:^(NSString *localPath){
                                      [weakself.viewController cmp_hideProgressHUD];
                                      NSLog(@"office---下载success:%@", localPath);
                                      weakself.filePath = localPath;
//                                      [weakself handleWPSDocumentWithPath:localPath config:wpsConfig];
                                      [weakself handleWPSDocumentNoCallBackWithPath:localPath config:wpsConfig];
            
                                  }
                                     fail:^(NSError *error) {
        [weakself.viewController cmp_hideProgressHUD];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"common_downloadFileFailed")];
        [weakself.commandDelegate sendPluginResult:result callbackId:weakself.callbackID];
    }];
}

- (void)clearDocument:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *fileID = [argumentsMap objectForKey:@"fileId"];
    NSString *lastModified = [argumentsMap objectForKey:@"lastModified"];
    
    if ([NSString isNull:fileID] ||
        [NSString isNull:lastModified]) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    [self.downloadTool deleteWithFileID:fileID];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"删除成功"];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)closeDocument:(CDVInvokedUrlCommand *)command {
}

- (void)openReadonlyDocument:(CDVInvokedUrlCommand *)command controller:(UIViewController *)controller {
    self.callbackID = command.callbackId;
    _hudViewController = controller;
    
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *fileName = [argumentsMap objectForKey:@"filename"];
//    NSString *fileType = [argumentsMap objectForKey:@"fileType"];
    NSString *path = [argumentsMap objectForKey:@"path"];
    
    NSDictionary *extData = [argumentsMap objectForKey:@"extData"];
    NSString *fileID = [extData objectForKey:@"fileId"];
    NSString *lastModified = [extData objectForKey:@"lastModified"];
    NSString *wpsKey = [extData objectForKey:@"iOSWpsKey"];
    NSDictionary *wpsConfig = [extData objectForKey:@"iOSWpsConfig"];
    NSString *origin = kCMP_ServerID;//[extData objectForKey:@"origin"];
    
    self.fileID = fileID;
    self.fullFileName = fileName;
    self.lastModified = lastModified;
    self.wpsConfig = wpsConfig;
    self.origin = origin;
    
    // WPS不可用
    if (![self _checkWpsReadyWithWpsKey:wpsKey]) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"copyRight或wpsKey错误"];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackID];
        return;
    }
    
    if ([path hasPrefix:@"http://"] || [path hasPrefix:@"https://"]) {
        // 下载文件
        CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
        //本地下载的记录
        __block NSArray *findResult = nil;
        NSString *serverID = [CMPCore sharedInstance].serverID;
        NSString *ownerID = [CMPCore sharedInstance].userID;
        [dbConnection downloadFileRecordsWithFileId:fileID
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
                NSString *title = aDownloadFile.fileName;
                NSString *filePath = [CMPFileManager unEncryptFile:localPath fileName:title];
                self.filePath = filePath;
                [self handleWPSDocumentWithPath:filePath config:wpsConfig];
                return;
            }
            else {
                [dbConnection deleteOfflineFileRecordsWithFileId:fileID origin:origin serverID:serverID ownerID:ownerID onCompletion:nil];
            }
        }
        else {
            //离线文档的记录
            [dbConnection offlineFileRecordsWithFileId:fileID
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
                    self.filePath = filePath;
                    [self handleWPSDocumentWithPath:filePath config:wpsConfig];
                    return;
                }
            }
        }
        
        [self downloadfileWithUrl:path fileName:fileName];
    } else { // 本地路径，可以不用下载
        self.filePath = path;
        [self handleWPSDocumentWithPath:path config:wpsConfig];
    }
}

- (BOOL)_checkWpsReadyWithWpsKey:(NSString *)wpsKey {
    if (!IOS9_Later) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"device_ios_low")];
        [self.commandDelegate sendPluginResult:result callbackId:_callbackID];
        return NO;
    }
    
    if ([NSString isNull:wpsKey]) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"iAppOffice_unauthorization")];
        [self.commandDelegate sendPluginResult:result callbackId:_callbackID];
        return NO;
    }
    
    if (![KWOfficeApi isAppstoreWPSInstalled] &&
        ![KWOfficeApi isEnterpriseWPSInstalled]) {
        [KWOfficeApi goDownloadWPS];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"please_install_wps")];
        [self.commandDelegate sendPluginResult:result callbackId:_callbackID];
        return NO;
    }
    
    [self registerWpsKey:wpsKey];
    
    return YES;
}

#pragma mark-
#pragma mark 文件下载

- (void)downloadfileWithUrl:(NSString *)aRequestUrl fileName:(NSString *)aFileName {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.requestUrl = aRequestUrl;
    aDataRequest.downloadDestinationPath = [CMPFileManager downloadFileTempPathWithFileName:aFileName];
    aDataRequest.requestType = kDataRequestType_FileDownload;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest {
    [_hudViewController cmp_showProgressHUD];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    NSString *aStr = [CMPFileManager pathForDownloadPath:aResponse.downloadDestinationPath responseHeaders:aResponse.responseHeaders];
    [CMPFileManager.defaultManager saveDownloadFileRecord:aStr fileId:self.fileID fileName:self.fullFileName lastModified:self.lastModified];
    self.filePath = aStr;
    [self handleWPSDocumentWithPath:self.filePath config:self.wpsConfig];
    [_hudViewController cmp_hideProgressHUD];
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    [_hudViewController cmp_hideProgressHUD];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"common_downloadFileFailed")];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackID];
}

#pragma mark-
#pragma mark 内部方法

- (void)registerWpsKey:(NSString *)wpsKey {
    [KWOfficeApi registerApp:wpsKey];
    [KWOfficeApi setLogToConsole:YES];
//    [KWOfficeApi registerApp:@"78530E3D71A93B61CDD292808343C19C"];
}

- (void)handleWPSDocumentWithPath:(NSString *)filePath config:(NSDictionary *)config {
    NSDictionary *policy = nil;
    if (config || [config isKindOfClass:[NSDictionary class]]) {
        policy = [OfficePlugin plicyWithConfig:config];
    } else {
        // 兼容低版本，默认权限
        policy = @{@"public.document.editEnable" : @"1",
                  @"wps.shell.editmode.toolbar.revision" : @"1",
                  @"wps.shell.editmode.toolbar.mark": @"1",
                  @"wps.shell.editmode.toolbar.revisionEnable": @"1",
                  @"wps.shell.editmode.toolbar.markEnable": @"1",
                  @"wps.shell.readmode.toolbar.revision":@"1",
                  @"wps.document.revision.username": [CMPCore sharedInstance].userName
                  };
    }
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    BOOL openWpsOk = [[KWOfficeApi sharedInstance]
     sendFileData:fileData
     withFileName:self.fullFileName
     callback:nil
     delegate:self
     policy:policy
     optionalInfo:nil
     error:&error
     completion:^(NSString * _Nullable fileState, NSString * _Nullable fileIdentifier) {
         
     }];
    
    if (openWpsOk) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:self.filePath];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackID];
    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"reopen_wps")];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackID];
    }
}
- (void)handleWPSDocumentNoCallBackWithPath:(NSString *)filePath config:(NSDictionary *)config {
    NSDictionary *policy = nil;
    if (config || [config isKindOfClass:[NSDictionary class]]) {
        policy = [OfficePlugin plicyWithConfig:config];
    } else {
        // 兼容低版本，默认权限
        policy = @{@"public.document.editEnable" : @"1",
                  @"wps.shell.editmode.toolbar.revision" : @"1",
                  @"wps.shell.editmode.toolbar.mark": @"1",
                  @"wps.shell.editmode.toolbar.revisionEnable": @"1",
                  @"wps.shell.editmode.toolbar.markEnable": @"1",
                  @"wps.shell.readmode.toolbar.revision":@"1",
                  @"wps.document.revision.username": [CMPCore sharedInstance].userName
                  };
    }
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    BOOL openWpsOk = [[KWOfficeApi sharedInstance]
     sendFileData:fileData
     withFileName:self.fullFileName
     callback:nil
     delegate:self
     policy:policy
     optionalInfo:nil
     error:&error
     completion:^(NSString * _Nullable fileState, NSString * _Nullable fileIdentifier) {
         
     }];
    
    if (openWpsOk) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:self.filePath];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackID];
    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"reopen_wps")];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackID];
    }
}

/**
 转换H5传过来的配置信息为金格SDK的配置

 @param config H5传过来的配置信息
 @return 金格SDK的配置
 */
+ (NSDictionary *)plicyWithConfig:(NSDictionary *)config {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSDictionary *iAppConfig = [OfficePlugin iAppConfig];
    [config enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
        if ([NSString isNull:key] ||
            [NSString isNull:value]) {
            return;
        }
        NSString *aKey = iAppConfig[key];
        if(aKey) {
            [dic setObject:value forKey:aKey];
        }
    }];
    if (![dic objectForKey:@"iAppOfficeRightsWordRevisionUserName"]) {
        [dic setObject:[CMPCore sharedInstance].userName forKey:@"wps.document.revision.username"];
    }
    [dic setObject:@"1" forKey:@"public.document.handwritingInk"];
    [dic setObject:@"1" forKey:@"public.document.highlight"];
    [dic setObject:@"1" forKey:@"public.document.strikeOut"];
    [dic setObject:@"1" forKey:@"public.document.underline"];
    [dic setObject:@"1" forKey:@"public.document.shape"];
    [dic setObject:@"1" forKey:@"public.document.stamp"];
    [dic setObject:@"1" forKey:@"public.document.signature"];
    return dic;
}

#pragma mark-
#pragma mark iAppOfficeApi Delegate

// 在WPS中点击保存数据时调用
- (void)KWOfficeApiDidReceiveData:(nonnull NSDictionary *)dict {
    NSData *fileData = [dict objectForKey:@"Body"];
    [fileData writeToFile:self.filePath atomically:YES];
    [CMPFileManager.defaultManager saveDownloadFileRecord:self.filePath fileId:self.fileID fileName:self.fullFileName lastModified:self.lastModified];
    
    //保存后回调一次
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:self.filePath];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:_callbackID];
}

// WPS完成编辑，退回到当前App时调用
- (void)KWOfficeApiDidFinished {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:self.filePath];
    [self.commandDelegate sendPluginResult:result callbackId:_callbackID];
}

// WPS结束编辑，并退回到后台时调用
- (void)KWOfficeApiDidAbort {
    NSLog(@"AppDelegate: <-[officeDidAbort]>");
    //回调一次
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:self.filePath];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:_callbackID];
}

// 和WPS通信传输过程中出现问题调用
- (void)KWOfficeApiDidCloseWithError:(NSError *)error {
    if (error) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"reopen_wps")];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:_callbackID];
    }else{
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:self.filePath];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:_callbackID];
    }
}

#pragma mark-
#pragma mark Getter&Setter

- (CMPDownloadAttachmentTool *)downloadTool {
    if (!_downloadTool) {
        _downloadTool = [[CMPDownloadAttachmentTool alloc] init];
    }
    return _downloadTool;
}

/** Office 权限映射 **/
+ (NSDictionary *)iAppConfig {
    return
    @{@"iAppOfficeRightsPublicIsBackup" : @"public.shell.backup",
      @"iAppOfficeRightsPublicIsWatermark" : @"public.document.watermark",
      @"iAppOfficeRightsPublicBackupInterval" : @"public.shell.backup.interval",
      @"iAppOfficeRightsPublicIsShare" : @"public.document.share",
      @"iAppOfficeRightsPublicIsPrint" : @"public.document.print",
      @"iAppOfficeRightsPublicIsSendMail" : @"public.document.sendMail",
      @"iAppOfficeRightsPublicIsExportPDF" : @"public.document.exportPDF",
      @"iAppOfficeRightsPublicIsSaveAs" : @"public.document.saveAs",
      @"iAppOfficeRightsPublicIsLocalization" : @"public.document.localization",
      @"iAppOfficeRightsPublicIsEditEnable" : @"public.document.editEnable",
      @"iAppOfficeRightsPublicIsOpenInEditMode" : @"public.document.openInEditMode",
      @"iAppOfficeRightsPublicIsHandwritingLnk" : @"public.document.handwritingInk",
      @"iAppOfficeRightsPublicIsHighlight" : @"public.document.highlight", // 高亮
      @"iAppOfficeRightsPublicIsStrikeOut" : @"public.document.strikeOut", // 删除线
      @"iAppOfficeRightsPublicIsUnderline" : @"public.document.underline", // 下划线
      @"iAppOfficeRightsPublicIsShape" : @"public.document.shape", // 图形
      @"iAppOfficeRightsPublicIsStamp" : @"public.document.stamp", // 插入图章
      @"iAppOfficeRightsPublicIsSignature" : @"public.document.signature", // 插入签名
      @"iAppOfficeRightsPublicIsWirelessProjection" : @"public.document.wirelessProjection",
      @"iAppOfficeRightsPublicIsDictionary" : @"public.document.dictionary",
      @"iAppOfficeRightsPublicIsWireProjection" : @"public.document.wireProjection",
      @"iAppOfficeRightsPublicIsCopyEnable" : @"public.document.copyEnable",
      @"iAppOfficeRightsPublicIsScreenCapture" : @"public.document.screenCapture",
      @"iAppOfficeRightsWordEditModeIsInsertPicture" : @"public.document.voiceRecord",
      @"iAppOfficeRightsWordEditModeIsRevision" : @"wps.shell.editmode.toolbar.revision",
      @"iAppOfficeRightsWordEditModeIsMark" : @"wps.shell.editmode.toolbar.mark",
      @"iAppOfficeRightsWordEditModeIsRevisionEnable" : @"wps.shell.editmode.toolbar.revisionEnable",
      @"iAppOfficeRightsWordEditModeIsMarkEnable" : @"wps.shell.editmode.toolbar.markEnable",
      @"iAppOfficeRightsWordReadModeIsRevision" : @"wps.shell.readmode.toolbar.revision",
      @"iAppOfficeRightsWordReadModeIsAddCommentEnable" : @"wps.shell.readmode.addCommentEnable",
      @"iAppOfficeRightsWordReadModeIsCommentEditEnable" : @"wps.shell.readmode.commentEditEnable",
      @"iAppOfficeRightsWordRevisionUserName" : @"wps.document.revision.username"
      };
}

@end
