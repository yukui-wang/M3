//
//  SyFileDBProvider.m
//  M1Core
//
//  Created by youlin guo on 14-3-11.
//
//

#import "SyFileDBProvider.h"
#import <CMPLib/CMPCommonDBProvider.h>

@implementation SyFileDBProvider

static SyFileDBProvider *_instance;

+ (SyFileDBProvider *)instance
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



- (BOOL)hasFileWithFileId:(NSString *)fileId {
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    return [dbConnection findOfflineFilesWithFileId:fileId serverID:[CMPCore sharedInstance].serverID ownerID:[CMPCore sharedInstance].userID];
}

- (BOOL)deleteOfflineFileWithFileIDs:(NSArray *)aFileIDs
{
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    __block BOOL aResult = NO;
    [dbConnection deleteOfflineFileWithFileIDs:aFileIDs
                                      serverID:[CMPCore sharedInstance].serverID
                                       ownerID:[CMPCore sharedInstance].userID
                                  onCompletion:^(BOOL success) {
                                      aResult = success;
                                  }];
	return aResult;
}

- (BOOL)deleteDownloadFileWithFileIDs:(NSArray *)aFileIDs {
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    for (NSString *fileID in aFileIDs) {
        [dbConnection deleteDownloadFileRecordsWithFileId:fileID origin:CMPCore.sharedInstance.serverurlForSeeyon serverID:CMPCore.sharedInstance.serverID onCompletion:nil];
    }
    return YES;
}

- (NSArray *)findeFilesWithStartIndex:(NSInteger)aStartIndex rowCount:(NSInteger )aRowCount
{
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
	__block NSArray *aResult;
    [dbConnection offlineFilesWithStartIndex:aStartIndex
                                    rowCount:aRowCount
                                    serverID:[CMPCore sharedInstance].serverID
                                     ownerID:[CMPCore sharedInstance].userID
                                onCompletion:^(NSArray *result) {
                                    aResult = [result copy];
                                }];
	return [aResult autorelease];
}

- (NSArray *)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord startIndex:(NSInteger)aStartIndex rowCount:(NSInteger)aRowCount
{
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
	__block NSArray *aResult;
    [dbConnection searchOfflineFilesWithKeyWord:aKeyWord
                                     startIndex:aStartIndex
                                       rowCount:aRowCount
                                       serverID:[CMPCore sharedInstance].serverID
                                        ownerID:[CMPCore sharedInstance].userID
                                   onCompletion:^(NSArray *result) {
                                       aResult = [result copy];
                                   }];
	return [aResult autorelease];
}

- (NSInteger)getOfflineFilesCount
{
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
	__block NSInteger aResult;
    [dbConnection countOfofflineFilesWithServerID:[CMPCore sharedInstance].serverID
                                          ownerID:[CMPCore sharedInstance].userID
                                     onCompletion:^(NSInteger total) {
                                         aResult = total;
                                     }];
	return aResult;
}

- (NSInteger)getSearchOfflineFilesCountWithKeyWord:(NSString *)aKeyWord {
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
	__block NSInteger aResult;
    [dbConnection countOfSearchOfflineFilesWithKeyWord:aKeyWord
                                              serverID:[CMPCore sharedInstance].serverID
                                               ownerID:[CMPCore sharedInstance].userID
                                          onCompletion:^(NSInteger total) {
                                              aResult = total;
                                          }];
	return aResult;
}

- (NSArray *)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord startIndex:(NSInteger)startIndex rowCount:(NSInteger)rowCount typeStr:(NSString *)typeStr {
    __block NSArray *aResult;
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    [dbConnection searchOfflineFilesWithKeyWord:aKeyWord startIndex:startIndex rowCount:rowCount typeStr:typeStr serverID:[CMPCore sharedInstance].serverID ownerID:[CMPCore sharedInstance].userID onCompletion:^(NSArray *result) {
        aResult = [result copy];
    }];
    
    return [aResult autorelease];
}

- (void)updateOfflineFileIconPath:(id)aFile {
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    [dbConnection updateOfflineFileIconPath:aFile];
}

@end
