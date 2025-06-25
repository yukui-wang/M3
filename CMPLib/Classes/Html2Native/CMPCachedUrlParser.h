//
//  CMPCachedUrlParser.h
//  CMPCore
//
//  Created by youlin on 16/5/17.
//
//

#import <Foundation/Foundation.h>

/** 政务版本放合包专用宏 **/
//#define CMPCachedUrlParser_GOV

@interface CMPCachedUrlParser : NSObject

+ (BOOL)chacedUrl:(NSURL *)aUrl;

+ (NSString *)mimeTypeWithSuffix:(NSString *)aSuffix;
+ (NSString *)cachedPathWithUrl:(NSURL *)aUrl;
+ (NSData *)cachedDataWithUrl:(NSURLRequest *)aRequest;

/**
 清理缓存：切换服务器时调用
 */
+ (void)clearCache;

/**
 处理政务版本路径

 @param path 原路径
 @return 政务版本路径
 */
+ (NSString *)govPathWithPath:(NSString *)path;

@end
