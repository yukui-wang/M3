//
//  CMPURLProtocolManager.m
//  CMPLib
//
//  Created by Kaku Songu on 5/27/21.
//  Copyright © 2021 crmo. All rights reserved.
//

#import "CMPURLProtocolManager.h"

@interface CMPURLProtocolManager()
{
    NSDictionary *_ignoreValueDic;
}
@end

@implementation CMPURLProtocolManager

static id shareInstance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [super allocWithZone:zone];
            }
        }
    }
    return shareInstance;
}

+ (instancetype)sharedInstance {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [[self alloc] init];
                [shareInstance _init];
            }
        }
    }
    return shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return shareInstance;
}


-(void)_init
{
    NSString *aPath = [[NSBundle mainBundle] pathForResource:@"CMPURLProtocolIgnoreProperties" ofType:@"plist"];
    _ignoreValueDic = [[NSDictionary alloc] initWithContentsOfFile:aPath];
    if (!_ignoreValueDic) {
        _ignoreValueDic = @{};
    }
    _ignoreQueryArr = _ignoreValueDic[@"IgnoreQueryRules"] ? : @[];
    _ignoreHostArr = _ignoreValueDic[@"IgnoreHostRules"] ? : @[];
    _ignoreSafariLoadHostArr = _ignoreValueDic[@"IgnoreSFSafariLoadHostRules"] ? : @[];
}

@end
