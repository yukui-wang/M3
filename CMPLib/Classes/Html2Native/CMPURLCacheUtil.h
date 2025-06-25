//
//  CMPURLCacheUtil.h
//  CMPLib
//
//  Created by youlin on 2018/5/18.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import "CMPObject.h"

@interface CMPCachedData : NSObject <NSCoding>
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSURLRequest *redirectRequest;
@property (nonatomic, strong) NSString *expires;
@end

@interface CMPURLCacheUtil : CMPObject
// 获取缓存时间戳
+ (long long)cachedTimeInterval:(NSDictionary *)allHeaderFields;
+ (BOOL)storeCachedResponse:(NSURLResponse *)aResponse data:(NSData *)aData forRequest:(NSURLRequest *)aRequest redirectRequest:(NSURLRequest *)aRedirectRequest;
+ (CMPCachedData *)cachedDataWithRequest:(NSURLRequest *)aRequest;
+ (NSError *)removeCachedDataWithRequest:(NSURLRequest *)aRequest;
+ (NSError *)removeCachedData:(NSString *)aRequestStr;
+ (BOOL)isValid:(CMPCachedData *)aCachedData;

@end
