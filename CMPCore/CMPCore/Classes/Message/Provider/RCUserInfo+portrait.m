//
//  RCUserInfo+portrait.m
//  M3
//
//  Created by 程昆 on 2020/1/9.
//

#import "RCUserInfo+portrait.h"
#import <CMPLib/CMPCore.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation RCUserInfo (portrait)

- (NSString *)portraitUri {
    NSString *portraitUri = objc_getAssociatedObject(self, @selector(portraitUri));
    if ([NSString isNull:portraitUri]) {
        NSString *portraitUri = [CMPCore memberIconUrlWithId:self.userId];
        objc_setAssociatedObject(self, @selector(portraitUri), portraitUri, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSString *portraitUria = objc_getAssociatedObject(self, @selector(portraitUri));
    if ([NSString isNull:portraitUria]) {
        
    }
    return portraitUri;
}

- (void)setPortraitUri:(NSString *)portraitUri {
    if ([NSString isNotNull:portraitUri]) {
        objc_setAssociatedObject(self, @selector(portraitUri), portraitUri, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end

//修复融云头像初次加载特别缓慢的bug
@interface RCDownloadHelper (aa)

@end

@implementation RCDownloadHelper (aa)

- (void)getDownloadFileToken:(int)fileType completeBlock:(void(^)(NSString *token))completion {
    completion(nil);
}

@end

#pragma clang diagnostic push
