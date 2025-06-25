//
//  CMPAppManager.h
//  CMPCore
//
//  Created by youlin on 16/5/30.
//
//

#import "CMPObject.h"
#import "CMPDBAppInfo.h"

@interface CMPAppManager : CMPObject

+ (NSString *)documentWithPath:(NSString *)aPath;
// 创建CMPlib包目录
+ (NSString *)cmpLibPath;
+ (NSString *)cmpH5ZipDownloadPath;
+ (NSString *)cmpAppCachePath;
// 创建AppsPath目录
+ (NSString *)appsPath:(NSString *)aName domain:(NSString *)aDomain;
+ (NSString *)appMixPath;

// 创建公共资源包目录
+ (NSString *)commonsLibPath:(NSString *)aDomain;
+ (NSMutableDictionary *)appInfoMap;
+ (NSMutableDictionary *)appInfoMapWithAppId;
//根据serverId、ownerId获取app list
+ (NSArray *)appListWithServerId:(NSString *)aServerId ownerId:(NSString *)ownerId;
// 根据appId、version、serverId、owerId获取app信息
+ (CMPDBAppInfo *)appInfoWithAppId:(NSString *)appId version:(NSString *)aVersion
                 serverId:(NSString *)aServerId owerId:(NSString *)owerId;
+ (void)resetAppsMap;
+ (BOOL)deleteAppWithAppId:(NSString *)appId version:(NSString *)aVersion aServerId:(NSString *)aServerId ownerId:(NSString *)ownerId;
+ (NSError *)storeAppWithZipPath:(NSString *)zipPath md5:(NSString *)aMd5;
+ (NSError *)storeAppWithZipPath:(NSString *)zipPath md5:(NSString *)aMd5 restAppsMap:(BOOL)aRestAppsMap;
+ (NSError *)presetAppsWithzipPaths:(NSArray *)aZipPaths md5List:(NSArray *)aMd5List;
+ (NSArray *)mainBundlePathsWithNames:(NSArray *)aNames;
// 应用入口
+ (NSDictionary *)appEntrysWithAppId:(NSString *)appId version:(NSString *)aVersion
                          serverId:(NSString *)aServerId owerId:(NSString *)owerId;
+ (NSString *)appIndexPageWithAppId:(NSString *)appId version:(NSString *)aVersion
                           serverId:(NSString *)aServerId;

// 合并
+ (void)startMerge;

@end
