//
//  CMPAttachmentDownloadTool.h
//  从V5接口下载附件 “seeyon/rest/attachment/file/2859682261574829588”
//  M3
//
//  Created by CRMO on 2017/12/14.
//

#import <CMPLib/CMPObject.h>

typedef void(^FileDownloadStart)(void);
typedef void(^FileDownloadProgressUpdateWithExt)(float progress,NSInteger recieveBytes,NSInteger totalBytes);
typedef void(^FileDownloadSuccess)(NSString *localPath);
typedef void(^FileDownloadFail)(NSError *error);

@interface CMPFileDownloadManager : CMPObject

+ (instancetype)defaultManager;

/**
 获取附件的本地路径
 */
- (NSString *)localPathWithFileID:(NSString *)fileID lastModified:(NSString *)lastModified;

- (void)downloadWithFileID:(NSString *)fileID
             fileName:(NSString *)fileName
         lastModified:(NSString *)lastModified
                  url:(NSString *)url
                start:(FileDownloadStart)start
progressUpdateWithExt:(FileDownloadProgressUpdateWithExt)update
              success:(FileDownloadSuccess)success
                 fail:(FileDownloadFail)fail;
/**
 删除文件
 */
- (void)deleteWithFileID:(NSString *)fileID;

/**
 取消所有下载
 */
- (void)cancelAllDownload;

- (void)cancelDownloadWithFileId:(NSString *)fileId;

@end
