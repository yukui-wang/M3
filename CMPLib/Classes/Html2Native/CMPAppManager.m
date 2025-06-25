//
//  CMPAppManager.m
//  CMPCore
//
//  Created by youlin on 16/5/30.
//
//

#import "CMPAppManager.h"
#import <sys/xattr.h>
#import "ZipArchive.h"
#import "CMPCommonDBProvider.h"
#import "CMPCachedUrlParser.h"
#import "CMPCachedResManager.h"

#define kCMPAppPath_H5 @"/h5/"
#define kCMPAppPath_CMP @"/h5/cmp/"
#define kCMPAppPath_Apps @"/h5/apps/"
#define kCMPAppPath_Commons @"/h5/commons/"
#define kCMPAppPath_cache @"/appcache/"

@implementation CMPAppManager

+ (NSString *)documentWithPath:(NSString *)aPath
{
    NSString *aDoucumentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    if (aPath) {
        NSString *pat = [aDoucumentPath stringByAppendingString:aPath];
        NSLog(@"local file path:%@",pat);
        return pat;
    }
    NSLog(@"local file path:%@",aDoucumentPath);
    return aDoucumentPath;
}

+ (NSString *)cmpAppCachePath
{
    NSString *path = [CMPAppManager documentWithPath:kCMPAppPath_cache];
    return [CMPAppManager createPath:path];
}

+ (NSString *)cmpH5ZipDownloadPath
{
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    if(![CMPCore sharedInstance].serverID){
        NSLog(@"");
    }
    NSString *h5DownloadPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"h5-download/%@",[CMPCore sharedInstance].serverID]];
    return [CMPAppManager createPath:h5DownloadPath];
}

// 创建CMPlib包目录
+ (NSString *)cmpLibPath
{
    NSString *path = [CMPAppManager documentWithPath:kCMPAppPath_CMP];
    return [CMPAppManager createPath:path];
}

// 创建AppsPath目录
+ (NSString *)appsPath:(NSString *)aName domain:(NSString *)aDomain
{
    NSString *path = [CMPAppManager documentWithPath:kCMPAppPath_H5];
    NSString *uuid = [NSString uuid];
    path = [path stringByAppendingString:uuid];
    return [CMPAppManager createPath:path];
}

+ (NSString *)appMixPath
{
    NSString *path = [CMPAppManager documentWithPath:kCMPAppPath_H5];
    [CMPAppManager createPath:path];
    NSString *uuid = [NSString uuid];
    path = [path stringByAppendingString:uuid];
    return path;
}

// 创建公共资源包目录
+ (NSString *)commonsLibPath:(NSString *)aDomain
{
    NSString *path = [CMPAppManager documentWithPath:kCMPAppPath_Commons];
    [path stringByAppendingString:aDomain];
    return [CMPAppManager createPath:path];
}

+ (CMPDBAppInfo *)appInfoWithAppId:(NSString *)appId version:(NSString *)aVersion
                 serverId:(NSString *)aServerId owerId:(NSString *)owerId
{
    CMPCommonDBProvider *dbconn = [CMPCommonDBProvider sharedInstance];
    __block NSArray *aList;
    [dbconn appListWithServerID:aServerId ownerID:owerId appId:appId onCompletion:^(NSArray *result) {
        aList = [result copy];
    }];
    return [[aList lastObject] autorelease];
}

+ (NSArray *)appListWithServerId:(NSString *)aServerId ownerId:(NSString *)ownerId
{
    CMPCommonDBProvider *dbconn = [CMPCommonDBProvider sharedInstance];
    NSArray *aList;
    aList = [[dbconn appListWithServerID:kCMP_ServerID
                                 ownerID:kCMP_OwnerID
                              startIndex:0
                                rowCount:NSIntegerMax] retain];
    // 判断当前的aList是否有值，没有值需要重新查询
    if (aList.count == 0) {
        [aList release];
        aList = [[dbconn appListWithServerID:@"cmp"
                                     ownerID:kCMP_OwnerID
                                  startIndex:0
                                    rowCount:NSIntegerMax] retain];
    }
    // add by guoyl  for 预置包
    return [aList autorelease];
}

static NSMutableDictionary *_appInfoMap;
static NSMutableDictionary *_appInfoMapWithAppId;
static dispatch_queue_t appInfoQueue;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appInfoQueue = dispatch_queue_create("com.seeyon.CMPAppManagerAppInfoQueue", DISPATCH_QUEUE_SERIAL);
    });
}

+ (NSMutableDictionary *)appInfoMap
{
    if (!_appInfoMap) {
        [CMPAppManager resetAppsMap];
    }
    return _appInfoMap;
}

+ (NSMutableDictionary *)appInfoMapWithAppId
{
    if (!_appInfoMapWithAppId) {
        [CMPAppManager resetAppsMap];
    }
    return _appInfoMapWithAppId;
}

+ (void)resetAppsMap
{
    dispatch_sync(appInfoQueue, ^{
        CMPCommonDBProvider *dbconn = [CMPCommonDBProvider sharedInstance];
        NSArray *aList;
        aList = [[dbconn appListWithServerID:kCMP_ServerID
                                      ownerID:kCMP_OwnerID
                                   startIndex:0
                                     rowCount:NSIntegerMax] retain];

        // add by guoyl  for 预置包
        NSMutableDictionary *aAppInfoMap = [[NSMutableDictionary alloc] initWithCapacity:aList.count];
        NSMutableDictionary *aAppInfoMapWithAppId = [[NSMutableDictionary alloc] initWithCapacity:aList.count];
        
        for (CMPDBAppInfo *appInfo in aList) {
            NSString *appId = appInfo.appId;
            NSString *version = appInfo.version;
            NSString *urlSchemes = appInfo.url_schemes;
            // appId map
            NSMutableDictionary *appIdDict = [aAppInfoMapWithAppId objectForKey:appId];
            if (!appIdDict) {
                appIdDict = [[[NSMutableDictionary alloc] init] autorelease];
            }
            [appIdDict setObject:appInfo forKey:version];
            [aAppInfoMapWithAppId setObject:appIdDict forKey:appId];
            // end
            NSMutableDictionary *mDict = [aAppInfoMap objectForKey:urlSchemes];
            if (!mDict) {
                mDict = [[[NSMutableDictionary alloc] init] autorelease];
            }
            [mDict setObject:appInfo forKey:version];
            // 需找到mDict的最新版本，以及每个版本的兼容版本
            [aAppInfoMap setObject:mDict forKey:urlSchemes];
        }
        [aList release];
        // 设置为自动释放
        [_appInfoMap autorelease];
        [_appInfoMapWithAppId autorelease];
        // 重新赋值
        _appInfoMap = aAppInfoMap;
        _appInfoMapWithAppId = aAppInfoMapWithAppId;
        [CMPCachedUrlParser clearCache];
    });
}

+ (NSString *)createPath:(NSString *)path
{
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
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion isEqualToString:@"5.0.1"]) {
        [CMPAppManager addSkipBackupAttributeToItemAtURL_501:[NSURL fileURLWithPath:path]];
    }
    else{
        [CMPAppManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
    }
    return path;
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

+ (BOOL)deleteAppWithAppId:(NSString *)appId version:(NSString *)aVersion aServerId:(NSString *)aServerId ownerId:(NSString *)ownerId
{
    BOOL success = NO;
    CMPCommonDBProvider *dbconn = [CMPCommonDBProvider sharedInstance];
    [dbconn deleteAppWithAppId:appId version:aVersion owerID:ownerId serverID:aServerId onCompletion:nil];
    NSMutableDictionary *aDict = [_appInfoMapWithAppId objectForKey:appId];
    CMPDBAppInfo *dbAppInfo = [aDict objectForKey:aVersion];
    if (![NSString isNull:dbAppInfo.path]) {
        [[NSFileManager defaultManager] removeItemAtPath:[CMPAppManager documentWithPath:dbAppInfo.path] error:nil];
    }
    [self resetAppsMap];
    return success;
}

+ (NSError *)storeAppWithZipPath:(NSString *)zipPath md5:(NSString *)aMd5
{
    return [CMPAppManager storeAppWithZipPath:zipPath md5:aMd5 restAppsMap:YES];
}

+ (NSError *)storeAppWithZipPath:(NSString *)zipPath md5:(NSString *)aMd5 restAppsMap:(BOOL)aRestAppsMap
{
    // copy appzip to cache
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *aTitle = [zipPath lastPathComponent];
    NSString *toPath = [[CMPAppManager cmpAppCachePath] stringByAppendingPathComponent:aTitle];
    // delete already exists
    if (![zipPath isEqualToString:toPath]) {
        NSError *error = nil;
        BOOL isDirectory = NO;
        BOOL existsPath = [[NSFileManager defaultManager] fileExistsAtPath:toPath isDirectory:&isDirectory];
        if (existsPath) {
            [fileManager removeItemAtPath:toPath error:nil];
        }
        error = nil;
        [fileManager copyItemAtPath:zipPath toPath:toPath error:&error];
        if (error) {
            NSLog(@"copy the zip fail.");
            [fileManager removeItemAtPath:toPath error:nil];
            return [NSError errorWithDomain:SY_STRING(@"common_fileCopyError") code:2 userInfo:nil];
        }
    }
    // unzip mix path
    NSString *destPath = [CMPAppManager appMixPath];
    ZipArchive *zip = [[ZipArchive alloc] init];
    BOOL ret = NO;
    if([zip UnzipOpenFile:toPath]) {
        ret = [zip UnzipFileTo:destPath overWrite:YES];
        [zip UnzipCloseFile];
    }
    [zip release];
    if (!ret) {
        return [NSError errorWithDomain:SY_STRING(@"common_unzipAppPackageFail") code:3 userInfo:nil];
    }
    // delete topath
    [fileManager removeItemAtPath:toPath error:nil];
    // 获取想对路径
    NSString *aDoucumentPath = [CMPAppManager documentWithPath:nil];
    NSString *storePath = [destPath replaceCharacter:aDoucumentPath withString:@""];
    // 读取manifest里面的值
    NSString *manifestPath = [destPath stringByAppendingPathComponent:@"manifest.json"];
    NSError *manifestError = nil;
    NSString *mainfestJsonStr = [NSString stringWithContentsOfFile:manifestPath encoding:NSUTF8StringEncoding error:&manifestError];
    if (manifestError) {
        NSLog(@"read the manifest error!");
        [fileManager removeItemAtPath:destPath error:nil];
        return [NSError errorWithDomain:SY_STRING(@"read_manifest_error") code:4 userInfo:nil];
    }
    NSDictionary *manifestDict = [mainfestJsonStr JSONValue];
    
    CMPDBAppInfo *appInfo = [[[CMPDBAppInfo alloc] initWithManifestDict:manifestDict] autorelease];
    appInfo.path = storePath;
    appInfo.serverID = kCMP_ServerID;
    appInfo.owerID = kCMP_OwnerID;
    appInfo.extend1 = aMd5; 
    CMPCommonDBProvider *dbconn = [CMPCommonDBProvider sharedInstance];
    // 插入数据之前，删除以前原有的版本信息以及目录地址
    __block NSArray *existAppInfoList;
    [dbconn appListWithServerID:kCMP_ServerID
                        ownerID:kCMP_OwnerID
                          appId:appInfo.appId
                   onCompletion:^(NSArray *result) {
                       existAppInfoList = [result copy];
                   }];
    if (existAppInfoList.count > 0) {
        for (CMPDBAppInfo *existAppInfo in existAppInfoList) {
            NSString *aPath = [CMPAppManager documentWithPath:existAppInfo.path];
            [dbconn deleteAppWithAppId:existAppInfo.appId version:existAppInfo.version owerID:existAppInfo.owerID serverID:existAppInfo.serverID onCompletion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:aPath error:nil];
        }
    }
    [existAppInfoList release];
    __block BOOL aSuccess = NO;
    [dbconn insertAppInfo:appInfo onCompletion:^(BOOL success) {
        aSuccess = success;
    }];
    if (!aSuccess) {
        NSLog(@"%@", @"download app, insert database error!");
        [fileManager removeItemAtPath:destPath error:nil];
        return [NSError errorWithDomain:SY_STRING(@"database_inser_error") code:5 userInfo:nil];
    }
    return nil;
}

+ (NSError *)presetAppsWithzipPaths:(NSArray *)aZipPaths md5List:(NSArray *)aMd5List
{
    NSError *error = nil;
    NSInteger aCount = aZipPaths.count;
    for (NSInteger i = 0; i < aCount; i ++) {
        NSString *aPath = [aZipPaths objectAtIndex:i];
        NSString *aMD5 = [aMd5List objectAtIndex:i];
        error = [CMPAppManager storeAppWithZipPath:aPath md5:aMD5];
    }
    return error;
}

+ (NSArray *)mainBundlePathsWithNames:(NSArray *)aNames
{
    NSMutableArray *aResult = [[NSMutableArray alloc] init];
    for (NSString *aValue in aNames) {
        NSString *aMainBundlePath = [[NSBundle mainBundle] pathForResource:aValue ofType:nil];
        [aResult addObject:aMainBundlePath];
    }
    return [aResult autorelease];
}

// 应用入口
+ (NSDictionary *)appEntrysWithAppId:(NSString *)appId version:(NSString *)aVersion
                            serverId:(NSString *)aServerId owerId:(NSString *)owerId
{
   CMPDBAppInfo *aDBAppInfo = [CMPAppManager appInfoWithAppId:appId version:aVersion serverId:kCMP_ServerID owerId:kCMP_OwnerID];
    if (!aDBAppInfo || !aDBAppInfo.path) {
        return nil;
    }
    NSString *aPath = [CMPAppManager documentWithPath:aDBAppInfo.finalPath];
    NSString *manifestPath = [aPath stringByAppendingPathComponent:@"manifest.json"];
    NSString *JSONString = [NSString stringWithContentsOfFile:manifestPath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *manifest = [JSONString JSONValue];
    NSDictionary *entry = [manifest objectForKey:@"entry"];
    if (!entry) {
        return nil;
    }
    NSString *urlSchemes = [manifest objectForKey:@"urlSchemes"];
    NSString *version = [manifest objectForKey:@"version"];
    NSString *aRootPath = [CMPCachedResManager rootPathWithHost:urlSchemes version:version];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:entry];

    if(aRootPath.length){
        [result setObject:aRootPath forKey:@"path"];
    }else if(aDBAppInfo.finalPath.length){
        [result setObject:aDBAppInfo.finalPath forKey:@"path"];
    }

    return [result autorelease];
}

+ (NSString *)appIndexPageWithAppId:(NSString *)appId version:(NSString *)aVersion
                           serverId:(NSString *)aServerId
{
    NSDictionary *aDict = [CMPAppManager appEntrysWithAppId:appId version:aVersion serverId:aServerId owerId:kCMP_OwnerID];
    if (aDict.count == 0) {
        return nil;
    }
    NSString *aPath = [aDict objectForKey:@"path"];
    NSString *entry = [aDict objectForKey:@"phone"];
    if (!aPath || !entry) {
        return nil;
    }
    NSString *aRootPath = aPath;//[CMPAppManager documentWithPath:aPath];
    NSString *indexPath = [NSString stringWithFormat:@"file://%@/%@", aRootPath, entry];
#ifdef CMPCachedUrlParser_GOV
    indexPath = [CMPCachedUrlParser govPathWithPath:indexPath];
    NSLog(@"zl---[%s]:%@", __FUNCTION__, indexPath);
#endif
    
    return indexPath;
}

#pragma mark -
#pragma mark Auto Merge


/**
 合并应用包
 每次有应用包更新都会触发合并操作
 */
+ (void)startMerge
{
    [CMPAppManager clearOldMerges];
    
    NSMutableDictionary *mergeAppMap = [[NSMutableDictionary alloc] init]; // 记录需要合并的APP
    NSDictionary *appInfoMap = [CMPAppManager appInfoMap];
    
    // 遍历所有应用的manifest.json，找出包含automerge的包
    for (NSString *urlScheme in appInfoMap) {
        NSDictionary *appInfoItem = appInfoMap[urlScheme];
        CMPDBAppInfo *appInfo = [appInfoItem objectForKey:[CMPAppManager getMaxKeyWithDic:appInfoItem]]; // 取最新版本的包
        NSString *manifestPath = [[CMPAppManager documentWithPath:appInfo.path] stringByAppendingPathComponent:@"manifest.json"];
        
        NSError *manifestError = nil;
        NSString *manifestJsonStr = [NSString stringWithContentsOfFile:manifestPath encoding:NSUTF8StringEncoding error:&manifestError];
        
        if (manifestError) {
            NSLog(@"autoMerge---Get manifestJsonStr is failed!");
            continue;
        }
        
        NSDictionary *manifestDict = [manifestJsonStr JSONValue];
        // 记录，判断当前应用包的html页面是否需要合并到其他应用包
        NSArray *automerge = [manifestDict objectForKey:@"automerge"];
        
        if (automerge) {
            [mergeAppMap setObject:automerge forKey:appInfo.path];
        }
    }
    
    if (mergeAppMap.count == 0 ||
        !mergeAppMap) {
        [mergeAppMap removeAllObjects];
        [mergeAppMap release];
        mergeAppMap = nil;
        return;
    }
    
    // 合并包
    for (NSString *path in mergeAppMap) {
        NSArray *autoMerges = mergeAppMap[path];
        for (NSDictionary *aMergeItem in autoMerges) {
            [CMPAppManager mergeWithAutomerge:aMergeItem localPath:[CMPAppManager documentWithPath:path]];
//            if (!mergeRet) {
//                NSLog(@"autoMerge---Merge fail, merge src:%@, merge insert:%@", aMergeItem[@"src"], aMergeItem[@"insert"]);
//            }
        }
    }
    
    [mergeAppMap removeAllObjects];
    [mergeAppMap release];
    mergeAppMap = nil;
}


/**
 根据manifest文件中的automerge信息，进行合并
 
 @param aMergeItem automerge信息
 @param path 应用包在本地的物理全路径
 @return
 */
+ (void)mergeWithAutomerge:(NSDictionary *)aMergeItem localPath:(NSString *)path {
    // 1、找到待合并的应用
    NSURL *srcUrl = [NSURL URLWithString:aMergeItem[@"src"]];
    NSString *srcHost = srcUrl.host;
    NSArray *srcUrlPaths = srcUrl.pathComponents;
//    NSArray *srcFileName = [srcUrlPaths lastObject];
    NSString *srcVersion = [srcUrlPaths objectAtIndex:1];
    srcVersion = [srcVersion stringByReplacingOccurrencesOfString:@"v" withString:@""];
    
    // 获取原应用的CMPDBAppInfo
    NSDictionary *aDict = [[CMPAppManager appInfoMap] objectForKey:srcHost];
    CMPDBAppInfo *srcAppInfo = [aDict objectForKey:srcVersion];
    
    if (!srcAppInfo) {
        srcAppInfo = [[aDict allValues] lastObject];
    }
    
    if (!srcAppInfo) {
        NSLog(@"autoMerge---%@ version %@ not be found!", srcHost, srcVersion);
        return;
    }
    
    // 获取原应用路径
    NSString *srcFolderPath = nil;
    BOOL hasMerged = NO;
    
    if (![NSString isNull:srcAppInfo.extend2]) {
        srcFolderPath = srcAppInfo.extend2;
        hasMerged = YES;
    } else {
        srcFolderPath = srcAppInfo.path;
    }
    
    srcFolderPath = [CMPAppManager documentWithPath:srcFolderPath];
    
    // 2、copy被合并的应用目录，作为被修改后的目录 例如：/h5/FED87891-D24E-4221-9C7A-0F566A6E059C
    NSString *copyDestPath = nil;
    
    if (!hasMerged) { // 如果应用之前没有合并过，拷贝一个目录作为合并目录
        copyDestPath = [CMPAppManager appMixPath];
        NSError *copyFileError = nil;
        [[NSFileManager defaultManager] copyItemAtPath:srcFolderPath toPath:copyDestPath error:&copyFileError];
        
        if (copyFileError) {
            NSLog(@"autoMerge---copy localSrc file fail!%@", copyFileError);
            return;
        }
    } else {
        copyDestPath = srcFolderPath; // 如果应用合并过，就用原合并目录
    }
    
    // 在拷贝路径中查找要合并的srcfile的路径
//    NSArray *subPaths = [[NSFileManager defaultManager] subpathsAtPath:copyDestPath];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"lastPathComponent", srcFileName];
//    NSString *srcCopyPath = [[NSString alloc] initWithFormat:@"%@/%@", copyDestPath, [[subPaths filteredArrayUsingPredicate:predicate] lastObject]];
    NSMutableString *srcCopyPath = [copyDestPath mutableCopy];
    [srcUrlPaths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 1) {
            [srcCopyPath appendFormat:@"/%@", path];
        }
    }];
    
    // 3、根据合并的配置，合并html页面
    NSArray *insertPathList = aMergeItem[@"insert"];
    NSMutableArray *insertFullPathList = [NSMutableArray array]; // 待注入代码的路径列表
    
    for (NSString *aInsertPathItem in insertPathList) {
        NSString *insertFullPath = [path stringByAppendingPathComponent:aInsertPathItem];
        [insertFullPathList addObject:insertFullPath];
    }
    
    BOOL mergeHTMLFileRet = [CMPAppManager mergeHTMLFile:insertFullPathList to:srcCopyPath];
    [srcCopyPath release];
    srcCopyPath = nil;
    
    if (!mergeHTMLFileRet) {
//        NSLog(@"autoMerge---MergeHTMLFile fail,insertFullPathList:%@, srcCopyPath:%@", insertFullPathList, srcCopyPath);
        return;
    }
    
    // 4、根据被合并的appID设置新的合并目录，更新数据库
    // 合并成功，更新数据库
    CMPCommonDBProvider *dbProvider = [CMPCommonDBProvider sharedInstance];
    [dbProvider deleteAppWithAppId:srcAppInfo.appId
                           version:srcAppInfo.version
                            owerID:kCMP_OwnerID
                          serverID:kCMP_ServerID
                      onCompletion:nil];
    // 获取相对路径
    NSString *aDoucumentPath = [CMPAppManager documentWithPath:nil];
    NSString *storePath = [copyDestPath replaceCharacter:aDoucumentPath withString:@""];
    
    srcAppInfo.extend2 = storePath;
    [dbProvider insertAppInfo:srcAppInfo
                 onCompletion:^(BOOL success) {
                     if (!success) {
                         NSLog(@"autoMerge---Insert database error!");
                         NSFileManager *fileManager = [NSFileManager defaultManager];
                         [fileManager removeItemAtPath:copyDestPath error:nil];
                     }
                 }];
}


/**
 删除所有以前合并的数据库记录及合并文件夹
 */
+ (void)clearOldMerges {
    NSDictionary *appInfoMap = [CMPAppManager appInfoMap];
    CMPCommonDBProvider *dbProvider = [CMPCommonDBProvider sharedInstance];
    
    for (NSString *urlScheme in appInfoMap) {
        NSDictionary *appInfoItems = appInfoMap[urlScheme];
        
        for (NSString *version in appInfoItems) {
            CMPDBAppInfo *appInfo = appInfoItems[version];
            
            if (![NSString isNull:appInfo.extend2]) { // 删除所有以前合并的数据库记录及合并文件夹
                NSString *aDocumentPath = [CMPAppManager documentWithPath:nil];
                NSString *mergeFolder = [aDocumentPath stringByAppendingPathComponent:appInfo.extend2];
                NSLog(@"autoMerge---Remove merge folder:%@", mergeFolder);
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError *removeFileError = nil;
                [fileManager removeItemAtPath:mergeFolder error:&removeFileError];
                
                if (removeFileError) {
                    NSLog(@"autoMerge---Remove old merge fail!");
                }
                
                // 从数据库中取最新的数据
                [dbProvider deleteAppWithAppId:appInfo.appId
                                       version:appInfo.version
                                        owerID:kCMP_OwnerID
                                      serverID:kCMP_ServerID
                                  onCompletion:^(BOOL success) {
                                      if (!success) {
                                          NSLog(@"autoMerge---clearOldMerge:Delete appinfo from db failed,appId:%@,version:%@", appInfo.appId, appInfo.version);
                                      }
                                  }];
                
                appInfo.extend2 = @"";
                [dbProvider insertAppInfo:appInfo
                             onCompletion:^(BOOL success) {
                                 if (!success) {
                                     NSLog(@"autoMerge---clearOldMerge:Insert appinfo to db failed,appId:%@,version:%@", appInfo.appId, appInfo.version);
                                 }
                             }];
            }
        }
    }
}


/**
 合并两个HTML文件，从src文件到dest文件中
 
 @param srcPathList 合并的源文件列表
 @param destPath 合并的目标文件
 @return
 */
+ (BOOL)mergeHTMLFile:(NSArray *)srcPathList to:(NSString *)destPath {
    NSString *mergedSrcHTML = @"";
    for (NSString *srcPath in srcPathList) {
        NSError *readSrcError = nil;
        NSString *srcHTML = [NSString stringWithContentsOfFile:srcPath encoding:NSUTF8StringEncoding error:&readSrcError];
        if (readSrcError) {
            NSLog(@"autoMerge---Read srcHTML fail!%@", readSrcError);
            return NO;
        }
        mergedSrcHTML = [mergedSrcHTML stringByAppendingString:srcHTML];
    }
    
    NSError *readDestError = nil;
    NSString *destHTML = [NSString stringWithContentsOfFile:destPath encoding:NSUTF8StringEncoding error:&readDestError];
    if (readDestError) {
        NSLog(@"autoMerge---Read destHTML fail!%@", readDestError);
        return NO;
    }
    
    // 用正则找到需要注入代码的位置
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(</body>){0,1}\\s*</html>(\\w|\\s|[\\*\\-]|(!>)|(<!))*$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *result = [regex matchesInString:destHTML options:0 range:NSMakeRange(0, destHTML.length)];
    
    if (!result) {
        NSLog(@"autoMerge---Merge HTML fail!destPath:%@", destPath);
        return NO;
    }
    
    // 合并html代码
    NSTextCheckingResult *res = [result lastObject];
    NSMutableString *mutableDestHTML = [destHTML mutableCopy];
    [mutableDestHTML insertString:mergedSrcHTML atIndex:res.range.location];
    // 写入文件
    NSError *writeDestError = nil;
    [mutableDestHTML writeToFile:destPath atomically:YES encoding:NSUTF8StringEncoding error:&writeDestError];
    
    [mutableDestHTML release];
    mutableDestHTML = nil;
    
    if (writeDestError) {
        NSLog(@"autoMerge---Write destHTML fail!%@", writeDestError);
        return NO;
    }
    
    return YES;
}


/**
 获取字典中key的版本号最大值
 版本号规则：x.x.x
 */
+ (NSString *)getMaxKeyWithDic:(NSDictionary *)dic {
    NSArray *allKeys = [dic allKeys];
    NSArray *afterSortKeyArray = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id _Nonnull obj2) {
        NSString *version1 = (NSString *)obj1;
        NSString *version2 = (NSString *)obj2;
        
        NSArray *versionArr1 = [version1 componentsSeparatedByString:@"."];
        NSArray *versionArr2 = [version2 componentsSeparatedByString:@"."];
        
        for (int i = 0; i < 3 ; i++) {
            if (versionArr1[i] > versionArr2[i]) {
                return NSOrderedDescending;
            } else if (versionArr1[i] < versionArr2[i]) {
                return NSOrderedAscending;
            }
        }
        
        return NSOrderedSame;
    }];
    return [afterSortKeyArray lastObject];
}

@end
