//
//  CMPCommonDataProviderTool.h
//  CMPLib
//
//  Created by MacBook on 2020/1/2.
//  Copyright © 2020 crmo. All rights reserved.
//  这个主要用于一些很多地方都会用到的同一个请求接口方法实现

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CollectCompletionBlock)(BOOL isSeccessful,NSString * _Nullable responseData, NSError * _Nullable error);

@interface CMPCommonDataProviderTool : NSObject

/// 这里是生成一个单例对象，如果是需要一个非单例对象的话，可以通过正常的alloc.init方法生成
+ (instancetype)sharedTool;

#pragma mark - 数据请求

/// 添加进收藏
- (void)requestToCollectWithSourceId:(NSString *)sourceId isUc:(BOOL)isUc filePath:( NSString * _Nullable )filePath;

- (void)requestToCollectWithSourceId:(NSString *)sourceId isUc:(BOOL)isUc completionBlock:(nullable CollectCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
