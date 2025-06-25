//
//  CMPFileManagementManager.h
//  M3
//
//  Created by MacBook on 2019/10/14.
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPFileTypeHandler.h>

@class CMPOfflineFileRecord,CMPFileManagementRecord;

NS_ASSUME_NONNULL_BEGIN

@interface CMPFileManagementManager : NSObject

- (void)addSelectedFile:(CMPFileManagementRecord *)fileRecord;
- (void)addSelectedFiles:(NSArray <CMPFileManagementRecord *>*)fileRecords;

- (void)removeSelectedFile:(CMPFileManagementRecord *)fileRecord;
- (void)removeSelectedFiles:(NSArray <CMPFileManagementRecord *>*)fileRecords;

- (NSArray *)getCurrentSelectedFiles;
- (NSInteger)getCurrentSelectedCount;

/// 删除文件
- (BOOL)deleteFilesWithOfflineFiles:(NSArray<CMPFileManagementRecord *> *)fileList;


/// 查询文件
- (NSArray *)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord startIndex:(NSInteger)startIndex rowCount:(NSInteger)rowCount type:(CMPFileMineType)type;

/// 找到显示在最上面的vc
+ (UIViewController *)cmp_frontVc;

//根据type返回手机文件格式
+ (NSArray *)getIphoneAcceptFileByType:(NSString *)type;
+ (NSArray *)getAcceptFileByType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
