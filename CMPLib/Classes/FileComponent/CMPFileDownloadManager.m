//
//  CMPAttachmentDownloadTool.m
//  M3
//
//  Created by CRMO on 2017/12/14.
//

#import "CMPFileDownloadManager.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPCommonDBProvider.h>
#import <CMPLib/CMPDownloadFileRecord.h>
#import <CMPLib/CMPFileDownloadManager.h>

NSString * const CMPAttachmentDownloadUrl = @"/rest/attachment/file/%@";

@interface CMPFileDownloadManager()<CMPDataProviderDelegate>
@property (strong, nonatomic) NSMutableDictionary *requestIdDic;
@end

@implementation CMPFileDownloadManager

+ (instancetype)defaultManager
{
    static CMPFileDownloadManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [CMPFileDownloadManager defaultManager];
}

// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [CMPFileDownloadManager defaultManager];
}

// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [CMPFileDownloadManager defaultManager];
}

- (void)downloadWithFileID:(NSString *)fileID
                  fileName:(NSString *)fileName
              lastModified:(NSString *)lastModified
                       url:(NSString *)url
                     start:(FileDownloadStart)start
     progressUpdateWithExt:(FileDownloadProgressUpdateWithExt)update
                   success:(FileDownloadSuccess)success
                      fail:(FileDownloadFail)fail
{
    NSString *localPath = [self localPathWithFileID:fileID lastModified:lastModified];
    if (localPath) {
        if (success) {
            success(localPath);
        }
        return;
    }
    [self requestDownloadWithFileID:fileID fileName:fileName lastModified:lastModified url:url start:start progressUpdateWithExt:update success:success fail:fail];
}

- (NSMutableDictionary *)requestIdDic {
    if (!_requestIdDic) {
        _requestIdDic = [NSMutableDictionary dictionary];
    }
    return _requestIdDic;
}

- (void)deleteWithFileID:(NSString *)fileID {
    NSString *origin = [CMPCore sharedInstance].serverID;
    [[CMPCommonDBProvider sharedInstance] deleteDownloadFileRecordsWithFileId:fileID origin:origin serverID:origin onCompletion:nil];
}

- (void)saveDownloadFileWithPath:(NSString *)aPath
                          fileID:(NSString *)fileId
                        fileName:(NSString *)fileName
                    lastModified:(NSString *)lastModified {
    [CMPFileManager.defaultManager saveDownloadFileRecord:aPath fileId:fileId fileName:fileName lastModified:lastModified];
}

- (void)cancelAllDownload
{
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
}

- (void)cancelDownloadWithFileId:(NSString *)fileId {
    NSString *requestID = [self.requestIdDic objectForKey:fileId];
    [[CMPDataProvider sharedInstance] cancelWithRequestId:requestID];
}

- (NSString *)localPathWithFileID:(NSString *)fileID lastModified:(NSString *)lastModified {
    NSString *filePath = nil;
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    NSString *aOrigin = kCMP_ServerID;
    __block NSArray *findResult = nil;
    [dbConnection downloadFileRecordsWithFileId:fileID
                                   lastModified:lastModified
                                         origin:aOrigin
                                       serverID:aOrigin
                                   onCompletion:^(NSArray *result) {
        findResult = [result copy];
    }];
    if (findResult.count > 0) {
        CMPDownloadFileRecord *aDownloadFile = [findResult objectAtIndex:0];
        NSString *localPath = [aDownloadFile fullLocalPath];
        BOOL isDirectory = NO;
        BOOL exist =  [[NSFileManager defaultManager] fileExistsAtPath:localPath isDirectory:&isDirectory];
        if (exist) {
            NSString *title = aDownloadFile.localName;
            filePath = [CMPFileManager unEncryptFile:localPath fileName:title];
        }
        else {
            [dbConnection deleteOfflineFileRecordsWithFileId:fileID origin:aOrigin serverID:aOrigin ownerID:[CMPCore sharedInstance].userID onCompletion:nil];
        }
    }
    return filePath;
}

- (void)requestDownloadWithFileID:(NSString *)fileID
                         fileName:(NSString *)fileName
                     lastModified:(NSString *)lastModified
                              url:(NSString *)url
                            start:(FileDownloadStart)start
            progressUpdateWithExt:(FileDownloadProgressUpdateWithExt)update
                          success:(FileDownloadSuccess)success
                             fail:(FileDownloadFail)fail
{
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    if ([NSString isNotNull:url]) {
        aDataRequest.requestUrl = url;
    }
    else {
        // 按照默认url地址拼接下载
        aDataRequest.requestUrl = [CMPCore fullUrlForPathFormat:CMPAttachmentDownloadUrl,fileID];
    }
    aDataRequest.downloadDestinationPath = [CMPFileManager downloadFileTempPathWithFileName:fileName];
    
    aDataRequest.requestType = kDataRequestType_FileDownload;
    [self.requestIdDic setObject:aDataRequest.requestID forKey:fileID];
    NSMutableDictionary *mUserInfo = [NSMutableDictionary dictionary];
    mUserInfo[@"startBlock"] = [start copy];
    mUserInfo[@"successBlock"] = [success copy];
    mUserInfo[@"failBlock"] = [fail copy];
    mUserInfo[@"fileID"] = fileID;
    mUserInfo[@"fileName"] = fileName;
    mUserInfo[@"lastModified"] = lastModified;
    mUserInfo[@"progressUpdateWithExtBlock"] = [update copy];
    aDataRequest.userInfo = [mUserInfo copy];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest {
    FileDownloadStart startBlock = aRequest.userInfo[@"startBlock"];
    if (startBlock) {
        startBlock();
    }
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    NSString *aStr = [CMPFileManager pathForDownloadPath:aResponse.downloadDestinationPath responseHeaders:aResponse.responseHeaders];
    NSString *fileID = aRequest.userInfo[@"fileID"];
    NSString *lastModified = aRequest.userInfo[@"lastModified"];
    NSString *fileName = aRequest.userInfo[@"fileName"];
    [self saveDownloadFileWithPath:aStr fileID:fileID fileName:fileName lastModified:lastModified];
    FileDownloadSuccess successBlock = aRequest.userInfo[@"successBlock"];
    if (successBlock) {
        successBlock(aStr);
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    FileDownloadFail failBlock = aRequest.userInfo[@"failBlock"];
    if (failBlock) {
        failBlock(error);
    }
}

- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt {
    float progress = [aExt[@"progress"] floatValue];
    NSInteger recieveBytes = [aExt[@"receiveBytes"] integerValue];
    NSInteger totalBytes = [aExt[@"totalBytes"] integerValue];
    FileDownloadProgressUpdateWithExt progressUpdateWithExtBlock = aRequest.userInfo[@"progressUpdateWithExtBlock"];
    if (progressUpdateWithExtBlock) {
        progressUpdateWithExtBlock(progress,recieveBytes,totalBytes);
    }
}

@end
