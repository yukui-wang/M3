//
//  YBIBWebImageManager.m
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/8/29.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "YBIBWebImageManager.h"
#if __has_include(<SDWebImage/SDWebImage.h>)
#import <SDWebImage/SDWebImage.h>
#else
#import "SDWebImageDownloader.h"
#import "SDWebImageManager.h"
#endif

#import <CMPLib/CMPCore.h>
#import "CMPURLUtils.h"
@implementation YBIBWebImageManager

#pragma mark public

+ (id)downloadImageWithURL:(NSURL *)url progress:(YBIBWebImageManagerProgressBlock)progress success:(YBIBWebImageManagerSuccessBlock)success failed:(YBIBWebImageManagerFailedBlock)failed {
    if (!url) return nil;
    
    //忽略默认端口号80或443
    url = [NSURL URLWithString:[CMPURLUtils ignoreDefaultPort:url.absoluteString]];
    
    SDWebImageDownloaderOptions options = SDWebImageDownloaderLowPriority|SDWebImageDownloaderHandleCookies|SDWebImageAllowInvalidSSLCertificates|SDWebImageDownloaderAllowInvalidSSLCertificates;
    SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
    if (![NSString isNull:[CMPCore sharedInstance].token]) {
        [imageDownloader setValue:[CMPCore sharedInstance].token forHTTPHeaderField:@"ltoken"];
    }
    [imageDownloader setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    SDWebImageDownloadToken *token = [imageDownloader downloadImageWithURL:url options:options progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (progress) {
            progress(receivedSize, expectedSize, targetURL);
        }
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (error) {
            if (failed) failed(error, finished);
            return;
        }
        if (success) {
            success(image, data, finished);
        }
    }];
    return token;
}

+ (void)cancelTaskWithDownloadToken:(id)token {
    if (token && [token isKindOfClass:SDWebImageDownloadToken.class]) {
        [((SDWebImageDownloadToken *)token) cancel];
    }
}

+ (void)storeImage:(UIImage *)image imageData:(NSData *)data forKey:(NSURL *)key toDisk:(BOOL)toDisk {
    if (!key) return;
    NSString *cacheKey = [SDWebImageManager.sharedManager cacheKeyForURL:key];
    if (!cacheKey) return;
    
    [[SDImageCache sharedImageCache] storeImage:image imageData:data forKey:cacheKey toDisk:toDisk completion:nil];
}

+ (void)queryCacheOperationForKey:(NSURL *)key completed:(YBIBWebImageManagerCacheQueryCompletedBlock)completed {
#define QUERY_CACHE_FAILED if (completed) {completed(nil, nil); return;}
    if (!key) QUERY_CACHE_FAILED
    NSString *cacheKey = [SDWebImageManager.sharedManager cacheKeyForURL:key];
    if (!cacheKey) QUERY_CACHE_FAILED
#undef QUERY_CACHE_FAILED
        
    SDImageCacheOptions options = SDImageCacheQueryDataWhenInMemory | SDImageCacheScaleDownLargeImages;
    [[SDImageCache sharedImageCache] queryCacheOperationForKey:cacheKey options:options done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if (completed) {
            completed(image, data);
        }
    }];
}

@end
