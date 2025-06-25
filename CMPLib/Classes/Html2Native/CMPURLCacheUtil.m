//
//  CMPURLCacheUtil.m
//  CMPLib
//
//  Created by youlin on 2018/5/18.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import "CMPURLCacheUtil.h"
#import "CMPFileManager.h"
#import "CMPDateHelper.h"

static NSString *const kDataKey = @"data";
static NSString *const kResponseKey = @"response";
static NSString *const kRedirectRequestKey = @"redirectRequest";

@implementation CMPCachedData

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self data] forKey:kDataKey];
    [aCoder encodeObject:[self response] forKey:kResponseKey];
    [aCoder encodeObject:[self redirectRequest] forKey:kRedirectRequestKey];
    [aCoder encodeObject:self.expires forKey:@"expires"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil) {
        [self setData:[aDecoder decodeObjectForKey:kDataKey]];
        [self setResponse:[aDecoder decodeObjectForKey:kResponseKey]];
        [self setRedirectRequest:[aDecoder decodeObjectForKey:kRedirectRequestKey]];
        [self setExpires:[aDecoder decodeObjectForKey:@"expires"]];
    }
    return self;
}

@end

@implementation CMPURLCacheUtil

// 获取缓存时间戳
+ (long long)cachedTimeInterval:(NSDictionary *)allHeaderFields
{
    NSString *aExpires = [allHeaderFields objectForKey:@"Expires"];
    NSString *aCacheControl = [allHeaderFields objectForKey:@"Cache-Control"];
    NSDictionary *propertyValue = [aCacheControl propertyValue];
    long long maxAge = [[propertyValue objectForKey:@"max-age"] longLongValue];
    NSDate *aExpiresDate = [CMPDateHelper getLocalDateFormateUTCDate:aExpires];
    // 如果aExpiresDate与 maxage==0，不做任何处理
    if (maxAge == 0 && !aExpiresDate) {
        return 0;
    }
    long long currentDateLen = [CMPDateHelper localeDateTimeInterval];
    long long aExpiresDateMax = currentDateLen + maxAge;
    
    long long aExpiresDateMin = [CMPDateHelper longLongFromDate:aExpiresDate];
    // 比较大小，取较大值
    if (aExpiresDateMax < aExpiresDateMin) {
        aExpiresDateMax = aExpiresDateMin;
    }
    // 如果当前的时间小于过期的时间就需要缓存
    if (aExpiresDateMax > currentDateLen) {
        return aExpiresDateMax;
    }
    return 0;
}

+ (NSString *)cachePathForRequest:(NSString *)aRequestUrl
{
    // This stores in the Caches directory, which can be deleted when space is low, but we only use it for offline access
    NSString *cachesPath = [CMPFileManager fileTempPath];
    //[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [aRequestUrl sha1];
    
    return [cachesPath stringByAppendingPathComponent:fileName];
}

+ (BOOL)storeCachedResponse:(NSURLResponse *)aResponse data:(NSData *)aData forRequest:(NSURLRequest *)aRequest redirectRequest:(NSURLRequest *)aRedirectRequest
{
    BOOL aCachedResult = NO;
    NSDictionary *allHeaderFields = [(NSHTTPURLResponse *)aResponse allHeaderFields];
    long long aExpire = [self cachedTimeInterval:allHeaderFields];
    if (aExpire > 0) {
        NSString *cachePath = [self cachePathForRequest:[aRequest.URL.absoluteString stringByAppendingFormat:@"__%@",[CMPCore sharedInstance].currentUser.userID]];
        // 删除以前的
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
        CMPCachedData *cache = [[CMPCachedData alloc] init];
        cache.response = aResponse;
        cache.data = aData;
        cache.expires = [NSString stringWithLongLong:aExpire];
        cache.redirectRequest = aRedirectRequest;
        [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];
        aCachedResult = YES;
    }
    return aCachedResult;
}

+ (CMPCachedData *)cachedDataWithRequest:(NSURLRequest *)aRequest
{
    NSString *aCachePath = [self cachePathForRequest:[aRequest.URL.absoluteString stringByAppendingFormat:@"__%@",[CMPCore sharedInstance].currentUser.userID]];
    CMPCachedData *cachedData = [NSKeyedUnarchiver unarchiveObjectWithFile:aCachePath];
    return cachedData;
}

+ (NSError *)removeCachedDataWithRequest:(NSURLRequest *)aRequest
{
    return [self removeCachedData:[aRequest.URL.absoluteString stringByAppendingFormat:@"__%@",[CMPCore sharedInstance].currentUser.userID]];
}

+ (NSError *)removeCachedData:(NSString *)aRequestStr
{
    NSString *aCachePath = [self cachePathForRequest:aRequestStr];
    [[NSFileManager defaultManager] removeItemAtPath:aCachePath error:nil];
    return nil;
}

+ (BOOL)isValid:(CMPCachedData *)aCachedData
{
    if (aCachedData && ([aCachedData.expires longLongValue] > [CMPDateHelper localeDateTimeInterval])) {
        return YES;
    }
    return NO;
}

@end
