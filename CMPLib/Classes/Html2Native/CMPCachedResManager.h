//
//  CMPCachedResManager.h
//  CMPCore
//
//  Created by youlin on 16/5/17.
//
//

#import <Foundation/Foundation.h>

@interface CMPCachedResManager : NSObject

// 检查是否有缓存资源
+ (BOOL)checkCachedResWithHost:(NSString *)aHost;

+ (NSString *)rootPathWithHost:(NSString *)aHost version:(NSString *)aVersion;

@end
