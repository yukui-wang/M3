//
//  NSObject+Thread.h
//  CMPLib
//
//  Created by CRMO on 2018/1/30.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(Thread)

/**
 安全的切换到主线程异步执行
 */
- (void)dispatchAsyncToMain:(void(^)(void))block;
/**
 安全的切换到主线程同步执行
 */
- (void)dispatchSyncToMain:(void(^)(void))block;

/**
 异步在子线程执行
 自动控制子线程并发数量
 */
- (void)dispatchAsyncToChild:(void(^)(void))block;

@end
