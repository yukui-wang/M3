//
//  SyFileProvider.h
//  M1Core
//
//  Created by youlin guo on 14-3-7.
//
//

#import <CMPLib/CMPOfflineFileRecord.h>
#import "SyFilePage.h"
#import <CMPLib/CMPObject.h>
#define kC_iFileDescType_FileName 0 // 文件名称排序
#define kC_iFileDescType_LastModifyTime 1 // 修改时间排序



@interface SyFileProvider : CMPObject

+ (SyFileProvider *)instance;

// 查询文件
- (SyFilePage *)findOfflineFilesWithStartIndex:(NSInteger)aStartIndex rowCount:(NSInteger)aRowCount;
//  搜索文件
- (SyFilePage *)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord startIndex:(NSInteger)aStartIndex rowCount:(NSInteger)aRowCount;
// 删除文件
- (BOOL)deleteFilesWithOfflineFiles:(NSArray<CMPOfflineFileRecord *> *)fileList;

@end
