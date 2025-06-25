//
//  NSObject+Thread.m
//  CMPLib
//
//  Created by CRMO on 2018/1/30.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import "NSObject+Thread.h"

@implementation NSObject(Thread)

- (void)dispatchAsyncToMain:(void(^)(void))block {
    if (!block) {
        return;
    }
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (void)dispatchSyncToMain:(void(^)(void))block {
    if (!block) {
        return;
    }
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void)dispatchAsyncToChild:(void(^)(void))block {
    if (!block) {
        return;
    }
//    dispatch_async(YYDispatchQueueGetForQOS(NSQualityOfServiceUserInitiated), block);
    dispatch_async(dispatch_get_global_queue(0, 0), block);
}

@end
