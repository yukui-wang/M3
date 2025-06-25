//
//  JSBridgeManager.h
//  CMPLib
//
//  Created by CRMO on 2018/10/22.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKJSBridgeManager : NSObject

#pragma mark-
#pragma mark 同步调用

/**
 判断是否是同步执行命令
 */
+ (BOOL)isSyncCommand:(NSURL *)url;

/**
 执行同步命令
 */
+ (NSString *)excuteSyncCommandWithRequestBody:(id)body;
#pragma mark-
#pragma mark 异步调用

+ (BOOL)isAsyncCommand:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
