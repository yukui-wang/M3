//
//  NSTimer+Addition.h
//  CMPLib
//
//  Created by 曾祥洁 on 2018/9/25.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (Addition)
- (void)pause;
- (void)resume;
- (void)resumeWithTimeInterval:(NSTimeInterval)time;

+ (NSTimer *)cmp_scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)(NSTimer *timer))block;
@end

NS_ASSUME_NONNULL_END
