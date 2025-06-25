//
//  CMPStopWatchTool.h
//  M3
//
//  Created by CRMO on 2018/2/24.
//

#import <Foundation/Foundation.h>

@interface CMPStopWatchTool : NSObject

+ (instancetype)sharedInstance;

/**
 开始计时
 */
- (void)start;

/**
 打点

 @param description 描述信息
 */
- (void)addNodeWithDescription:(NSString *)description;

/**
 结束计时
 */
- (void)stop;

@end
