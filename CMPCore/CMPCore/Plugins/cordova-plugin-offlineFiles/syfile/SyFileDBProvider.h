//
//  SyFileDBProvider.h
//  M1Core
//
//  Created by youlin guo on 14-3-11.
//
//

#import <CMPLib/CMPObject.h>

@interface SyFileDBProvider : CMPObject

+ (SyFileDBProvider *)instance;

- (BOOL)hasFileWithFileId:(NSString *)fileId;

- (BOOL)deleteOfflineFileWithFileIDs:(NSArray *)aFileIDs;
- (BOOL)deleteDownloadFileWithFileIDs:(NSArray *)aFileIDs;
// 查询文件
- (NSArray *)findeFilesWithStartIndex:(NSInteger)aStartIndex rowCount:(NSInteger )aRowCount;
- (NSArray *)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord startIndex:(NSInteger)aStartIndex rowCount:(NSInteger)aRowCount;
- (NSArray *)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord startIndex:(NSInteger)startIndex rowCount:(NSInteger)rowCount typeStr:(NSString *)typeStr;
- (NSInteger)getOfflineFilesCount;
- (NSInteger)getSearchOfflineFilesCountWithKeyWord:(NSString *)aKeyWord;
- (void)updateOfflineFileIconPath:(id)aFile;
@end
