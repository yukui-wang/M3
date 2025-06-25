//
//  CMPFileManager.m
//  M1Core
//
//  Created by admin on 12-10-19.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//


#import "CMPFileManager.h"
#import <sys/xattr.h>
#import "ZipArchiveUtils.h"
#import "CMPOfflineFileRecord.h"
#import "CMPCommonDBProvider.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPDownloadFileRecord.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CMPLib/CMPFileDownloadManager.h>

@implementation CMPFileManager

static CMPFileManager *instance = nil;

- (void)dealloc
{
    [super dealloc];
}

+ (CMPFileManager *)defaultManager
{
    if (!instance) {
        [self createFullPath:kLocalSavedFilePath];
        instance = [[super allocWithZone:NULL] init];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        // 初始化下载队列
        // 初始化上传队列
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self defaultManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

+ (NSString *)appendCurrentHomeDirectory:(NSString *)aPath
{
	// 判断是否有homedictionary，没有需要加上
	NSString *aHomePath = NSHomeDirectory();
	NSRange aRange = [aPath rangeOfString:aHomePath];
	if (aRange.length == 0) {
		NSRange r = [aPath rangeOfString:@"Documents/"];
		aPath = [aPath substringFromIndex:r.location];
		aPath = [aHomePath stringByAppendingPathComponent:aPath];
	}
	// end
	return aPath;
}

+ (NSString *)homeDirectory
{
	return NSHomeDirectory();
}

+ (NSString *)createFullPath:(NSString *)aPath 
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:aPath];
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if ((exists && !isDirectory) || !exists) {
        if (!isDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [NSException raise:@"FailedToCreateCacheDirectory" format:@"Failed to create a directory for the downloadFileTempPath at '%@'",path];
        }
    }
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion isEqualToString:@"5.0.1"]) {
        [CMPFileManager addSkipBackupAttributeToItemAtURL_501:[NSURL fileURLWithPath:path]];
    }
    else{
          [CMPFileManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
    }
    return path;
}

+ (NSString *) uploadTempFilePath
{
    return [CMPFileManager createFullPath:kUploadTempFilePath];
}

+ (NSString *)fileTempPath {
    return [CMPFileManager createFullPath:kFileTempPath];
}

+ (NSString *) downloadFilePath {
    return [CMPFileManager createFullPath:kDownloadFilePath];
}

+ (NSString *) localSavedFilePath {
    return [CMPFileManager createFullPath:kLocalSavedFilePath];
}

+ (NSString *)downloadFileTempPathWithFileName:(NSString *)aFileName {
    NSString *str = [CMPFileManager fileTempPath];
	if ([NSString isNull:aFileName]) {
		NSLog(@"fileName is nil");
		return nil;
	}
    return [str stringByAppendingPathComponent:aFileName];
    // 需要删除以前的
}

+ (NSString *)downloadFileLocalSavedPathWithFileName:(NSString *)aFileName {
    NSString *str = [CMPFileManager localSavedFilePath];
    if ([NSString isNull:aFileName]) {
        NSLog(@"fileName is nil");
        return nil;
    }
    return [str stringByAppendingPathComponent:aFileName];
    // 需要删除以前的
}

+ (NSString *)thumbnailImgPath {
    return [CMPFileManager createFullPath:kThumbnailImgPath];
}
+ (NSString*)thumbnailImgPathWithName:(NSString *)imgName {
    //我的文件缩略图位置，清除缓存不能清
    NSString *str = [CMPFileManager thumbnailImgPath];
       if ([NSString isNull:imgName]) {
           NSLog(@"fileName is nil");
           return nil;
       }
       return [str stringByAppendingPathComponent:imgName];
}

+ (NSString *)fileTempPathWithType:(NSInteger)aType ext:(NSString *)ext
{
    NSString *aName = @"";
    switch (aType) {
        case kFileType_Image: {
            if (!ext) {
                ext = @"png";
            }
            aName = @"图片%@.";
            aName = [aName stringByAppendingString:ext];
            break;
        }
        case kFileType_Audio:
            aName = SY_STRING(@"Common_Voc1");
            break;
        case kFileType_Movie:
            aName = SY_STRING(@"Common_Mov1");
        default:
            break;
    }
    NSString *str = [CMPFileManager uploadTempFilePath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [NSDate date];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    str = [str stringByAppendingPathComponent:[NSString stringWithFormat:aName, dateStr]];
    [dateFormatter release];
    return str;
}

+ (NSString *)imageMultiTempPath
{
    NSString *str = [CMPFileManager uploadTempFilePath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSDate *date = [NSDate date];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    str = [NSString stringWithFormat:@"%@/图片%@.png",str,dateStr] ;
    [dateFormatter release];
    return str;
}

+ (NSString *)gifMultiTempPath {
    NSString *str = [CMPFileManager uploadTempFilePath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSDate *date = [NSDate date];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    str = [NSString stringWithFormat:@"%@/GIF_%@.gif",str,dateStr] ;
    [dateFormatter release];
    return str;
}

+ (NSString *)menuSettingPathWithAccountID:(long long)aAccountID userID:(long long)aUserID {
    NSString *str = [CMPFileManager createFullPath:kMenuSettingsPath];
    return [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.setting", [NSString stringWithLongLong:aAccountID], [NSString stringWithLongLong:aUserID]]];
}

+ (NSString *)menuSettingDeleteFlagPathWithAccountID:(long long)aAccountID userID:(long long)aUserID {
    NSString *str = [CMPFileManager createFullPath:kMenuSettingsPath];
    return [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_deleteFlag.setting", [NSString stringWithLongLong:aAccountID], [NSString stringWithLongLong:aUserID]]];
}

+ (NSString *)promptFlagsFilePathWithAccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSString *str = [CMPFileManager createFullPath:kPromptFlagsPath];
    return [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.setting", [NSString stringWithLongLong:aAccountID], [NSString stringWithLongLong:aUserID]]];
}

+ (NSString *)faceImagePathWithWithUniqueId:(NSString *)aUniqueId serverIdentifier:(NSString *)aServerId
{
    NSString *str = [CMPFileManager createFullPath:[kFaceImagePath stringByAppendingPathComponent:aServerId]];
    str = [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", aUniqueId]];
    return str;
}

+ (void)removeFileTempPath
{
    NSString *aPath = [CMPFileManager fileTempPath];
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:&isDirectory];
    if (exists) {
        [[NSFileManager defaultManager] removeItemAtPath:aPath error:nil];
		// 同时再创建一个
		[CMPFileManager fileTempPath];
    }
}

+ (void)removeFileWithPath:(NSString *)aPath
{
	BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:&isDirectory];
    if (exists) {
        [[NSFileManager defaultManager] removeItemAtPath:aPath error:nil];
	}
}

+ (NSString *)uniqueFileNameWithSuffix:(NSString *)aSuffix
{
	// Create universally unique identifier (object)
	CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
	// Get the string representation of CFUUID object.
	NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
	CFRelease(uuidObject);
	NSString *localName = [uuidStr stringByAppendingPathExtension:aSuffix];
	[uuidStr release];
	return localName;
}

+ (NSString *)localFilePath
{
	return [CMPFileManager createFullPath:kLocalFilePath];
}

+ (NSString *)cmpIconPath
{
	return [CMPFileManager createFullPath:kCMPIconPath];
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
	
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+ (BOOL)addSkipBackupAttributeToItemAtURL_501:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
	
    const char* filePath = [[URL path] fileSystemRepresentation];
	
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
	
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}


- (NSArray *)fileListWithServerID:(NSString *)aServerID ownerID:(NSString *)aOwnerID
{
	return nil;
}

- (void)saveDownloadFileRecord:(NSString *)aPath fileId:(NSString *)aFileId fileName:(NSString *)aFileName lastModified:(NSString *)aLastModified
{
    NSString *downloadPath = aPath;
    NSString *fileId = aFileId;
    NSString *lastModified = aLastModified;
    NSString *origin = kCMP_ServerID;
    NSString *title = aPath.lastPathComponent.originalFileNameSpecialCharactersAtPath;
    
    NSString *aZipPath = [self saveToZip:aPath fileName:title];

    // create SyDownloadFile instance
    CMPDownloadFileRecord *aDownloadFile = [[[CMPDownloadFileRecord alloc] init] autorelease];
    aDownloadFile.fileId = fileId;
    aDownloadFile.fileName = title;
    aDownloadFile.localName = title;
    aDownloadFile.fileSuffix = title.pathExtension;
    aDownloadFile.savePath = aZipPath;
    aDownloadFile.origin = origin;
    aDownloadFile.modifyTime = lastModified;
    aDownloadFile.createDate = @"";
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    dateFormatter = nil;
    
    aDownloadFile.downloadTime = destDateString;
    aDownloadFile.creatorName = @"";
    aDownloadFile.serverId = kCMP_ServerID;
    
    long long aLen = [CMPFileManager fileSizeAtPath:downloadPath];
    aDownloadFile.fileSize = [NSString stringWithLongLong:aLen];
    
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    [dbConnection deleteDownloadFileRecordsWithFileId:fileId origin:origin serverID:[CMPCore sharedInstance].serverID onCompletion:nil];
    [dbConnection insertDownloadFileRecord:aDownloadFile onCompletion:nil];
}

#pragma mark - 保存文件
- (NSString *)saveToZip:(NSString *)filePath fileName:(NSString *)aFileName
{
    //压缩文件
    NSString *aStorePath = [CMPFileManager localFilePath];
    NSString *localName = aFileName;
    NSString *aZipPath = nil;
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    CFRelease(uuidObject);
    localName = [uuidStr stringByAppendingPathExtension:@"zip"];
    [uuidStr release];
    aZipPath = [aStorePath stringByAppendingPathComponent:localName];
    [ZipArchiveUtils zipArchive:filePath zipPath:aZipPath];
    
    // 去掉 homedictionary
    NSString *aHomePath = [NSString stringWithFormat:@"%@/", [CMPFileManager homeDirectory]];
    aZipPath = [aZipPath replaceCharacter:aHomePath withString:@""];
    // end
    return aZipPath;
}


- (void)saveFile:(CMPFile *)aFile {
    NSString *fileName = aFile.fileName;
    if ([NSString isNull:fileName]) {
        fileName = aFile.filePath.lastPathComponent.originalFileNameSpecialCharactersAtPath;
    }
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    __weak typeof(self) weakSelf = self;
    [dbConnection checkOfflineFileName:fileName fileId:aFile.fileID origin:kCMP_ServerID ownerId:CMP_USERID serverId:kCMP_ServerID onCompletion:^(NSString* aFileName) {
        NSString *localName = fileName;
        NSString *filePath = aFile.filePath;
        if (![localName  isEqualToString:aFileName]) {
            //修改下路径,修改成添加了同名后缀的路径
            NSString *localPath = [[filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:aFileName];
            NSFileManager *manager = [NSFileManager defaultManager];
            if ([manager fileExistsAtPath:localPath]) {
                [manager removeItemAtPath:localPath error:nil];
            }
            //不能用移动，不然在查看界面会不现实，应为文件移走了，用copy
            [manager copyItemAtPath:aFile.filePath toPath:localPath error:nil];
            aFile.filePath = localPath;
        }
        aFile.fileName = aFileName;
        [weakSelf dispatchAsyncToChild:^{
            [weakSelf save2OfflineFile:aFile];
        }];
    }];
}

- (void)save2OfflineFile:(CMPFile *)aFile
{
    NSString *filePath = aFile.filePath;
    NSString *fileName = aFile.fileName;
    NSString *fileId = aFile.fileID;
    NSString *from = aFile.from;
    NSString *lastModified = aFile.lastModified;
    NSString *origin = kCMP_ServerID;//aFile.origin;
    if ([NSString isNull:fileName]) {
        fileName = aFile.filePath.lastPathComponent.originalFileNameSpecialCharactersAtPath;
    }
   
    CMPOfflineFileRecord *aDownloadFile = [[CMPOfflineFileRecord alloc] init];
    aDownloadFile.fileId = fileId;
    aDownloadFile.fileName = fileName;
    aDownloadFile.localName = fileName;
    aDownloadFile.fileSuffix = fileName.pathExtension;
    aDownloadFile.origin = origin;
    aDownloadFile.modifyTime = lastModified;
    aDownloadFile.extend2 = from ? from : @"";//来源from
    aDownloadFile.extend3 = aFile.fromType;//来源类型
    aDownloadFile.extend4 = [CMPFileTypeHandler getFileMineTypeWithFilePath:filePath];//来源类型
    aDownloadFile.createDate = @"";
    aDownloadFile.creatorName = @"";
    aDownloadFile.serverId = kCMP_ServerID;
    aDownloadFile.ownerId = CMP_USERID;
    

    NSString *iconPath = @"";//缩略图
    if ([CMPFileTypeHandler fileMineTypeWithMineType:aDownloadFile.extend4] == CMPFileMineTypeImage) {
        iconPath = [self saveThumbnailImgWithPath:filePath];
    }
    aDownloadFile.extend1 = iconPath;

    NSString *aZipPath = [self saveToZip:filePath fileName:fileName];
    aDownloadFile.savePath = aZipPath;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    dateFormatter = nil;
    
    aDownloadFile.downloadTime = destDateString;
    
    long long aLen = [CMPFileManager fileSizeAtPath:filePath];
    aDownloadFile.fileSize = [NSString stringWithLongLong:aLen];
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    
    [dbConnection deleteOfflineFileRecordsWithFileId:fileId origin:origin serverID:[CMPCore sharedInstance].serverID ownerID:[CMPCore sharedInstance].userID onCompletion:nil];
    [dbConnection insertOfflineFileRecord:aDownloadFile onCompletion:nil];
       
    [aDownloadFile release];
}

+ (CMPFile *)saveImageFileToLocal:(UIImage *)image type:(NSString *)type{
    if(!image) return nil;
    CMPFile *file = [[CMPFile alloc]init];
    file.fileName = [file.fileID stringByAppendingFormat:@".%@",type];
    file.filePath = [[CMPFileManager localSavedFilePath] stringByAppendingFormat:@"/%@",file.fileName];
    BOOL success = NO;
    if ([type containsString:@"jpg"]) {
        success = [UIImageJPEGRepresentation(image, 1) writeToFile:file.filePath atomically:YES];
    }else if([type containsString:@"png"]){
        success = [UIImagePNGRepresentation(image) writeToFile:file.filePath atomically:YES];
    }
    return success?file:nil;
}

+(CMPFile *)copyFileToLocal:(NSString *)url type:(NSString *)type{
    CMPFile *file = [[CMPFile alloc]init];
    if([[type lowercaseString] containsString:@"heic"]){
        type = @"jpg";
    }
    file.fileName = [file.fileID stringByAppendingFormat:@".%@",type];
    file.filePath = [[CMPFileManager localSavedFilePath] stringByAppendingFormat:@"/%@",file.fileName];
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:url toPath:file.filePath error:nil];    
    return success?file:nil;
}

//保存图片缩略图
- (NSString *)saveThumbnailImgWithPath:(NSString *)imagePath {
    if (![[NSFileManager defaultManager]fileExistsAtPath:imagePath]) {
        return @"";
    }
    UIImage *aImage = [UIImage imageWithContentsOfFile:imagePath];
    UIImage *mImage = [aImage cmp_scaleToSize:CGSizeMake(40, 40)];
    NSString *mImgName = [NSString stringWithFormat:@"%@.jpg", [NSString uuid]];
    NSString *mImgPath = [CMPFileManager thumbnailImgPathWithName:mImgName];
    [UIImagePNGRepresentation(mImage) writeToFile:mImgPath atomically:YES];
    // 去掉 homedictionary
    NSString *aHomePath = [NSString stringWithFormat:@"%@/", [CMPFileManager homeDirectory]];
    NSString *iconPath = [mImgPath replaceCharacter:aHomePath withString:@""];
    return iconPath;
}

/// 保存图片到相册
/// @param aPath 要保存的图片的原始路径
- (void)saveImageToPhotosAlbum:(NSString *)aPath
{
    //保存到相册
    UIImage* image = [UIImage imageWithContentsOfFile:aPath];
    [CMPCommonTool.sharedTool savePhotoWithImage:image target:nil action:nil];
}

/// 获取单个文件的文件大小
/// @param filePath 文件路径
+ (long long) fileSizeAtPath:(NSString*) filePath
{
    if (!filePath) {
        return 0;
    }
	NSFileManager* manager = [NSFileManager defaultManager];
	if ([manager fileExistsAtPath:filePath]){
		return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
	}
	return 0;
}

//遍历文件夹获得文件夹大小，返回多少M
+ (float)folderSizeAtPath:(NSString*) folderPath
{
	NSFileManager* manager = [NSFileManager defaultManager];
	if (![manager fileExistsAtPath:folderPath]) return 0;
	NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
	NSString* fileName;
	long long folderSize = 0;
	while ((fileName = [childFilesEnumerator nextObject]) != nil){
		NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
		folderSize += [self fileSizeAtPath:fileAbsolutePath];
	}
	return folderSize/(1024.0*1024.0);
}

+ (NSString *)zipArchive:(NSString *)aFilePath fileName:(NSString *)aFileName
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    CFRelease(uuidObject);
    NSString *localName = [uuidStr stringByAppendingPathExtension:@"zip"];
    [uuidStr release];
    NSString *attaPath = [[CMPFileManager localFilePath] stringByAppendingPathComponent:localName];
    [ZipArchiveUtils zipArchive:aFilePath zipPath:attaPath];
    return attaPath;
}

+ (NSString *)unEncryptFile:(NSString *)aFilePath fileName:(NSString *)aFileName
{
    // 解密到本地文件
    NSString *path = @"";
    NSString *tmpPath = [CMPFileManager fileTempPath];
    aFileName = [aFileName handleFileNameSpecialCharactersAtPath];
    path = [tmpPath stringByAppendingPathComponent:aFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    BOOL isUnZipSucces = [ZipArchiveUtils unZipArchive:aFilePath unzipto:tmpPath];
    if (isUnZipSucces) {
        return path;
    }
    return path;
}

+ (NSString *)pathForDownloadPath:(NSString *)oldPath responseHeaders:(NSDictionary *)responseHeaders
{
    NSString *disposition = [responseHeaders objectForKey:@"Content-Disposition"];
    NSString *result = oldPath;
    if (disposition && [disposition isKindOfClass:[NSString class]]) {
        NSArray *array = [disposition componentsSeparatedByString:@";"];
        for (NSString *obj in array) {
            if ([obj rangeOfString:@"filename="].location != NSNotFound) {
                NSString *olduffix = [oldPath pathExtension];
                NSString *filename = [obj replaceCharacter:@"filename=" withString:@""];
                filename = [filename replaceCharacter:@"\"" withString:@""];
                NSString *newSufix = [filename pathExtension];
                if (newSufix && newSufix.length >0 && ![olduffix.lowercaseString isEqualToString:newSufix.lowercaseString]) {
                    result = [[oldPath stringByDeletingPathExtension] stringByAppendingPathExtension:newSufix];
                    [[NSFileManager defaultManager] removeItemAtPath:result error:nil];
                    [[NSFileManager  defaultManager] moveItemAtPath:oldPath toPath:result error:nil];
                }
                break;
            }
        }
    }
    return result;
}

+ (NSInteger)getFileType:(NSString *)aPath
{
    NSMutableSet *imageTypeSet = [NSMutableSet setWithObjects:@"PNG", @"JPG", @"JPEG", @"BMP",
                                  @"TIFF", @"TIF", @"TGA", @"WMF", @"ICO", @"DIB", nil];
    NSMutableSet *gifTypeSet = [NSMutableSet setWithObjects:@"GIF", nil];
    NSMutableSet *audioTags = [NSMutableSet setWithObjects:@"CAF", @"MP3", @"WAV", @"MID", @"MP1", @"MP2",
                               @"RA", @"ASF", @"WMA", @"AMR", nil];
    NSMutableSet *compressionTags = [NSMutableSet setWithObjects:@"ZIP", @"RAR", @"TZ", nil];
    
    // change buy wujs OA-209905 BAT 不支持查看
    NSMutableSet *textTags = [[[NSMutableSet alloc] initWithObjects:@"TXT", @"INI", @"JAVA", @"M",
                               @"MM", @"H", @"CPP", nil] autorelease];
    NSMutableSet *wpsTypeSet = [NSMutableSet setWithObjects:@"WPS", @"ET", nil];
    NSMutableSet *etTypeSet = [NSMutableSet setWithObjects: @"ET", nil];
    NSMutableSet *officeDocTypeSet = [NSMutableSet setWithObjects:@"DOC", @"DOCX",
                                      @"RTF", nil];
    NSMutableSet *officeExceTypeSet = [NSMutableSet setWithObjects: @"XLS", @"XLSX", nil];
    NSMutableSet *officePPtTypeSet = [NSMutableSet setWithObjects:@"PPT",@"PPTX", nil];
    NSMutableSet *officePdfTypeSet = [NSMutableSet setWithObjects:@"PDF", nil];
    NSMutableSet *videoTypeSet = [NSMutableSet setWithObjects:@"MP4", @"MOV", @"M4V", nil];
    NSMutableSet *officeOtherTypeSet = [NSMutableSet setWithObjects:@"PHP", @"HTM", @"HTML", nil];
    
    NSString *extention = [aPath.pathExtension uppercaseString];
    if ([imageTypeSet containsObject:extention])
    {
        return QK_AttchmentType_Image;
        
    }else if ([gifTypeSet containsObject:extention])
    {
        return QK_AttchmentType_Gif;
        
    }else if ([audioTags containsObject:extention])
    {
        return QK_AttchmentType_AUDIO;
        
    }else if ([compressionTags containsObject:extention])
    {
        return QK_AttchmentType_PRESS;
        
    }else if ([textTags containsObject:extention])
    {
        return QK_AttchmentType_TEXT;
        
    }else if ([wpsTypeSet containsObject:extention])
    {
        return QK_AttchmentType_WPS;
    }
    else if ([officeDocTypeSet containsObject:extention]){
        
        return QK_AttchmentType_Office_Doc;
        
    }else if ([officeExceTypeSet containsObject:extention]){
        
        return QK_AttchmentType_Office_Excel;
        
    }else if ([officePPtTypeSet containsObject:extention]){
        
        return QK_AttchmentType_Office_PPt;
        
    }else if ([officePdfTypeSet containsObject:extention]){
        
        return QK_AttchmentType_Office_Pdf;
        
    }else if ([officeOtherTypeSet containsObject:extention]){
        
        return QK_AttchmentType_Office_Other;
        
    }else if([etTypeSet containsObject:extention]){
        
        return QK_AttchmentType_ET;
    }else if([videoTypeSet containsObject:extention]){
        return QK_AttchmentType_Video;
    }
    
    return QK_AttchmentType_Unkown;
}

+ (NSString *)handelFileNameBySubString:(NSString *)fileName {
    NSString *pathExtension = fileName.pathExtension;
    NSInteger index = 250 - pathExtension.length - 1;
    
    NSInteger sum = 0;
    
    NSString *subStr = [[NSString alloc] init];
    
    for(int i = 0; i<[fileName length]; i++){
        
        unichar strChar = [fileName characterAtIndex:i];
        
        if(strChar < 256){
            sum += 1;
        }
        else {
            sum += 2;
        }
        if (sum >= index) {
            
            subStr = [fileName substringToIndex:i+1];
            return [subStr stringByAppendingPathExtension:pathExtension];
        }
 
    }
    
    return fileName;
}

@end
