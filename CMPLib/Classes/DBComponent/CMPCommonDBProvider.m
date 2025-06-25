//
//  CMPCommonDBProvider.m
//  CMPLib
//
//  Created by CRMO on 2018/3/20.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import "CMPCommonDBProvider.h"
#import "FMDB.h"
#import "CMPDBAppInfo.h"
#import "SyFaceDownloadRecordObj.h"
#import "CMPScheduleEventRcord.h"
#import "CMPOfflineFileRecord.h"
#import "FMDatabaseQueueFactory.h"
#import "CMPDownloadFileRecord.h"
NSString * const CMPCommonDBProviderDbName = @"seeyon_cmp_db.db";

@interface CMPCommonDBProvider()

@property (strong, nonatomic) FMDatabaseQueue *dataQueue;

@end

@implementation CMPCommonDBProvider

#pragma mark-
#pragma mark Init

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self dataQueue];
        [self initTables];
    }
    return self;
}

/**
 初始化库表
 */
- (void)initTables {
    [_dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[[self class] createAppsTableSql]];
        [db executeUpdate:[[self class] createCMPOfflineFileRecordsTableSql]];
        [db executeUpdate:[[self class] createFaceDownloadRecordsTableSql]];
        [db executeUpdate:[[self class] createCMPDownloadFileRecordsTable]];
        [db executeUpdate:[[self class] createScheduleRecordsTable]];
    }];
}

- (void)clearTableForClearCache {
    [_dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM CMPDownloadFileRecords"];
        [db executeUpdate:@"DELETE FROM FaceDownloadRecords"];
    }];
}

#pragma mark-
#pragma mark CMP apps

- (void)insertAppInfo:(CMPDBAppInfo *)app
         onCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        NSInteger count = [db intForQuery:@"select count(*) from cmp_apps where serverID = ? and owerID = ? and appId = ? and version = ?", app.serverID, app.owerID, app.appId, app.version];
        if (count > 0) {
            result = YES;
            return;
        }
        
        result = [db executeUpdate:@"INSERT INTO cmp_apps (appId, bundle_identifier, bundle_name, bundle_display_name, version, team, path, bundle_type, desc, deployment_target, compatible_version, icon_files, supported_platforms, url_schemes, serverID, owerID, downloadTime, extend1, extend2, extend3, extend4, extend5, extend6, extend7, extend8, extend9, extend10, extend11, extend12, extend13, extend14, extend15) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", app.appId, app.bundle_identifier, app.bundle_name, app.bundle_display_name, app.version, app.team, app.path, app.bundle_type, app.desc, app.deployment_target, app.compatible_version, app.icon_files, app.supported_platforms, app.url_schemes, app.serverID, app.owerID, app.downloadTime, app.extend1, app.extend2, app.extend3, app.extend4, app.extend5, app.extend6, app.extend7, app.extend8, app.extend9, app.extend10, app.extend11, app.extend12, app.extend13, app.extend14, app.extend15];
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)appListWithServerID:(NSString *)serverID
                    ownerID:(NSString *)aOwnerID
                      appId:(NSString *)aAppId
               onCompletion:(CMPCommonDBProviderArrayCompletion)completion {
    NSMutableArray *result = [NSMutableArray array];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM cmp_apps where serverID = ? and owerID = ? and appId = ? order by  downloadTime desc", serverID, aOwnerID, aAppId];
        
        while ([resultSet next]) {
            CMPDBAppInfo *appInfo = [CMPDBAppInfo yy_modelWithDictionary:[resultSet resultDictionary]];
            [result addObject:appInfo];
        }
    }];
    
    if (completion) {
        completion(result);
    }
}

- (NSArray *)appListWithServerID:(NSString *)serverID
                    ownerID:(NSString *)aOwnerID
                 startIndex:(NSInteger)aStartIndex
                   rowCount:(NSInteger)aRowCount
{
    NSMutableArray *result = [NSMutableArray array];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM cmp_apps where serverID = ? and owerID = ? order by  downloadTime desc LIMIT ? OFFSET ? ", serverID, aOwnerID, [NSNumber numberWithInteger:aRowCount], [NSNumber numberWithInteger:aStartIndex]];
        
        while ([resultSet next]) {
            CMPDBAppInfo *appInfo = [CMPDBAppInfo yy_modelWithDictionary:[resultSet resultDictionary]];
            [result addObject:appInfo];
        }
    }];
    return result;
}

- (void)appListWithServerID:(NSString *)serverID
                         ownerID:(NSString *)aOwnerID
                           appId:(NSString *)aAppId
                         version:(NSString *)version
                    onCompletion:(CMPCommonDBProviderArrayCompletion)completion {
    NSMutableArray *result = [NSMutableArray array];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM cmp_apps where serverID = ? and owerID = ? and appId = ? and version = ? order by  downloadTime desc", serverID, aOwnerID, aAppId, version];
        
        while ([resultSet next]) {
            CMPDBAppInfo *appInfo = [CMPDBAppInfo yy_modelWithDictionary:[resultSet resultDictionary]];
            [result addObject:appInfo];
        }
        
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)deleteAppWithAppId:(NSString *)appId
                   version:(NSString *)aVersion
                    owerID:(NSString *)aOwerID
                  serverID:(NSString *)aServerID
              onCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"DELETE FROM cmp_apps where owerID = ? and serverID = ? and appId = ? and version = ?", aOwerID, aServerID, appId, aVersion];
    }];
    if (completion) {
        completion(result);
    }
}

#pragma mark-
#pragma mark 头像

- (void)insertFaceDownloadRecord:(SyFaceDownloadRecordObj *)aFile
                    onCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        NSInteger count = [db intForQuery:@"select count(*) from FaceDownloadRecords where memberId = ? and serverId = ?", aFile.memberId, aFile.serverId];
        if (count > 0) {
            result = YES;
            return;
        }
        
        result = [db executeUpdate:@"INSERT INTO FaceDownloadRecords ( memberId, serverId, savePath, downloaMd5, extend1, extend2, extend3, extend4, extend5 ) VALUES(?,?,?,?,?,?,?,?,?)", aFile.memberId, aFile.serverId, aFile.savePath, aFile.downloadUrlMd5, aFile.extend1, aFile.extend2, aFile.extend3, aFile.extend4, aFile.extend5];
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)faceDownloadRecordsWithObj:(SyFaceDownloadObj *)obj
                      onCompletion:(CMPCommonDBProviderArrayCompletion)completion {
    NSMutableArray *result = [NSMutableArray array];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM FaceDownloadRecords where memberId = ? and serverId = ? and downloaMd5 = ?", obj.memberId, obj.serverId, obj.downloadUrl.md5String];
        
        while ([set next]) {
            SyFaceDownloadRecordObj *record = [SyFaceDownloadRecordObj yy_modelWithDictionary:[set resultDictionary]];
            [result addObject:record];
        }
        
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)deleteFaceRecordsWithMemberId:(NSString *)memberId
                             serverId:(NSString *)aServerId
                         onCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"DELETE FROM FaceDownloadRecords where memberId = ? and serverId = ?", memberId, aServerId];
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)deleteAllFaceRecordsOnCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"DELETE FROM FaceDownloadRecords"];
    }];
    
    if (completion) {
        completion(result);
    }
}

#pragma mark-
#pragma mark 日程

- (void)insertScheduleRecordItem:(CMPScheduleEventRcord *)syncRecord
                    onCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"INSERT INTO syncRecords ( scheduleLocalID, serverIdentifier, userID, syncDate, timeCalEventID, subject, beginDate, endDate, type, status, account, alarmDate, address, hasRemindFlag, repeatType, addedEvent, extend1, extend2, extend3, extend4, extend5, extend6, extend7, extend8, extend9, extend10) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", syncRecord.scheduleLocalID, syncRecord.serverIdentifier, syncRecord.userID, syncRecord.syncDate, syncRecord.timeCalEventID, syncRecord.subject, syncRecord.beginDate, syncRecord.endDate, syncRecord.type, syncRecord.status, syncRecord.account, syncRecord.alarmDate, syncRecord.address, syncRecord.hasRemindFlag, syncRecord.repeatType, syncRecord.addedEvent, syncRecord.extend1, syncRecord.extend2, syncRecord.extend3, syncRecord.extend4, syncRecord.extend5, syncRecord.extend6, syncRecord.extend7, syncRecord.extend8, syncRecord.extend9, syncRecord.extend10];
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)isExistsScheduleWithID:(NSString *)aScheduleID
                      serverID:(NSString *)aServerID
                        userID:(NSString *)aUserID
                  onCompletion:(CMPCommonDBProviderArrayCompletion)completion {
    NSMutableArray *result = [NSMutableArray array];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM syncRecords where timeCalEventID = ? and serverIdentifier = ? and userID = ?", aScheduleID, aServerID, aUserID];
        
        while ([set next]) {
            NSString *eventID = [set stringForColumnIndex:1];
            if ([NSString isNotNull:eventID]) {
                [result addObject:eventID];
            }
        }
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)deleteScheduleRecordWithID:(NSString *)aScheduleID
                          serverID:(NSString *)aServerID
                            userID:(NSString *)aUserID
                      onCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"DELETE FROM syncRecords where timeCalEventID = ? and serverIdentifier = ? and userID = ?", aScheduleID, aServerID, aUserID];
    }];
    
    if (completion) {
        completion(result);
    }
}

#pragma mark-
#pragma mark 离线文档

/// 查找文件
/// @param fileId 文件id
/// @param serverID 服务器id
/// @param ownerID ownerID
- (BOOL)findOfflineFilesWithFileId:(NSString *)fileName
                          serverID:(NSString *)serverID
                           ownerID:(NSString *)ownerID {
    NSMutableArray *result = [NSMutableArray array];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM CMPOfflineFileRecords where serverIdentifier = ? and ownerId = ? and fileName = ? ", serverID, ownerID, fileName];
        
        while ([set next]) {
            CMPOfflineFileRecord *record = [CMPOfflineFileRecord yy_modelWithDictionary:[set resultDictionary]];
            [result addObject:record];
        }
    }];
    return result.count > 0;
}
- (void)checkOfflineFileName:(NSString *)fileName
                      fileId:(NSString *)fileId
                      origin:(NSString *)origin
                     ownerId:(NSString *)ownerId
                    serverId:(NSString *)serverId
                onCompletion:(void(^)(NSString* fileName))completion {
    
    [_dataQueue inDatabase:^(FMDatabase *db) {
        //如果当前文件已存在
        FMResultSet *set = [db executeQuery:@"select fileName from CMPOfflineFileRecords where fileName = ? and origin = ? and ownerId = ? and serverIdentifier = ? and fileId == ?", fileName, origin,ownerId,serverId,fileId];
        while ([set next]) {
            NSString *fileName = [set stringForColumn:@"fileName"];
            completion(fileName);
            return;
        }
        NSString *pathExtension = fileName.pathExtension;
        NSString *name = fileName.stringByDeletingPathExtension;
        NSString *likeStr = [NSString stringWithFormat:@"%@(%%).%@",name,pathExtension];
        
        FMResultSet *sameSuffixSet = [db executeQuery:@"select fileName from CMPOfflineFileRecords where (fileName = ? or fileName like ? ) and origin = ? and ownerId = ? and serverIdentifier = ? and fileId != ?", fileName,likeStr, origin,ownerId,serverId,fileId];
        NSMutableArray *sameSuffixArray = [[NSMutableArray alloc] init];
        while ([sameSuffixSet next]) {
            NSString *fileName = [sameSuffixSet stringForColumn:@"fileName"];
            [sameSuffixArray addObject:fileName];
        }
        if (sameSuffixArray.count == 0 || ![sameSuffixArray containsObject:fileName]) {
            completion(fileName);
        }
        else {
            for (NSInteger t = 1; t < sameSuffixArray.count+3; t++) {
                  NSString *tempName = [NSString fileNameAppendSuffix:fileName suffix:t];
                if (![sameSuffixArray containsObject:tempName]) {
                    completion(tempName);
                    break;
                }
            }
        }
    }];
}

- (void)insertOfflineFileRecord:(CMPOfflineFileRecord *)aFile
                   onCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        NSInteger count = [db intForQuery:@"select count(*) from CMPOfflineFileRecords where fileId = ? and origin = ? and ownerId = ?", aFile.fileId, aFile.origin,aFile.ownerId];
        if (count > 0) {
            result = YES;
            return;
        }
        result = [db executeUpdate:@"INSERT INTO CMPOfflineFileRecords ( fileId, fileName, suffix, savePath, saveName, serverIdentifier, createTime, modifyTime, downloadTime, fileSize, creatorName, origin, ownerId, extend1, extend2, extend3, extend4, extend5 ) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", aFile.fileId, aFile.fileName, aFile.fileSuffix, aFile.savePath, aFile.localName, aFile.serverId, aFile.createDate, aFile.modifyTime ?: @"", aFile.downloadTime, aFile.fileSize, aFile.creatorName, aFile.origin, aFile.ownerId, aFile.extend1, aFile.extend2, aFile.extend3, aFile.extend4, aFile.extend5];
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)offlineFileRecordsWithFileId:(NSString *)aFileId
                        lastModified:(NSString *)lastModified
                              origin:(NSString *)origin
                            serverID:(NSString *)serverID
                             ownerID:(NSString *)ownerID
                        onCompletion:(CMPCommonDBProviderArrayCompletion)completion {
    NSMutableArray *result = [NSMutableArray array];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM CMPOfflineFileRecords where fileId = ? and origin = ? and modifyTime = ? and serverIdentifier = ? and ownerId = ?", aFileId, origin, lastModified ?: @"", serverID, ownerID];
        
        while ([set next]) {
            CMPOfflineFileRecord *record = [CMPOfflineFileRecord yy_modelWithDictionary:[set resultDictionary]];
            [result addObject:record];
        }
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)deleteOfflineFileRecordsWithFileId:(NSString *)aFileId
                                    origin:(NSString *)origin
                                  serverID:(NSString *)serverID
                                   ownerID:(NSString *)ownerID
                              onCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"DELETE FROM CMPOfflineFileRecords where  fileId = ? and origin = ? and serverIdentifier = ? and ownerId = ?", aFileId, origin, serverID, ownerID];
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)countOfofflineFilesWithServerID:(NSString *)serverID
                                ownerID:(NSString *)ownerID
                           onCompletion:(CMPCommonDBProviderIntCompletion)completion {
    __block NSInteger count = 0;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        count = [db intForQuery:@"SELECT count(*) FROM CMPOfflineFileRecords where serverIdentifier = ? and ownerId = ? ", serverID, ownerID];
    }];
    
    if (completion) {
        completion(count);
    }
}

- (void)offlineFilesWithStartIndex:(NSInteger)aStartIndex
                          rowCount:(NSInteger)aRowCount
                          serverID:(NSString *)serverID
                           ownerID:(NSString *)ownerID
                      onCompletion:(CMPCommonDBProviderArrayCompletion)completion {
    NSMutableArray *result = [NSMutableArray array];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM CMPOfflineFileRecords where serverIdentifier = ? and ownerId = ? order by  downloadTime desc LIMIT ? OFFSET ?", serverID, ownerID, [NSNumber numberWithInteger:aRowCount], [NSNumber numberWithInteger:aStartIndex]];
        
        while ([set next]) {
            CMPOfflineFileRecord *record = [CMPOfflineFileRecord yy_modelWithDictionary:[set resultDictionary]];
            [result addObject:record];
        }
    }];
    if (completion) {
        completion(result);
    }
}


- (void)countOfSearchOfflineFilesWithKeyWord:(NSString *)aKeyWord
                                    serverID:(NSString *)serverID
                                     ownerID:(NSString *)ownerID
                                      onCompletion:(CMPCommonDBProviderIntCompletion)completion {
    __block NSInteger count = 0;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM CMPOfflineFileRecords where serverIdentifier = ? and ownerId = ? and fileName like '%%%@%%' or extend2 like '%%%@%%'", aKeyWord,aKeyWord];
        count = [db intForQuery:sql, serverID, ownerID];
    }];
    
    if (completion) {
        completion(count);
    }
}

- (void)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord
                           startIndex:(NSInteger)aStartIndex
                             rowCount:(NSInteger)aRowCount
                             serverID:(NSString *)serverID
                              ownerID:(NSString *)ownerID
                         onCompletion:(CMPCommonDBProviderArrayCompletion)completion {
    NSMutableArray *result = [NSMutableArray array];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM CMPOfflineFileRecords where serverIdentifier = ? and ownerId = ? and fileName like '%%%@%%' or extend2 like '%%%@%%' order by downloadTime desc LIMIT ? OFFSET ?", aKeyWord,aKeyWord];
        FMResultSet *set = [db executeQuery:sql, serverID, ownerID, [NSNumber numberWithInteger:aRowCount], [NSNumber numberWithInteger:aStartIndex]];
        
        while ([set next]) {
            CMPOfflineFileRecord *record = [CMPOfflineFileRecord yy_modelWithDictionary:[set resultDictionary]];
            [result addObject:record];
        }
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord
                           startIndex:(NSInteger)startIndex
                             rowCount:(NSInteger)rowCount
                              typeStr:(NSString *)typeStr
                             serverID:(NSString *)serverID
                              ownerID:(NSString *)ownerID
                         onCompletion:(CMPCommonDBProviderArrayCompletion)completion {
    NSMutableArray *result = [NSMutableArray array];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        NSString *keywordSql = @"";
        if (![NSString isNull:aKeyWord]) {
            keywordSql = [NSString stringWithFormat:@" and (fileName like '%%%@%%' or extend2 like '%%%@%%')  ",aKeyWord,aKeyWord];
        }
        NSString *typeStrSql = @"";

        if (![NSString isNull:typeStr]) {
            typeStrSql = [NSString stringWithFormat:@" and lower(suffix) %@ ",typeStr];
        }
        [db executeQuery:@"PRAGMA case_sensitive_like=ON"];//大小写
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM CMPOfflineFileRecords where serverIdentifier = ? and ownerId = ? %@ %@ order by downloadTime desc LIMIT ? OFFSET ?", typeStrSql,keywordSql];
        FMResultSet *set = [db executeQuery:sql, serverID, ownerID, [NSNumber numberWithInteger:rowCount], [NSNumber numberWithInteger:startIndex]];
        
        while ([set next]) {
            CMPOfflineFileRecord *record = [CMPOfflineFileRecord yy_modelWithDictionary:[set resultDictionary]];
            [result addObject:record];
        }        
    }];
    if (completion) {
        completion(result);
    }
}

- (void)updateOfflineFileIconPath:(CMPOfflineFileRecord *)aFile {
    [_dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE CMPOfflineFileRecords set extend1 = ? WHERE fileId = ? and serverIdentifier = ? and ownerId = ? ",aFile.extend1,aFile.fileId,aFile.serverId,aFile.ownerId];
    }];
}

- (void)deleteOfflineFileWithFileIDs:(NSArray *)aFileIDs
                            serverID:(NSString *)serverID
                             ownerID:(NSString *)ownerID
                        onCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i < aFileIDs.count; i ++) {
        [str appendString:@"'"];
        [str appendString:[aFileIDs objectAtIndex:i]];
        [str appendString:@"'"];
        if (i != aFileIDs.count - 1) {
            [str appendString:@","];
        }
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM CMPOfflineFileRecords where fileId in (%@) and serverIdentifier = ? and ownerId = ?", str];
    
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, serverID, ownerID];
    }];
    if (completion) {
        completion(result);
    }
}

#pragma mark-
#pragma mark 文件下载

- (void)insertDownloadFileRecord:(CMPDownloadFileRecord *)aFile
                    onCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        NSInteger count = [db intForQuery:@"select count(*) from CMPDownloadFileRecords where fileId = ? and origin = ?", aFile.fileId, aFile.origin];
        if (count > 0) {
            result = YES;
            return;
        }
        
        result = [db executeUpdate:@"INSERT INTO CMPDownloadFileRecords ( fileId, fileName, suffix, savePath, saveName, serverIdentifier, createTime, modifyTime, downloadTime, fileSize, creatorName, origin, extend1, extend2, extend3, extend4, extend5 ) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", aFile.fileId, aFile.fileName, aFile.fileSuffix, aFile.savePath, aFile.localName, aFile.serverId, aFile.createDate, aFile.modifyTime ?:@"", aFile.downloadTime, aFile.fileSize, aFile.creatorName, aFile.origin,  aFile.extend1, aFile.extend2, aFile.extend3, aFile.extend4, aFile.extend5];
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)downloadFileRecordsWithFileId:(NSString *)aFileId
                         lastModified:(NSString *)lastModified
                               origin:(NSString *)origin
                             serverID:(NSString *)serverID
                         onCompletion:(CMPCommonDBProviderArrayCompletion)completion {
    NSMutableArray *result = [NSMutableArray array];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM CMPDownloadFileRecords where fileId = ? and origin = ? and modifyTime = ? and serverIdentifier = ?", aFileId, origin, lastModified ?:@"", serverID];
        
        while ([set next]) {
            CMPDownloadFileRecord *record = [CMPDownloadFileRecord yy_modelWithDictionary:[set resultDictionary]];
            [result addObject:record];
        }
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)deleteDownloadFileRecordsWithFileId:(NSString *)aFileId
                                     origin:(NSString *)origin
                                   serverID:(NSString *)serverID
                               onCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"DELETE FROM CMPDownloadFileRecords where  fileId = ? and origin = ? and serverIdentifier = ?", aFileId, origin, serverID];
    }];
    
    if (completion) {
        completion(result);
    }
}

- (void)deleteAllDownloadFileRecordsOnCompletion:(CMPCommonDBProviderBOOLCompletion)completion {
    __block BOOL result = NO;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"DELETE FROM CMPDownloadFileRecords"];
    }];
    
    if (completion) {
        completion(result);
    }
}

#pragma mark-
#pragma mark Getter & Setter

- (FMDatabaseQueue *)dataQueue {
    if (!_dataQueue) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = paths[0];
        NSString *dbPath = [documentsPath stringByAppendingPathComponent:CMPCommonDBProviderDbName];
        _dataQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:YES];
        //_dataQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:NO];
    }
    return _dataQueue;
}

#pragma mark-
#pragma mark Sql

+ (NSString *)createAppsTableSql {
    NSString *createSql =
    @"create table if not exists cmp_apps (id integer primary key autoincrement,\
    appId text,\
    bundle_identifier text,\
    bundle_name text,\
    bundle_display_name text,\
    version text,\
    team text,\
    path text,\
    bundle_type text,\
    desc text,\
    deployment_target text,\
    compatible_version text,\
    icon_files text,\
    supported_platforms text,\
    url_schemes text,\
    serverID text,\
    owerID text,\
    downloadTime text,\
    extend1 text, \
    extend2 text, \
    extend3 text, \
    extend4 text, \
    extend5 text, \
    extend6 text, \
    extend7 text, \
    extend8 text, \
    extend9 text, \
    extend10 text, \
    extend11 text, \
    extend12 text, \
    extend13 text, \
    extend14 text, \
    extend15 text)";
    return createSql;
}

+ (NSString *)createCMPOfflineFileRecordsTableSql {
    NSString *createFileSql = @"create table if not exists CMPOfflineFileRecords (id integer primary key autoincrement, \
    fileId text, \
    fileName text, \
    suffix text, \
    savePath text, \
    saveName text, \
    serverIdentifier text, \
    createTime text, \
    modifyTime text, \
    downloadTime text, \
    fileSize text, \
    creatorName text, \
    origin text, \
    ownerId text ,\
    extend1 text, \
    extend2 text, \
    extend3 text, \
    extend4 text, \
    extend5 text)";
    return createFileSql;
}

+ (NSString *)createFaceDownloadRecordsTableSql {
    NSString *createFileSql = @"create table if not exists FaceDownloadRecords (id integer primary key autoincrement, \
    memberId text, \
    serverId text, \
    savePath text, \
    downloaMd5 text, \
    extend1 text, \
    extend2 text, \
    extend3 text, \
    extend4 text, \
    extend5 text)";
    return createFileSql;
}

+ (NSString *)createCMPDownloadFileRecordsTable {
    NSString *createFileSql = @"create table if not exists CMPDownloadFileRecords (id integer primary key autoincrement, \
    fileId text, \
    fileName text, \
    suffix text, \
    savePath text, \
    saveName text, \
    serverIdentifier text, \
    createTime text, \
    modifyTime text, \
    downloadTime text, \
    fileSize text, \
    creatorName text, \
    origin text, \
    extend1 text, \
    extend2 text, \
    extend3 text, \
    extend4 text, \
    extend5 text)";
    return createFileSql;
}

+ (NSString *)createScheduleRecordsTable {
    NSString *createSql = @"create table if not exists syncRecords (id integer primary key autoincrement,\
    scheduleLocalID text,\
    serverIdentifier text,\
    userID text, \
    syncDate text, \
    timeCalEventID text, \
    subject text,\
    beginDate text,\
    endDate text,\
    type text,\
    status text,\
    account text,\
    alarmDate text,\
    address text,\
    hasRemindFlag text,\
    repeatType integer,\
    addedEvent text,\
    extend1 text,\
    extend2 text,\
    extend3 text,\
    extend4 text,\
    extend5 text,\
    extend6 text,\
    extend7 text,\
    extend8 text,\
    extend9 text,\
    extend10 text)";
    return createSql;
}

@end
