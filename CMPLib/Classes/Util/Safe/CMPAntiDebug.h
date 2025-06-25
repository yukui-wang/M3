//
//  CMPAntiDebug.h
//  CMPLib
//
//  Created by CRMO on 2019/5/22.
//  Copyright © 2019 crmo. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface CMPAntiDebug : NSObject

/**
 开启反调试
 检测到调试直接关闭APP
 */
- (void)startAntiDebug;

@end

NS_ASSUME_NONNULL_END
