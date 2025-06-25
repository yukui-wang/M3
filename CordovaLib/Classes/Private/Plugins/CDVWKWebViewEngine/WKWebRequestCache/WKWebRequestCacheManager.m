//
//  WKWebRequestCacheManager.m
//  CordovaLib
//
//  Created by SeeyonMobileM3MacMini2 on 2021/8/10.
//  Copyright © 2021 crmo. All rights reserved.
//

#import "WKWebRequestCacheManager.h"

@interface WKWebRequestCacheManager()

@property (nonatomic,strong) NSMutableDictionary<NSString *,NSMutableArray<WKWebRequestCache *> *> *reqCacheDic;

@end

@implementation WKWebRequestCacheManager

static id shareInstance;

+ (instancetype)shareInstance {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [[self alloc] init];
            }
        }
    }
    return shareInstance;
}

+(BOOL)needCache:(id)body
{
    if (body && [body isKindOfClass:[NSDictionary class]]) {
        NSString *url = body[@"url"];
        if (url && url.length) {
            if ([url isEqualToString:@"ios://bodyCache"]) {
                NSString *cacheId = body[@"__bodyCacheId__"];
                if (cacheId &&cacheId.length) {
                    return YES;
                }
            }
        }
    }
    return NO;
}


-(BOOL)cacheBody:(NSDictionary *)body
          result:(void(^)(BOOL success, NSString *cacheId, WKWebRequestCache *curCacheObj))result
{
    NSString *cacheId;
    if (body && [body isKindOfClass:[NSDictionary class]]) {
        NSString *url = body[@"url"];
        if (url && url.length) {
            if ([url isEqualToString:@"ios://bodyCache"]) {
                cacheId = body[@"__bodyCacheId__"];
                if (cacheId &&cacheId.length) {
                    NSDictionary *contentBody = body[@"contentBody"];
                    if (contentBody && [contentBody isKindOfClass:[NSDictionary class]]) {
                        id data = contentBody[@"data"];
                        if (data) {
                            WKWebRequestCache *aCache = [[WKWebRequestCache alloc] initWithBody:body];
                            if (aCache) {
                                NSMutableArray *cachArr = [self.reqCacheDic objectForKey:cacheId];
                                if (!cachArr) {
                                    NSMutableArray *arr = [NSMutableArray array];
                                    [arr addObject:aCache];
                                    [self.reqCacheDic setObject:arr forKey:cacheId];
                                }else{
                                    [cachArr addObject:aCache];
                                }
                                if (result) {
                                    result(YES,cacheId,aCache);
                                }
                                return YES;
                            }
                        }
                    }
                }
            }
        }
    }
    if (result) {
        result(NO,cacheId,nil);
    }
    return NO;
}


-(NSMutableArray<WKWebRequestCache *> *)cacheById:(NSString *)cacheId
{
    return [self.reqCacheDic objectForKey:cacheId];
}

-(NSMutableDictionary<NSString *,NSMutableArray<WKWebRequestCache *> *> *)reqCacheDic
{
    if (!_reqCacheDic) {
        _reqCacheDic = [[NSMutableDictionary alloc] init];
    }
    return _reqCacheDic;
}

-(void)removeCacheById:(NSString *)cacheId
{
    if (cacheId) {
        [self.reqCacheDic removeObjectForKey:cacheId];
    }
}

-(void)clear
{
    [self.reqCacheDic removeAllObjects];
}

@end
