//
//  CMPMediator.h
//  CMPMediator
//
//  Created by CRMO on 19/3/29.
//  Copyright © 2019年 CRMO. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kCTMediatorParamsKeySwiftTargetModuleName;

@interface CMPMediator : NSObject

+ (instancetype)sharedInstance;

/**
 远程App调用入口

 @param url 远程调用URL
 @param completion 成功回调
 @return 返回值
 */
- (id)performActionWithUrl:(NSURL *)url
                completion:(void(^)(NSDictionary *info))completion;

/**
 本地组件调用入口

 @param targetName target名称
 @param actionName action名称
 @param params 参数
 @param shouldCacheTarget 是否缓存
 @return 返回值
 */
- (id)performTarget:(NSString *)targetName
             action:(NSString *)actionName
             params:(NSDictionary *)params
  shouldCacheTarget:(BOOL)shouldCacheTarget;

/**
 清理缓存

 @param targetName target名称
 */
- (void)releaseCachedTargetWithTargetName:(NSString *)targetName;

@end
