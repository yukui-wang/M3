//
//  CMPAttachmentDownloadTool.m
//  M3
//
//  Created by CRMO on 2017/12/14.
//

#import "CMPDownloadAttachmentTool.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPCommonDBProvider.h>
#import <CMPLib/ZipArchiveUtils.h>
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPDownloadFileRecord.h>

NSString * const AttachmentDownloadUrl = @"/rest/attachment/file/%@";

@interface CMPDownloadAttachmentTool()<CMPDataProviderDelegate>
@property (strong, nonatomic) NSString *requestID;
@property (strong, nonatomic) NSMutableDictionary *requestIdDic;
@property (strong, nonatomic) NSString *fileID;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *lastModified;
@property (copy, nonatomic) DownloadAttachmentStart startBlock;
@property (copy, nonatomic) DownloadAttachmentProgressUpdate progressUpdateBlock;
@property (copy, nonatomic) DownloadAttachmentProgressUpdateWithExt progressUpdateWithExtBlock;
@property (copy, nonatomic) DownloadAttachmentSuccess successBlock;
@property (copy, nonatomic) DownloadAttachmentFail failBlock;
@end

@implementation CMPDownloadAttachmentTool

- (void)downloadWithFileID:(NSString *)fileID
                  fileName:(NSString *)fileName
              lastModified:(NSString *)lastModified
                     start:(DownloadAttachmentStart)start
            progressUpdate:(DownloadAttachmentProgressUpdate)update
                   success:(DownloadAttachmentSuccess)success
                      fail:(DownloadAttachmentFail)fail {
    [self downloadWithFileID:fileID fileName:fileName lastModified:lastModified headers:nil start:start progressUpdate:update success:success fail:fail];
}

- (void)downloadWithFileID:(NSString *)fileID
                  fileName:(NSString *)fileName
              lastModified:(NSString *)lastModified
                   headers:(NSDictionary *)headers
                     start:(DownloadAttachmentStart)start
            progressUpdate:(DownloadAttachmentProgressUpdate)update
                   success:(DownloadAttachmentSuccess)success
                      fail:(DownloadAttachmentFail)fail {
    self.startBlock = start;
    self.progressUpdateBlock = update;
    self.successBlock = success;
    self.failBlock = fail;
    self.fileID = fileID;
    self.fileName = fileName;
    self.lastModified = lastModified;
    
    NSString *localPath = [self localPathWithFileID:fileID lastModified:lastModified];
    if (localPath) {
        if (success) {
            success(localPath);
        }
        return;
    }
    
    [self requestDownloadWithFileID:fileID fileName:fileName url:nil headers:headers];
}


- (void)downloadWithFileID:(NSString *)fileID
                  fileName:(NSString *)fileName
              lastModified:(NSString *)lastModified
                     start:(DownloadAttachmentStart)start
     progressUpdateWithExt:(DownloadAttachmentProgressUpdateWithExt)update
                   success:(DownloadAttachmentSuccess)success
                      fail:(DownloadAttachmentFail)fail {
    [self downloadWithFileID:fileID fileName:fileName lastModified:lastModified url:nil start:start progressUpdateWithExt:update success:success fail:fail];
}

- (void)downloadWithFileID:(NSString *)fileID
                  fileName:(NSString *)fileName
              lastModified:(NSString *)lastModified
                       url:(NSString *)url
                     start:(DownloadAttachmentStart)start
     progressUpdateWithExt:(DownloadAttachmentProgressUpdateWithExt)update
                   success:(DownloadAttachmentSuccess)success
                      fail:(DownloadAttachmentFail)fail {
    self.startBlock = start;
    self.progressUpdateWithExtBlock = update;
    self.successBlock = success;
    self.failBlock = fail;
    self.fileID = fileID;
    self.fileName = fileName;
    self.lastModified = lastModified;
    
    NSString *localPath = [self localPathWithFileID:fileID lastModified:lastModified];
    if (localPath) {
        if (success) {
            success(localPath);
        }
        return;
    }
    [self requestDownloadWithFileID:fileID fileName:fileName url:url headers:nil];
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

- (void)cancelDownload {
    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.requestID];
}

- (void)cancelDownloadWithFileId:(NSString *)fileId {
    NSString *requestID = [self.requestIdDic objectForKey:fileId];
    [[CMPDataProvider sharedInstance] cancelWithRequestId:requestID];
}

- (NSString *)localPathWithFileID:(NSString *)fileID lastModified:(NSString *)lastModified {
    NSString *filePath = nil;
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    NSString *aOrigin = kCMP_ServerID;//[CMPCore sharedInstance].serverID;
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

- (void)requestDownloadWithFileID:(NSString *)fileID fileName:(NSString *)fileName url:(NSString *)url headers:(NSDictionary *)headers {
    if ([NSString isNull:fileID] && [NSString isNull:url]) {
        return;
    }
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    if ([NSString isNotNull:url]) {
        aDataRequest.requestUrl = url;
    }
    else {
        // 按照默认url地址拼接下载
        aDataRequest.requestUrl = [CMPCore fullUrlForPathFormat:AttachmentDownloadUrl,fileID];
    }
    if (fileName && ![aDataRequest.requestUrl containsString:@"fileName="]) {
        NSString *escapedFileName = [fileName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [aDataRequest.requestUrl appendHtmlUrlParam:@"fileName" value:escapedFileName];
    }
    aDataRequest.downloadDestinationPath = [CMPFileManager downloadFileTempPathWithFileName:fileName];
    
    aDataRequest.requestType = kDataRequestType_FileDownload;
    self.requestID = aDataRequest.requestID;
    [self.requestIdDic setObject:aDataRequest.requestID forKey:fileID];
    NSMutableDictionary *mUserInfo = [NSMutableDictionary dictionary];
    mUserInfo[@"startBlock"] = [self.startBlock copy];
    mUserInfo[@"successBlock"] = [self.successBlock copy];
    mUserInfo[@"failBlock"] = [self.failBlock copy];
    mUserInfo[@"fileID"] = self.fileID;
    mUserInfo[@"fileName"] = self.fileName;
    mUserInfo[@"lastModified"] = self.lastModified;
    mUserInfo[@"progressUpdateBlock"] = [self.progressUpdateBlock copy];
    mUserInfo[@"progressUpdateWithExtBlock"] = [self.progressUpdateWithExtBlock copy];
    aDataRequest.userInfo = [mUserInfo copy];
    if ([headers isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableHeader = [[CMPDataProvider headers] mutableCopy];
        [mutableHeader addEntriesFromDictionary:headers];
        aDataRequest.headers =  [mutableHeader copy];
    }
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest {
    DownloadAttachmentStart startBlock = aRequest.userInfo[@"startBlock"];
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
    DownloadAttachmentSuccess successBlock = aRequest.userInfo[@"successBlock"];
    if (successBlock) {
        successBlock(aStr);
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    DownloadAttachmentFail failBlock = aRequest.userInfo[@"failBlock"];
    if (failBlock) {
        failBlock(error);
    }
}

- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt {
    float progress = [aExt[@"progress"] floatValue];
    NSInteger recieveBytes = [aExt[@"receiveBytes"] integerValue];
    NSInteger totalBytes = [aExt[@"totalBytes"] integerValue];
    DownloadAttachmentProgressUpdate progressUpdateBlock = aRequest.userInfo[@"progressUpdateBlock"];
    DownloadAttachmentProgressUpdateWithExt progressUpdateWithExtBlock = aRequest.userInfo[@"progressUpdateWithExtBlock"];
    if (progressUpdateBlock) {
        progressUpdateBlock(progress);
    }
    
    if (progressUpdateWithExtBlock) {
        progressUpdateWithExtBlock(progress,recieveBytes,totalBytes);
    }
}

@end
