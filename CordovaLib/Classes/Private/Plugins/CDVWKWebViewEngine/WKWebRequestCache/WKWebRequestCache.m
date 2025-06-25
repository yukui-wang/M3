//
//  WKWebRequestCache.m
//  CordovaLib
//
//  Created by SeeyonMobileM3MacMini2 on 2021/8/10.
//  Copyright © 2021 crmo. All rights reserved.
//

#import "WKWebRequestCache.h"

@implementation WKWebRequestCache

-(instancetype)initWithBody:(NSDictionary *)body
{
    if (!body) return nil;
    if (self = [super init]) {
        _cid = body[@"__bodyCacheId__"]?:@"";
        _url = body[@"url"]?:@"";
        NSDictionary *contentBody = body[@"contentBody"];
        if (contentBody && [contentBody isKindOfClass:[NSDictionary class]]) {
            _type = contentBody[@"dataType"]?:@"";
            _data = contentBody[@"data"];
        }
    }
    return self;
}

@end
