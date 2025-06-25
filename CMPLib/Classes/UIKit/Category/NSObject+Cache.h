//
//  NSObject+Cache.h
//  CMPLib
//
//  Created by CRMO on 2017/11/15.
//  Copyright © 2017年 CMPCore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"

@interface NSObject(Cache)


/**
 将对象转换为json串，然后缓存到磁盘

 @param key 缓存文件名
 */
- (BOOL)cmp_cacheToDiskWithKey:(NSString *)key;

/**
 将对象转换为json串，然后缓存到磁盘
 自定义目录
 
 @param key 缓存文件名
 @param folder 缓存文件保存目录
 */
- (BOOL)cmp_cacheToDiskWithKey:(NSString *)key folder:(NSString *)folder;

/**
 从磁盘中获取缓存的对象

 @param key 缓存文件名
 @return 缓存的对象
 */
- (NSObject *)cmp_getObjectFromCacheWithKey:(NSString *)key;

/**
 从磁盘中获取缓存的对象，自定义存储目录

 @param key 缓存文件名
 @param folder 缓存文件保存目录
 @return 缓存的对象
 */
- (NSObject *)cmp_getObjectFromCacheWithKey:(NSString *)key folder:(NSString *)folder;

@end
