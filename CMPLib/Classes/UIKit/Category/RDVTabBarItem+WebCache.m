//
//  UITabbarItem+WebCache.m
//  CMPLib
//
//  Created by CRMO on 2017/11/13.
//  Copyright © 2017年 CMPCore. All rights reserved.
//

#import "RDVTabBarItem+WebCache.h"
#import "SDWebImageManager.h"
#import "UIImage+CMPImage.h"
#import "CMPCore.h"

typedef void(^RDVTabBarItemLoadImageCompletion)(UIImage *image);

@implementation RDVTabBarItem(WebCache)

- (void)cmp_setImageUrl:(NSString *)imageUrl placeHolder:(UIImage *)placeHolder {
    [self setUnselectedImage:placeHolder];
    [self loadImageWithUrl:imageUrl onCompletion:^(UIImage *image) {
        if (image) {
            [self setUnselectedImage:image];
        }
    }];
}

- (void)cmp_setSelectedImageUrl:(NSString *)imageUrl placeHolder:(UIImage *)placeHolder {
    [self setSelectedImage:placeHolder];
    [self loadImageWithUrl:imageUrl onCompletion:^(UIImage *image) {
        if (image) {
            [self setSelectedImage:image];
        }
    }];
}

- (void)loadImageWithUrl:(NSString *)imageUrl onCompletion:(RDVTabBarItemLoadImageCompletion)completion {
    if (!imageUrl) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    [[SDWebImageManager sharedManager].imageDownloader setValue:[CMPCore sharedInstance].token forHTTPHeaderField:@"ltoken"];
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageHandleCookies|SDWebImageAllowInvalidSSLCertificates|SDWebImageDownloaderAllowInvalidSSLCertificates progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (error) {
            if (completion) {
                completion(nil);
            }
        } else {
            if (completion) {
                completion(image);
            }
        }
    }];
}

@end
