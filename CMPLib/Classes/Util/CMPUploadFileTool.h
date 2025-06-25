//
//  CMPUploadFileTool.h
//  CMPLib
//
//  Created by MacBook on 2020/1/18.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPUploadFileTool : NSObject

/// 这里是生成一个单例对象，如果是需要一个非单例对象的话，可以通过正常的alloc.init方法生成
+ (instancetype)sharedTool;

#pragma mark - 数据请求
- (void)requestToUploadFileWithFilePath:(NSString *)filePath startBlock:(nullable void(^)(void))startBlock successBlock:(nullable void (^)(NSString *fileId))successBlock failedBlock:(nullable void(^)(NSError *error))failedBlock;

//同时上传多个文件时使用
- (void)uploadFileWithPath:(NSString *)filePath startBlock:(void(^)(NSString *requestId))startBlock  successBlock:(nullable void (^)(NSString *fileId))successBlock failedBlock:(nullable void(^)(NSError *error))failedBlock;

//取消某个id
- (void)cancelRequestById:(NSString *)requestId;
@end

NS_ASSUME_NONNULL_END
