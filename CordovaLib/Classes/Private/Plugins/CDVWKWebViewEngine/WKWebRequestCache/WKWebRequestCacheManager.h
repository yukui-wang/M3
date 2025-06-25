//
//  WKWebRequestCacheManager.h
//  CordovaLib
//
//  Created by SeeyonMobileM3MacMini2 on 2021/8/10.
//  Copyright © 2021 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKWebRequestCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebRequestCacheManager : NSObject

+(instancetype)shareInstance;
+(BOOL)needCache:(id)body;
-(BOOL)cacheBody:(NSDictionary *)body
          result:(void(^)(BOOL success, NSString *cacheId, WKWebRequestCache *curCacheObj))result;
-(NSMutableArray<WKWebRequestCache *> *)cacheById:(NSString *)cacheId;
-(void)removeCacheById:(NSString *)cacheId;
-(void)clear;

@end

NS_ASSUME_NONNULL_END
