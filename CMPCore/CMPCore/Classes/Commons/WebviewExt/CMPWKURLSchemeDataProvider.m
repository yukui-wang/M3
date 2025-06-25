//
//  CMPWKURLSchemeDataProvider.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/5/24.
//

#import "CMPWKURLSchemeDataProvider.h"

#import <CMPLib/CMPCachedUrlParser.h>

@interface CMPWKURLSchemeDataProvider()

@end

@implementation CMPWKURLSchemeDataProvider

+(instancetype)shareInstance
{
    static id manager ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

-(NSData *)dataForRequestUrl:(NSURL *)reqUrl
{
    if (!reqUrl) return nil;
    NSURLRequest *req = [NSURLRequest requestWithURL:reqUrl];
    NSData *data = [CMPCachedUrlParser cachedDataWithUrl:req];
    return data;
}

@end
