//
//  SyFileManager.h
//  M1Core
//
//  Created by admin on 12-10-19.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//
//
#import <Foundation/Foundation.h>
#import "CMPObject.h"
#import "CMPFile.h"


typedef NS_ENUM(NSInteger, QK_AttchmentType) {
    QK_AttchmentType_Image = 1,
    QK_AttchmentType_Gif,
    QK_AttchmentType_AUDIO,
    QK_AttchmentType_PRESS,
    QK_AttchmentType_TEXT,
    QK_AttchmentType_WPS,
    QK_AttchmentType_ET,
    QK_AttchmentType_Office_Doc,
    QK_AttchmentType_Office_Excel,
    QK_AttchmentType_Office_PPt,
    QK_AttchmentType_Office_Pdf,
    QK_AttchmentType_Office_Other,
    QK_AttchmentType_Other,
    QK_AttchmentType_Unkown,
    QK_AttchmentType_Video
};

@interface CMPFileManager : CMPObject {
}

+ (CMPFileManager *)defaultManager;

+ (NSString *)appendCurrentHomeDirectory:(NSString *)aPath;
+ (NSString *)homeDirectory;
+ (NSString *)createFullPath:(NSString *)aPath;
+ (NSString *)fileTempPath;
+ (NSString *)localSavedFilePath;
+ (NSString *)downloadFilePath;
+ (NSString *)uploadTempFilePath;
+ (NSString *)downloadFileTempPathWithFileName:(NSString *)aFileName;
+ (NSString *)downloadFileLocalSavedPathWithFileName:(NSString *)aFileName;
+ (NSString*)thumbnailImgPathWithName:(NSString *)imgName;
+ (NSString *)fileTempPathWithType:(NSInteger)aType ext:(NSString *)ext;
+ (NSString *)imageMultiTempPath;//图片多选时到毫秒
+ (NSString *)gifMultiTempPath;

+ (NSString *)promptFlagsFilePathWithAccountID:(long long)aAccountID userID:(long long)aUserID;
+ (NSString *)faceImagePathWithWithUniqueId:(NSString *)aUniqueId serverIdentifier:(NSString *)aServerId;
+ (void)removeFileTempPath;

+ (NSString *)uniqueFileNameWithSuffix:(NSString *)aSuffix;
+ (NSString *)localFilePath; // 本地文件路径
+ (NSString *)cmpIconPath; // cmp icon存放路径

+ (void)removeFileWithPath:(NSString *)aPath;
//单个文件的大小
+ (long long) fileSizeAtPath:(NSString*) filePath;
//遍历文件夹获得文件夹大小，返回多少M
+ (float ) folderSizeAtPath:(NSString*) folderPath;

/**
 *
 * 获取文件列表
 * aServerID: 服务器ID
 * aOwenerID: 拥有者ID
 */
- (NSArray *)fileListWithServerID:(NSString *)aServerID ownerID:(NSString *)aOwnerID;

// 保存文件下载记录，用于第二次无需下载
- (void)saveDownloadFileRecord:(NSString *)aPath fileId:(NSString *)aFileId fileName:(NSString *)aFileName lastModified:(NSString *)aLastModified;
// 保存到我的文件
- (void)saveFile:(CMPFile *)aFile;
//保存图片缩略图
- (NSString *)saveThumbnailImgWithPath:(NSString *)imagePath;

+ (NSString *)zipArchive:(NSString *)aFilePath fileName:(NSString *)aFileName;
+ (NSString *)unEncryptFile:(NSString *)aFilePath fileName:(NSString *)aFileName;
+ (NSString *)pathForDownloadPath:(NSString *)oldPath responseHeaders:(NSDictionary *)responseHeaders;

// 根据文件路径获取文件类型
+ (NSInteger)getFileType:(NSString *)aPath;

// 处理文件名,超过250字节截取
+ (NSString *)handelFileNameBySubString:(NSString *)fileName;

//存UIimage到本地目录，并返回path
+ (CMPFile *)saveImageFileToLocal:(UIImage *)image type:(NSString *)type;

//把文件目录的pdf copy到document目录
+(CMPFile *)copyFileToLocal:(NSString *)url type:(NSString *)type;
@end
