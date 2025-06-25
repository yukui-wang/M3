//
//  CMPAttachmentDownloadTool.h
//  从V5接口下载附件 “seeyon/rest/attachment/file/2859682261574829588”
//  M3
//
//  Created by CRMO on 2017/12/14.
//

#import <CMPLib/CMPObject.h>

typedef void(^DownloadAttachmentStart)(void);
typedef void(^DownloadAttachmentProgressUpdate)(float progress);
typedef void(^DownloadAttachmentProgressUpdateWithExt)(float progress,NSInteger recieveBytes,NSInteger totalBytes);
typedef void(^DownloadAttachmentSuccess)(NSString *localPath);
typedef void(^DownloadAttachmentFail)(NSError *error);

@interface CMPDownloadAttachmentTool : CMPObject

/**
 获取附件的本地路径
 */
- (NSString *)localPathWithFileID:(NSString *)fileID lastModified:(NSString *)lastModified;

/**
下载附件，如果本地存在直接返回本地的
*/
- (void)downloadWithFileID:(NSString *)fileID
                  fileName:(NSString *)fileName
              lastModified:(NSString *)lastModified
                   headers:(NSDictionary *)headers
                     start:(DownloadAttachmentStart)start
            progressUpdate:(DownloadAttachmentProgressUpdate)update
                   success:(DownloadAttachmentSuccess)success
                      fail:(DownloadAttachmentFail)fail;

/**
 下载附件，如果本地存在直接返回本地的
 */
- (void)downloadWithFileID:(NSString *)fileID
                  fileName:(NSString *)fileName
              lastModified:(NSString *)lastModified
                     start:(DownloadAttachmentStart)start
            progressUpdateWithExt:(DownloadAttachmentProgressUpdateWithExt)update
                   success:(DownloadAttachmentSuccess)success
                      fail:(DownloadAttachmentFail)fail;
/**
 下载附件，如果本地存在直接返回本地的
 */
- (void)downloadWithFileID:(NSString *)fileID
                  fileName:(NSString *)fileName
              lastModified:(NSString *)lastModified
                     start:(DownloadAttachmentStart)start
            progressUpdate:(DownloadAttachmentProgressUpdate)update
                   success:(DownloadAttachmentSuccess)success
                      fail:(DownloadAttachmentFail)fail;


- (void)downloadWithFileID:(NSString *)fileID
             fileName:(NSString *)fileName
         lastModified:(NSString *)lastModified
                  url:(NSString *)url
                start:(DownloadAttachmentStart)start
progressUpdateWithExt:(DownloadAttachmentProgressUpdateWithExt)update
              success:(DownloadAttachmentSuccess)success
                 fail:(DownloadAttachmentFail)fail;
/**
 删除文件
 */
- (void)deleteWithFileID:(NSString *)fileID;

/**
 手动将文件存到缓存中
 */
- (void)saveDownloadFileWithPath:(NSString *)aPath
                          fileID:(NSString *)fileID
                        fileName:(NSString *)fileName
                    lastModified:(NSString *)lastModified;

/**
 取消下载
 */
- (void)cancelDownload;

- (void)cancelDownloadWithFileId:(NSString *)fileId;

@end
