//
//  SyFileProvider.m
//  M1Core
//
//  Created by youlin guo on 14-3-7.
//
//

#import "SyFileProvider.h"
#import <CMPLib/SyFileManager.h>
#import "SyFileDBProvider.h"
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/ZipArchiveUtils.h>
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/YYModel.h>

@interface SyFileProvider () {
	NSMutableDictionary *_fileRequestDict;
}


- (NSString *)zipArchive:(NSString *)aFilePath fileName:(NSString *)aFileName;

@end

@implementation SyFileProvider

static SyFileProvider *_instance;


+ (SyFileProvider *)instance
{
	if (!_instance) {
        _instance = [[super allocWithZone:NULL] init];
	}
	return _instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self instance] retain];
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

- (void)dealloc
{
	[_fileRequestDict release];
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self) {
		_fileRequestDict = [[NSMutableDictionary alloc] init];
	}
	return self;
}

// 查询文件
- (SyFilePage *)findOfflineFilesWithStartIndex:(NSInteger)aStartIndex rowCount:(NSInteger)aRowCount 
{
	NSInteger aTotalCount = [[SyFileDBProvider instance] getOfflineFilesCount];
	NSArray *aFileList = [[SyFileDBProvider instance] findeFilesWithStartIndex:aStartIndex rowCount:aRowCount];
	SyFilePage *aFilePage = [[SyFilePage alloc] init];
	aFilePage.totalCount = aTotalCount;
	aFilePage.fileList = aFileList;
	return [aFilePage autorelease];
}

//  搜索文件
- (SyFilePage *)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord startIndex:(NSInteger)aStartIndex rowCount:(NSInteger)aRowCount
{
	NSInteger aTotalCount = [[SyFileDBProvider instance] getSearchOfflineFilesCountWithKeyWord:aKeyWord ];
	NSArray *aFileList = [[SyFileDBProvider instance] searchOfflineFilesWithKeyWord:aKeyWord startIndex:aStartIndex rowCount:aRowCount];
	SyFilePage *aFilePage = [[SyFilePage alloc] init];
	aFilePage.totalCount = aTotalCount;
	aFilePage.fileList = aFileList;
	return [aFilePage autorelease];
}

// 删除文件
- (BOOL)deleteFilesWithOfflineFiles:(NSArray<CMPOfflineFileRecord *> *)fileList
{
    NSMutableArray *fileIDList = [NSMutableArray array];
    NSMutableArray *downloadFileIDList = [NSMutableArray array];
    // 删除以前的文件下载记录
    for (CMPOfflineFileRecord *aFile in fileList) {
        //如果不为空则添加进数组中
        if (aFile.fileId) {
            [fileIDList addObject:aFile.fileId];
            if (aFile.extend2.length) {
                [downloadFileIDList addObject:aFile.fileId];
            }
        }
        
    }
    //数据库中删除数据记录
    [SyFileDBProvider.instance deleteDownloadFileWithFileIDs:downloadFileIDList];
    BOOL succ = [SyFileDBProvider.instance deleteOfflineFileWithFileIDs:fileIDList];
    
    //当删除的文件数据在数据库中没有数据记录的时候，就将本地存储的文件数据删除
    for (CMPOfflineFileRecord *aFile in fileList) {
        
        if (!aFile.fileId || [SyFileDBProvider.instance hasFileWithFileId:aFile.fileName]) continue;
        
        NSString *aPath = aFile.fullLocalPath;
        BOOL isDirectory = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:&isDirectory];
        if (exists) {
            [[NSFileManager defaultManager] removeItemAtPath:aPath error:nil];
        }
        
        exists = NO;
        CMPFileManagementRecord *mfr = [CMPFileManagementRecord yy_modelWithJSON:aFile.extend1];
        exists = [[NSFileManager defaultManager] fileExistsAtPath:mfr.filePath isDirectory:&isDirectory];
        if (exists) {
            [[NSFileManager defaultManager] removeItemAtPath:mfr.filePath error:nil];
        }
        if (![NSString isNull:aFile.extend1]) {
            NSString *iconPath = aFile.extend1;
            if (![iconPath containsString:NSHomeDirectory()]) {
                iconPath = [NSHomeDirectory() stringByAppendingPathComponent:iconPath];
            }
            if ([[NSFileManager defaultManager]fileExistsAtPath:iconPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:iconPath error:nil];
            }
        }
        

    }
    
    return succ;
}


- (NSString *)zipArchive:(NSString *)aFilePath fileName:(NSString *)aFileName
{
	// Create universally unique identifier (object)
	CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
	// Get the string representation of CFUUID object.
	NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
	CFRelease(uuidObject);
	NSString *localName = [uuidStr stringByAppendingPathExtension:@"zip"];
	[uuidStr release];
	NSString *attaPath = [[SyFileManager localFilePath] stringByAppendingPathComponent:localName];
	[ZipArchiveUtils zipArchive:aFilePath zipPath:attaPath];
	return attaPath;
}

@end
