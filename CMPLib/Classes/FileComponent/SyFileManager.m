//
//  SyFileManager.m
//  M1Core
//
//  Created by admin on 12-10-19.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//
#define kFileTempPath                   @"Documents/File/temp"
#define kDownloadFilePath               @"Documents/File/Download"
#define kUploadTempFilePath             @"Documents/File/UploadTemp"
#define kMenuSettingsPath               @"Documents/File/MenuSettings"
#define kQuickMenusPath                 @"Documents/File/QuickFunciton"
#define kPromptFlagsPath                @"Documents/File/PromptFlags"
#define kFaceImagePath                  @"Documents/File/FaceImagePath"
#define kSkinPath                       @"Documents/File/Skin/%@/%@"
#define kLocalFilePath					@"Documents/File/Local"
#define kCMPIconPath					@"Documents/File/CMP/Icons"
#define kLoginResultsPath				@"Documents/File/LoginResults"
#define kMenuSettingsHidePath           @"Documents/File/MenuHideSettings"



#import "SyFileManager.h"
#import "CMPConstant.h"
#import "NSString+CMPString.h"
#import "CMPGlobleManager.h"
#import "JSON.h"
#import <sys/xattr.h>
//#import "SySearchHistory.h"
@implementation SyFileManager
@synthesize viewController = _viewController;
static SyFileManager *instance = nil;
- (void)dealloc
{
    [_viewController release];_viewController = nil;
    [super dealloc];
}
+ (SyFileManager *)defaultManager
{
    if (!instance) {
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
    if (exists && !isDirectory) {
        [NSException raise:@"FileExistsAtDownloadTempPath" format:@"Cannot create a directory for the downloadFileTempPath at '%@', because a file already exists",path];
    } 
    else if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [NSException raise:@"FailedToCreateCacheDirectory" format:@"Failed to create a directory for the downloadFileTempPath at '%@'",path];
        }
    }
//	NSString *aURL = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion isEqualToString:@"5.0.1"]) {
        [SyFileManager addSkipBackupAttributeToItemAtURL_501:[NSURL fileURLWithPath:path]];
    }
    else{
      	[SyFileManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
    }
    return path;
}

+ (NSString *) uploadTempFilePath
{
    return [SyFileManager createFullPath:kUploadTempFilePath];
}

+ (NSString *)fileTempPath {
    return [SyFileManager createFullPath:kFileTempPath];
}

+ (NSString *) downloadFilePath {
    return [SyFileManager createFullPath:kDownloadFilePath];
}

+ (NSString *)downloadFileTempPathWithFileName:(NSString *)aFileName {
    NSString *str = [SyFileManager fileTempPath];
	if ([NSString isNull:aFileName]) {
		NSLog(@"fileName is nil");
		return nil;
	}
    return [str stringByAppendingPathComponent:aFileName];
    // 需要删除以前的
}

+ (NSString *)fileTempPathWithType:(NSInteger)aType ext:(NSString *)ext
{
    NSString *aName = @"";
    switch (aType) {
        case kFileType_Image: {
            if (!ext) {
                ext = @"png";
            }
            aName = SY_STRING(@"Common_Pic1");
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
    NSString *str = [SyFileManager uploadTempFilePath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [NSDate date];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    str = [str stringByAppendingPathComponent:[NSString stringWithFormat:aName, dateStr]];
    [dateFormatter release];
    return str;
}

+ (NSString *)fileTempPathWithType:(NSInteger)aType ext:(NSString *)ext index:(NSInteger)index
{
    NSString *aName = @"";
    switch (aType) {
        case kFileType_Image: {
            if (!ext) {
                ext = @"png";
            }
            aName = SY_STRING(@"Common_Pic1");
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
    NSString *str = [SyFileManager uploadTempFilePath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [NSDate date];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    dateStr = [NSString stringWithFormat:@"%@_%ld",dateStr,(long)index];
    str = [str stringByAppendingPathComponent:[NSString stringWithFormat:aName, dateStr]];
    [dateFormatter release];
    return str;
}

+ (NSString *)menuSettingPathWithAccountID:(long long)aAccountID userID:(long long)aUserID {
    NSString *str = [SyFileManager createFullPath:kMenuSettingsPath];
    return [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.setting", [NSString stringWithLongLong:aAccountID], [NSString stringWithLongLong:aUserID]]];
}

+ (NSString *)menuSettingDeleteFlagPathWithAccountID:(long long)aAccountID userID:(long long)aUserID {
    NSString *str = [SyFileManager createFullPath:kMenuSettingsPath];
    return [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_deleteFlag.setting", [NSString stringWithLongLong:aAccountID], [NSString stringWithLongLong:aUserID]]];
}

//kl added 快捷菜单
+(NSString *)quicFunctionMenuAddedWidhAccountID:(long long)aAccountID userID:(long long)aUserID{
    NSString *str = [SyFileManager createFullPath:kQuickMenusPath];
    return [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_addedFlag.setting", [NSString stringWithLongLong:aAccountID], [NSString stringWithLongLong:aUserID]]];
}
//end

+ (NSString *)promptFlagsFilePathWithAccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSString *str = [SyFileManager createFullPath:kPromptFlagsPath];
    return [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.setting", [NSString stringWithLongLong:aAccountID], [NSString stringWithLongLong:aUserID]]];
}

+ (NSString *)faceImagePathWithWithUniqueId:(NSString *)aUniqueId serverIdentifier:(NSString *)aServerId
{
    NSString *str = [SyFileManager createFullPath:[kFaceImagePath stringByAppendingPathComponent:aServerId]];
    str = [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", aUniqueId]];
    return str;
}

+ (void)removeFileTempPath
{
    NSString *aPath = [SyFileManager fileTempPath];
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:&isDirectory];
    if (exists) {
        [[NSFileManager defaultManager] removeItemAtPath:aPath error:nil];
		// 同时再创建一个
		[SyFileManager fileTempPath];
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

//缓存管理 start


- (NSArray *)clearCachePathLstt
{
    NSMutableArray *result = [NSMutableArray array];
    [result addObject:[SyFileManager downloadFilePath]];
    [result addObject:[SyFileManager fileTempPath]];
    [result addObject:[SyFileManager uploadTempFilePath]];
    [result addObject: [SyFileManager createFullPath:@"Documents/File/BGDownload"]];
    [result addObject: [SyFileManager createFullPath:@"Documents/httpCache"]];
    
    return result;
}


//通常用于删除缓存的时，计算缓存大小
//单个文件的大小
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
//遍历文件夹获得文件夹大小，返回多少b
- (long long ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}
//计算要清除缓存的大小
- (long long)sizeOfCacheFiles
{
    long long size = 0;
    NSArray *array = [self clearCachePathLstt];
    for (NSString *path in array) {
        size += [self folderSizeAtPath:path];
    }
    return size;
}

- (void)deleteCacheFiles
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *array = [self clearCachePathLstt];
    for (NSString *path in array) {
        BOOL bRet = [fileMgr fileExistsAtPath:path];
        if (bRet) {
            NSError *err;
            [fileMgr removeItemAtPath:path error:&err];
            NSLog(@"path = %@",path);
        }
    }
   
//    [self performSelectorOnMainThread:@selector(deleteCacheFilesFinished) withObject:nil waitUntilDone:NO];

}

- (void)checkClearCacheFilesIsFinished
{
    long long size = [self sizeOfCacheFiles];
    if (size == 0 ) {
        [self performSelector:@selector(deleteCacheFilesFinished) withObject:nil];
    }
    else {
        [self performSelector:@selector(checkClearCacheFilesIsFinished) withObject:nil afterDelay:0.1];
    }
}
- (NSString *)getSize:(long long) aSize
{
    NSString *result = @"0k";
    
    if(aSize >= 1048576) {
        NSInteger finalSize = aSize / 1048576 + 1;
        result = [NSString stringWithFormat:@"%ldMB", (long)finalSize];
    }
    else{
        NSInteger finalSize = aSize / 1024 + 1;
        result = [NSString stringWithFormat:@"%ldKB", (long)finalSize];
    }
    return result;
}
- (void)deleteCacheFilesFinished
{
    NSString *str = SY_STRING(@"Setting_Clean_Finished");
//    int size_m = _maxSize/(1024*1024);
//    NSString *sizeStr = [NSString stringWithFormat:@"%d M",size_m];
    NSString *sizeStr = _maxSize >0 ?@"0KB": [self getSize:_maxSize];
    if (_type == 2 ) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:[NSString stringWithFormat:@"%@%@",str,sizeStr] autoHide:NO animated:NO];
        [self performSelector:@selector(dissmissMarqueeView) withObject:nil afterDelay:1];
    }
    else if (self.viewController &&[self.viewController respondsToSelector:@selector(showHUDModeTextLoadingViewWithText:detailText:)]){
        [self.viewController performSelector:@selector(showHUDModeTextLoadingViewWithText:detailText:) withObject:str withObject:sizeStr]; 
        [self.viewController performSelector:@selector(logoutAfterClear) withObject:nil afterDelay:1];
    }
}

- (void)dissmissMarqueeView
{
    [[CMPGlobleManager sharedSyGlobleManager] dismissMarqueeView:YES];
}

- (void)deleteCacheFilesWithViewController:(UIViewController*)acontroller type:(NSInteger)type
{
//    [SySearchHistory clearAll];//清除搜索记录
    self.viewController = nil;
    self.viewController = acontroller;
    _type = type;
    _maxSize = [self sizeOfCacheFiles];
    if (_type == 2 ) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"Setting_Cleaning...") autoHide:NO animated:YES];
    }
    else if ([self.viewController respondsToSelector:@selector(showLoadingViewWithText:)] && type ==1) {
        [self.viewController performSelector:@selector(showLoadingViewWithText:) withObject:SY_STRING(@"Setting_Cleaning...")];
    }
    [self performSelector:@selector(checkClearCacheFilesIsFinished) withObject:nil afterDelay:0.2];
    [NSThread detachNewThreadSelector:@selector(deleteCacheFiles) toTarget:self withObject:nil];
}
//缓存管理 end
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
	return [SyFileManager createFullPath:kLocalFilePath];
}

+ (NSString *)cmpIconPath
{
	return [SyFileManager createFullPath:kCMPIconPath];
}

//业务管理添加到菜单 ipad
+ (NSString *)menuSettingBGaddFlagPathWithAccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSString *str = [SyFileManager createFullPath:kMenuSettingsPath];
    return [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_BGFlag.setting", [NSString stringWithLongLong:aAccountID], [NSString stringWithLongLong:aUserID]]];
}
+ (NSArray *)arrayForBGInMenuViewWithAccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSArray *array = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [SyFileManager menuSettingBGaddFlagPathWithAccountID:aAccountID userID:aUserID];
    if ([fileManager fileExistsAtPath:path]) {
        NSStringEncoding encoding;
        NSError *error;
        NSString *str = [NSString stringWithContentsOfFile:path usedEncoding:&encoding error:&error];
        array = [str JSONValue];
    }
    return array;
}
+ (NSDictionary *)dictionaryForBGInMenuViewWithAccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSArray *array = [SyFileManager arrayForBGInMenuViewWithAccountID:aAccountID userID:aUserID];
    NSMutableDictionary *bgAddToMenuDic = [NSMutableDictionary dictionary];
    for (NSString *str in array) {
        [bgAddToMenuDic setObject:str forKey:str];
    }
    return bgAddToMenuDic;
}

+ (void)addBGToMenuViewWithMenuIDArray:(NSArray *)menuIDArray AccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSArray *oldArray = [SyFileManager arrayForBGInMenuViewWithAccountID:aAccountID userID:aUserID];
    NSMutableArray *newArray = [NSMutableArray array];
    [newArray addObjectsFromArray:oldArray];
    [newArray addObjectsFromArray:menuIDArray];
    NSString *bgstring = @"";
    if (newArray.count > 0) {
        bgstring = [newArray JSONRepresentation];
    }
    NSString *bgpath = [SyFileManager menuSettingBGaddFlagPathWithAccountID:aAccountID userID:aUserID];
    [bgstring writeToFile:bgpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (void)removeBGFormMenuViewWithMenuID:(NSString *)menuID AccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSArray *oldArray = [SyFileManager arrayForBGInMenuViewWithAccountID:aAccountID userID:aUserID];
    NSMutableArray *newArray = [NSMutableArray array];
    [newArray addObjectsFromArray:oldArray];
    for (NSString *idString in newArray) {
        if ([idString isEqualToString:menuID]) {
            [newArray removeObject:idString];
            break;
        }
    }
    NSString *bgstring = @"";
    if (newArray.count > 0) {
        bgstring = [newArray JSONRepresentation];
    }
    NSString *bgpath = [SyFileManager menuSettingBGaddFlagPathWithAccountID:aAccountID userID:aUserID];
    [bgstring writeToFile:bgpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

//cmp添加到菜单
//cmp添加到菜单
+ (NSString *)menuSettingCMPaddFlagPathWithAccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSString *str = [SyFileManager createFullPath:kMenuSettingsPath];
    return [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_CMPFlag.setting", [NSString stringWithLongLong:aAccountID], [NSString stringWithLongLong:aUserID]]];
  
}

+ (NSArray *)arrayForCMPInMenuViewWithAccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSArray *array = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [SyFileManager menuSettingCMPaddFlagPathWithAccountID:aAccountID userID:aUserID];
    if ([fileManager fileExistsAtPath:path]) {
        NSStringEncoding encoding;
        NSError *error;
        NSString *str = [NSString stringWithContentsOfFile:path usedEncoding:&encoding error:&error];
        array = [str JSONValue];
    }
    return array;
}

+ (NSDictionary *)dictionaryForCMPInMenuViewWithAccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSArray *array = [SyFileManager arrayForCMPInMenuViewWithAccountID:aAccountID userID:aUserID];
    NSMutableDictionary *bgAddToMenuDic = [NSMutableDictionary dictionary];
    for (NSString *str in array) {
        [bgAddToMenuDic setObject:str forKey:str];
    }
    return bgAddToMenuDic;
}

+ (void)addCMPToMenuViewWithMenuIDArray:(NSArray *)menuIDArray AccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSArray *oldArray = [SyFileManager arrayForCMPInMenuViewWithAccountID:aAccountID userID:aUserID];
    NSMutableArray *newArray = [NSMutableArray array];
    [newArray addObjectsFromArray:oldArray];
    [newArray addObjectsFromArray:menuIDArray];
    NSString *bgstring = @"";
    if (newArray.count > 0) {
        bgstring = [newArray JSONRepresentation];
    }
    NSString *bgpath = [SyFileManager menuSettingCMPaddFlagPathWithAccountID:aAccountID userID:aUserID];
    [bgstring writeToFile:bgpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (void)removeCMPFormMenuViewWithMenuID:(NSString *)menuID AccountID:(long long)aAccountID userID:(long long)aUserID
{
    NSArray *oldArray = [SyFileManager arrayForCMPInMenuViewWithAccountID:aAccountID userID:aUserID];
    NSMutableArray *newArray = [NSMutableArray array];
    [newArray addObjectsFromArray:oldArray];
    for (NSString *idString in newArray) {
        if ([idString isEqualToString:menuID]) {
            [newArray removeObject:idString];
            break;
        }
    }
    NSString *bgstring = @"";
    if (newArray.count > 0) {
        bgstring = [newArray JSONRepresentation];
    }
    NSString *bgpath = [SyFileManager menuSettingCMPaddFlagPathWithAccountID:aAccountID userID:aUserID];
    [bgstring writeToFile:bgpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
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


@end
