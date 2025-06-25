//
//  CMPAutoLockTool.h
//  M3
//
//  Created by CRMO on 2019/3/15.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPAutoLockTool : CMPObject

/**
 开启自动锁定
 */
- (void)begin;

/**
 停止自动锁定
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
