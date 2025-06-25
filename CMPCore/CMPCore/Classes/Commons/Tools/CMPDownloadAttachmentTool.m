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

NSString * const AttachmentDownloadUrl = @"%@/rest/attachment/file/%@";

@interface CMPDownloadAttachmentTool()<CMPDataProviderDelegate>
@property (strong, nonatomic) NSString *requestID;
@property (strong, nonatomic) NSMutableDictionary *requestIdDic;
@property (strong, nonatomic) NSString *fileID;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *lastModified;
@property (copy, nonatomic) DownloadAttachmentStart startBlock;
@property (copy, nonatomic) DownloadAttachmentProgressUpdate progressUpdateBlock;
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
    
    [self requestDownloadWithFileID:fileID fileName:fileName];
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
                    lastModified:(NSString *)lastModified {
   
       NSString *downloadPath = aPath;
       NSString *origin = [CMPCore sharedInstance].serverID;
       NSString *title = [aPath lastPathComponent];
       
       //压缩文件
       NSString *aStorePath = [CMPFileManager downloadFilePath];
       NSString *localName = title;
       NSString *attaPath = nil;
       CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
       NSString *uuidStr = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
       CFRelease(uuidObject);
       localName = [uuidStr stringByAppendingPathExtension:@"zip"];
       attaPath = [aStorePath stringByAppendingPathComponent:localName];
       [ZipArchiveUtils zipArchive:downloadPath zipPath:attaPath];
       
       // 去掉 homedictionary
       NSString *aHomePath = [NSString stringWithFormat:@"%@/", [CMPFileManager homeDirectory]];
       attaPath = [attaPath replaceCharacter:aHomePath withString:@""];
       
       // create SyDownloadFile instance
       CMPOfflineFileRecord *aDownloadFile = [[CMPOfflineFileRecord alloc] init];
       aDownloadFile.fileId = fileId;
       aDownloadFile.fileName = title;
       aDownloadFile.localName = title;
       aDownloadFile.fileSuffix = title.pathExtension;
       aDownloadFile.savePath = attaPath;
       aDownloadFile.origin = origin;
       aDownloadFile.modifyTime = lastModified;
       aDownloadFile.createDate = @"";
       aDownloadFile.extend2 = @"来自:协同";//来源from
       
       NSString *mfrFilePath = [aPath stringByReplacingOccurrencesOfString:kFileTempPath withString:kLocalSavedFilePath];
       CMPFileManagementRecord *record = [[CMPFileManagementRecord alloc] init];
       record.lastModify = CMPCommonTool.getCurrentTimeStamp;
       record.filePath = mfrFilePath;
       record.fileUrl = mfrFilePath;
       record.fileType = [CMPFileTypeHandler getFileMineTypeWithFilePath:downloadPath];
       record.from = aDownloadFile.extend2;
       record.fileId = fileId;
       record.fileName = title;
       
       
       NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
       [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
       NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
       dateFormatter = nil;
       
       aDownloadFile.downloadTime = destDateString;
       aDownloadFile.creatorName = @"";
       aDownloadFile.serverId = [CMPCore sharedInstance].serverID;
       
       long long aLen = [CMPFileManager fileSizeAtPath:downloadPath];
       aDownloadFile.fileSize = [NSString stringWithLongLong:aLen];
       record.fileSize = aDownloadFile.fileSize;
       aDownloadFile.extend1 = record.jsonString;
       
       CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
       [dbConnection deleteDownloadFileRecordsWithFileId:fileId origin:origin serverID:[CMPCore sharedInstance].serverID onCompletion:nil];
       [dbConnection insertDownloadFileRecord:aDownloadFile onCompletion:nil];
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
    NSString *aOrigin = [CMPCore sharedInstance].serverID;
    __block NSArray *findResult = nil;
    [dbConnection downloadFileRecordsWithFileId:fileID
                                   lastModified:lastModified
                                         origin:aOrigin
                                       serverID:aOrigin
                                   onCompletion:^(NSArray *result) {
                                       findResult = [result copy];
                                   }];
    if (findResult.count > 0) {
        CMPOfflineFileRecord *aDownloadFile = [findResult objectAtIndex:0];
        NSString *localPath = [aDownloadFile fullLocalPath];
        BOOL isDirectory = NO;
        BOOL exist =  [[NSFileManager defaultManager] fileExistsAtPath:localPath isDirectory:&isDirectory];
        if (exist) {
            NSString *title = aDownloadFile.fileName;
            filePath = [CMPFileManager unEncryptFile:localPath fileName:title];
        }
        else {
            [dbConnection deleteOfflineFileRecordsWithFileId:fileID origin:aOrigin serverID:aOrigin ownerID:[CMPCore sharedInstance].userID onCompletion:nil];
        }
    }
    return filePath;
}

- (void)requestDownloadWithFileID:(NSString *)fileID fileName:(NSString *)fileName {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"Get";
    aDataRequest.requestUrl = [NSString stringWithFormat:AttachmentDownloadUrl, [CMPCore sharedInstance].serverurlForSeeyon, fileID];
    aDataRequest.downloadDestinationPath = [CMPFileManager downloadFileTempPathWithFileName:fileID];
    if ([NSString isNotNull:fileName]) {
         aDataRequest.downloadDestinationPath = [CMPFileManager downloadFileTempPathWithFileName:fileName];
    } else {
        aDataRequest.downloadDestinationPath = [CMPFileManager downloadFileTempPathWithFileName:fileID];
    }
    aDataRequest.requestType = kDataRequestType_FileDownload;
    self.requestID = aDataRequest.requestID;
    [self.requestIdDic setObject:aDataRequest.requestID forKey:fileID];
    aDataRequest.userInfo = @{@"startBlock" : [self.startBlock copy],
                              @"progressUpdateBlock" : [self.progressUpdateBlock copy],
                              @"successBlock" : [self.successBlock copy],
                              @"failBlock" : [self.failBlock copy],
                              @"fileID" : self.fileID,
                              @"fileName" : self.fileName,
                              @"lastModified" : self.lastModified
    };
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
    [self saveDownloadFileWithPath:aStr fileID:fileID lastModified:lastModified];
    DownloadAttachmentSuccess successBlock = aRequest.userInfo[@"successBlock"];
    if (successBlock) {
        successBlock(aStr);
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    DownloadAttachmentFail failBlock = aRequest.userInfo[@"failBlock"];
    if (failBlock) {
        failBlock();
    }
}

- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt {
    float aProgress = [[aExt objectForKey:@"progress"] floatValue];
    DownloadAttachmentProgressUpdate progressUpdateBlock = aRequest.userInfo[@"progressUpdateBlock"];
    if (progressUpdateBlock) {
        progressUpdateBlock(aProgress);
    }
}

@end
