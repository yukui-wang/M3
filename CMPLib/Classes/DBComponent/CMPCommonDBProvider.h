//
//  CMPCommonDBProvider.h
//  CMPLib
//
//  Created by CRMO on 2018/3/20.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import "CMPObject.h"

typedef void(^CMPCommonDBProviderBOOLCompletion)(BOOL success);
typedef void(^CMPCommonDBProviderArrayCompletion)(NSArray *result);
typedef void(^CMPCommonDBProviderIntCompletion)(NSInteger total);

@class CMPDBAppInfo;
@class SyFaceDownloadRecordObj;
@class SyFaceDownloadObj;
@class CMPScheduleEventRcord;
@class CMPOfflineFileRecord;
@class CMPDownloadFileRecord;
@interface CMPCommonDBProvider : CMPObject

+ (instancetype)sharedInstance;

/**
 清除缓存的时候要请数据库
 */
- (void)clearTableForClearCache;

#pragma mark-
#pragma mark CMP apps

/**
 插入App信息

 @param app app信息
 @param completion 完成回调
 */
- (void)insertAppInfo:(CMPDBAppInfo *)app
         onCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

/**
 获取APP列表，按照downloadTime倒序
 
 @param serverID 服务器ID
 @param aOwnerID 用户ID
 @param aAppId APP ID
 @param completion 完成回调
 */
- (void)appListWithServerID:(NSString *)serverID
                    ownerID:(NSString *)aOwnerID
                      appId:(NSString *)aAppId
               onCompletion:(CMPCommonDBProviderArrayCompletion)completion;

- (NSArray *)appListWithServerID:(NSString *)serverID
                    ownerID:(NSString *)aOwnerID
                 startIndex:(NSInteger)aStartIndex
                   rowCount:(NSInteger)aRowCount;

- (void)appListWithServerID:(NSString *)serverID
                    ownerID:(NSString *)aOwnerID
                      appId:(NSString *)aAppId
                    version:(NSString *)version
               onCompletion:(CMPCommonDBProviderArrayCompletion)completion;

- (void)deleteAppWithAppId:(NSString *)appId
                   version:(NSString *)aVersion
                    owerID:(NSString *)aOwerID
                  serverID:(NSString *)aServerID
              onCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

#pragma mark-
#pragma mark 头像

- (void)insertFaceDownloadRecord:(SyFaceDownloadRecordObj *)aFile
                    onCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

- (void)faceDownloadRecordsWithObj:(SyFaceDownloadObj *)obj
                      onCompletion:(CMPCommonDBProviderArrayCompletion)completion;

- (void)deleteFaceRecordsWithMemberId:(NSString *)memberId
                             serverId:(NSString *)aServerId
                         onCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

- (void)deleteAllFaceRecordsOnCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

#pragma mark-
#pragma mark 日程

- (void)insertScheduleRecordItem:(CMPScheduleEventRcord *)syncRecord
                    onCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

- (void)isExistsScheduleWithID:(NSString *)aScheduleID
                      serverID:(NSString *)aServerID
                        userID:(NSString *)aUserID
                  onCompletion:(CMPCommonDBProviderArrayCompletion)completion;

- (void)deleteScheduleRecordWithID:(NSString *)aScheduleID
                          serverID:(NSString *)aServerID
                            userID:(NSString *)aUserID
                      onCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

#pragma mark-
#pragma mark 离线文档

- (BOOL)findOfflineFilesWithFileId:(NSString *)fileName
                           serverID:(NSString *)serverID
                           ownerID:(NSString *)ownerID;
//判断重名文件，返回重名文件后缀
- (void)checkOfflineFileName:(NSString *)fileName
                      fileId:(NSString *)fileId
                      origin:(NSString *)origin
                     ownerId:(NSString *)ownerId
                    serverId:(NSString *)serverId
            onCompletion:(void(^)(NSString* aFileName))completion;
// 插入文件下载记录
- (void)insertOfflineFileRecord:(CMPOfflineFileRecord *)aFile
                   onCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

- (void)offlineFileRecordsWithFileId:(NSString *)aFileId
                        lastModified:(NSString *)lastModified
                              origin:(NSString *)origin
                            serverID:(NSString *)serverID
                             ownerID:(NSString *)ownerID
                        onCompletion:(CMPCommonDBProviderArrayCompletion)completion;
// 根据文件id删除文件记录
- (void)deleteOfflineFileRecordsWithFileId:(NSString *)aFileId
                                    origin:(NSString *)origin
                                  serverID:(NSString *)serverID
                                   ownerID:(NSString *)ownerID
                              onCompletion:(CMPCommonDBProviderBOOLCompletion)completion;
//离线文件  total
- (void)countOfofflineFilesWithServerID:(NSString *)serverID
                                ownerID:(NSString *)ownerID
                           onCompletion:(CMPCommonDBProviderIntCompletion)completion;

//离线文件
- (void)offlineFilesWithStartIndex:(NSInteger)aStartIndex
                          rowCount:(NSInteger)aRowCount
                          serverID:(NSString *)serverID
                           ownerID:(NSString *)ownerID
                      onCompletion:(CMPCommonDBProviderArrayCompletion)completion;

//离线文件 搜索  total
- (void)countOfSearchOfflineFilesWithKeyWord:(NSString *)aKeyWord
                                    serverID:(NSString *)serverID
                                     ownerID:(NSString *)ownerID
                                onCompletion:(CMPCommonDBProviderIntCompletion)completion;

//离线文件 搜索
- (void)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord
                           startIndex:(NSInteger)aStartIndex
                             rowCount:(NSInteger)aRowCount
                             serverID:(NSString *)serverID
                              ownerID:(NSString *)ownerID
                         onCompletion:(CMPCommonDBProviderArrayCompletion)completion;

- (void)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord
                           startIndex:(NSInteger)startIndex
                             rowCount:(NSInteger)rowCount
                              typeStr:(NSString *)typeStr
                             serverID:(NSString *)serverID
                              ownerID:(NSString *)ownerID
                         onCompletion:(CMPCommonDBProviderArrayCompletion)completion;
//更新缩略图
- (void)updateOfflineFileIconPath:(CMPOfflineFileRecord *)aFile;
//删除
- (void)deleteOfflineFileWithFileIDs:(NSArray *)aFileIDs
                            serverID:(NSString *)serverID
                             ownerID:(NSString *)ownerID
                        onCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

#pragma mark-
#pragma mark 文件下载

- (void)insertDownloadFileRecord:(CMPDownloadFileRecord *)aFile
                    onCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

- (void)downloadFileRecordsWithFileId:(NSString *)aFileId
                         lastModified:(NSString *)lastModified
                               origin:(NSString *)origin
                             serverID:(NSString *)serverID
                         onCompletion:(CMPCommonDBProviderArrayCompletion)completion;

// 根据文件id删除文件记录
- (void)deleteDownloadFileRecordsWithFileId:(NSString *)aFileId
                                     origin:(NSString *)origin
                                   serverID:(NSString *)serverID
                               onCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

// 删除所有下载记录
- (void)deleteAllDownloadFileRecordsOnCompletion:(CMPCommonDBProviderBOOLCompletion)completion;

@end
