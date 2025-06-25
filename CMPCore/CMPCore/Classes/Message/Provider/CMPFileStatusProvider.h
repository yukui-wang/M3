//
//  CMPFileStatusProvider.h
//  CMPCore
//
//  Created by CRMO on 2017/9/15.
//
//

#import <CMPLib/CMPObject.h>

@interface CMPFileStatusProvider : CMPObject


/**
 设置文件已经被下载

 @param msgUid msgUId
 @return 是否设置成功
 */
+ (BOOL)fileDownloadedWithMsgUId:(NSString *)msgUId;


/**
 获取文件是否已经被下载

 @param msgUId msgUId
 @return 文件是否已经被下载
 */
+ (BOOL)isFileDownloadedWithMsgUId:(NSString *)msgUId;

@end
